import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:polyrythms/rainbow_pendulum.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: GridView(
      padding: const EdgeInsets.all(24.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16.0,
      ),
      children: const [
        Page(
          icon: StaticWidget(),
          route: RainbowPendulum.route,
        ),
        Page(
          icon: StaticWidget(),
          route: RainbowPendulum.route,
        ),
        Page(
          icon: StaticWidget(),
          route: RainbowPendulum.route,
        ),
        Page(
          icon: StaticWidget(),
          route: RainbowPendulum.route,
        ),
      ],
    )));
  }
}

class Page extends StatelessWidget {
  final Widget icon;
  final Route Function() route;

  const Page({super.key, required this.icon, required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(route());
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(24)),
            color: Colors.black),
        child: Center(child: icon),
      ),
    );
  }
}

class StaticWidget extends StatelessWidget {
  const StaticWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CirclePainter(width: MediaQuery.sizeOf(context).width / 5),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double width;
  const CirclePainter({required this.width});

  static const numItems = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final smallestRadius = width / 4;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = width / 20
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < numItems; i++) {
      final offset = (width - smallestRadius) / numItems;

      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(0, width / 3),
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
