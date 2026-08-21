  import 'dart:convert';

  import 'package:creativetrainclient/Handler/app_state.dart';
  import 'package:creativetrainclient/UI/render_registerconfig.dart';
  import 'package:creativetrainclient/Wrappers/GeneralConfig.dart';
  import 'package:creativetrainclient/Wrappers/RoleConfigData.dart';
  import 'package:creativetrainclient/configs/UI/standartm3edesign.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:m3e_buttons/m3e_buttons.dart';

  import '../Handler/handle_client_api_requests.dart';

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
                    child: ValueListenableBuilder<GeneralConfig>(
                      valueListenable: app_state.generalConfig,
                      builder: (context, generalConfigData, _) {
                        Map<String, dynamic> config;

                        if (_section == 'general') {
                          return _GeneralConfigEditor(config: generalConfigData);
                        }
                        return _RoleConfigEditor(config: app_state.roleConfig.value);
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
    final RoleConfigData config;

    const _RoleConfigEditor({required this.config});

    @override
    State<_RoleConfigEditor> createState() => _RoleConfigEditorState();
  }class _RoleConfigEditorState extends State<_RoleConfigEditor> {
    int _selectedRole = 0;

    // These come from /api/session/allRoles
    List<Map<String, dynamic>> _roles = [];

    @override
    void initState() {
      super.initState();
      _loadRoles();
    }

    Future<void> _loadRoles() async {
      try {
        final roles = await getAllRoles();

        if (!mounted) return;

        setState(() {
          _roles = roles;
        });
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load roles: $e'),
          ),
        );
      }
    }

    int get _effectiveSelectedRole {
      if (_roles.isEmpty) return 0;

      return _selectedRole.clamp(0, _roles.length - 1).toInt();
    }

    Map<String, dynamic>? get _selectedRoleMap {
      if (_roles.isEmpty) return null;

      return _roles[_effectiveSelectedRole];
    }

    @override
    Widget build(BuildContext context) {
      if (_roles.isEmpty) {
        return const Center(
          child: Text(
            'No roles configured',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        );
      }

      final roleInfo = _selectedRoleMap!;

      final roleName = roleInfo['name'] as String? ?? 'Unknown Role';
      final roleHex = roleInfo['hex'] as String?;

      /*
     * Find the editable configuration for this role.
     *
     * app_state.roleConfig contains:
     *
     * RoleConfigData
     *   └── List<RoleConfig>
     *
     * We match it using the role name.
     */
      RoleConfig? roleConfig;

      for (final config in widget.config.roleConfig) {
        if (config.name == roleName) {
          roleConfig = config;
          break;
        }
      }

      /*
     * The role exists in allRoles but doesn't have configuration yet.
     */
      if (roleConfig == null) {
        roleConfig = RoleConfig(
          name: roleName,
          passiveIncome: false,
          taskIncome: 0,
        );

        widget.config.roleConfig.add(roleConfig);
      }

      final role = roleConfig;

      final actions = <M3EToggleButtonGroupAction>[
        for (var i = 0; i < _roles.length; i++)
          M3EToggleButtonGroupAction(
            label: Text(
              (_roles[i]['name'] as String?) ?? 'Role $i',
              style: const TextStyle(fontSize: 14),
            ),
            decoration: M3EToggleButtonDecoration.styleFrom(
              backgroundColor: _hexToColor(
                _roles[i]['hex'] as String?,
              ),
              foregroundColor: Colors.white,
              checkedBackgroundColor: Colors.blueGrey.shade400,
              checkedForegroundColor: _hexToColor(
                _roles[i]['hex'] as String?,
              ),
            ),
          ),
      ];

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
                setState(() {
                  _selectedRole = index ?? 0;
                });
              },
              actions: actions,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 8,
              ),
              children: [
                Text(
                  roleName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _LabeledSwitch(
                  label: 'Enabled',
                  value: role.enabled,
                  onChanged: (v) {
                    setState(() {
                      role.enabled = v;
                    });
                  },
                ),

                _LabeledSwitch(
                  label: 'Passive Income',
                  value: role.passiveIncome,
                  onChanged: (v) {
                    setState(() {
                      role.passiveIncome = v;
                    });
                  },
                ),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Task Income',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    NumberInput(
                      label: 'Task Income',
                      value: role.taskIncome,
                      onChanged: (v) {
                        setState(() {
                          role.taskIncome = v;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _ItemListEditor(
                  header: 'Base Inventory',
                  items: role.baseInventory,
                  showPrice: false,
                  onChanged: () {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 24),

                _ItemListEditor(
                  header: 'Item Shop',
                  items: role.itemShop,
                  showPrice: true,
                  onChanged: () {
                    setState(() {});
                  },
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
  class _ItemListEditor extends StatelessWidget {
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
      if (showPrice) {
        items.add(
          ShopItemConfig(
            'Knife',
            10,
          ),
        );
      } else {
        items.add(
          InventoryItem('Knife'),
        );
      }

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
      if (showPrice) {
        final item = items[index] as ShopItemConfig;

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
                label: 'name',
                value: item.name,
                options: _names,
                onChanged: (v) {
                  item.name = v;
                  onChanged();
                },
              ),

              NumberInput(
                label: 'price',
                value: item.price,
                onChanged: (v) {
                  item.price = v;
                  onChanged();
                },
              ),

              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                tooltip: 'Remove item',
                onPressed: () {
                  items.removeAt(index);
                  onChanged();
                },
              ),
            ],
          ),
        );
      } else {
        final item = items[index] as InventoryItem;

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
                label: 'name',
                value: item.name,
                options: _names,
                onChanged: (v) {
                  item.name = v;
                  onChanged();
                },
              ),

              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
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
    final GeneralConfig config;

    const _GeneralConfigEditor({required this.config});

    @override
    State<_GeneralConfigEditor> createState() => _GeneralConfigEditorState();
  }
  class _GeneralConfigEditorState extends State<_GeneralConfigEditor> {


    @override
    Widget build(BuildContext context) {
      final general = widget.config;
      final depressionData = general.depressionData;

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
            value: general.baseTimerMins,
            onChanged: (v) {
              general.baseTimerMins = v;
            },
          ),

          _GeneralNumberInput(
            label: 'Base Timer (secs)',
            value: general.baseTimerSecs,
            onChanged: (v) {
              general.baseTimerSecs = v;

            },
          ),

          _GeneralNumberInput(
            label: 'Increment Timer On Kill (s)',
            value: general.incrementTimerOnKillInSeconds,
            onChanged: (v) {
              general.incrementTimerOnKillInSeconds = v;

            },
          ),

          _GeneralNumberInput(
            label: 'Kill Reward',
            value: general.killReward,
            onChanged: (v) {
              general.killReward = v;

            },
          ),

          _GeneralNumberInput(
            label: 'Passive Income',
            value: general.passiveIncome,
            onChanged: (v) {
              general.passiveIncome = v;

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
            value: depressionData.baseDepression,
            onChanged: (v) {
              depressionData.baseDepression = v;

            },
          ),

          _GeneralNumberInput(
            label: 'Base Sanity',
            value: depressionData.baseSanity,
            onChanged: (v) {
              depressionData.baseSanity = v;

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
