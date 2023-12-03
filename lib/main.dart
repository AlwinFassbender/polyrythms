import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:polyrythms/screens/box_metronome.dart';
import 'package:polyrythms/screens/circle_metronome.dart';
import 'package:polyrythms/screens/poly_rythms.dart';
import 'package:polyrythms/screens/rainbow_pendulum.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:polyrythms/gen/assets.gen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      title: 'Flutter Demo',
      routes: {
        HomeScreen.destination: (context) => const HomeScreen(),
        RainbowPendulum.destination: (context) => const RainbowPendulum(),
        PolyRythms.destination: (context) => const PolyRythms(),
        CircleMetronome.destination: (context) => const CircleMetronome(),
        BoxMetronome.destination: (context) => const BoxMetronome(),
      },
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'RubikMonoOne',
        primaryColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  static const destination = "/";

  static const padding = 24.0;
  static const spacing = 16.0;
  static const nCols = 2;

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;
    final paddingVertical =
        height >= width ? (height - width) / 2 + padding : padding;
    final paddingHorizontal =
        width >= height ? (width - height) / 2 + padding : padding;

    final iconSize =
        (width - 2 * paddingHorizontal - (nCols - 1) * spacing) / 4;

    return Scaffold(
        body: Center(
            child: GridView(
      padding: EdgeInsets.symmetric(
        vertical: paddingVertical,
        horizontal: paddingHorizontal,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: nCols,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      children: [
        Page(
          icon: RainbowIcon(width: iconSize),
          destination: RainbowPendulum.destination,
        ),
        Page(
          icon: _PolygonIcon(width: iconSize),
          destination: PolyRythms.destination,
        ),
        Page(
          icon: _MetronomeIcon(width: iconSize),
          destination: CircleMetronome.destination,
        ),
        Page(
          icon: _BoxIcon(width: iconSize),
          destination: BoxMetronome.destination,
        ),
      ],
    )));
  }
}

class Page extends StatelessWidget {
  final Widget icon;
  final String destination;

  const Page({super.key, required this.icon, required this.destination});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(destination);
      },
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(24)),
            color: Colors.black),
        child: Center(child: icon),
      ),
    );
  }
}

class RainbowIcon extends StatelessWidget {
  final double width;
  const RainbowIcon({required this.width, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RainbowPainter(width: width),
    );
  }
}

class RainbowPainter extends CustomPainter {
  final double width;
  const RainbowPainter({required this.width});

  static const numItems = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final smallestRadius = width / 4;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = _iconStrokeWidth(width)
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < numItems; i++) {
      final offset = (width - smallestRadius) / numItems;

      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(0, width / 4),
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

class _MetronomeIcon extends StatelessWidget {
  final double width;
  const _MetronomeIcon({required this.width});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter:
              CirclePainter(width / 2, strokeWidth: _iconStrokeWidth(width)),
        ),
        CustomPaint(
          painter: MetronomePointPainter(
            radius: width / 2,
            elapsedTimeInMs: 6000,
            numItems: 666,
            circleRadius: _iconStrokeWidth(width) / 2,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}

class _BoxIcon extends StatelessWidget {
  final double width;
  const _BoxIcon({required this.width});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: RectanglePainter(
            width: width,
            height: width * 9 / 16,
            strokeWidth: _iconStrokeWidth(width),
          ),
        ),
        CustomPaint(
          painter: DVDLogoPainter(
            timePassedInMs: 301000,
            height: width * 9 / 16,
            width: width,
            velocityY: 0.0028,
            velocityX: 0.001,
            strokeWidth: _iconStrokeWidth(width),
            showDot: false,
          ),
        ),
      ],
    );
  }
}

class _PolygonIcon extends StatelessWidget {
  final double width;
  const _PolygonIcon({required this.width});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...{4, 8}.map(
          (rythm) => CustomPaint(
            painter: PolygonPainter(
                rythm: rythm,
                radius: width / 2,
                strokeWidth: _iconStrokeWidth(width)),
          ),
        ),
      ],
    );
  }
}

double _iconStrokeWidth(double width) => width / 20;
