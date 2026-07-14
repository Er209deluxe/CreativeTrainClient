import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/Handler/handle_buttons_clientconfig.dart';
import 'package:creativetrainclient/Handler/handle_client_api_requests.dart';
import 'package:creativetrainclient/UI/render_registerconfig.dart';
import 'package:creativetrainclient/configs/UI/standartm3edesign.dart';
import 'package:flutter/material.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

class RenderInactivesession extends StatefulWidget {
  const RenderInactivesession({super.key});

  @override
  State<RenderInactivesession> createState() => _RenderInactivesessionState();
}

class _RenderInactivesessionState extends State<RenderInactivesession> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GradientHomeBG(),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 35),
                if (app_state.getCurrentSession().isHost)
                  M3EButton(
                    onPressed: () {
                      //TODO: start session button
                    },
                    decoration: M3EButtonDecoration.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 13, 188, 0),
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    size: M3EButtonSize.custom(height: 65, width: 550),
                    child: const Text(
                      'Start Session',
                      style: TextStyle(fontSize: 22),
                    ),
                  )
                else
                  M3EButton(
                    onPressed: () {
                      //Leave game
                      String? ipAddress = app_state.getIpAddress();
                      if (ipAddress == null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return ErrorDialogM3E(
                              errorHeader: 'Missing ip address',
                              errorText: 'Ip address not found',
                            );
                          },
                        );
                        return;
                      }
                      leaveSession(
                        ipAddress,
                        app_state.getCurrentSession().playerUuid,
                        app_state.getCurrentSession().token,
                      );

                      Navigator.pop(context);
                    },
                    decoration: M3EButtonDecoration.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 143, 3, 3),
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    size: M3EButtonSize.custom(height: 65, width: 550),
                    child: const Text(
                      'Leave Game',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                const SizedBox(height: 20),
                M3EButton(
                  onPressed: () {},
                  decoration: M3EButtonDecoration.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 59, 143),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  size: M3EButtonSize.custom(height: 65, width: 550),
                  child: const Text('Players', style: TextStyle(fontSize: 22)),
                ),
                //TODO: Render all Player names
                const SizedBox(height: 20),
                M3EHeader(headerText: 'Player 1'),
                const SizedBox(height: 20),
                M3EHeader(headerText: 'Player 2'),
                const SizedBox(height: 20),
                M3EHeader(headerText: 'Player 3'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
