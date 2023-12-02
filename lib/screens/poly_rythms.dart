import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

const _period = 8000;
const _polygonRadius = 200.0;

const rythms = {
  2: Info(color: Colors.blue, sound: "none"),
  3: Info(color: Colors.green, sound: "none"),
  4: Info(color: Colors.yellow, sound: "none"),
  5: Info(color: Colors.red, sound: "none"),
  6: Info(color: Colors.purple, sound: "none"),
  8: Info(color: Colors.teal, sound: "none")
};

class Info {
  final Color color;
  final String sound;

  const Info({
    required this.color,
    required this.sound,
  });
}

class PolyRythms extends StatefulWidget {
  static const destination = "poly-rythms";

  const PolyRythms({super.key});

  @override
  State<PolyRythms> createState() => _PolyRythmsState();
}

class _PolyRythmsState extends State<PolyRythms> {
  final startTime = DateTime.now();
  final List<Timer> soundTimers = [];
  final activeRythms = <int>{rythms.keys.elementAt(1)};

  @override
  void dispose() {
    super.dispose();
    for (final timer in soundTimers) {
      timer.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    for (final i in rythms.keys) {
      final durationInMs = _period ~/ i;
      soundTimers
          .add(Timer.periodic(Duration(milliseconds: durationInMs), (timer) {
        if (activeRythms.contains(i)) {
          print("playing key $i");
        }
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...rythms.keys.map((key) => RythmSelector(
                      rythm: key,
                      active: activeRythms.contains(key),
                      onTap: selectRythm))
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    ...activeRythms.map((rythm) => PolygonWidget(
                          rythm: rythm,
                        )),
                    ...activeRythms.map((rythm) => RythmWidget(
                          rythm: rythm,
                          startTime: startTime,
                        ))
                    // const RythmWidget(),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  void selectRythm(int rythm) {
    setState(() {
      if (activeRythms.contains(rythm)) {
        activeRythms.remove(rythm);
      } else {
        activeRythms.add(rythm);
      }
    });
  }
}

class RythmSelector extends StatelessWidget {
  final int rythm;
  final bool active;
  final void Function(int) onTap;

  const RythmSelector(
      {super.key,
      required this.rythm,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final info = rythms[rythm]!;
    final color = active ? info.color : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: GestureDetector(
        onTap: () => onTap(rythm),
        child: Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: color,
                blurRadius: 4.0,
                spreadRadius: 2.0,
              )
            ],
          ),
          child: Center(
            child: Text(
              "$rythm",
              style: TextStyle(fontSize: 20, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class RythmWidget extends StatefulWidget {
  final int rythm;
  final DateTime startTime;
  const RythmWidget({super.key, required this.rythm, required this.startTime});

  @override
  State<RythmWidget> createState() => _RythmWidgetState();
}

class _RythmWidgetState extends State<RythmWidget> {
  late Timer renderTimer;

  /// Between 0 and 1
  double state = 0;

  @override
  void dispose() {
    super.dispose();
    renderTimer.cancel();
  }

  @override
  void initState() {
    super.initState();

    // 60 fps
    renderTimer =
        Timer.periodic(const Duration(milliseconds: 1000 ~/ 60), (timer) {
      setState(() {
        state = (DateTime.now().difference(widget.startTime).inMilliseconds %
            _period /
            _period);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RythmPainter(state: state, rythm: widget.rythm),
    );
  }
}

class RythmPainter extends CustomPainter {
  final double state;
  final int rythm;

  const RythmPainter({required this.state, required this.rythm});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = rythms[rythm]!.color
      ..style = PaintingStyle.fill;

    final velocity = perimeterOfShape(_polygonRadius, rythm);
    final distance = velocity * state;

    final position = positionFromDistance(distance, rythm);

    canvas.drawCircle(
      Offset(position.dx, position.dy),
      20,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

double perimeterOfShape(double radius, int rythm) {
  final sideLength = sideLengthOfShape(radius, rythm);
  return sideLength * rythm;
}

double sideLengthOfShape(double radius, int rythm) {
  return 2 * radius * math.sin(math.pi / rythm);
}

Offset positionFromDistance(double distance, int rythm) {
  final sideLength = sideLengthOfShape(_polygonRadius, rythm);
  final positionOnSide = distance % sideLength;
  final sideIndex = distance ~/ sideLength;
  final previousIndex = sideIndex == 0 ? rythm - 1 : sideIndex - 1;
  final offset = getOffset(rythm, sideIndex, _polygonRadius);
  final previousOffset = getOffset(rythm, previousIndex, _polygonRadius);

  final x = previousOffset.dx +
      (offset.dx - previousOffset.dx) * positionOnSide / sideLength;
  final y = previousOffset.dy +
      (offset.dy - previousOffset.dy) * positionOnSide / sideLength;
  return Offset(x, y);
}

class PolygonWidget extends StatelessWidget {
  final int rythm;
  const PolygonWidget({super.key, required this.rythm});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PolygonPainter(rythm: rythm),
    );
  }
}

class PolygonPainter extends CustomPainter {
  final int rythm;
  final double radius;
  final double strokeWidth;
  const PolygonPainter({
    required this.rythm,
    this.radius = _polygonRadius,
    this.strokeWidth = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final startOffset = getOffset(rythm, 0, radius);
    path.moveTo(startOffset.dx, startOffset.dy);

    for (int i = 1; i <= rythm; i++) {
      final endOffset = getOffset(rythm, i, radius);
      path.lineTo(endOffset.dx, endOffset.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

Offset getOffset(int rythm, int index, double radius) {
  final angle = (2 * math.pi / rythm) * index + math.pi / 2;
  final x = math.cos(angle) * radius;
  final y = math.sin(angle) * radius;

  return Offset(x, y);
}
