import 'package:flutter/cupertino.dart';

class HanldeButtonsRoleconfiguration extends StatefulWidget {
  final int? actionNr;
  const HanldeButtonsRoleconfiguration({super.key, required this.actionNr});

  @override
  State<HanldeButtonsRoleconfiguration> createState() =>
      _HanldeButtonsRoleconfigurationState();
}

class _HanldeButtonsRoleconfigurationState
    extends State<HanldeButtonsRoleconfiguration> {
  @override
  Widget build(BuildContext context) {
    if (widget.actionNr == 1) {
      return const Placeholder();
    } else {
      return const Placeholder();
    }
  }
}
