import 'package:flutter/services.dart';

class NfcTags {
  static const MethodChannel _channel =
  MethodChannel('nfc_peer');

  // ============================================================
  // SESSION UUID TAG
  // ============================================================

  static Future<void> setSessionUuid(
      String sessionUuid,
      ) async {
    await _channel.invokeMethod(
      'setSessionUuid',
      {
        'sessionUuid': sessionUuid,
      },
    );
  }

  static Future<void> clearSessionUuid() async {
    await _channel.invokeMethod(
      'clearSessionUuid',
    );
  }

  // ============================================================
  // PLAYER INFO TAG
  // ============================================================

  static Future<void> setPlayerInfo({
    required String playerUuid,
    required String challenge,
  }) async {
    await _channel.invokeMethod(
      'setPlayerInfo',
      {
        'playerUuid': playerUuid,
        'challenge': challenge,
      },
    );
  }

  static Future<void> clearPlayerInfo() async {
    await _channel.invokeMethod(
      'clearPlayerInfo',
    );
  }

  // ============================================================
  // ALL TAGS
  // ============================================================

  static Future<void> clearAll() async {
    await _channel.invokeMethod(
      'clearTags',
    );
  }
}