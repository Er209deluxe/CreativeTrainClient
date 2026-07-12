import 'package:creativetrainclient/UI/render_clientconfig.dart';
import 'package:creativetrainclient/UI/render_registerconfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _selected;

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
                M3EToggleButtonGroup(
                  selectedIndex: _selected,
                  onSelectedIndexChanged: (index) {
                    setState(() {
                      _selected = index;
                    });
                    // Press Action
                    if (index == 1) {
                      Navigator.of(context).push(
                        CupertinoPageRoute(builder: (_) => ClientConfigPage()),
                      );
                    }
                  },
                  size: M3EButtonSize.custom(height: 150, width: 300),
                  direction: Axis.vertical,
                  decoration: M3EToggleButtonDecoration.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 59, 143),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    checkedBackgroundColor: const Color.fromARGB(
                      255,
                      130,
                      142,
                      215,
                    ),
                    checkedForegroundColor: Colors.white,
                  ),
                  actions: [
                    M3EToggleButtonGroupAction(
                      icon: const Icon(Icons.cloud, size: 50),
                      label: const Text(
                        'Server',
                        style: TextStyle(fontSize: 50),
                      ),
                    ),
                    M3EToggleButtonGroupAction(
                      icon: const Icon(Icons.phone_android, size: 50),
                      label: const Text(
                        'Client',
                        style: TextStyle(fontSize: 50),
                      ),
                    ),
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
