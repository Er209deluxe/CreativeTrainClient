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
              crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
