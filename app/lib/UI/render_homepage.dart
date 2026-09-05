import 'package:creativetrainclient/Handler/handle_buttons_clientconfig.dart';
import 'package:creativetrainclient/UI/reader_page.dart';
import 'package:creativetrainclient/UI/render_clientconfig.dart';
import 'package:creativetrainclient/UI/render_registerconfig.dart';
import 'package:creativetrainclient/UI/reader_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GradientHomeBG(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                M3EButton(
                  size: M3EButtonSize.custom(
                    height: 140,
                    width: 310,
                  ),
                  decoration: M3EButtonDecoration.styleFrom(
                    backgroundColor:
                    const Color.fromARGB(255, 3, 59, 143),
                    foregroundColor:
                    const Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud, size: 50),
                      const SizedBox(width: 10),
                      Text(
                        'Server',
                        style: TextStyle(fontSize: 50),
                      ),
                    ],
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return ErrorDialogM3E(
                          errorHeader: 'Unavailable',
                          errorText: 'Coming soon...',
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                M3EButton(
                  size: M3EButtonSize.custom(
                    height: 140,
                    width: 310,
                  ),
                  decoration: M3EButtonDecoration.styleFrom(
                    backgroundColor:
                    const Color.fromARGB(255, 3, 59, 143),
                    foregroundColor:
                    const Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_android, size: 50),
                      const SizedBox(width: 10),
                      Text(
                        'Client',
                        style: TextStyle(fontSize: 50),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => ClientConfigPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // NFC READER BUTTON
                M3EButton(
                  size: M3EButtonSize.custom(
                    height: 140,
                    width: 310,
                  ),
                  decoration: M3EButtonDecoration.styleFrom(
                    backgroundColor:
                    const Color.fromARGB(255, 3, 59, 143),
                    foregroundColor:
                    const Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contactless,
                        size: 50,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Reader',
                        style: TextStyle(fontSize: 50),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const ReaderPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}