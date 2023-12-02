import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RainbowPendulum extends StatelessWidget {
  static const destination = "rainbow-pendulum";

  const RainbowPendulum({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              StaticWidget(),
              MovingWidget(),
            ],
          ),
        ));
  }
}

class MovingWidget extends StatefulWidget {
  const MovingWidget({super.key});

  @override
  State<MovingWidget> createState() => _MovingWidgetState();
}

class _MovingWidgetState extends State<MovingWidget> {
  final startTime = DateTime.now();
  int elapsedTimeInMs = 0;
  late Timer renderTimer;
  final List<Timer> soundTimers = [];

  @override
  void dispose() {
    super.dispose();
    renderTimer.cancel();
    for (final timer in soundTimers) {
      timer.cancel();
    }
  }

  @override
  void initState() {
    super.initState();

    renderTimer =
        Timer.periodic(const Duration(milliseconds: 1000 ~/ 60), (timer) {
      setState(() {
        elapsedTimeInMs = DateTime.now().difference(startTime).inMilliseconds;
      });
    });

    for (int i = 0; i < CirclePainter.numItems; i++) {
      final durationInMs = 1 ~/ calculateVelocity(i);
      soundTimers
          .add(Timer.periodic(Duration(milliseconds: durationInMs), (timer) {
        print("playing key $i");
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PointPainter(elapsedTimeInMs: elapsedTimeInMs),
    );
  }
}

class PointPainter extends CustomPainter {
  final int elapsedTimeInMs;

  const PointPainter({required this.elapsedTimeInMs});

  static const colors = [
    Color(0xFFD0E7F5),
    Color(0xFFD9E7F4),
    Color(0xFFD6E3F4),
    Color(0xFFBCDFF5),
    Color(0xFFB7D9F4),
    Color(0xFFC3D4F0),
    Color(0xFF9DC1F3),
    Color(0xFF9AA9F4),
    Color(0xFF8D83EF),
    Color(0xFFAE69F0),
    Color(0xFFD46FF1),
    Color(0xFFDB5AE7),
    Color(0xFFD911DA),
    Color(0xFFD601CB),
    Color(0xFFE713BF),
    Color(0xFFF24CAE),
    Color(0xFFFB79AB),
    Color(0xFFFFB6C1),
    Color(0xFFFED2CF),
    Color(0xFFFDDFD5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < colors.length; i++) {
      final velocity = calculateVelocity(i);
      final angle = math.pi * elapsedTimeInMs * velocity;
      // Keep points between 1pi and 0pi
      final modAngle = angle % (math.pi * 2);
      final adjustedAngle =
          modAngle <= math.pi ? math.pi * 2 - modAngle : modAngle;

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final radius = calculateRadius(i);

      final x = math.cos(adjustedAngle) * radius;
      final y = math.sin(adjustedAngle) * radius + CirclePainter.yOffSet;

      canvas.drawCircle(
        Offset(x, y),
        7,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

double calculateRadius(int index) {
  const offset = (CirclePainter.width - CirclePainter.smallestRadius) /
      (CirclePainter.numItems * 2);
  return CirclePainter.smallestRadius / 2 + offset * (index + 1);
}

double calculateVelocity(int index) {
  return (math.pi * 2 * (20 - index / 4)) / (1000 * 900);
}

class StaticWidget extends StatelessWidget {
  const StaticWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: CirclePainter(),
    );
  }
}

class CirclePainter extends CustomPainter {
  const CirclePainter();

  static const width = 1000.0;
  static const smallestRadius = 200.0;
  static const numItems = 20;

  /// The y offset of the center of the circle relative to the center of the screen
  /// Because we only show the top half of the circle, it doesnt feel centered
  static const yOffSet = width / 6;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(-width / 2, yOffSet),
        const Offset(width / 2, yOffSet), paint);

    for (int i = 0; i < numItems; i++) {
      const offset = (width - smallestRadius) / numItems;

      canvas.drawArc(
        Rect.fromCenter(
            center: const Offset(0, yOffSet),
            width: width - offset * i,
            height: width - offset * i),
        math.pi,
        math.pi,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
