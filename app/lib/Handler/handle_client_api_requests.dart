import 'package:creativetrainclient/Wrappers/register_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  Future<RegisterResponse> handleRegistration(String ipAddress,String playerName,http.MultipartFile playerQr,String? joinedSession)
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
    String uuid =registrationJson["sessionUuid"];

    final connectedUsersUrl = Uri.http(
      ipAddress,
      '/api/session/connectedUsers',
      {
        'sessionUuid': uuid,
      },
    );

    final getHostUrl = Uri.http(
      ipAddress,
      '/api/session/hostName',
      {
        'sessionUuid': uuid,
      },
    );

      final futureResult = await Future.wait([
        http.get(connectedUsersUrl),
        http.get(getHostUrl)
      ]);

    final users = (jsonDecode(futureResult.first.body) as List<dynamic>)
        .cast<String>();
    String hostName = futureResult.last.body;
      return RegisterResponse.fromJson(registrationJson,users,hostName);
    }


