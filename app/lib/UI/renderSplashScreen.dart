import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AnimatedSplashPage extends StatefulWidget {
  const AnimatedSplashPage({super.key});

  @override
  State<AnimatedSplashPage> createState() => _AnimatedSplashPageState();
}

class _AnimatedSplashPageState extends State<AnimatedSplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;

  @override
  void initState() {
    _waveCtrl = AnimationController(vsync: this, duration: Duration(seconds: 8))
      ..repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              //Logo Fade in and out
              AnimatedOpacity(
                opacity: 1,
                duration: Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                child: SplashLogo(
                  size: logoSize,
                  glowValue: _waveCtrl.value,
                ), //test
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//Logo
class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key, required this.size, required this.glowValue});

  final double size;
  final double glowValue;

  @override
  Widget build(BuildContext context) {
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
          child: ClipRect(
            // borderRadius: BorderRadius.circular(100),
            child: Image.asset('assets/images/icon.png', fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

// Gradient Background
class _GradientBG extends StatelessWidget {
  const _GradientBG({super.key});

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
