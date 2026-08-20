import 'dart:async';
import 'dart:collection';

import 'package:creativetrainclient/Handler/handle_buttons_clientconfig.dart';
import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/Handler/sse_handler.dart';
import 'package:creativetrainclient/Wrappers/register_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';

StreamSubscription? sseSubscription;
Future<bool> handleTestConnectionToServer(
  String pUrl,
  BuildContext context,
) async {
  var url = Uri.parse('http://$pUrl');
  var response;
  try {
    response = await http.get(url);
  } on http.ClientException {}
  if (response != null) {
    if (response.statusCode != 200) {
      print('Request failed with status: ${response.statusCode}.');
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return ErrorDialogM3E(
            errorHeader:
                'The Server you are trying to connect is not running CreativeTrain',
            errorText:
                'Please check for any typo or if the server is working properly',
          );
        },
      );

      return false;
    }

    print(response.body);
    if (!response.body.contains('CreativeTrain')) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return ErrorDialogM3E(
            errorHeader:
                'The Server you are trying to connect is not running CreativeTrain',
            errorText:
                'Please check for any typo or if the server is working properly',
          );
        },
      );
      return false;
    }
    if (!response.body.contains('v1')) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return ErrorDialogM3E(
            errorHeader: 'Api version incompatable',
            errorText: 'Please look for any Updates of the Client',
          );
        },
      );

      return false;
    }

    print('Valid CreativeTrainServer and API version');

    return true;
  } else {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ErrorDialogM3E(
          errorHeader: 'What the heck did you input?',
          errorText:
              'Please check for any typo or if the server is working properly',
        );
      },
    );
    return false;
  }
}

Future<bool> startSession(BuildContext context) async {
  String token = app_state.getCurrentSession().token;
  String sessionUuid = app_state.getCurrentSession().sessionUuid;
  String playerUuid = app_state.getCurrentSession().playerUuid;
  String? ipAddress = app_state.getIpAddress();
  if (ipAddress == null) return false;

  final configJson = jsonDecode(app_state.modifiedConfig.value);

  final roleConfig = (configJson['roleConfig'] as List<dynamic>).map((role) {
    final roleMap = Map<String, dynamic>.from(role as Map<String, dynamic>);
    for (final key in ['baseInventory', 'itemShop']) {
      final items = roleMap[key];
      if (items is List) {
        roleMap[key] = items.map((item) {
          final itemMap = Map<String, dynamic>.from(
            item as Map<String, dynamic>,
          );
          itemMap.remove('type');
          return itemMap;
        }).toList();
      }
    }
    return roleMap;
  }).toList();

  final requestBody = jsonEncode({
    'roleConfig': roleConfig,
    'generalConfig': configJson['generalConfig'],
  });

  final uri = Uri.parse(
    'http://$ipAddress/api/session/start?token=${Uri.encodeQueryComponent(token)}&sessionUuid=$sessionUuid&playerUuid=$playerUuid',
  );

  print(requestBody);

  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return ErrorDialogM3E(
            errorHeader: 'Session could not be started',
            errorText: response.body.isEmpty
                ? 'Server responded with status ${response.statusCode}'
                : response.body,
          );
        },
      );
      return false;
    }
    return true;
  } catch (e) {
    print('Error starting session: $e');
    return false;
  }
}
/**
 * ipAddress: the ip Adress of the connected CreativeTrain server example: 127.0.0.1:8080
 * playerName: the name of the player
 * playerQr: png image of the qr code that the player registers under
 * joinedSession: the UUID of the session the player wants to join, is null if the user registers as host
   */

