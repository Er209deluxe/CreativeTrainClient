import 'package:http/http.dart' as http;

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
