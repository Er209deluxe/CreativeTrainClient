import 'dart:convert';

import 'package:creativetrainclient/Handler/NfcPeer.dart';
import 'package:creativetrainclient/Handler/app_state.dart';
import 'package:creativetrainclient/Wrappers/RoleWrapper.dart';
import 'package:flutter/cupertino.dart';


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
Future<void> updateChallenge(String? challenge) async {
  if (challenge == null || challenge.trim().isEmpty) {
    return;
  }

  final cleanChallenge = challenge.trim();

  debugPrint(
    'Challenge received: $cleanChallenge',
  );

  app_state.updateChallenge(
    cleanChallenge,
  );

  // Switch NFC completely from session mode
  // to player mode.



  debugPrint(
    'NFC MODE: PLAYER INFO',
  );
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

  if (json['sanity'] is String) return;
  final sanity = (json['sanity'] as num?)?.toDouble() ?? 1.0;
  print("Sanity update: $sanity");
  app_state.updateSanity(sanity);

  if (json['depression'] is String) return;
  final depression = (json['depression'] as num?)?.toDouble() ?? 0.0;
  print("Depression update: $depression");
  app_state.updateDepression(depression);
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

void gameEndData(String? data) {
  if (data == null) return;
  app_state.setGameStarted(false);
  final json = jsonDecode(data);
  app_state.updateSessionEndData(json);
}
