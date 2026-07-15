import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/Handler/handle_buttons_clientconfig.dart';
import 'package:creativetrainclient/Handler/handle_client_api_requests.dart';
import 'package:creativetrainclient/UI/render_registerconfig.dart';
import 'package:creativetrainclient/configs/UI/standartm3edesign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

class RenderInactivesession extends StatefulWidget {
  const RenderInactivesession({super.key});

  @override
  State<RenderInactivesession> createState() =>
      _RenderInactivesessionState();
}

class _RenderInactivesessionState extends State<RenderInactivesession> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GradientHomeBG(),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 35),
                Row(
                  children: [
                    const SizedBox(width: 40),
                    if (app_state.getCurrentSession().isHost)
                      Expanded(
                        child: M3EButton(
                          onPressed: () {
                            print("start session");
                            startSession("temp role configR");
                          },
                          decoration: M3EButtonDecoration.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              13,
                              188,
                              0,
                            ),
                            foregroundColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                          ),
                          size: M3EButtonSize.custom(height: 65, width: 550),
                          child: const Text(
                            'Start Session',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                      ),

                    const SizedBox(width: 20),
                    Expanded(
                      child: M3EButton(
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
                          foregroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                        ),
                        size: M3EButtonSize.custom(height: 65, width: 550),
                        child: const Text(
                          'Leave Session',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                if (app_state.getCurrentSession().sessionUuid != '')
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const SizedBox(width: 35),
                          Expanded(
                            child: M3EButton(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(
                                    text: app_state
                                        .getCurrentSession()
                                        .sessionUuid,
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Copied Session UUID'),
                                  ),
                                );
                              },
                              decoration: M3EButtonDecoration.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  29,
                                  27,
                                  50,
                                ),
                                foregroundColor: const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ),
                              ),
                              size: M3EButtonSize.custom(
                                height: 65,
                                width: 550,
                              ),
                              child: Text(
                                app_state.getCurrentSession().sessionUuid,
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 35),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(width: 35),
                    Expanded(
                      child: Container(
                        height: 65,
                        width: 550,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 3, 59, 143),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Players',
                          style: TextStyle(
                            fontSize: 22,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),

                        ),
                      ),

                    ),

                    const SizedBox(width: 35),
                  ],
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 550,
                      child: ValueListenableBuilder<int>(
                        valueListenable: app_state.playerListNotifier,
                        builder: (_, __, ___) {
                          final players = app_state.getCurrentSession().playerList;

                          return ListView.builder(
                            itemCount: players.length,
                            itemBuilder: (_, index) {
                              return SizedBox(
                                height: 30,
                                child: Text(
                                  players[index],
                                  key: ValueKey(players[index]),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              );
                            },
                          );
                        },
                      ),
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
