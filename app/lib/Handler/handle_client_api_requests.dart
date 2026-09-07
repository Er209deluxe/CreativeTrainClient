import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/Handler/handle_buttons_clientconfig.dart';
import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/Handler/sse_handler.dart';
import 'package:creativetrainclient/Wrappers/register_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';

import '../Wrappers/GeneralConfig.dart';
import '../Wrappers/RoleConfigData.dart';
import 'NfcPeer.dart';

StreamSubscription? sseSubscription;
Future<bool> handleTestConnectionToServer(
  String pUrl,
  BuildContext context,
) async {
  var url = Uri.parse('http://$pUrl');
  var response;
  try {
    response = await http.get(url);
  } on http.ClientException catch (e) {
    print('Connection test failed: $e');
    response = null;
  }
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

  final generalConfig = GeneralConfig(
    10, // baseTimerMins
    0, // baseTimerSecs
    30, // incrementTimerOnKillInSeconds
    100, // killReward
    5, // passiveIncome
    DepressionData(
      120, // baseDepression
      60, // baseSanity
    ),
  );

  print(jsonEncode(generalConfig.toJson()));

  final requestBody = jsonEncode({
    'roleConfig': app_state.roleConfig.value.toJson(),
    'generalConfig': app_state.generalConfig.value.toJson(),
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

Future<bool> killPlayer(String ipAddress,String victimUuid,String itemUuid, BuildContext context) async {
final killUrl = Uri.http(ipAddress, 'api/session/kill');
final killRequest = http.MultipartRequest('POST', killUrl)..fields['killerUuid'] = " ";
  killRequest.fields['sessionToken'] = app_state.getCurrentSession().token;
  killRequest.fields['challenge'] = app_state.getChallenge();
  killRequest.fields['victimUuid'] = victimUuid;
  killRequest.fields['itemUuid'] = itemUuid;

  final streamedResponse = killRequest.send();
  final killResponse = await http.Response.fromStream(await streamedResponse);
  if(killResponse.statusCode==200) {
    return true;
  }
showDialog(
  context: context,
  builder: (BuildContext dialogContext) {
    return ErrorDialogM3E(
      errorHeader: 'Couldn\'t kill player',
      errorText: killResponse.body.isEmpty
          ? 'Server responded with status ${killResponse.statusCode}'
          : killResponse.body,
    );
  },
);
  return false;
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
  String joinedSession,
  BuildContext context,
  bool host,
) async {
  print(joinedSession);
  if (app_state.inSession) return false;

  final registerUrl = Uri.http(ipAddress, '/api/session/register');

  final registerRequest = http.MultipartRequest('POST', registerUrl)
    ..fields['playerName'] = playerName;

  if (joinedSession == '' && !host) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ErrorDialogM3E(
          errorHeader: 'No UUID',
          errorText: 'No session UUID was given',
        );
      },
    );
    return false;
  }
  registerRequest.fields['joinedSession'] = joinedSession;
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
  app_state.setCurrentSession(
    returnResponse,
  );

  app_state.changeGameActivation(true);

  await NfcPeer.clear();

  await NfcPeer.setSessionUuid(
    sessionUuid,
  );

  debugPrint(
    'NFC MODE: SESSION UUID',
  );

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
  try {
    final leaveUrl = Uri.parse('http://$ipAddress/api/session/leaveGame');

    final leaveRequest = http.MultipartRequest('POST', leaveUrl)
      ..fields['playerUuid'] = playerUuid
      ..fields['sessionToken'] = sessionToken;

    final streamedResponse = await leaveRequest.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }

    app_state.inSession = false;
    app_state.changeGameActivation(false);

    return true;
  } on SocketException catch (e) {
    print('Could not connect to server: $e');
    return false;
  } on http.ClientException catch (e) {
    print('HTTP request failed: $e');
    return false;
  } catch (e) {
    print('Unexpected error leaving session: $e');
    return false;
  }
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

Future<List<Map<String, dynamic>>> getAllRoles() async {
  String? ipAddress = app_state.getIpAddress();

  if (ipAddress == null) {
    throw Exception("Ip Address not found");
  }

  final getRolesUri = Uri.parse('http://$ipAddress/api/session/allRoles');

  final response = await http.get(getRolesUri);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception(
      'Failed to load roles: ${response.statusCode} ${response.body}',
    );
  }
}

