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
                const SizedBox(height: 20),
                M3EHeader(headerText: 'Players'),
                const SizedBox(height: 20),
                M3EButton(
                  onPressed: null,
                  decoration: M3EButtonDecoration(),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 25, color: Colors.white),
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
