import 'package:flutter/material.dart';

class M3EHeader extends StatelessWidget {
  final String headerText;

  const M3EHeader({super.key, required this.headerText});

  @override
  Widget build(BuildContext context) {
    return Text(
      headerText,
      style: TextStyle(color: Colors.white, fontSize: 25),
    );
  }
}
