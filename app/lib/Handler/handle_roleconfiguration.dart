import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void resetCurrentConfig(BuildContext context) {
  app_state.resetConfigToDefaults();
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Settings have been reset')));
}
