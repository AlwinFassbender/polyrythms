import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:polyrythms/functions/calculate_radius.dart';
import 'package:polyrythms/functions/pad_with_zeros.dart';
import 'package:polyrythms/functions/slider_functions.dart';
import 'package:polyrythms/screens/rainbow_pendulum.dart';
import 'package:polyrythms/widgets/control_toggle.dart';
import 'package:polyrythms/widgets/selection_container.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:soundpool/soundpool.dart';

class CircleMetronome extends StatelessWidget {
  static const destination = "rainbow-pendulum";

  final Soundpool soundpool;

  const CircleMetronome(this.soundpool, {super.key});

  static Route route(Soundpool pool) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: destination),
      builder: (_) => CircleMetronome(pool),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: setAssets(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done || data == null) {
          return const SizedBox.shrink();
        }
        return CircleMetronomeScreen(soundIds: data, soundpool: soundpool);
      },
    );
  }

  Future<List<int>> setAssets() async {
    // https://github.com/patchandthat/wave-generator could be used to generate the sounds, but the package is very outdated.
    // Could be cool to set the frequencies yourself though
    final List<int> soundIds = [];

    // It seems like this package is not able to handle this many sounds at once, so we leave this out for now
    //   for (int i = 1; i <= _numItems; i++) {
    //     soundIds.add(await soundpool.load(await rootBundle.load("assets/sound/frequencies/tone-$i.wav")));
    //   }
    return soundIds;
  }
}

class CircleMetronomeScreen extends StatefulWidget {
  static const destination = "circle-metronome";

  const CircleMetronomeScreen({required this.soundpool, required this.soundIds, super.key});

  final Soundpool soundpool;
  final List<int> soundIds;

  @override
  State<CircleMetronomeScreen> createState() => _CircleMetronomeScreenState();
}

class _CircleMetronomeScreenState extends State<CircleMetronomeScreen> {
  DateTime startTime = DateTime.now();
  double _velocityDelta = 0.99;
  double _velocityFactor = 10000;
  int _numItems = 250;

  bool _showControls = false;

