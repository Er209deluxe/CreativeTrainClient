import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/Handler/handle_buttons_clientconfig.dart';
import 'package:creativetrainclient/Handler/handle_client_api_requests.dart';
import 'package:creativetrainclient/UI/render_homepage.dart';
import 'package:creativetrainclient/UI/render_inactivesession.dart';
import 'package:creativetrainclient/configs/UI/standartm3edesign.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

import '../Handler/NfcPeer.dart';

class RenderRegisterconfig extends StatefulWidget {
  const RenderRegisterconfig({super.key});

  @override
  State<RenderRegisterconfig> createState() =>
      _RenderRegisterconfigState();
}

class _RenderRegisterconfigState
    extends State<RenderRegisterconfig> {

  final TextEditingController _playerName =
  TextEditingController();

  final TextEditingController _sessionUUID =
  TextEditingController();

  bool hostSession = false;

  @override
  void initState() {
    super.initState();

    NfcPeer.setMessageHandler(
      _handleNfcMessage,
    );

    _startNfcReader();
  }

  Future<void> _startNfcReader() async {
    try {
      await NfcPeer.startReader();

      debugPrint(
        'NFC reader started',
      );
    } catch (e) {
      debugPrint(
        'Failed to start NFC reader: $e',
      );
    }
  }

  void _handleNfcMessage(
      String json,
      ) {
    debugPrint(
      'NFC DATA RECEIVED: $json',
    );

    final data =
    NfcPeer.parseData(json);

    if (data == null) {
      debugPrint(
        'Invalid NFC data received',
      );

      return;
    }

    final sessionUuid =
        data.sessionUuid;

    if (sessionUuid == null ||
        sessionUuid.isEmpty) {
      debugPrint(
        'No session UUID found in NFC data',
      );

      return;
    }

    // The host does not need to read a session UUID.
    if (!mounted || hostSession) {
      return;
    }

    setState(() {
      _sessionUUID.text =
          sessionUuid;

      _sessionUUID.selection =
          TextSelection.collapsed(
            offset:
            _sessionUUID.text.length,
          );
    });

    debugPrint(
      'Session UUID filled from NFC: '
          '$sessionUuid',
    );

    // The other values are available too if
    // this screen ever needs them:
    //
    // data.playerUuid
    // data.challenge
  }

  @override
  void dispose() {
    NfcPeer.stopReader();

    NfcPeer.setMessageHandler(
      null,
    );

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
          const GradientHomeBG(),

          Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.center,
              mainAxisSize:
              MainAxisSize.min,
              children: [

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [

                    const SizedBox(
                      width: 15,
                    ),

                    const M3EHeader(
                      headerText:
                      'Host a Session',
                    ),

                    Checkbox(
                      value:
                      hostSession,
                      onChanged:
                          (bool? value) {
                        setState(() {
                          hostSession =
                              value ?? false;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(
                  height: 13,
                ),

                // Player name
                Row(
                  children: [

                    const SizedBox(
                      width: 15,
                    ),

                    Expanded(
                      child: TextField(
                        maxLength: 20,
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                        ),
                        controller:
                        _playerName,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'Player Name',
                          labelStyle:
                          TextStyle(
                            color:
                            Colors.white,
                            fontSize:
                            16,
                          ),
                          border:
                          OutlineInputBorder(),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 15,
                    ),
                  ],
                ),

                // Session UUID
                if (!hostSession)
                  Row(
                    children: [

                      const SizedBox(
                        width: 15,
                      ),

                      Expanded(
                        child: TextField(
                          maxLength: 36,
                          style:
                          const TextStyle(
                            color:
                            Colors.white,
                          ),
                          controller:
                          _sessionUUID,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Session UUID',
                            labelStyle:
                            TextStyle(
                              color:
                              Colors.white,
                              fontSize:
                              16,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 15,
                      ),
                    ],
                  )
                else
                  const SizedBox(
                    height: 68,
                  ),

                M3EButton(
                  onPressed: () async {

                    final String? ipAddress =
                    app_state.getIpAddress();

                    if (ipAddress == null) {
                      showDialog(
                        context: context,
                        builder:
                            (BuildContext dialogContext) {
                          return const ErrorDialogM3E(
                            errorHeader:
                            'Missing IP address',
                            errorText:
                            'IP address not found',
                          );
                        },
                      );

                      return;
                    }

                    if (_playerName
                        .text
                        .isEmpty) {
                      showDialog(
                        context: context,
                        builder:
                            (BuildContext dialogContext) {
                          return const ErrorDialogM3E(
                            errorHeader:
                            'No Name given',
                            errorText:
                            'Please input a player name',
                          );
                        },
                      );

                      return;
                    }

                    if (hostSession) {
                      _sessionUUID.clear();

                      app_state.inSession =
                      false;
                    }

                    final registered =
                    await handleRegistration(
                      ipAddress,
                      _playerName.text,
                      _sessionUUID.text,
                      context,
                      hostSession,
                    );

                    if (!registered) {
                      return;
                    }

                    if (!mounted) {
                      return;
                    }

                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) =>
                            RenderInactivesession(),
                      ),
                    );
                  },
                  decoration:
                  M3EButtonDecoration(),
                  size:
                  M3EButtonSize.lg,
                  child:
                  const Text(
                    'Register',
                    style:
                    TextStyle(
                      fontSize: 22,
                    ),
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


/// Checks whether an IP address exists.
bool isValidIp(
    String? ipAddress,
    BuildContext context,
    ) {
  if (ipAddress == null) {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) {
        return const ErrorDialogM3E(
          errorHeader:
          'Missing ip address',
          errorText:
          'Ip address not found',
        );
      },
    );

    return false;
  }

  return true;
}


/// Gradient background.
class GradientHomeBG
    extends StatelessWidget {

  const GradientHomeBG({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      decoration:
      const BoxDecoration(
        gradient:
        LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            Color.fromARGB(
              255,
              119,
              50,
              43,
            ),
            Color.fromARGB(
              255,
              97,
              6,
              92,
            ),
            Color.fromARGB(
              255,
              21,
              38,
              87,
            ),
          ],
        ),
      ),
    );
  }
}