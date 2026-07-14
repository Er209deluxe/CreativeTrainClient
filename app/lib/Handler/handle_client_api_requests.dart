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
) async {
  print(joinedSession);
  if (app_state.inGame) return false;

  final registerUrl = Uri.http(ipAddress, '/api/session/register');

  final registerRequest = http.MultipartRequest('POST', registerUrl)
    ..fields['playerName'] = playerName;
  if (joinedSession != null) {
    registerRequest..fields['joinedSession'] = joinedSession;
  }
  final streamedResponse = await registerRequest.send();
  final registerResponse = await http.Response.fromStream(streamedResponse);

  if (registerResponse.statusCode < 200 || registerResponse.statusCode >= 300) {
    throw Exception(registerResponse.body);
  }

  var registrationJson =
      jsonDecode(registerResponse.body) as Map<String, dynamic>;
  String sessionUuid = registrationJson["sessionUuid"];

  final connectedUsersUrl = Uri.http(ipAddress, '/api/session/connectedUsers', {
    'sessionUuid': sessionUuid,
  });

  final getHostUrl = Uri.http(ipAddress, '/api/session/hostName', {
    'sessionUuid': sessionUuid,
  });

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
    "playerLeft": playerLeft,
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
    throw Exception(registerResponse.body);
  }
  app_state.inGame = false;
  return true;
}

Future<bool> startSession(
  String ipAddress,
  String token,
  String sessionUuid,
  String playerUuid,
  Map<String, dynamic> roleConfig,
) async {
  final url = Uri.http(ipAddress, '/api/session/start', {
    'playerUuid': playerUuid,
    'token': token,
    'sessionUuid': sessionUuid,
  });
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(roleConfig),
  );

  return true;
}
