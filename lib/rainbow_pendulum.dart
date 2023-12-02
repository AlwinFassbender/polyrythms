import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:polyrythms/functions/calculate_radius.dart';

const colors = [
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

final _numItems = colors.length;

double calculateYOffset(double radius) {
  return radius / 3;
}

class RainbowPendulum extends StatelessWidget {
  static const destination = "rainbow-pendulum";

  const RainbowPendulum({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = calculateRadius(MediaQuery.sizeOf(context));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            StaticWidget(radius),
            MovingWidget(radius),
          ],
        ),
      ),
    );
  }
}

class MovingWidget extends StatefulWidget {
  final double radius;
  const MovingWidget(this.radius, {super.key});

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

    for (int i = 0; i < _numItems; i++) {
      final durationInMs = 1 ~/ _calculateVelocity(i);
      soundTimers
          .add(Timer.periodic(Duration(milliseconds: durationInMs), (timer) {
        print("playing key $i");
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PointPainter(widget.radius, elapsedTimeInMs: elapsedTimeInMs),
    );
  }
}

class PointPainter extends CustomPainter {
  final int elapsedTimeInMs;
  final double radius;
  const PointPainter(this.radius, {required this.elapsedTimeInMs});

  @override
  void paint(Canvas canvas, Size size) {
    final yOffSet = calculateYOffset(radius);

    for (int i = 0; i < colors.length; i++) {
      final velocity = _calculateVelocity(i);
      final angle = math.pi * elapsedTimeInMs * velocity;
      // Keep points between 1pi and 0pi
      final modAngle = angle % (math.pi * 2);
      final adjustedAngle =
          modAngle <= math.pi ? math.pi * 2 - modAngle : modAngle;

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final arcRadius = _calculateArcRadius(i, radius);

      final x = math.cos(adjustedAngle) * arcRadius;
      final y = math.sin(adjustedAngle) * arcRadius + yOffSet;

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

double _calculateArcRadius(int index, double radius) {
  final offset = radius * 0.8 / _numItems;
  return radius * 0.2 + offset * (index + 1);
}

double _calculateVelocity(int index) {
  return (math.pi * 2 * (20 - index / 4)) / (1000 * 900);
}

class StaticWidget extends StatelessWidget {
  final double radius;

  const StaticWidget(this.radius, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArcPainter(radius),
    );
  }
}

class ArcPainter extends CustomPainter {
  final double radius;

  const ArcPainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final yOffSet = calculateYOffset(radius);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(Offset(-radius, yOffSet), Offset(radius, yOffSet), paint);

    for (int i = 0; i < _numItems; i++) {
      final arcRadius = _calculateArcRadius(i, radius);

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(0, yOffSet),
          width: arcRadius * 2,
          height: arcRadius * 2,
        ),
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
