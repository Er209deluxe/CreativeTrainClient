import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class NfcPeer {
  static const MethodChannel _channel =
  MethodChannel('nfc_peer');

  static void Function(
      String json,
      )? _messageHandler;

  static bool _handlerRegistered = false;

  static void setMessageHandler(
      void Function(String json)? handler,
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

    final json = arguments['json'];

    if (json is! String) {
      return null;
    }

    _messageHandler?.call(json);

    return null;
  }
  static Future<bool> isNfcAvailable() async {
    try {
      final bool? available =
      await _channel.invokeMethod<bool>(
        'isNfcAvailable',
      );

      return available ?? false;
    } catch (e) {
      debugPrint(
        'Failed to check NFC availability: $e',
      );

      return false;
    }
  }
  // ------------------------------------------------------------
  // NFC DATA
  // ------------------------------------------------------------

  static Future<void> setSessionUuid(
      String? sessionUuid,
      ) async {
    await _channel.invokeMethod(
      'setSessionUuid',
      {
        'sessionUuid': sessionUuid,
      },
    );
  }

  static Future<void> setPlayerUuid(
      String? playerUuid,
      ) async {
    await _channel.invokeMethod(
      'setPlayerUuid',
      {
        'playerUuid': playerUuid,
      },
    );
  }

  static Future<void> setChallenge(
      String? challenge,
      ) async {
    await _channel.invokeMethod(
      'setChallenge',
      {
        'challenge': challenge,
      },
    );
  }

  static Future<void> clear() async {
    print("Cleared NFC tags");
    await _channel.invokeMethod(
      'clearTags',
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

  static NfcPeerData? parseData(String json) {
    try {
      final decoded = jsonDecode(json);

      if (decoded is! Map) {
        return null;
      }

      return NfcPeerData(
        sessionUuid: decoded['sessionuuid'] as String?,
        playerUuid: decoded['playeruuid'] as String?,
        challenge: decoded['challenge'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

class NfcPeerData {
  final String? sessionUuid;
  final String? playerUuid;
  final String? challenge;

  const NfcPeerData({
    this.sessionUuid,
    this.playerUuid,
    this.challenge,
  });
}