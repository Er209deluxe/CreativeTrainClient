import 'dart:math' as math;

import 'package:creativetrainclient/UI/renderHomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedSplashPage extends StatefulWidget {
  const AnimatedSplashPage({super.key});

  @override
  State<AnimatedSplashPage> createState() => _AnimatedSplashPageState();
}

class _AnimatedSplashPageState extends State<AnimatedSplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;
  late final AnimationController _glowCtrl;

  bool _showLogo = false;
  bool _showText = false;

  @override
  void initState() {
    _waveCtrl = AnimationController(vsync: this, duration: Duration(seconds: 8))
      ..repeat(reverse: true);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    Future<void>.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showLogo = true;
        });
      }
    });

    Future<void>.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showText = true;
        });
      }
    });

    //Navigate(Switch) After Delay to home Page
    Future<void>.delayed(Duration(seconds: 3), () async {
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(CupertinoPageRoute(builder: (_) => HomePage()));
    });
    super.initState();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final shortestSide = media.size.shortestSide;
    final logoSize = math.min(160.0, shortestSide * .34);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Gradient Background
          _GradientBG(),
          //Animated Transition
          AnimatedBuilder(
            animation: _waveCtrl,
            builder: (context, _) =>
                CustomPaint(painter: _WavePaint(progress: _waveCtrl.value)),
          ),

          //Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                //Logo Fade in and out
                AnimatedOpacity(
                  opacity: _showLogo ? 1 : 0,
                  duration: Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  child: SplashLogo(
                    size: logoSize,
                    glowValue: _glowCtrl.value,
                  ), //test
                ),
                SizedBox(height: 10),
                //Animated Text
                AnimatedOpacity(
                  opacity: _showText ? 1 : 0,
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  child: SplashTexts(
                    appName: 'CTC',
                    description: 'A CreativeTrain Client for a selfhosted Game',
                  ), //test
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//Splash Text class
class SplashTexts extends StatelessWidget {
  const SplashTexts({
    super.key,
    required this.appName,
    required this.description,
  });

  final String appName;
  final String description;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          appName,
          textAlign: TextAlign.center,
          style: textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          description,
          textAlign: TextAlign.center,
          style: textTheme.displaySmall?.copyWith(
            color: const Color(0xFFB794C8),
            letterSpacing: 0.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

//Logo Animated
class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key, required this.size, required this.glowValue});

  final double size;
  final double glowValue;

  @override
  Widget build(BuildContext context) {
    final double blur = 18 + glowValue * 28;
    final double spread = 2 + glowValue + 10;
    final Color glowColor = Color(
      0xFF7B2CBF,
    ).withValues(alpha: (.55 + glowValue * .25).clamp(0.0, 1.0));
    return AnimatedContainer(
      width: size,
      height: size,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: SizedBox(
        width: size * .9,
        height: size * .9,
        child: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset('assets/images/icon.png', fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

// Gradient Background
class _GradientBG extends StatelessWidget {
  const _GradientBG();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 215, 90, 78),
            Color.fromARGB(255, 249, 17, 237),
            Color.fromARGB(255, 51, 94, 212),
          ],
        ),
      ),
    );
  }
}

class _WavePaint extends CustomPainter {
  _WavePaint({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Layer waves
    final Paint paint1 = Paint()
      ..color = Colors.white.withValues(alpha: .06)
      ..style = PaintingStyle.fill;
    final Paint paint2 = Paint()
      ..color = Colors.white.withValues(alpha: .04)
      ..style = PaintingStyle.fill;

    final Path path1 = Path();
    final Path path2 = Path();

    final double amplitude1 = size.height * 0.06;
    final double amplitude2 = size.height * 0.04;

    final double yBase1 = size.height * 0.72;
    final double yBase2 = size.height * 0.78;

    path1.moveTo(0, yBase1);
    path2.moveTo(0, yBase2);

    for (double x = 0; x <= size.width; x += 2) {
      final double t = (x / size.width) * 2 * math.pi;
      final double y1 =
          yBase1 + math.sin(t + progress * 2 * math.pi) * amplitude1;
      final double y2 =
          yBase2 + math.sin(t * 1.5 + progress * 2 * math.pi) * amplitude2;

      path1.lineTo(x, y1);
      path2.lineTo(x, y2);
    }

    path1
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    path2
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WavePaint oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
