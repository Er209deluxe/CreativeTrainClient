import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class NfcPeer {
  static const MethodChannel _channel =
  MethodChannel('nfc_peer');

  final StreamController<Map<String, dynamic>> _messages =
  StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages =>
      _messages.stream;

  // ============================================================
  // HCE / EMULATOR
  // ============================================================

  Future<void> startEmulator() async {
    await _channel.invokeMethod(
      'startEmulator',
    );
  }

  Future<void> stopEmulator() async {
    await _channel.invokeMethod(
      'stopEmulator',
    );
  }

  // ============================================================
  // READER
  // ============================================================

  Future<void> startReader() async {
    await _channel.invokeMethod(
      'startReader',
    );
  }

  Future<void> stopReader() async {
    await _channel.invokeMethod(
      'stopReader',
    );
  }

  // ============================================================
  // SEND
  // ============================================================

  Future<Map<String, dynamic>?> send(
      Map<String, dynamic> message,
      ) async {
    final result =
    await _channel.invokeMethod<String>(
      'send',
      {
        'json': jsonEncode(message),
      },
    );

    if (result == null) {
      return null;
    }

    return jsonDecode(result)
    as Map<String, dynamic>;
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  void dispose() {
    _messages.close();
  }

  static Future<String?> readSessionUuid() {
    return _channel.invokeMethod<String>('readSessionUuid');
  }

  static Future<String?> readPlayerInfo() {
    return _channel.invokeMethod<String>('readPlayerInfo');
  }
}