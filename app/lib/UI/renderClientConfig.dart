import 'dart:math' as math;

import 'package:creativetrainclient/UI/Handler/handleButtonsClientConfig.dart';
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
  final int _selected = 0;

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
                HandleTextField(),
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
      onSelectedIndexChanged: (index) {
        index ??= 0;
        setState(() => _selected = index);
        DomainPressAction(selectedWidget: null); //Change Text field
      },
      actions: const [
        M3EToggleButtonGroupAction(
          label: Text('Domain', style: TextStyle(fontSize: 18)),
        ),
        M3EToggleButtonGroupAction(
          label: Text('IP', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}

class HandleTextField extends StatelessWidget {
  const HandleTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // or start, end, center
      children: [
        const SizedBox(width: 15),
        Expanded(
          child: TextField(
            maxLength: 3,
            style: const TextStyle(color: Colors.white),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: '0',
              labelStyle: TextStyle(color: Colors.white, fontSize: 16),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w200,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: TextField(
            maxLength: 3,
            style: const TextStyle(color: Colors.white),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: '-',
              labelStyle: TextStyle(color: Colors.white, fontSize: 16),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w200,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: TextField(
            maxLength: 3,
            style: const TextStyle(color: Colors.white),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: '256',
              labelStyle: TextStyle(color: Colors.white, fontSize: 16),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w200,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: TextField(
            maxLength: 3,
            style: const TextStyle(color: Colors.white),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'IP',
              labelStyle: TextStyle(color: Colors.white, fontSize: 16),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          ':',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w200,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: TextField(
            maxLength: 10,
            style: const TextStyle(color: Colors.white),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Port',
              labelStyle: TextStyle(color: Colors.white, fontSize: 16),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}
