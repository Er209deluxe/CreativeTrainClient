import 'dart:async';
import 'dart:math' as math;

import 'package:creativetrainclient/Handler/NfcPeer.dart';
import 'package:creativetrainclient/Handler/handle_client_api_requests.dart';
import 'package:creativetrainclient/UI/render_homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedSplashPage extends StatefulWidget {
  const AnimatedSplashPage({super.key});

  @override
  State<AnimatedSplashPage> createState() =>
      _AnimatedSplashPageState();
}

class _AnimatedSplashPageState
    extends State<AnimatedSplashPage>
    with TickerProviderStateMixin {

  late final AnimationController _waveCtrl;
  late final AnimationController _glowCtrl;

  bool _checkingNfc = false;

  bool _showLogo = false;
  bool _showText = false;

  @override
  void initState() {
    super.initState();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    Future<void>.delayed(
      const Duration(milliseconds: 300),
          () {
        if (!mounted) return;

        setState(() {
          _showLogo = true;
        });
      },
    );

    Future<void>.delayed(
      const Duration(milliseconds: 800),
          () {
        if (!mounted) return;

        setState(() {
          _showText = true;
        });
      },
    );

    Future<void>.delayed(
      const Duration(seconds: 10),
          () async {
        if (!mounted) return;

        await _checkNfcAndContinue();
      },
    );
  }

  Future<void> _checkNfcAndContinue() async {
    if (_checkingNfc) {
      return;
    }

    _checkingNfc = true;

    bool isAvailable = false;
    String? error;

    try {
      /*
       * NfcPeer now returns a bool.
       *
       * true  = NFC hardware exists AND NFC is enabled
       * false = NFC unavailable OR NFC disabled
       */
      isAvailable =
      await NfcPeer.isNfcAvailable();

    } catch (e) {
      error = e.toString();
    }

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'NFC Status',
          ),
          content: Text(
            error != null
                ? 'Could not check NFC availability.\n\n$error'
                : isAvailable
                ? 'NFC is available and enabled on this device.'
                : 'NFC is not available or is disabled on this device.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _glowCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media =
    MediaQuery.of(context);

    final shortestSide =
        media.size.shortestSide;

    final logoSize =
    math.min(
      160.0,
      shortestSide * .34,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          /// Gradient Background
          const _GradientBG(),

          /// Animated Transition
          AnimatedBuilder(
            animation: _waveCtrl,
            builder: (context, _) {
              return CustomPaint(
                painter: _WavePaint(
                  progress:
                  _waveCtrl.value,
                ),
              );
            },
          ),

          /// Content
          Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.center,
              mainAxisSize:
              MainAxisSize.min,
              children: [

                /// Logo Fade In
                AnimatedOpacity(
                  opacity:
                  _showLogo ? 1 : 0,
                  duration:
                  const Duration(
                    milliseconds: 700,
                  ),
                  curve:
                  Curves.easeInOut,
                  child: SplashLogo(
                    size: logoSize,
                    glowValue:
                    _glowCtrl.value,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                /// Animated Text
                AnimatedOpacity(
                  opacity:
                  _showText ? 1 : 0,
                  duration:
                  const Duration(
                    milliseconds: 600,
                  ),
                  curve:
                  Curves.easeInOut,
                  child: const SplashTexts(
                    appName:
                    'CTC v1',
                    description:
                    'A CreativeTrain Client for a self hosted Game',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/// Splash Text
class SplashTexts
    extends StatelessWidget {

  const SplashTexts({
    super.key,
    required this.appName,
    required this.description,
  });

  final String appName;
  final String description;

  @override
  Widget build(
      BuildContext context,
      ) {
    final TextTheme textTheme =
        Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [

        Text(
          appName,
          textAlign:
          TextAlign.center,
          style:
          textTheme.displaySmall?.copyWith(
            color:
            Colors.white,
            fontWeight:
            FontWeight.w700,
            letterSpacing:
            1.2,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Text(
          description,
          textAlign:
          TextAlign.center,
          style:
          textTheme.displaySmall?.copyWith(
            color:
            const Color(0xFFB794C8),
            letterSpacing:
            0.6,
            fontWeight:
            FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


/// Animated Logo
class SplashLogo
    extends StatelessWidget {

  const SplashLogo({
    super.key,
    required this.size,
    required this.glowValue,
  });

  final double size;
  final double glowValue;

  @override
  Widget build(
      BuildContext context,
      ) {
    return AnimatedContainer(
      width: size,
      height: size,
      duration:
      const Duration(
        milliseconds: 600,
      ),
      curve:
      Curves.easeInOut,
      decoration:
      const BoxDecoration(
        shape:
        BoxShape.circle,
      ),
      child: SizedBox(
        width:
        size * .9,
        height:
        size * .9,
        child: CircleAvatar(
          backgroundColor:
          Colors.white.withValues(
            alpha: 0.05,
          ),
          child: ClipRRect(
            borderRadius:
            BorderRadius.circular(25),
            child: Image.asset(
              'assets/images/icon.png',
              fit:
              BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}


/// Gradient Background
class _GradientBG
    extends StatelessWidget {

  const _GradientBG();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      decoration:
      const BoxDecoration(
        gradient:
        LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            Color.fromARGB(
              255,
              215,
              90,
              78,
            ),
            Color.fromARGB(
              255,
              249,
              17,
              237,
            ),
            Color.fromARGB(
              255,
              51,
              94,
              212,
            ),
          ],
        ),
      ),
    );
  }
}


/// Animated Waves
class _WavePaint
    extends CustomPainter {

  _WavePaint({
    required this.progress,
  });

  final double progress;

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final Paint paint1 =
    Paint()
      ..color =
      Colors.white.withValues(
        alpha: .06,
      )
      ..style =
          PaintingStyle.fill;

    final Paint paint2 =
    Paint()
      ..color =
      Colors.white.withValues(
        alpha: .04,
      )
      ..style =
          PaintingStyle.fill;

    final Path path1 =
    Path();

    final Path path2 =
    Path();

    final double amplitude1 =
        size.height * 0.06;

    final double amplitude2 =
        size.height * 0.04;

    final double yBase1 =
        size.height * 0.72;

    final double yBase2 =
        size.height * 0.78;

    path1.moveTo(
      0,
      yBase1,
    );

    path2.moveTo(
      0,
      yBase2,
    );

    for (
    double x = 0;
    x <= size.width;
    x += 2
    ) {
      final double t =
          (x / size.width) *
              2 *
              math.pi;

      final double y1 =
          yBase1 +
              math.sin(
                t +
                    progress *
                        2 *
                        math.pi,
              ) *
                  amplitude1;

      final double y2 =
          yBase2 +
              math.sin(
                t * 1.5 +
                    progress *
                        2 *
                        math.pi,
              ) *
                  amplitude2;

      path1.lineTo(
        x,
        y1,
      );

      path2.lineTo(
        x,
        y2,
      );
    }

    path1
      ..lineTo(
        size.width,
        size.height,
      )
      ..lineTo(
        0,
        size.height,
      )
      ..close();

    path2
      ..lineTo(
        size.width,
        size.height,
      )
      ..lineTo(
        0,
        size.height,
      )
      ..close();

    canvas.drawPath(
      path1,
      paint1,
    );

    canvas.drawPath(
      path2,
      paint2,
    );
  }

  @override
  bool shouldRepaint(
      covariant _WavePaint oldDelegate,
      ) {
    return oldDelegate.progress !=
        progress;
  }
}