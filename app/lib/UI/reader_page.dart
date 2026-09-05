import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  static const MethodChannel _channel = MethodChannel('nfc_peer');

  bool _readerRunning = false;
  bool _reading = false;

  String? _tagType;
  String? _jsonText;
  String? _error;

  @override
  void initState() {
    super.initState();

    _channel.setMethodCallHandler(_handleNativeMessage);
  }

  Future<dynamic> _handleNativeMessage(MethodCall call) async {
    if (call.method != 'nfcMessage') {
      return null;
    }

    final value = call.arguments;

    // New native format:
    //
    // {
    //   "type": "sessionUuid",
    //   "json": "{\"sessionUuid\":\"...\"}"
    // }
    //
    // or:
    //
    // {
    //   "type": "playerInfo",
    //   "json": "{\"playerUuid\":\"...\",\"challenge\":\"...\"}"
    // }

    if (value is Map) {
      final type = value['type'];
      final json = value['json'];

      if (json is String) {
        _displayJson(
          json,
          type is String ? type : null,
        );
      }
    }

    // Backwards compatibility if native sends just a String.
    else if (value is String) {
      _displayJson(value, null);
    }

    return null;
  }

  void _displayJson(String value, String? type) {
    if (!mounted) {
      return;
    }

    setState(() {
      _reading = false;
      _error = null;
      _tagType = type;
      _jsonText = value;
    });
  }

  Future<void> _startReader() async {
    try {
      setState(() {
        _readerRunning = true;
        _reading = true;
        _error = null;
        _tagType = null;
        _jsonText = null;
      });

      await _channel.invokeMethod('startReader');
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _readerRunning = false;
        _reading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _stopReader() async {
    try {
      await _channel.invokeMethod('stopReader');

      if (!mounted) {
        return;
      }

      setState(() {
        _readerRunning = false;
        _reading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = e.toString();
      });
    }
  }

  void _clearResult() {
    setState(() {
      _tagType = null;
      _jsonText = null;
      _error = null;
      _reading = false;
    });
  }

  String _prettyJson(String value) {
    try {
      final decoded = jsonDecode(value);

      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return value;
    }
  }

  String _tagTitle() {
    switch (_tagType) {
      case 'sessionUuid':
        return 'Session UUID';

      case 'playerInfo':
        return 'Player Info';

      default:
        return 'NFC Data';
    }
  }

  IconData _tagIcon() {
    switch (_tagType) {
      case 'sessionUuid':
        return Icons.key;

      case 'playerInfo':
        return Icons.person;

      default:
        return Icons.nfc;
    }
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);

    // Don't await this here because dispose() cannot be async.
    _channel.invokeMethod('stopReader');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Reader'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Icon(
                _tagIcon(),
                size: 80,
                color: _readerRunning
                    ? theme.colorScheme.primary
                    : Colors.grey,
              ),

              const SizedBox(height: 24),

              Text(
                _readerRunning
                    ? 'Reader is active'
                    : 'Reader is stopped',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),

              const SizedBox(height: 12),

              Text(
                _reading
                    ? 'Hold this phone against the NFC device...'
                    : _jsonText != null
                    ? 'NFC data received'
                    : 'Press Start Reader and hold this phone against the HCE phone.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),

              const SizedBox(height: 32),

              if (_reading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Waiting for NFC...'),
                  ],
                ),

              if (_jsonText != null) ...[
                Row(
                  children: [
                    Text(
                      'Received Tag',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (_tagType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _tagType!,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  _tagTitle(),
                  style: theme.textTheme.headlineSmall,
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _prettyJson(_jsonText!),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: _clearResult,
                  child: const Text('Clear'),
                ),
              ] else if (_error != null) ...[
                const SizedBox(height: 16),

                Text(
                  'Error',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _error!,
                  textAlign: TextAlign.center,
                ),
              ],

              if (_jsonText == null)
                const Spacer(),

              if (!_readerRunning)
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _startReader,
                    icon: const Icon(Icons.contactless),
                    label: const Text('Start NFC Reader'),
                  ),
                )
              else
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _stopReader,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop NFC Reader'),
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}