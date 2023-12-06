import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polyrythms/functions/slider_functions.dart';
import 'package:polyrythms/widgets/control_toggle.dart';
import 'package:polyrythms/widgets/selection_container.dart';
import 'package:soundpool/soundpool.dart';

const _polygonRadius = 200.0;

/// In milliseconds
double periodFromBpm(int bpm) {
  return 2 * 60 * 1000 / bpm;
}

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

class PolyRythms extends StatelessWidget {
  static const destination = "poly-rythms";
  final Soundpool soundpool;

  const PolyRythms(this.soundpool, {super.key});

  static Route route(Soundpool pool) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: destination),
      builder: (_) => PolyRythms(pool),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, int>>(
      future: setAssets(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done || data == null) {
          return const SizedBox.shrink();
        }
        return PolyRythmsScreen(soundIds: data, soundpool: soundpool);
      },
    );
  }

  Future<Map<int, int>> setAssets() async {
    final Map<int, int> soundIds = {};
    for (final i in rythms.keys) {
      soundIds[i] = await soundpool.load(await rootBundle.load('assets/sound/synth-$i.wav'));
    }
    return soundIds;
  }
}

class PolyRythmsScreen extends StatefulWidget {
  final Soundpool soundpool;
  final Map<int, int> soundIds;
  const PolyRythmsScreen({required this.soundIds, required this.soundpool, super.key});

  @override
  State<PolyRythmsScreen> createState() => _PolyRythmsScreenState();
}

class _PolyRythmsScreenState extends State<PolyRythmsScreen> {
  DateTime _startTime = DateTime.now();
  final List<Timer> _soundTimers = [];
  final _activeRythms = <int>{rythms.keys.elementAt(1), rythms.keys.elementAt(2), rythms.keys.elementAt(3)};

  int _bpm = 40;

  bool _showControls = false;

  double get _bpmSliderValue => normalizeValue(_bpm, _minbpm, _maxbpm);

  final _maxbpm = 200;
  final _minbpm = 1;

  @override
  void dispose() {
    super.dispose();
    cancelTimers();
  }

  @override
  void initState() {
    super.initState();
    setTimers();
  }

  void setTimers() {
    _startTime = DateTime.now();
    for (final i in rythms.keys) {
      final durationInMs = periodFromBpm(_bpm) ~/ i;
      _soundTimers.add(Timer.periodic(Duration(milliseconds: durationInMs), (timer) {
        if (_activeRythms.contains(i)) {
          widget.soundpool.play(widget.soundIds[i]!);
        }
      }));
    }
  }

  void cancelTimers() {
    for (final timer in _soundTimers) {
      timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            ControlToggle((active) => setState(() => _showControls = active)),
            if (_showControls)
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("bpm", style: TextStyle(fontSize: 12)),
                            Row(
                              children: [
                                Text(padWithZeros(_bpm, _maxbpm)),
                                Padding(
                                  padding: const EdgeInsets.only(right: 32.0),
                                  child: Slider(
                                    value: _bpmSliderValue,
                                    onChanged: (value) => setState(
                                      () {
                                        _bpm = scaleValue(value, _minbpm, _maxbpm).toInt();
                                        cancelTimers();
                                        setTimers();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...rythms.keys.map((key) =>
                            _RythmSelector(rythm: key, active: _activeRythms.contains(key), onTap: _selectRythm))
                      ],
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    ..._activeRythms.map(
                      (rythm) => _StaticWidget(
                        rythm: rythm,
                      ),
                    ),
                    ..._activeRythms.map(
                      (rythm) => _MovingWidget(
                        rythm: rythm,
                        bpm: _bpm,
                        startTime: _startTime,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  void _selectRythm(int rythm) {
    setState(() {
      if (_activeRythms.contains(rythm)) {
        _activeRythms.remove(rythm);
      } else {
        _activeRythms.add(rythm);
      }
    });
  }
}

class _RythmSelector extends StatelessWidget {
  final int rythm;
  final bool active;
  final void Function(int) onTap;

  const _RythmSelector({required this.rythm, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final info = rythms[rythm]!;
    final color = active ? info.color : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: SelectContainer(
        onTap: () => onTap(rythm),
        shadowColor: color,
        child: Center(
          child: Text(
            "$rythm",
            style: TextStyle(fontSize: 20, color: color),
          ),
        ),
      ),
    );
  }
}

class _MovingWidget extends StatefulWidget {
  final int rythm;
  final int bpm;
  final DateTime startTime;

  const _MovingWidget({
    required this.rythm,
    required this.startTime,
    required this.bpm,
  });

  @override
  State<_MovingWidget> createState() => _MovingWidgetState();
}

class _MovingWidgetState extends State<_MovingWidget> {
  late Timer _renderTimer;

  double get _period => periodFromBpm(widget.bpm);

  /// Between 0 and 1
  double _state = 0;

  @override
  void dispose() {
    super.dispose();
    _renderTimer.cancel();
  }

  @override
  void initState() {
    super.initState();

    // 60 fps
    _renderTimer = Timer.periodic(const Duration(milliseconds: 1000 ~/ 60), (timer) {
      setState(() {
        _state = (DateTime.now().difference(widget.startTime).inMilliseconds % _period / _period);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RythmPainter(state: _state, rythm: widget.rythm),
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
  final previousIndex = distance ~/ sideLength;
  final sideIndex = previousIndex == rythm - 1 ? 0 : previousIndex + 1;
  final offset = getOffset(rythm, sideIndex, _polygonRadius);
  final previousOffset = getOffset(rythm, previousIndex, _polygonRadius);

  final x = previousOffset.dx + (offset.dx - previousOffset.dx) * positionOnSide / sideLength;
  final y = previousOffset.dy + (offset.dy - previousOffset.dy) * positionOnSide / sideLength;
  return Offset(x, y);
}

class _StaticWidget extends StatelessWidget {
  final int rythm;
  const _StaticWidget({required this.rythm});

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
    this.strokeWidth = 3,
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
  final angle = (2 * math.pi / rythm) * index - math.pi / 2;
  final x = math.cos(angle) * radius;
  final y = math.sin(angle) * radius;

  return Offset(x, y);
}
