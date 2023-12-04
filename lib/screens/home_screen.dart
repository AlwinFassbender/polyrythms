import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polyrythms/screens/box_metronome.dart';
import 'package:polyrythms/screens/circle_metronome.dart';
import 'package:polyrythms/screens/poly_rythms.dart';
import 'package:polyrythms/screens/rainbow_pendulum.dart';
import 'package:soundpool/soundpool.dart';

/// The circle icons look to big compared to the rectangular ones, that is why they are scaled down
const _circleIconScaleFactor = 0.85;

class SoundpoolInitializer extends StatefulWidget {
  const SoundpoolInitializer({super.key});

  @override
  SoundpoolInitializerState createState() => SoundpoolInitializerState();
}

class SoundpoolInitializerState extends State<SoundpoolInitializer> {
  Soundpool? _pool;
  SoundpoolOptions _soundpoolOptions = const SoundpoolOptions(streamType: StreamType.music);

  @override
  void initState() {
    super.initState();
    _initPool(_soundpoolOptions);
  }

  @override
  Widget build(BuildContext context) {
    if (_pool == null) {
      return const Material(
        child: Center(child: Text("failed to initialize sounds")),
      );
    } else {
      return HomeScreen(_pool!);
    }
  }

  void _initPool(SoundpoolOptions soundpoolOptions) {
    _pool?.dispose();
    setState(() {
      _soundpoolOptions = soundpoolOptions;
      _pool = Soundpool.fromOptions(options: _soundpoolOptions);
    });
  }
}

class HomeScreen extends StatelessWidget {
  final Soundpool pool;
  static const destination = "/";

  static const padding = 24.0;
  static const spacing = 16.0;
  static const nCols = 2;

  const HomeScreen(this.pool, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;
    final paddingVertical = height >= width ? (height - width) / 2 + padding : padding;
    final paddingHorizontal = width >= height ? (width - height) / 2 + padding : padding;

    final iconSize = (width - 2 * paddingHorizontal - (nCols - 1) * spacing) / 4;

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
          route: () => RainbowPendulum.route(pool),
        ),
        Page(
          icon: _PolygonIcon(width: iconSize),
          route: () => PolyRythms.route(pool),
        ),
        Page(
          icon: _MetronomeIcon(width: iconSize),
          route: () => CircleMetronome.route(pool),
        ),
        Page(
          icon: _BoxIcon(width: iconSize),
          route: () => BoxMetronome.route(pool),
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
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(24)), color: Colors.black),
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
        Rect.fromCenter(center: Offset(0, width / 4), width: width - offset * i, height: width - offset * i),
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
          painter: CirclePainter(width * _circleIconScaleFactor * 1.11 / 2, strokeWidth: _iconStrokeWidth(width)),
        ),
        CustomPaint(
          painter: MetronomePointPainter(
            velocityFactor: 12000,
            velocityDelta: 0.9,
            radius: width * _circleIconScaleFactor / 2,
            elapsedTimeInMs: 26650,
            numItems: 54,
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
            timePassedInMs: (width * 1000).toInt(),
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
                rythm: rythm, radius: width * _circleIconScaleFactor / 2, strokeWidth: _iconStrokeWidth(width)),
          ),
        ),
      ],
    );
  }
}

double _iconStrokeWidth(double width) => width / 20;
