import 'package:creativetrainclient/UI/render_registerconfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

class RenderRoleconfiguration extends StatefulWidget {
  const RenderRoleconfiguration({super.key});

  @override
  State<RenderRoleconfiguration> createState() =>
      _RenderRoleconfigurationState();
}

class _RenderRoleconfigurationState extends State<RenderRoleconfiguration> {
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
              children: [
                const SizedBox(height: 25),
                Row(
                  children: [
                    const SizedBox(width: 25),
                    M3EButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      decoration: M3EButtonDecoration.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      size: M3EButtonSize.custom(height: 65, width: 65),
                      child: Icon(Icons.arrow_back_ios, size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RenderRoleConfigEditor(
                  initialIndex: _selected,
                  onSelectionChanged: (int? newIndex) {
                    setState(() {
                      _selected = newIndex;
                    });
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

class RenderRoleConfigEditor extends StatefulWidget {
  final int? initialIndex;
  final Function(int?) onSelectionChanged;

  const RenderRoleConfigEditor({
    super.key,
    required this.onSelectionChanged,
    this.initialIndex,
  });

  @override
  State<RenderRoleConfigEditor> createState() => _RenderRoleConfigEditorState();
}

class _RenderRoleConfigEditorState extends State<RenderRoleConfigEditor> {
  int? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          Center(
            child: M3EToggleButtonGroup(
              type: M3EButtonGroupType.connected,
              selectedIndex: _selected,
              size: M3EButtonSize.md,
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
              onSelectedIndexChanged: (index) {
                setState(() => _selected = index);
                widget.onSelectionChanged(index);
              },
              actions: const [
                M3EToggleButtonGroupAction(
                  label: Text('Innocent', style: TextStyle(fontSize: 18)),
                ),
                M3EToggleButtonGroupAction(
                  label: Text(
                    'Get Roles from Server',
                    style: TextStyle(fontSize: 18),
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
