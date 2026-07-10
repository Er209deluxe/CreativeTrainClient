import 'dart:async';
import 'dart:collection';

import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/Handler/sse_handler.dart';
import 'package:creativetrainclient/Wrappers/register_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';

Future<bool> handleTestConnectionToServer(String pUrl) async {
  var url = Uri.parse('http://$pUrl');
  var response = await http.get(url);
  if (response.statusCode == 200) {
    print(response.body);
    return true;
  } else {
    print('Request failed with status: ${response.statusCode}.');
    return false;
  }
}


/**
 * ipAddress: the ip Adress of the connected CreativeTrain server example: 127.0.0.1:8080
 * playerName: the name of the player
 * playerQr: png image of the qr code that the player registers under
 * joinedSession: the UUID of the session the player wants to join, is null if the user registers as host
   */
  void handleRegistration(String ipAddress,String playerName,http.MultipartFile playerQr,String? joinedSession)
  async{

    final registerUrl = Uri.http(ipAddress, '/api/session/register');

    final registerRequest = http.MultipartRequest('POST', registerUrl)
      ..fields['playerName'] = playerName
      ..files.add(playerQr);
    final streamedResponse = await registerRequest.send();
    final registerResponse = await http.Response.fromStream(streamedResponse);

    if (registerResponse.statusCode < 200 || registerResponse.statusCode >= 300) {
      throw Exception(registerResponse.body);
    }

      var registrationJson = jsonDecode(registerResponse.body) as Map<String, dynamic>;
    String sessionUuid =registrationJson["sessionUuid"];

    final connectedUsersUrl = Uri.http(
      ipAddress,
      '/api/session/connectedUsers',
      {
        'sessionUuid': sessionUuid,
      },
    );

    final getHostUrl = Uri.http(
      ipAddress,
      '/api/session/hostName',
      {
        'sessionUuid': sessionUuid,
      },
    );

      final futureResult = await Future.wait([
        http.get(connectedUsersUrl),
        http.get(getHostUrl)
      ]);

    final users = (jsonDecode(futureResult.first.body) as List<dynamic>)
        .cast<String>();
    String hostName = futureResult.last.body;

    RegisterResponse returnResponse = RegisterResponse.fromJson(registrationJson,users,hostName);
    print(jsonEncode(returnResponse.toJson()));
    app_state.sseSubscription = startStream(ipAddress,returnResponse.playerUuid , returnResponse.token);
    app_state.setCurrentSession(returnResponse);
    app_state.changeGameActivation(true);
    }


StreamSubscription<SSEModel> startStream(String ipAddress,String playerUuid, String sessionToken) {
  /**
   * key: event name
   * value: corresponding function in "sse_handler.dart"
   */
  final Map<String, void Function(String)> eventMap = {
    "playerJoined" : playerJoined,
    "playerLeft" : playerLeft
  };

  final stream = SSEClient.subscribeToSSE(
  method: SSERequestType.GET,
  url: "http://$ipAddress/api/stream?playerUuid=$playerUuid&sessionToken=$sessionToken",
  header: {
  "Accept": "text/event-stream",
  },
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

