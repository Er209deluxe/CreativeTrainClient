import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3e_buttons/m3e_buttons.dart';
import 'package:creativetrainclient/UI/renderSplashScreen.dart';
import 'package:m3e_collection/m3e_collection.dart';

class ClientConfigPage extends StatefulWidget {
  const ClientConfigPage({super.key});

  @override
  State<ClientConfigPage> createState() => _ClientConfigPageState();
}

class _ClientConfigPageState extends State<ClientConfigPage> {
  int? _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _GradientHomeBG(),
          Center(
            child: Column(
              spacing: 16.0,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              //Center Content
              children: [
                BtnForIPOrDomain(initialIndex: _selected),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^[a-zA-Z0-9.\-]*$'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'IP address of Server',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: OutlineInputBorder(),
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

// Gradient Background
class _GradientHomeBG extends StatelessWidget {
  const _GradientHomeBG();

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

class BtnForIPOrDomain extends StatefulWidget {
  final int? initialIndex;

  const BtnForIPOrDomain({super.key, required this.initialIndex});

  @override
  State<BtnForIPOrDomain> createState() => _BtnForIPOrDomainState();
}

class _BtnForIPOrDomainState extends State<BtnForIPOrDomain> {
  int? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return M3EToggleButtonGroup(
      type: M3EButtonGroupType.connected,
      selectedIndex: _selected,
      onSelectedIndexChanged: (index) => setState(() => _selected = index),
      actions: const [
        M3EToggleButtonGroupAction(
          icon: Icon(Icons.format_bold),
          semanticLabel: 'Bold',
        ),
        M3EToggleButtonGroupAction(
          icon: Icon(Icons.format_italic),
          semanticLabel: 'Italic',
        ),
      ],
    );
  }
}
