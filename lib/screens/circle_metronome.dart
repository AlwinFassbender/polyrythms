import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:polyrythms/functions/calculate_radius.dart';
import 'package:polyrythms/screens/rainbow_pendulum.dart';
import 'package:rainbow_color/rainbow_color.dart';

const _numItems = 250;

class CircleMetronome extends StatelessWidget {
  static const destination = "circle-metronome";

  const CircleMetronome({super.key});

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
        ));
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

    // 60 fps
    renderTimer =
        Timer.periodic(const Duration(milliseconds: 1000 ~/ 60), (timer) {
      setState(() {
        elapsedTimeInMs = DateTime.now().difference(startTime).inMilliseconds;
      });
    });

    for (int i = 0; i < _numItems; i++) {
      final durationInMs =
          (widget.radius * 2) ~/ _calculateVelocity(i, widget.radius);
      Future.delayed(Duration(milliseconds: durationInMs), () {
        soundTimers
            .add(Timer.periodic(Duration(milliseconds: durationInMs), (timer) {
          print("playing key $i");
        }));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MetronomePointPainter(
          radius: widget.radius, elapsedTimeInMs: elapsedTimeInMs),
    );
  }
}

class MetronomePointPainter extends CustomPainter {
  final double radius;
  final int elapsedTimeInMs;
  final int numItems;
  final double circleRadius;
  final Color? color;

  MetronomePointPainter({
    required this.elapsedTimeInMs,
    required this.radius,
    this.numItems = _numItems,
    this.circleRadius = 7,
    this.color,
  });

  final rainbow = Rainbow(spectrum: colors);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < numItems; i++) {
      final velocity = _calculateVelocity(i, radius);
      final angle = (2 * math.pi) / numItems * i;
      final distance = velocity * elapsedTimeInMs;
      final distanceInsideCircle =
          calculateDistanceInsideCircle(distance, radius);

      final x = distanceInsideCircle * math.cos(angle);
      final y = distanceInsideCircle * math.sin(angle);

      final paint = Paint()
        ..color = color != null ? color! : rainbow[i / numItems]
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        circleRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

double calculateDistanceInsideCircle(double distance, double radius) {
  final cutoff = distance % (4 * radius);
  if (cutoff > 3 * radius) {
    return (cutoff) - 4 * radius;
  } else if (cutoff > radius) {
    return 2 * radius - cutoff;
  } else {
    return cutoff;
  }
}

double _calculateVelocity(int index, double radius) {
  // Points must travel 4 times the radius to complete one cycle
  // We want the rythm to complete one cycle in 900 seconds
  final cycleCompletionFactor = 4 * radius / 900;

  // Each point has its own speed. The speed difference between the fastest and the slowest point should be
  // The first point should be the fastest, the last point the slowest
  final indexFactor = _numItems * 10 - index * 9;

  // The speed factor is a number chosen to make the points move at a reasonable speed
  const speedFactor = 1 / 20000;

  return cycleCompletionFactor * indexFactor * speedFactor;
}

class StaticWidget extends StatelessWidget {
  final double radius;
  const StaticWidget(this.radius, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CirclePainter(radius),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  const CirclePainter(this.radius, {this.strokeWidth = 2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCenter(
          center: const Offset(0, 0), width: 2 * radius, height: 2 * radius),
      0,
      2 * math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
