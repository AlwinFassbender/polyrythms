import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:polyrythms/poly_rythms.dart';
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
      initialRoute: "/",
      title: 'Flutter Demo',
      routes: {
        MyHomePage.destination: (context) => const MyHomePage(),
        RainbowPendulum.destination: (context) => const RainbowPendulum(),
        PolyRythms.destination: (context) => const PolyRythms(),
      },
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'RubikMonoOne',
        primaryColor: Colors.white,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  static const destination = "/";

  static const padding = 24.0;
  static const spacing = 16.0;

  static const nCols = 2;

  const MyHomePage({super.key});

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
          icon: PolygonIcon(width: iconSize),
          destination: PolyRythms.destination,
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
      painter: CirclePainter(width: width),
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

class PolygonIcon extends StatelessWidget {
  final double width;
  const PolygonIcon({required this.width, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...{2, 4, 6}.map(
          (rythm) => CustomPaint(
            painter: PolygonPainter(
                rythm: rythm, radius: width / 2, strokeWidth: width / 20),
          ),
        ),
      ],
    );
  }
}
