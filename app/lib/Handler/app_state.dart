import 'dart:async';
import 'package:creativetrainclient/Handler/NfcPeer.dart';
import 'package:creativetrainclient/Wrappers/GeneralConfig.dart';
import 'package:creativetrainclient/Wrappers/RoleConfigData.dart';
import 'package:flutter/cupertino.dart';
import 'package:creativetrainclient/Handler/handle_client_api_requests.dart';
import 'package:flutter/foundation.dart';
import '../Wrappers/RoleWrapper.dart';
import '../Wrappers/register_response.dart';

class app_state {
  static late StreamSubscription sseSubscription;
  static RegisterResponse? _currentSession;
  static String? _ipAddress;
  static bool inSession = false;
  static bool _gameStarted = false;
  static late String? _challenge;
  static RoleWrapper? _role;

  static final ValueNotifier<bool> gameStartedNotifier = ValueNotifier(false);
  static final ValueNotifier<Map<String, dynamic>> gameEndDataNotifier =
      ValueNotifier({});
  static final ValueNotifier<RoleWrapper?> roleNotifier = ValueNotifier(null);
  static final ValueNotifier<double> sanityNotifier = ValueNotifier(1.0);
  static final ValueNotifier<double> depressionNotifier = ValueNotifier(0.0);
  static final ValueNotifier<int> coinsNotifier = ValueNotifier(0);

  static final ValueNotifier<int> playerListNotifier = ValueNotifier(0);

  static final ValueNotifier<String> winnerTeam = ValueNotifier("Unknown");
  static final ValueNotifier<String> reason = ValueNotifier("Unknown");

  static final GeneralConfig _defaultGeneralConfig = GeneralConfig(10, 0, 60, 50, 50, DepressionData(100, 100));
  static final ValueNotifier<GeneralConfig> generalConfig = ValueNotifier(_defaultGeneralConfig);

  static String? getChallenge(){
    return _challenge;
}
  static final RoleConfigData _roleConfigData = RoleConfigData([
    RoleConfig(
      name: "Innocent",
      passiveIncome: true,
      taskIncome: 20,
      baseInventory: [
        InventoryItem("Food"),
      ],
      itemShop: [
        ShopItemConfig("Knife", 10),
        ShopItemConfig("Knife", 20),
        ShopItemConfig("Food", 13),
        ShopItemConfig("Gun", 50),
      ],
    ),
    RoleConfig(
      name: "Vigilante",
      enabled: true,
      passiveIncome: true,
      taskIncome: 12,
      itemShop: [
        ShopItemConfig("Gun", 0),
      ],
    ),
    RoleConfig(
      name: "Killer",
      enabled: true,
      passiveIncome: true,
      taskIncome: 12,
      itemShop: [
        ShopItemConfig("Gun", 0),
      ],
    ),
  ]);
  static final ValueNotifier<RoleConfigData> roleConfig = ValueNotifier(_roleConfigData);

  static void updateSessionEndData(Map<String, dynamic> json) {
    gameEndDataNotifier.value = json;

    final str = json.toString();

    final matchWinnerTeam = RegExp(r'winnerTeam:\s*([^,]+),').firstMatch(str);
    final matchReason = RegExp(r'reason:\s*([^}]*)\}?').firstMatch(str);

    winnerTeam.value = matchWinnerTeam?.group(1)?.trim() ?? "Unknown";
    reason.value = matchReason?.group(1)?.trim() ?? "Unknown";
  }

  static void playerJoined(String name) {
    if(_currentSession==null) return;
    _currentSession!.addPlayer(name);
    playerListNotifier.value++;
  }

  static void playerLeft(String name) {
    if(_currentSession==null) return;

    _currentSession!.removePlayer(name);
    playerListNotifier.value++;
  }

  static void setGameStarted(bool started) {
    _gameStarted = started;
    gameStartedNotifier.value = started;
  }

  static bool isGameStarted() {
    return _gameStarted;
  }

  static Future<void> updateChallenge(String challenge) async {
    await NfcPeer.setChallenge(challenge);
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
  static void removeCurrentSession(){
    NfcPeer.clear();
    _challenge=null;
    inSession = false;
    changeGameActivation(false);
    _currentSession = null;
  }
  static Future<void> setCurrentSession(RegisterResponse sessionData) async {
    if (inSession) {
      return;
    }
    inSession = true;
    _currentSession = sessionData;

    await NfcPeer.setSessionUuid(sessionData.sessionUuid);
    await NfcPeer.setPlayerUuid(sessionData.playerUuid);
  }

  static void setRole(RoleWrapper roleData) {
    _role = roleData;
    roleNotifier.value = roleData;
  }

  static void updateSanity(double sanity) {
    sanityNotifier.value = sanity.clamp(0.0, 1.0);
  }

  static void updateDepression(double depression) {
    depressionNotifier.value = depression.clamp(0.0, 1.0);
  }

  static void updateCoins(int coins) {
    if(_currentSession==null) return;
    coinsNotifier.value = coins;
    _currentSession!.setCoins(coins);
  }

  static void updateInventory(List<dynamic> inventory) {
    if (_role == null) return;
    _role = _role?.copyWith(
      team: _role!.team.copyWith(baseInventory: inventory),
    );
    roleNotifier.value = _role;
  }

  static RegisterResponse getCurrentSession() {
    return _currentSession!;
  }
}
