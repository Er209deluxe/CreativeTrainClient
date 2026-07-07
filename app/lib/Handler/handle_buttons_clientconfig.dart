import 'package:creativetrainclient/Handler/handle_client_api_requests.dart';
import 'package:creativetrainclient/configs/UI/standartm3edesign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

bool validateInput(int? validationType, String pInput) {
  // 0 DomainValidation | 1 IP validation
  //Extract Textinput
  switch (validationType) {
    case 0: //Domain
      final RegExp domainRegex = RegExp(
        r'^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$',
      );

      return domainRegex.hasMatch(pInput.toLowerCase());
    case 1: //IP
      final RegExp ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}\:\d{0,6}$');
      print(pInput);

      return ipRegex.hasMatch(pInput.toLowerCase());
  }
  return false;
}

class DomainPressAction extends StatefulWidget {
  final int? actionNr;
  const DomainPressAction({super.key, required this.actionNr});

  @override
  State<DomainPressAction> createState() => _DomainPressActionState();
}

class _DomainPressActionState extends State<DomainPressAction> {
  final _domainInput = TextEditingController();
  final _ipInput1 = TextEditingController();
  final _ipInput2 = TextEditingController();
  final _ipInput3 = TextEditingController();
  final _ipInput4 = TextEditingController();
  final _portInput = TextEditingController();

  @override
  void dispose() {
    _domainInput.dispose();
    _ipInput1.dispose();
    _ipInput2.dispose();
    _ipInput3.dispose();
    _ipInput4.dispose();
    _portInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.actionNr == 1) {
      return Column(
        children: [
          Row(
            // IP address input
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // or start, end, center
            children: [
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  maxLength: 3,
                  style: const TextStyle(color: Colors.white),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: _ipInput1,
                  decoration: InputDecoration(
                    labelText: '0',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextField(
                  maxLength: 3,
                  style: const TextStyle(color: Colors.white),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: _ipInput2,
                  decoration: InputDecoration(
                    labelText: '-',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextField(
                  maxLength: 3,
                  style: const TextStyle(color: Colors.white),
                  controller: _ipInput3,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: '256',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextField(
                  maxLength: 3,
                  controller: _ipInput4,
                  style: const TextStyle(color: Colors.white),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'IP',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                ':',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextField(
                  maxLength: 5,
                  style: const TextStyle(color: Colors.white),
                  controller: _portInput,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Port',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
          M3EButton(
            onPressed: () {
              // Merge ip inputs and validate
              String ip1 = _ipInput1.text;
              String ip2 = _ipInput2.text;
              String ip3 = _ipInput3.text;
              String ip4 = _ipInput4.text;
              String port = _portInput.text;
              if (port == '') {
                port = '8080';
              }

              String ipAdress = '$ip1.$ip2.$ip3.$ip4:$port';
              if (validateInput(1, ipAdress)) {
                // valid ip address
                validInput(0, context, ipAdress);
              } else {
                // invalid ip address
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return ErrorDialogM3E(
                      errorHeader: 'Invalid IP-Adress',
                      errorText:
                          'Please input a Valid IP-Adress for e.g. 192.178.5.21. If no Port is given the Client will try 8080',
                    );
                  },
                );
              }
            },
            decoration: M3EButtonDecoration(),
            size: M3EButtonSize.lg,
            child: const Text(
              'Test Connection',
              style: TextStyle(fontSize: 22),
            ),
          ),
        ],
      );
    } else if (widget.actionNr == 0) {
      return Column(
        children: [
          Row(
            // Domain name input
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // or start, end, center
            children: [
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  maxLength: 100,
                  controller: _domainInput,
                  style: const TextStyle(color: Colors.white),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z.0-9]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'example.com',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 16),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
          M3EButton(
            // Testing Domain Connection
            onPressed: () {
              String domainName = _domainInput.text;
              if (validateInput(0, domainName)) {
                // Valid Domain Name
                validInput(1, context, domainName);
              } else {
                // Invalid Domain name
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return ErrorDialogM3E(
                      errorHeader: 'Invalid Domain Name',
                      errorText:
                          'Please input a valid domain Name for e.g. example.com',
                    );
                  },
                );
              }
            },
            decoration: M3EButtonDecoration(),
            size: M3EButtonSize.lg,
            child: const Text(
              'Test Connection',
              style: TextStyle(fontSize: 22),
            ),
          ),
        ],
      );
    } else {
      return Row();
    }
  }
}

class ErrorDialogM3E extends StatefulWidget {
  final String errorHeader;
  final String errorText;

  const ErrorDialogM3E({
    super.key,
    required this.errorHeader,
    required this.errorText,
  });

  @override
  State<ErrorDialogM3E> createState() => _ErrorDialogM3EState();
}

class _ErrorDialogM3EState extends State<ErrorDialogM3E> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 16.0,
      backgroundColor: const Color.fromARGB(255, 34, 68, 117),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.errorHeader,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.errorText,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TestConnectionButton extends StatelessWidget {
  const TestConnectionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 3, 59, 143),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            M3EHeader(headerText: 'Testing Connection...'),
          ],
        ),
      ),
    );
  }
}

class CircleLoadingUI extends StatefulWidget {
  final bool showLoadingIndicator;
  const CircleLoadingUI({super.key, required this.showLoadingIndicator});

  @override
  State<CircleLoadingUI> createState() => CircleLoadingState();
}

class CircleLoadingState extends State<CircleLoadingUI> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 3, 59, 143),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showLoadingIndicator)
              const CircularProgressIndicator(color: Colors.blue)
            else
              Icon(Icons.check, color: Colors.green),
            const SizedBox(height: 16),
            const M3EHeader(headerText: 'Testing Connection...'),
          ],
        ),
      ),
    );
  }
}

Future<dynamic> testConnection(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CircleLoadingUI(showLoadingIndicator: true);
    },
  );
}

Future<void> validInput(
  int pConnectionType,
  BuildContext context,
  String pUrl,
) async {
  testConnection(context);
  switch (pConnectionType) {
    case 0: // Domain
      CircleLoadingUI(showLoadingIndicator: true);
      if (await handleTestConnectionToServer(pUrl)) {}
      break;
    case 1: // IP
      break;
  }
}
