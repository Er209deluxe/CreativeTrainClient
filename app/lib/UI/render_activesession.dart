import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/UI/render_registerconfig.dart';
import 'package:creativetrainclient/Wrappers/RoleWrapper.dart';
import 'package:creativetrainclient/configs/UI/standartm3edesign.dart';
import 'package:flutter/material.dart';

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
                                      color: Colors.white.withOpacity(0.9),
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
                              LinearProgressIndicator(
                                value: sanity,
                                minHeight: 22,
                                borderRadius: BorderRadius.circular(6),
                                backgroundColor: Colors.white.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  sanity > 0.5
                                      ? Colors.greenAccent
                                      : sanity > 0.25
                                      ? Colors.amber
                                      : Colors.redAccent,
                                ),
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
                                      color: Colors.white.withOpacity(0.9),
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
                              LinearProgressIndicator(
                                value: depression,
                                minHeight: 22,
                                borderRadius: BorderRadius.circular(4),
                                backgroundColor: Colors.white.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  depression < 0.3
                                      ? Colors.greenAccent
                                      : depression < 0.6
                                      ? Colors.amber
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
