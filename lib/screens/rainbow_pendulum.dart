import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polyrythms/functions/calculate_radius.dart';
import 'package:polyrythms/functions/slider_functions.dart';
import 'package:polyrythms/widgets/control_toggle.dart';
import 'package:polyrythms/widgets/selection_container.dart';
import 'package:soundpool/soundpool.dart';

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

const _radiusDelta = 0.8;
final _numItems = colors.length;

double calculateYOffset(double radius) {
  return radius / 3;
}

class RainbowPendulum extends StatelessWidget {
  static const destination = "rainbow-pendulum";

  final Soundpool soundpool;

  const RainbowPendulum(this.soundpool, {super.key});

  static Route route(Soundpool pool) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: destination),
      builder: (_) => RainbowPendulum(pool),
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
        return RainbowPendulumScreen(soundIds: data, soundpool: soundpool);
      },
    );
  }

  Future<List<int>> setAssets() async {
    final List<int> soundIds = [];
    for (int i = 1; i <= _numItems; i++) {
      soundIds.add(await soundpool.load(await rootBundle.load('assets/sound/key-$i.wav')));
    }
    return soundIds;
  }
}

class RainbowPendulumScreen extends StatefulWidget {
  const RainbowPendulumScreen({required this.soundpool, required this.soundIds, super.key});

  final Soundpool soundpool;
  final List<int> soundIds;

  @override
  State<RainbowPendulumScreen> createState() => _RainbowPendulumScreenState();
}

class _RainbowPendulumScreenState extends State<RainbowPendulumScreen> {
  double _velocityDelta = 0.20;
  double _velocityFactor = 50;

  DateTime _startTime = DateTime.now();
  bool _showControls = false;

  @override
  Widget build(BuildContext context) {
    final radius = calculateRadius(MediaQuery.sizeOf(context));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          ControlToggle((active) => setState(() => _showControls = active)),
          if (_showControls)
            _RythmSelector(
              velocityDelta: _velocityDelta,
              velocityFactor: _velocityFactor,
              onConfirm: (velocityDelta, velocityFactor) {
                setState(() {
                  _velocityDelta = velocityDelta;
                  _velocityFactor = velocityFactor;
                  _startTime = DateTime.now();
                });
              },
            ),
          Expanded(
            child: Center(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  _StaticWidget(radius),
                  _MovingWidget(
                    key: ValueKey("$_startTime-$_velocityDelta-$_velocityFactor"),
                    startTime: _startTime,
                    radius: radius,
                    velocityFactor: _velocityFactor,
                    velocityDelta: _velocityDelta,
                    soundpool: widget.soundpool,
                    sounds: widget.soundIds,
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
  final void Function(double velocityDelta, double velocity) onConfirm;
  final double velocityDelta;
  final double velocityFactor;

  const _RythmSelector({
    required this.onConfirm,
    required this.velocityDelta,
    required this.velocityFactor,
  });

  @override
  State<_RythmSelector> createState() => _RythmSelectorState();
}

class _RythmSelectorState extends State<_RythmSelector> {
  final pow = 4;

  late double _velocityFactor = widget.velocityFactor;
  late double _velocityDelta = widget.velocityDelta;

  double get _factorSliderValue => normalizeValue(math.pow(_velocityFactor, 1 / pow), _minPowFactor, _maxPowFactor);
  double get _deltaSliderValue => normalizeValue(_velocityDelta, _minDelta, _maxDelta);

  final double _minFactor = 1;
  final double _maxFactor = 1000;
  double get _minPowFactor => math.pow(_minFactor, 1 / pow).toDouble();
  double get _maxPowFactor => math.pow(_maxFactor, 1 / pow).toDouble();

  final double _minDelta = 0.01;
  final double _maxDelta = 0.99;

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
                  Text(padWithZeros(_velocityFactor.toInt(), _maxFactor)),
                  Padding(
                    padding: const EdgeInsets.only(right: 32.0),
                    child: Slider(
                      value: _factorSliderValue,
                      onChanged: (value) => setState(
                        () {
                          _velocityFactor =
                              math.pow(scaleValue(value, _minPowFactor, _maxPowFactor), pow).round().toDouble();
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SelectContainer(
              onTap: () => widget.onConfirm(_velocityDelta, _velocityFactor),
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
  final List<int> sounds;
  final Soundpool soundpool;
  final double velocityFactor;
  final double velocityDelta;
  final DateTime startTime;

  const _MovingWidget({
    super.key,
    required this.sounds,
    required this.radius,
    required this.soundpool,
    required this.velocityFactor,
    required this.velocityDelta,
    required this.startTime,
  });

  @override
  State<_MovingWidget> createState() => _MovingWidgetState();
}

class _MovingWidgetState extends State<_MovingWidget> {
  int elapsedTimeInMs = 0;
  late Timer renderTimer;
  final List<Timer> soundTimers = [];

  @override
  void dispose() {
    super.dispose();
    cancelTimers();
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

    for (int i = 0; i < _numItems; i++) {
      final durationInMs = 1 ~/ _calculateVelocity(i, _numItems, widget.velocityFactor, widget.velocityDelta);
      soundTimers.add(
        Timer.periodic(
          Duration(milliseconds: durationInMs),
          (timer) {
            widget.soundpool.play(widget.sounds[i]);
          },
        ),
      );
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
      painter: PointPainter(
        radius: widget.radius,
        elapsedTimeInMs: elapsedTimeInMs,
        velocityDelta: widget.velocityDelta,
        velocityFactor: widget.velocityFactor,
      ),
    );
  }
}

class PointPainter extends CustomPainter {
  final int elapsedTimeInMs;
  final double radius;
  final double velocityFactor;
  final double velocityDelta;
  const PointPainter({
    required this.radius,
    required this.elapsedTimeInMs,
    required this.velocityFactor,
    required this.velocityDelta,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final yOffSet = calculateYOffset(radius);

    for (int i = 0; i < colors.length; i++) {
      final velocity = _calculateVelocity(i, _numItems, velocityFactor, velocityDelta);
      final angle = math.pi * elapsedTimeInMs * velocity;
      // Keep points between 1pi and 0pi
      final modAngle = angle % (math.pi * 2);
      final adjustedAngle = modAngle <= math.pi ? math.pi * 2 - modAngle : modAngle;

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      final arcRadius = _calculateArcRadius(i, radius);

      final x = math.cos(adjustedAngle) * arcRadius;
      final y = math.sin(adjustedAngle) * arcRadius + yOffSet;

      canvas.drawCircle(
        Offset(x, y),
        0.5 * _radiusDelta * radius / _numItems,
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
  final offset = radius * _radiusDelta / _numItems;
  return radius * (1 - _radiusDelta) + offset * (index + 1);
}

double _calculateVelocity(
  int index,
  int itemCount,
  double velocityFactor,
  double velocityDelta,
) {
  return (math.pi * 2 * (1 - (index + 1) / itemCount * velocityDelta)) / (1000 * velocityFactor);
}

class _StaticWidget extends StatelessWidget {
  final double radius;

  const _StaticWidget(this.radius);

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