Future<bool> handleRegistration(
  String ipAddress,
  String playerName,
  String? joinedSession,
  BuildContext context,
) async {
  print(joinedSession);
  if (app_state.inSession) return false;

  final registerUrl = Uri.http(ipAddress, '/api/session/register');

  final registerRequest = http.MultipartRequest('POST', registerUrl)
    ..fields['playerName'] = playerName;
  if (joinedSession != null) {
    registerRequest.fields['joinedSession'] = joinedSession;
  }
  final streamedResponse = await registerRequest.send();
  final registerResponse = await http.Response.fromStream(streamedResponse);

  if (registerResponse.statusCode < 200 || registerResponse.statusCode >= 300) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ErrorDialogM3E(
          errorHeader: 'Server Message:',
          errorText: registerResponse.body,
        );
      },
    );
    return false;
  }

  var registrationJson =
      jsonDecode(registerResponse.body) as Map<String, dynamic>;
  String sessionUuid = registrationJson["sessionUuid"];

  final connectedUsersUrl = Uri.parse(
    'http://$ipAddress/api/session/connectedUsers?sessionUuid=${Uri.encodeQueryComponent(sessionUuid)}',
  );
  final getHostUrl = Uri.parse(
    'http://$ipAddress/api/session/hostName?sessionUuid=${Uri.encodeQueryComponent(sessionUuid)}',
  );

  final futureResult = await Future.wait([
    http.get(connectedUsersUrl),
    http.get(getHostUrl),
  ]);

  final users = (jsonDecode(futureResult.first.body) as List<dynamic>)
      .cast<String>();
  String hostName = futureResult.last.body;

  RegisterResponse returnResponse = RegisterResponse.fromJson(
    registrationJson,
    users,
    hostName,
  );
  print(jsonEncode(returnResponse.toJson()));
  sseSubscription = startStream(
    ipAddress,
    returnResponse.playerUuid,
    returnResponse.token,
  );
  app_state.setCurrentSession(returnResponse);
  app_state.changeGameActivation(true);
  return true;
}

StreamSubscription<SSEModel> startStream(
  String ipAddress,
  String playerUuid,
  String sessionToken,
) {
  /**
   * key: event name
   * value: corresponding function in "sse_handler.dart"
   */
  final Map<String, void Function(String)> eventMap = {
    "playerJoined": playerJoined,
    "playerDisconnected": playerLeft,
    "challengeUpdate": updateChallenge,
    "sessionStart": sessionStart,
    "sanityUpdate": sanityUpdate,
    "coinUpdate": coinUpdate,
    "inventoryUpdate": inventoryUpdate,
    "sessionEnd": gameEndData,
    //"timerUpdate" : timerUpdate,
  };

  final stream = SSEClient.subscribeToSSE(
    method: SSERequestType.GET,
    url:
        "http://$ipAddress/api/stream?playerUuid=$playerUuid&sessionToken=$sessionToken",
    header: {"Accept": "text/event-stream"},
  );

  return stream.listen((event) {
    print("Event: ${event.event}");
    print("Data: ${event.data}");

    final handler = eventMap[event.event];

    if (handler != null && event.data != null) {
      handler(event.data!);
    }
  });
}

Future<bool> leaveSession(
  String ipAddress,
  String playerUuid,
  String sessionToken,
) async {
  final leaveUrl = Uri.http(ipAddress, '/api/session/leaveGame');

  final leaveRequest = http.MultipartRequest('POST', leaveUrl)
    ..fields['playerUuid'] = playerUuid
    ..fields['sessionToken'] = sessionToken;

  final streamedResponse = await leaveRequest.send();
  final registerResponse = await http.Response.fromStream(streamedResponse);

  if (registerResponse.statusCode < 200 || registerResponse.statusCode >= 300) {
    return false;
  }
  app_state.inSession = false;
  app_state.changeGameActivation(false);
  return true;
}

Future<String> buyItem(
  String ipAddress,
  String playerUuid,
  String sessionToken,
  String itemUUID,
) async {
  final buyUrl = Uri.http(ipAddress, '/api/session/buyItem');

  final buyRequest = http.MultipartRequest('POST', buyUrl)
    ..fields['playerUuid'] = playerUuid
    ..fields['sessionToken'] = sessionToken
    ..fields['itemUuid'] = itemUUID;

  final streamedResponse = await buyRequest.send();
  final buyResponse = await http.Response.fromStream(streamedResponse);

  if (buyResponse.statusCode < 200 || buyResponse.statusCode >= 300) {
    return buyResponse.body;
  }

  return 'Bought Item';
}

Future<List<dynamic>> fetchInventory(
  String ipAddress,
  String playerUuid,
  String sessionToken,
) async {
  final inventoryUrl = Uri.parse(
    'http://$ipAddress/api/session/inventory?playerUuid=${Uri.encodeQueryComponent(playerUuid)}&sessionToken=${Uri.encodeQueryComponent(sessionToken)}&isShop=false',
  );

  final inventoryResponse = await http.get(inventoryUrl);

  if (inventoryResponse.statusCode < 200 ||
      inventoryResponse.statusCode >= 300) {
    return [];
  }

  return jsonDecode(inventoryResponse.body) as List<dynamic>;
}
