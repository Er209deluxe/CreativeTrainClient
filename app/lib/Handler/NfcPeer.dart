import 'dart:convert';

import 'package:flutter/services.dart';

class NfcPeer {
  static const MethodChannel _channel =
  MethodChannel('nfc_peer');

  static void Function(
      String type,
      String json,
      )? _messageHandler;

  static bool _handlerRegistered = false;

  static void setMessageHandler(
      void Function(
          String type,
          String json,
          )? handler,
      ) {
    _messageHandler = handler;

    if (_handlerRegistered) {
      return;
    }

    _handlerRegistered = true;

    _channel.setMethodCallHandler(
      _handleNativeMessage,
    );
  }

  static Future<dynamic> _handleNativeMessage(
      MethodCall call,
      ) async {
    if (call.method != 'nfcMessage') {
      return null;
    }

    final arguments = call.arguments;

    print('NFC MESSAGE: $arguments');

    if (arguments is! Map) {
      return null;
    }

    final type = arguments['type'];
    final json = arguments['json'];

    if (type is! String || json is! String) {
      return null;
    }

    _messageHandler?.call(
      type,
      json,
    );

    return null;
  }

  // ------------------------------------------------------------
  // SESSION UUID
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // PLAYER INFO
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // CLEAR EVERYTHING
  // ------------------------------------------------------------

  static Future<void> clear() async {
    await _channel.invokeMethod(
      'clearTags',
    );
  }

  // ------------------------------------------------------------
  // HCE
  // ------------------------------------------------------------

  static Future<void> start() async {
    await _channel.invokeMethod(
      'startEmulator',
    );
  }

  static Future<void> stop() async {
    await _channel.invokeMethod(
      'stopEmulator',
    );
  }

  // ------------------------------------------------------------
  // READER
  // ------------------------------------------------------------

  static Future<void> startReader() async {
    await _channel.invokeMethod(
      'startReader',
    );
  }

  static Future<void> stopReader() async {
    await _channel.invokeMethod(
      'stopReader',
    );
  }

  // ------------------------------------------------------------
  // PARSING
  // ------------------------------------------------------------

  static String? parseSessionUuid(
      String json,
      ) {
    try {
      final decoded = jsonDecode(json);

      if (decoded is! Map) {
        return null;
      }

      final uuid = decoded['sessionuuid'];

      if (uuid is String && uuid.isNotEmpty) {
        return uuid;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static PlayerInfo? parsePlayerInfo(
      String json,
      ) {
    try {
      final decoded = jsonDecode(json);

      if (decoded is! Map) {
        return null;
      }

      final playerUuid = decoded['playeruuid'];
      final challenge = decoded['challenge'];

      if (playerUuid is! String ||
          challenge is! String) {
        return null;
      }

      return PlayerInfo(
        playerUuid: playerUuid,
        challenge: challenge,
      );
    } catch (_) {
      return null;
    }
  }
}

class PlayerInfo {
  final String playerUuid;
  final String challenge;

  const PlayerInfo({
    required this.playerUuid,
    required this.challenge,
  });
}