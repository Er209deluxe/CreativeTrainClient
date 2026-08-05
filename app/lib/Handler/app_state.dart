import 'dart:async';

import 'package:creativetrainclient/Handler/handle_client_api_requests.dart';
import 'package:flutter/cupertino.dart';

import '../Wrappers/RoleWrapper.dart';
import '../Wrappers/register_response.dart';

class app_state {
  static late StreamSubscription sseSubscription;
  static late RegisterResponse _currentSession;
  static String? _ipAddress;
  static bool inSession = false;
  static bool _gameStarted = false;
  static late String _challenge;
  static RoleWrapper? _role;

  static final ValueNotifier<bool> gameStartedNotifier = ValueNotifier(false);
  static final ValueNotifier<RoleWrapper?> roleNotifier = ValueNotifier(null);
  static final ValueNotifier<double> sanityNotifier = ValueNotifier(1.0);
  static final ValueNotifier<double> depressionNotifier = ValueNotifier(0.0);
  static final ValueNotifier<int> coinsNotifier = ValueNotifier(0);

  static final ValueNotifier<int> playerListNotifier = ValueNotifier(0);

  static void playerJoined(String name) {
    _currentSession.addPlayer(name);
    playerListNotifier.value++;
  }

  static void playerLeft(String name) {
    _currentSession.removePlayer(name);
    playerListNotifier.value++;
  }
  static void setGameStarted(bool started) {
    _gameStarted = started;
    gameStartedNotifier.value = started;
  }
  static bool isGameStarted() {
    return _gameStarted;
  }

  static void updateChallenge(String challenge) {
    _challenge = challenge;
  }

  static void changeGameActivation(bool isActive) {
    inSession = isActive;
  }

  static RoleWrapper? getRole() {
    return _role;
  }

  static bool setIpAddress(String pIpAddress) {
    if (inSession) return false;
    _ipAddress = pIpAddress;
    return true;
  }

  static String? getIpAddress() {
    return _ipAddress;
  }

  static void setCurrentSession(RegisterResponse sessionData) {
    if (inSession) {
      return;
    }
    inSession = true;
    _currentSession = sessionData;
  }

  static void setRole(RoleWrapper roleData) {
    _role = roleData;
    roleNotifier.value = roleData;
  }

  static void updateSanity(double sanity, double depression) {
    sanityNotifier.value = sanity.clamp(0.0, 1.0);
    depressionNotifier.value = depression.clamp(0.0, 1.0);
  }

  static void updateCoins(int coins) {
    coinsNotifier.value = coins;
    _currentSession.setCoins(coins);
  }

  static void updateInventory(List<dynamic> inventory) {
    if (_role == null) return;
    _role = _role?.copyWith(
      team: _role!.team.copyWith(baseInventory: inventory),
    );
    roleNotifier.value = _role;
  }

  static RegisterResponse getCurrentSession() {
    return _currentSession;
  }
}
