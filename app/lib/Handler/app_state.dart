import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:creativetrainclient/Handler/handle_client_api_requests.dart';
import 'package:flutter/foundation.dart';
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
  static final ValueNotifier<Map<String, dynamic>> gameEndDataNotifier =
      ValueNotifier({});
  static final ValueNotifier<RoleWrapper?> roleNotifier = ValueNotifier(null);
  static final ValueNotifier<double> sanityNotifier = ValueNotifier(1.0);
  static final ValueNotifier<double> depressionNotifier = ValueNotifier(0.0);
  static final ValueNotifier<int> coinsNotifier = ValueNotifier(0);

  static final ValueNotifier<int> playerListNotifier = ValueNotifier(0);

  static final ValueNotifier<String> winnerTeam = ValueNotifier("Unknown");
  static final ValueNotifier<String> reason = ValueNotifier("Unknown");

  static final String standartConfig = r'''
{
    "roleConfig": [
        {
            "name": "Innocent",
            "team": "CIVILIAN",
            "hex": "#00FF00",
            "enabled": true,
            "passiveIncome": true,
            "taskIncome": 50,
            "baseInventory": [
                {
                    "type": "consumable",
                    "name": "Food"
                }
            ],
            "itemShop": [
                {
                    "type": "weapon",
                    "name": "Knife",
                    "price": 10
                },
                {
                    "type": "weapon",
                    "name": "Knife",
                    "price": 20
                },
                {
                    "type": "consumable",
                    "name": "Food",
                    "price": 13
                },
                {
                    "type": "weapon",
                    "name": "Gun",
                    "price": 50
                }
            ]
        },
        {
            "name": "LicensedVillain",
            "team": "NEUTRAL",
            "hex": "#888888",
            "enabled": true,
            "passiveIncome": true,
            "taskIncome": 12,
            "baseInventory": [
                {
                    "type": "consumable",
                    "name": "Food"
                }
            ],
            "itemShop": [
                {
                    "type": "weapon",
                    "name": "Knife",
                    "price": 20
                },
                {
                    "type": "weapon",
                    "name": "Gun",
                    "price": 10
                },
                {
                    "type": "consumable",
                    "name": "Food",
                    "price": 10
                }
            ]
        },
        {
            "name": "Vigilante",
            "team": "CIVILIAN",
            "hex": "#FFD700",
            "enabled": true,
            "passiveIncome": true,
            "taskIncome": 50,
            "baseInventory": [
                {
                    "type": "weapon",
                    "name": "Gun"
                }
            ],
            "itemShop": [
                {
                    "type": "weapon",
                    "name": "Knife",
                    "price": 10
                },
                {
                    "type": "weapon",
                    "name": "Gun",
                    "price": 10
                },
                {
                    "type": "consumable",
                    "name": "Food",
                    "price": 10
                }
            ]
        },
        {
            "name": "Killer",
            "team": "KILLER",
            "hex": "#FF0000",
            "enabled": true,
            "passiveIncome": true,
            "taskIncome": 100,
            "baseInventory": [],
            "itemShop": [
                {
                    "type": "weapon",
                    "name": "Knife",
                    "price": 10
                },
                {
                    "type": "weapon",
                    "name": "Gun",
                    "price": 10
                }
            ]
        }
    ],
    "generalConfig": {
        "baseTimerMins": 3,
        "baseTimerSecs": 0,
        "incrementTimerOnKillInSeconds": 30,
        "killReward": 50,
        "passiveIncome": 50,
        "depressionData": {
            "baseDepression": 90,
            "baseSanity": 240
        }
    }
}
''';
  static ValueNotifier<String> modifiedConfig = ValueNotifier(standartConfig);

  static void updateSessionEndData(Map<String, dynamic> json) {
    gameEndDataNotifier.value = json;

    final str = json.toString();

    final matchWinnerTeam = RegExp(r'winnerTeam:\s*([^,]+),').firstMatch(str);
    final matchReason = RegExp(r'reason:\s*([^}]*)\}?').firstMatch(str);

    winnerTeam.value = matchWinnerTeam?.group(1)?.trim() ?? "Unknown";
    reason.value = matchReason?.group(1)?.trim() ?? "Unknown";
  }

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

  static void updateSanity(double sanity) {
    sanityNotifier.value = sanity.clamp(0.0, 1.0);
  }

  static void updateDepression(double depression) {
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
