import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/Handler/handle_buttons_clientconfig.dart';
import 'package:creativetrainclient/Handler/handle_client_api_requests.dart';
import 'package:creativetrainclient/UI/render_homepage.dart';
import 'package:creativetrainclient/configs/UI/standartm3edesign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:m3e_buttons/m3e_buttons.dart';

class RenderRegisterconfig extends StatefulWidget {
  const RenderRegisterconfig({super.key});

  @override
  State<RenderRegisterconfig> createState() => _RenderRegisterconfigState();
}

class _RenderRegisterconfigState extends State<RenderRegisterconfig> {
  final _playerName = TextEditingController();
  final _sessionUUID = TextEditingController();
  bool hostSession = false;

  @override
  void dispose() {
    _playerName.dispose();
    _sessionUUID.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GradientHomeBG(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 15),
                    M3EHeader(headerText: 'Host a Session'),
                    Checkbox(
                      value: hostSession,
                      onChanged: (bool? value) {
                        setState(() {
                          hostSession = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        maxLength: 20,
                        style: const TextStyle(color: Colors.white),
                        controller: _playerName,
                        decoration: InputDecoration(
                          labelText: 'Player Name',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
                if (!hostSession)
                  Row(
                    children: [
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          maxLength: 36,
                          style: const TextStyle(color: Colors.white),
                          controller: _sessionUUID,
                          decoration: InputDecoration(
                            labelText: 'Session UUID',
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                    ],
                  )
                else
                  const SizedBox(height: 68),M3EButton(
                  onPressed: () async {
                    String? ipAddress = app_state.getIpAddress();

                    if (ipAddress == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return ErrorDialogM3E(
                            errorHeader: 'Missing IP address',
                            errorText: 'IP address not found',
                          );
                        },
                      );
                      return;
                    }

                    if (!await handleRegistration(
                      ipAddress,
                      _playerName.text,
                      _sessionUUID.text,
                    )) {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return ErrorDialogM3E(
                            errorHeader: 'Already connected to session',
                            errorText: 'Leave the session to join another one',
                          );
                        },
                      );
                      return;
                    }
                  },
                  decoration: M3EButtonDecoration(),
                  size: M3EButtonSize.lg,
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
bool isValidIp(String? ipAddress,BuildContext context){
  if(ipAddress==null){
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ErrorDialogM3E(
          errorHeader: 'Missing ip address',
          errorText:
          'Ip address not found',
        );
      },
    );
    return false;
  }
  return true;
}
// Gradient Background
class GradientHomeBG extends StatelessWidget {
  const GradientHomeBG({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 119, 50, 43),
            Color.fromARGB(255, 97, 6, 92),
            Color.fromARGB(255, 21, 38, 87),
          ],
        ),
      ),
    );
  }
}
