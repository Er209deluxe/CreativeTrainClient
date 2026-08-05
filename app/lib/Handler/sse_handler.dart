import 'dart:convert';

import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/Wrappers/RoleWrapper.dart';

void playerJoined(String? data) {
  if (data != null) {
    print("${data.replaceAll('\n', '')} joined");
    app_state.playerJoined(data);
  }
}

void playerLeft(String? data) {
  if (data != null) {
    print("${data.replaceAll('\n', '')} left");
    app_state.playerLeft(data);
  }
}

void updateChallenge(String? challenge) {
  if (challenge == null) {
    return;
  }
  print("Challenge: ${challenge.replaceAll('\n', '')}");
  app_state.updateChallenge(challenge);
}

void sessionStart(String? data) {
  if (data == null) return;

  RoleWrapper role = RoleWrapper.fromJson(jsonDecode(data));
  print("session started role: ${role.team.name}");
  app_state.setRole(role);
  app_state.setGameStarted(true);
}

void sanityUpdate(String? data) {
  if (data == null) return;
  final json = jsonDecode(data);
  final sanity = (json['sanity'] as num?)?.toDouble() ?? 1.0;
  final depression = (json['depression'] as num?)?.toDouble() ?? 0.0;
  print("Sanity update: $sanity, Depression: $depression");
  app_state.updateSanity(sanity, depression);
}

void coinUpdate(String? data) {
  if (data == null) return;
  final coins = int.tryParse(data.trim()) ?? 0;
  print("Coin update: $coins");
  app_state.updateCoins(coins);
}

void inventoryUpdate(String? data) {
  if (data == null) return;
  try {
    final inventory = jsonDecode(data) as List<dynamic>;
    app_state.updateInventory(inventory);
  } catch (e) {
    print("Failed to parse inventory update: $e");
  }
}
