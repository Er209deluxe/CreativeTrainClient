import 'dart:convert';

import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/UI/render_registerconfig.dart';
import 'package:creativetrainclient/configs/UI/standartm3edesign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

class RenderRoleconfiguration extends StatefulWidget {
  const RenderRoleconfiguration({super.key});

  @override
  State<RenderRoleconfiguration> createState() =>
      _RenderRoleconfigurationState();
}

class _RenderRoleconfigurationState extends State<RenderRoleconfiguration> {
  String _section = 'roles';
  String _profile = 'p1';

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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      M3EButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        decoration: M3EButtonDecoration.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        size: M3EButtonSize.custom(height: 65, width: 65),
                        child: const Icon(Icons.arrow_back_ios, size: 30),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _SectionDropdown(
                            value: _section,
                            onChanged: (value) {
                              setState(() => _section = value);
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _ProfileDropdown(
                            value: _profile,
                            onChanged: (value) {
                              setState(() => _profile = value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: ValueListenableBuilder<String>(
                    valueListenable: app_state.modifiedConfig,
                    builder: (context, configString, _) {
                      Map<String, dynamic> config;
                      try {
                        config =
                            jsonDecode(configString) as Map<String, dynamic>;
                      } catch (e) {
                        config =
                            jsonDecode(app_state.standartConfig)
                                as Map<String, dynamic>;
                      }
                      if (_section == 'general') {
                        return _GeneralConfigEditor(config: config);
                      }
                      return _RoleConfigEditor(config: config);
                    },
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

class _SectionDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SectionDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        underline: const SizedBox.shrink(),
        iconEnabledColor: Colors.white,
        dropdownColor: const Color(0xFF223E5F),
        style: const TextStyle(color: Colors.white, fontSize: 18),
        items: const [
          DropdownMenuItem(
            value: 'roles',
            child: Text('Role Config', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'general',
            child: Text(
              'General Config',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _ProfileDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        underline: const SizedBox.shrink(),
        iconEnabledColor: Colors.white,
        dropdownColor: const Color(0xFF223E5F),
        style: const TextStyle(color: Colors.white, fontSize: 18),
        items: const [
          DropdownMenuItem(
            value: 'p1',
            child: Text('Profile 1', style: TextStyle(color: Colors.white)),
          ),
          DropdownMenuItem(
            value: 'pnew',
            child: Text(
              'Add new Profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

Color _hexToColor(String? hex) {
  final cleaned = (hex ?? '').replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  return value != null ? Color(0xFF000000 | value) : Colors.grey;
}

class _RoleConfigEditor extends StatefulWidget {
  final Map<String, dynamic> config;

  const _RoleConfigEditor({required this.config});

  @override
  State<_RoleConfigEditor> createState() => _RoleConfigEditorState();
}

class _RoleConfigEditorState extends State<_RoleConfigEditor> {
  static const _teamNames = ['CIVILIAN', 'NEUTRAL', 'KILLER'];

  int _selectedRole = 0;

  List<dynamic> get _roles =>
      widget.config['roleConfig'] as List<dynamic>? ?? [];

  int get _effectiveSelectedRole =>
      _selectedRole.clamp(0, _roles.length - 1).toInt();

  Map<String, dynamic>? get _selectedRoleMap {
    if (_roles.isEmpty) return null;
    return _roles[_effectiveSelectedRole] as Map<String, dynamic>;
  }

  void _commit() {
    app_state.modifiedConfig.value = jsonEncode(widget.config);
  }

  @override
  Widget build(BuildContext context) {
    final actions = <M3EToggleButtonGroupAction>[
      for (var i = 0; i < _roles.length; i++)
        M3EToggleButtonGroupAction(
          label: Text(
            (_roles[i]['name'] as String?) ?? 'Role $i',
            style: const TextStyle(fontSize: 14),
          ),
          decoration: M3EToggleButtonDecoration.styleFrom(
            backgroundColor: _hexToColor(_roles[i]['hex'] as String?),
            foregroundColor: Colors.white,
            checkedBackgroundColor: Colors.blueGrey.shade400,
            checkedForegroundColor: _hexToColor(_roles[i]['hex'] as String?),
          ),
        ),
    ];

    if (_roles.isEmpty) {
      return const Center(
        child: Text(
          'No roles configured',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final role = _selectedRoleMap!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: M3EToggleButtonGroup(
            type: M3EButtonGroupType.standard,
            size: M3EButtonSize.md,
            overflow: M3EButtonGroupOverflow.scroll,
            selectedIndex: _effectiveSelectedRole,
            onSelectedIndexChanged: (index) {
              setState(() => _selectedRole = index ?? 0);
            },
            actions: actions,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            children: [
              Text(
                (role['name'] as String?) ?? 'Role',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _LabeledSwitch(
                label: 'Enabled',
                value: (role['enabled'] as bool?) ?? true,
                onChanged: (v) {
                  role['enabled'] = v;
                  _commit();
                },
              ),
              _LabeledSwitch(
                label: 'Passive Income',
                value: (role['passiveIncome'] as bool?) ?? true,
                onChanged: (v) {
                  role['passiveIncome'] = v;
                  _commit();
                },
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Task Income',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  NumberInput(
                    label: 'Task Income',
                    value: (role['taskIncome'] as int?) ?? 0,
                    onChanged: (v) {
                      role['taskIncome'] = v;
                      _commit();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Team',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 8),
              M3EToggleButtonGroup(
                type: M3EButtonGroupType.connected,
                size: M3EButtonSize.md,
                decoration: M3EToggleButtonDecoration.styleFrom(
                  backgroundColor: _hexToColor(role['hex'] as String?),
                  foregroundColor: Colors.white,
                  checkedBackgroundColor: Colors.blueGrey.shade400,
                  checkedForegroundColor: _hexToColor(role['hex'] as String?),
                ),
                selectedIndex:
                    _teamNames.indexOf((role['team'] as String?) ?? '') >= 0
                    ? _teamNames.indexOf((role['team'] as String?) ?? '')
                    : 0,
                onSelectedIndexChanged: (index) {
                  if (index == null) return;
                  role['team'] = _teamNames[index];
                  _commit();
                },
                actions: [
                  for (final team in _teamNames)
                    M3EToggleButtonGroupAction(
                      label: Text(team, style: const TextStyle(fontSize: 14)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Hex Color',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: _HexInput(
                      value: (role['hex'] as String?) ?? '#FFFFFF',
                      onChanged: (v) {
                        role['hex'] = v;
                        _commit();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _ItemListEditor(
                header: 'Base Inventory',
                items: (role['baseInventory'] as List<dynamic>?) ?? [],
                showPrice: false,
                onChanged: _commit,
              ),
              const SizedBox(height: 24),
              _ItemListEditor(
                header: 'Item Shop',
                items: (role['itemShop'] as List<dynamic>?) ?? [],
                showPrice: true,
                onChanged: _commit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabeledSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _LabeledSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        Switch(
          value: value,
          activeTrackColor: Colors.green,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _HexInput extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _HexInput({required this.value, required this.onChanged});

  @override
  State<_HexInput> createState() => _HexInputState();
}

class _HexInputState extends State<_HexInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  String get _display => widget.value.replaceFirst('#', '');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _display);
  }

  @override
  void didUpdateWidget(covariant _HexInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value.replaceFirst('#', '') !=
            oldWidget.value.replaceFirst('#', '') &&
        !_focusNode.hasFocus) {
      _controller.text = _display;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      maxLength: 6,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
      ],
      decoration: InputDecoration(
        labelText: 'Hex (no #)',
        labelStyle: const TextStyle(color: Colors.white70),
        counterText: '',
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (text) {
        widget.onChanged('#${text.replaceAll(RegExp('[^0-9a-fA-F]'), '')}');
      },
    );
  }
}

class _ItemListEditor extends StatelessWidget {
  static const _types = ['weapon', 'consumable'];
  static const _names = ['Knife', 'Gun', 'Food'];

  final String header;
  final List<dynamic> items;
  final bool showPrice;
  final VoidCallback onChanged;

  const _ItemListEditor({
    required this.header,
    required this.items,
    required this.showPrice,
    required this.onChanged,
  });

  void _addItem() {
    items.add(
      showPrice
          ? {'type': 'weapon', 'name': 'Knife', 'price': 10}
          : {'type': 'weapon', 'name': 'Knife'},
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildItemRow(i),
          ),
        M3EButton(
          onPressed: _addItem,
          decoration: M3EButtonDecoration.styleFrom(
            backgroundColor: Colors.blueAccent,
          ),
          size: M3EButtonSize.sm,
          child: const Text('Add Item'),
        ),
      ],
    );
  }

  Widget _buildItemRow(int index) {
    final item = items[index] as Map<String, dynamic>;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _FieldDropdown(
            label: 'type',
            value: item['type'] as String?,
            options: _types,
            onChanged: (v) {
              item['type'] = v;
              onChanged();
            },
          ),
          _FieldDropdown(
            label: 'name',
            value: item['name'] as String?,
            options: _names,
            onChanged: (v) {
              item['name'] = v;
              onChanged();
            },
          ),
          if (showPrice)
            NumberInput(
              label: 'price',
              value: (item['price'] as int?) ?? 0,
              onChanged: (v) {
                item['price'] = v;
                onChanged();
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Remove item',
            onPressed: () {
              items.removeAt(index);
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

class _FieldDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _FieldDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = options.contains(value) ? value : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Theme(
            data: ThemeData.dark(useMaterial3: true),
            child: DropdownButton<String>(
              value: selected,
              isDense: true,
              underline: const SizedBox.shrink(),
              iconEnabledColor: Colors.white,
              dropdownColor: const Color(0xFF223E5F),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: [
                for (final o in options)
                  DropdownMenuItem(
                    value: o,
                    child: Text(o, style: const TextStyle(color: Colors.white)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralConfigEditor extends StatefulWidget {
  final Map<String, dynamic> config;

  const _GeneralConfigEditor({required this.config});

  @override
  State<_GeneralConfigEditor> createState() => _GeneralConfigEditorState();
}

class _GeneralConfigEditorState extends State<_GeneralConfigEditor> {
  void _commit() {
    app_state.modifiedConfig.value = jsonEncode(widget.config);
  }

  @override
  Widget build(BuildContext context) {
    final general = widget.config['generalConfig'] as Map<String, dynamic>?;
    if (general == null) {
      return const Center(
        child: Text(
          'No general config found',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final depressionData =
        general['depressionData'] as Map<String, dynamic>? ?? {};

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      children: [
        const Text(
          'General Config',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _GeneralNumberInput(
          label: 'Base Timer (mins)',
          value: (general['baseTimerMins'] as int?) ?? 0,
          onChanged: (v) {
            general['baseTimerMins'] = v;
            _commit();
          },
        ),
        _GeneralNumberInput(
          label: 'Base Timer (secs)',
          value: (general['baseTimerSecs'] as int?) ?? 0,
          onChanged: (v) {
            general['baseTimerSecs'] = v;
            _commit();
          },
        ),
        _GeneralNumberInput(
          label: 'Increment Timer On Kill (s)',
          value: (general['incrementTimerOnKillInSeconds'] as int?) ?? 0,
          onChanged: (v) {
            general['incrementTimerOnKillInSeconds'] = v;
            _commit();
          },
        ),
        _GeneralNumberInput(
          label: 'Kill Reward',
          value: (general['killReward'] as int?) ?? 0,
          onChanged: (v) {
            general['killReward'] = v;
            _commit();
          },
        ),
        _GeneralNumberInput(
          label: 'Passive Income',
          value: (general['passiveIncome'] as int?) ?? 0,
          onChanged: (v) {
            general['passiveIncome'] = v;
            _commit();
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Depression Data',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _GeneralNumberInput(
          label: 'Base Depression',
          value: (depressionData['baseDepression'] as int?) ?? 0,
          onChanged: (v) {
            depressionData['baseDepression'] = v;
            _commit();
          },
        ),
        _GeneralNumberInput(
          label: 'Base Sanity',
          value: (depressionData['baseSanity'] as int?) ?? 0,
          onChanged: (v) {
            depressionData['baseSanity'] = v;
            _commit();
          },
        ),
      ],
    );
  }
}

class _GeneralNumberInput extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _GeneralNumberInput({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          NumberInput(label: label, value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