  @override
  Widget build(BuildContext context) {
    final radius = calculateRadius(MediaQuery.sizeOf(context)) * 0.8;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          ControlToggle((active) => setState(() => _showControls = active)),
          if (_showControls)
            _RythmSelector(
              onConfirm: (velocityDelta, velocityFactor, numItems) {
                setState(() {
                  startTime = DateTime.now();
                  _velocityDelta = velocityDelta;
                  _velocityFactor = velocityFactor;
                  _numItems = numItems;
                });
              },
              velocityDelta: _velocityDelta,
              velocityFactor: _velocityFactor,
              numItems: _numItems,
            ),
          Expanded(
            child: Center(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  _StaticWidget(radius),
                  _MovingWidget(
                    radius: radius,
                    startTime: startTime,
                    soundpool: widget.soundpool,
                    sounds: widget.soundIds,
                    velocityDelta: _velocityDelta,
                    velocityFactor: _velocityFactor,
                    numItems: _numItems,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RythmSelector extends StatefulWidget {
  final void Function(double velocityDelta, double velocityFactor, int numItems) onConfirm;
  final double velocityDelta;
  final double velocityFactor;
  final int numItems;

  const _RythmSelector({
    required this.onConfirm,
    required this.velocityDelta,
    required this.velocityFactor,
    required this.numItems,
  });

  @override
  State<_RythmSelector> createState() => _RythmSelectorState();
}

class _RythmSelectorState extends State<_RythmSelector> {
  late double _velocityFactor;
  late double _velocityDelta;
  late int _numItems;

  double get _factorSliderValue => normalizeValue(_velocityFactor, _minFactor, _maxFactor);
  double get _deltaSliderValue => normalizeValue(_velocityDelta, _minDelta, _maxDelta);
  double get _numItemsSliderValue => normalizeValue(_numItems, _minItems, _maxItems);

  final double _minFactor = 1000;
  final double _maxFactor = 100000;

  final int _maxItems = 1000;
  final int _minItems = 1;

  final double _minDelta = 0.01;
  final double _maxDelta = 0.99;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(covariant _RythmSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    init();
  }

  void init() {
    _velocityFactor = widget.velocityFactor;
    _velocityDelta = widget.velocityDelta;
    _numItems = widget.numItems;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("velocity factor", style: TextStyle(fontSize: 12)),
              Row(
                children: [
                  Text(padWithZeros(_velocityFactor ~/ _minFactor, _maxFactor ~/ _minFactor)),
                  Padding(
                    padding: const EdgeInsets.only(right: 32.0),
                    child: Slider(
                      value: _factorSliderValue,
                      onChanged: (value) => setState(
                        () {
                          _velocityFactor = scaleValue(value, _minFactor, _maxFactor);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("velocity delta", style: TextStyle(fontSize: 12)),
              Row(
                children: [
                  Text(_velocityDelta.toStringAsFixed(2)),
                  Padding(
                    padding: const EdgeInsets.only(right: 32.0),
                    child: Slider(
                      value: _deltaSliderValue,
                      onChanged: (value) => setState(
                        () {
                          _velocityDelta = scaleValue(value, _minDelta, _maxDelta);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("dots", style: TextStyle(fontSize: 12)),
              Row(
                children: [
                  Text(padWithZeros(_numItems, _maxItems)),
                  Padding(
                    padding: const EdgeInsets.only(right: 32.0),
                    child: Slider(
                      value: _numItemsSliderValue,
                      onChanged: (value) => setState(
                        () {
                          _numItems = scaleValue(value, _minItems, _maxItems) ~/ 1;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SelectContainer(
              onTap: () => widget.onConfirm(_velocityDelta, _velocityFactor, _numItems),
              child: const Center(
                child: Text(
                  "Set",
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _MovingWidget extends StatefulWidget {
  final double radius;
  final DateTime startTime;
  final Soundpool soundpool;
  final List<int> sounds;
  final double velocityFactor;
  final double velocityDelta;
  final int numItems;
  const _MovingWidget({
    required this.radius,
    required this.startTime,
    required this.soundpool,
    required this.sounds,
    required this.velocityFactor,
    required this.velocityDelta,
    required this.numItems,
  });

  @override
  State<_MovingWidget> createState() => _MovingWidgetState();
}

class _MovingWidgetState extends State<_MovingWidget> {
  final startTime = DateTime.now();
  int elapsedTimeInMs = 0;
  late Timer renderTimer;
  final List<Timer> soundTimers = [];

  @override
  void dispose() {
    super.dispose();
    cancelTimers();
  }

  @override
  void didUpdateWidget(covariant _MovingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    cancelTimers();
    init();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    renderTimer = Timer.periodic(const Duration(milliseconds: 1000 ~/ 60), (timer) {
      if (!mounted) return;
      setState(() {
        elapsedTimeInMs = DateTime.now().difference(widget.startTime).inMilliseconds;
      });
    });

    for (int i = 0; i < widget.sounds.length; i++) {
      final durationInMs = widget.radius *
          2 ~/
          _calculateVelocity(i, widget.radius, widget.velocityFactor, widget.velocityDelta, widget.numItems);

      Future.delayed(Duration(milliseconds: durationInMs ~/ 2), () {
        print("playing sound $i");
        widget.soundpool.play(widget.sounds[i]);
        soundTimers.add(
          Timer.periodic(
            Duration(milliseconds: durationInMs),
            (timer) {
              print("playing sound $i");
              widget.soundpool.play(widget.sounds[i]);
            },
          ),
        );
      });
    }
  }

  void cancelTimers() {
    renderTimer.cancel();
    for (final timer in soundTimers) {
      timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MetronomePointPainter(
        radius: widget.radius,
        elapsedTimeInMs: elapsedTimeInMs,
        velocityDelta: widget.velocityDelta,
        velocityFactor: widget.velocityFactor,
        numItems: widget.numItems,
      ),
    );
  }
}

class MetronomePointPainter extends CustomPainter {
  final double radius;
  final int elapsedTimeInMs;
  final int numItems;
  final double circleRadius;
  final double velocityFactor;
  final double velocityDelta;
  final Color? color;

  MetronomePointPainter({
    required this.elapsedTimeInMs,
    required this.radius,
    required this.numItems,
    required this.velocityDelta,
    required this.velocityFactor,
    this.circleRadius = 7,
    this.color,
  });

  final rainbow = Rainbow(spectrum: colors);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < numItems; i++) {
      final velocity = _calculateVelocity(i, radius, velocityFactor, velocityDelta, numItems);
      final angle = (2 * math.pi) / numItems * i;
      final distance = velocity * elapsedTimeInMs;
      final distanceInsideCircle = calculateDistanceInsideCircle(distance, radius);

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

double _calculateVelocity(int index, double radius, double velocityFactor, double velocityDelta, int itemCount) {
  // Points must travel 4 times the radius to complete one cycle
  // We want the rythm to complete one cycle in 900 seconds
  final cycleCompletionFactor = 4 * radius;

  // Each point has its own speed. The speed difference between the fastest and the slowest point should be
  // The first point should be the fastest, the last point the slowest
  final indexFactor = (1 - (index + 1) / itemCount * velocityDelta);

  // The speed factor is a number chosen to make the points move at a reasonable speed
  final velocityFactorInverse = 1 / velocityFactor;

  return cycleCompletionFactor * indexFactor * velocityFactorInverse;
}

class _StaticWidget extends StatelessWidget {
  final double radius;
  const _StaticWidget(this.radius);

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
        center: const Offset(0, 0),
        width: 2 * radius,
        height: 2 * radius,
      ),
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
