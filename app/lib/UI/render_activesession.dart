import 'package:creativetrainclient/UI/render_registerconfig.dart';
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
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 35),
                Row(children: [M3EHeader(headerText: 'SessionStarted')]),
                const SizedBox(height: 35),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
