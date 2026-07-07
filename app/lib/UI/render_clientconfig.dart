import 'package:creativetrainclient/Handler/handle_buttons_clientconfig.dart';
import 'package:creativetrainclient/configs/UI/standartm3edesign.dart';
import 'package:flutter/material.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

class ClientConfigPage extends StatefulWidget {
  const ClientConfigPage({super.key});

  @override
  State<ClientConfigPage> createState() => _ClientConfigPageState();
}

class _ClientConfigPageState extends State<ClientConfigPage> {
  int? _selected;

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
              //Center Content Client Configuration UI
              children: [
                M3EHeader(headerText: 'Choose Connection Method'),
                BtnForIPOrDomain(
                  initialIndex: _selected,
                  onSelectionChanged: (int? newIndex) {
                    // 2. Update parent state when child notifies
                    setState(() {
                      _selected = newIndex;
                    });
                  },
                ),
                DomainPressAction(actionNr: _selected),
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
  final Function(int?) onSelectionChanged;

  const BtnForIPOrDomain({
    super.key,
    required this.initialIndex,
    required this.onSelectionChanged,
  });

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
      size: M3EButtonSize.md,
      decoration: M3EToggleButtonDecoration.styleFrom(
        backgroundColor: const Color.fromARGB(255, 3, 59, 143),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        checkedBackgroundColor: const Color.fromARGB(255, 130, 142, 215),
        checkedForegroundColor: Colors.white,
      ),
      onSelectedIndexChanged: (index) {
        setState(() => _selected = index);
        widget.onSelectionChanged(index);
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
