import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/UI/render_registerconfig.dart';
import 'package:creativetrainclient/Wrappers/RoleWrapper.dart';
import 'package:creativetrainclient/configs/UI/standartm3edesign.dart';
import 'package:flutter/material.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

class RenderActivesession extends StatefulWidget {
  const RenderActivesession({super.key});

  @override
  State<RenderActivesession> createState() => _RenderActivesessionState();
}

class _RenderActivesessionState extends State<RenderActivesession> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GradientHomeBG(),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                ValueListenableBuilder<RoleWrapper?>(
                  valueListenable: app_state.roleNotifier,
                  builder: (context, role, _) {
                    return M3EHeader(
                      headerText: "Role: ${role?.team.name ?? 'Loading...'}",
                    );
                  },
                ),
                const SizedBox(height: 25),
                ValueListenableBuilder<double>(
                  valueListenable: app_state.sanityNotifier,
                  builder: (context, sanity, _) {
                    return ValueListenableBuilder<double>(
                      valueListenable: app_state.depressionNotifier,
                      builder: (context, depression, _) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sanity',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(sanity * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: sanity,
                                  end: sanity,
                                ),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                                builder: (context, animatedSanity, _) {
                                  return LinearProgressIndicator(
                                    value: animatedSanity,
                                    minHeight: 22,
                                    borderRadius: BorderRadius.circular(6),
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      animatedSanity > 0.5
                                          ? Colors.greenAccent
                                          : animatedSanity > 0.25
                                          ? Colors.amber
                                          : Colors.redAccent,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Depression',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(depression * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: depression,
                                  end: depression,
                                ),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                                builder: (context, animatedDepression, _) {
                                  return LinearProgressIndicator(
                                    value: animatedDepression,
                                    minHeight: 22,
                                    borderRadius: BorderRadius.circular(4),
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      animatedDepression > 0.9
                                          ? Colors.greenAccent
                                          : animatedDepression > 0.4
                                          ? Colors.amber
                                          : Colors.redAccent,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    const SizedBox(width: 25),
                    Expanded(
                      child: M3EButton(
                        onPressed: () {
                          //TODO: Leave Game
                        },
                        size: M3EButtonSize.custom(height: 85),
                        decoration: M3EButtonDecoration.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            224,
                            11,
                            11,
                          ),
                          foregroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                        ),
                        child: Text(
                          'Leave Game',
                          style: TextStyle(fontSize: 27),
                        ),
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: M3EButton(
                        onPressed: () {
                          //TODO: Refresh Inventory
                        },
                        size: M3EButtonSize.custom(height: 85),
                        decoration: M3EButtonDecoration.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            3,
                            59,
                            143,
                          ),
                          foregroundColor: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ),
                        ),
                        child: Text(
                          'Refresh Inventory',
                          style: TextStyle(fontSize: 27),
                        ),
                      ),
                    ),
                    const SizedBox(width: 25),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
