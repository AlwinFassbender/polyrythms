import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polyrythms/functions/calculate_radius.dart';
import 'package:polyrythms/functions/slider_functions.dart';
import 'package:polyrythms/gen/assets.gen.dart';
import 'package:polyrythms/widgets/control_toggle.dart';
import 'package:polyrythms/widgets/selection_container.dart';
import 'package:soundpool/soundpool.dart';

class Info {
  final Color color;
  final String sound;

  const Info({
    required this.color,
    required this.sound,
  });
}

class BoxMetronome extends StatelessWidget {
  static const destination = "box-metronome";

  final Soundpool soundpool;

  static Route route(Soundpool soundpool) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: destination),
      builder: (_) => BoxMetronome(soundpool),
    );
  }

  const BoxMetronome(this.soundpool, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: setAssets(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (snapshot.connectionState != ConnectionState.done || data == null) {
            return const SizedBox.shrink();
          }
          return BoxMetronomeScreen(soundpool: soundpool, soundIds: data);
        });
  }

  Future<List<int>> setAssets() async {
    final List<int> soundIds = [];
    var hihat = await rootBundle.load(Assets.sound.hiHat);
    var drumstick = await rootBundle.load(Assets.sound.drumstick);
    soundIds.addAll([
      await soundpool.load(hihat),
      await soundpool.load(drumstick),
    ]);
    return soundIds;
  }
}

class BoxMetronomeScreen extends StatefulWidget {
  final List<int> soundIds;
  final Soundpool soundpool;
  const BoxMetronomeScreen({required this.soundpool, required this.soundIds, super.key});

  @override
  State<BoxMetronomeScreen> createState() => _BoxMetronomeScreenState();
}

class _BoxMetronomeScreenState extends State<BoxMetronomeScreen> {
  double _velocity = 0.00025;
  int _verticalRythm = 69;
  int _horizontalRythm = 420;
  bool _showControls = false;
  DateTime _startTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final radius = calculateRadius(MediaQuery.sizeOf(context));
    final width = radius * 2;
    final height = radius * 2 * 9 / 16;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          ControlToggle((active) => setState(() => _showControls = active)),
          if (_showControls)
            _RythmSelector(
              active: true,
              verticalRythm: _verticalRythm,
              horizontalRythm: _horizontalRythm,
              velocity: _velocity,
              onConfirm: (verticalRythm, horizontalRythm, velocity) {
                setState(() {
                  _verticalRythm = verticalRythm;
                  _horizontalRythm = horizontalRythm;
                  _velocity = velocity;
                  _startTime = DateTime.now();
                });
              },
            ),
          Expanded(
            child: Center(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  _StaticWidget(width: width, height: height),
                  _MovingWidget(
                    key: ValueKey("$_verticalRythm-$_horizontalRythm-$_velocity-$width-$height-$_startTime"),
                    startTime: _startTime,
                    width: width,
                    height: height,
                    velocity: _velocity,
                    horizontalRythm: _horizontalRythm,
                    verticalRythm: _verticalRythm,
                    soundpool: widget.soundpool,
                    verticalSoundId: widget.soundIds[0],
                    horizontalSoundId: widget.soundIds[1],
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
  final bool active;
  final void Function(int verticalRythm, int horizontalRythm, double velocity) onConfirm;
  final int verticalRythm;
  final int horizontalRythm;
  final double velocity;

  const _RythmSelector({
    required this.active,
    required this.onConfirm,
    required this.verticalRythm,
    required this.horizontalRythm,
    required this.velocity,
  });

  @override
  State<_RythmSelector> createState() => _RythmSelectorState();
}

class _RythmSelectorState extends State<_RythmSelector> {
  late int _verticalRythm = widget.verticalRythm;
  late int _horizontalRythm = widget.horizontalRythm;

  late double _velocity = widget.velocity;

  double get _sliderValue => normalizeValue(math.log(_velocity), _minLog, _maxLog);

  final double _minVelocity = 0.00005;
  final double _maxVelocity = 0.005;

  double get _minLog => math.log(_minVelocity);
  double get _maxLog => math.log(_maxVelocity);

  late final maxDisplayValue = (1 * _maxVelocity) ~/ _minVelocity;

  int getDisplayValue(double velocity) {
    return (1 * velocity) ~/ _minVelocity;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(padWithZeros(getDisplayValue(_velocity), maxDisplayValue)),
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Slider(
              value: _sliderValue,
              onChanged: (value) => setState(
                () {
                  _velocity = math.exp(scaleValue(value, _minLog, _maxLog));
                },
              ),
            ),
          ),
          _RythmTextField(
              initialValue: widget.verticalRythm,
              onChanged: (p0) {
                setState(() {
                  _verticalRythm = p0;
                });
              }),
          _RythmTextField(
              initialValue: widget.horizontalRythm,
              onChanged: (p0) {
                setState(() {
                  _horizontalRythm = p0;
                });
              }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SelectContainer(
              onTap: () => widget.onConfirm(_verticalRythm, _horizontalRythm, _velocity),
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

class _RythmTextField extends StatelessWidget {
  final void Function(int) onChanged;
  final int initialValue;
  const _RythmTextField({required this.onChanged, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: SizedBox(
        width: 80,
        child: TextFormField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hoverColor: Colors.pinkAccent,
            focusColor: Colors.pinkAccent,
            labelText: "Rythm",
            hintText: "Rythm",
            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
          initialValue: "$initialValue",
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final rythm = int.tryParse(value);
            if (rythm != null) {
              onChanged(rythm);
            }
          },
        ),
      ),
    );
  }
}

class _MovingWidget extends StatefulWidget {
  final double width;
  final double height;
  final double velocity;
  final DateTime startTime;
  final int verticalRythm;
  final int horizontalRythm;
  final int verticalSoundId;
  final int horizontalSoundId;

  final Soundpool soundpool;
  const _MovingWidget({
    super.key,
    required this.height,
    required this.width,
    required this.velocity,
    required this.startTime,
    required this.horizontalRythm,
    required this.verticalRythm,
    required this.soundpool,
    required this.verticalSoundId,
    required this.horizontalSoundId,
  });

  @override
  State<_MovingWidget> createState() => _MovingWidgetState();
}

class _MovingWidgetState extends State<_MovingWidget> {
  late double width;
  late double height;

  late int horizontalRythm;
  late int verticalRythm;

  late double angleAlpha;
  late double angleBeta;

  late double velocityY;
  late double velocityX;

  late DateTime startTime;
  late int timePassedInMs = 0;

  late Timer verticalSoundTimer;
  late Timer horizontalSoundTimer;
  late Timer renderTimer;

  void init() {
    width = widget.width;
    height = widget.height;
    horizontalRythm = widget.horizontalRythm;
    verticalRythm = widget.verticalRythm;
    final xFraction = horizontalRythm > verticalRythm ? width : width * verticalRythm / horizontalRythm;
    final yFraction = verticalRythm > horizontalRythm ? height : height * horizontalRythm / verticalRythm;
    velocityY = widget.velocity * yFraction;
    velocityX = widget.velocity * xFraction;
    startTime = widget.startTime;
    verticalSoundTimer = Timer.periodic(Duration(milliseconds: widget.height ~/ velocityY), (timer) {
      widget.soundpool.play(widget.verticalSoundId);
    });
    horizontalSoundTimer = Timer.periodic(Duration(milliseconds: widget.width ~/ velocityX), (timer) {
      widget.soundpool.play(widget.horizontalSoundId);
    });
    // 60 fps
    renderTimer = Timer.periodic(const Duration(milliseconds: 1000 ~/ 60), (timer) {
      if (!mounted) return;
      setState(() {
        timePassedInMs = DateTime.now().difference(startTime).inMilliseconds;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
    cancelTimers();
  }

  void cancelTimers() {
    verticalSoundTimer.cancel();
    horizontalSoundTimer.cancel();
    renderTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DVDLogoPainter(
        timePassedInMs: timePassedInMs,
        width: width,
        height: height,
        velocityY: velocityY,
        velocityX: velocityX,
      ),
    );
  }
}

class DVDLogoPainter extends CustomPainter {
  final int timePassedInMs;
  final double width;
  final double height;
  final double velocityY;
  final double velocityX;
  final bool showDot;
  final double strokeWidth;
  DVDLogoPainter({
    required this.timePassedInMs,
    required this.height,
    required this.width,
    required this.velocityY,
    required this.velocityX,
    this.showDot = true,
    this.strokeWidth = 3,
  });

  late final trailPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth;

  drawTrail(Path path, int timeRemaining, double x, double y) {
    int xBounces = calculateBounces(velocityX, timeRemaining, width);
    int yBounces = calculateBounces(velocityY, timeRemaining, height);

    final timeTerminationCondiiton = timeRemaining < 0;
    final bounceTerminationCondition = xBounces == 0 && yBounces == 0;
    final velocityTerminationCondition = velocityX * timeRemaining <= width && velocityY * timeRemaining <= height;
    if (timeTerminationCondiiton || bounceTerminationCondition || velocityTerminationCondition) {
      return;
    }

    final distanceSinceLastXCollision = xBounces.isEven ? x : width - x;
    final distanceSinceLastYCollision = yBounces.isEven ? y : height - y;

    double lastCollisionX, lastCollisionY;
    double timeSinceLastXCollision = distanceSinceLastXCollision / velocityX;
    double timeSinceLastYCollision = distanceSinceLastYCollision / velocityY;

    if (timeSinceLastXCollision < timeSinceLastYCollision) {
      lastCollisionX = xBounces.isEven ? 0 : width;
      lastCollisionY =
          yBounces.isEven ? y - timeSinceLastXCollision * velocityY : y + timeSinceLastXCollision * velocityY;
      timeRemaining -= math.max(1, timeSinceLastXCollision.toInt());
    } else {
      lastCollisionY = yBounces.isEven ? 0 : height;
      lastCollisionX =
          xBounces.isEven ? x - timeSinceLastYCollision * velocityX : x + timeSinceLastYCollision * velocityX;
      timeRemaining -= math.max(1, timeSinceLastYCollision.toInt());
    }

    path.lineTo(lastCollisionX - width / 2, lastCollisionY - height / 2);

    drawTrail(path, timeRemaining, lastCollisionX, lastCollisionY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    // Calculate current position
    double x = calculateCurrentPosition(velocityX, timePassedInMs, width);
    double y = calculateCurrentPosition(velocityY, timePassedInMs, height);

    path.moveTo(x - width / 2, y - height / 2);

    drawTrail(path, timePassedInMs, x, y);

    path.lineTo(-width / 2, -height / 2);
    canvas.drawPath(path, trailPaint);

    if (showDot) {
      canvas.drawCircle(Offset(x - width / 2, y - height / 2), 20, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

double calculateCurrentPosition(double velocity, int timePassedInMs, double size) {
  final dist = velocity * timePassedInMs % size;

  final bounces = calculateBounces(velocity, timePassedInMs, size);
  if (bounces % 2 == 1) {
    return size - dist;
  }
  return dist;
}

int calculateBounces(double velocity, int timePassedInMs, double size, [double startOffset = 0]) {
  return (velocity * timePassedInMs ~/ size);
}

class _StaticWidget extends StatelessWidget {
  final double height;
  final double width;
  const _StaticWidget({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: RectanglePainter(
      width: width,
      height: height,
    ));
  }
}

class RectanglePainter extends CustomPainter {
  final double width;
  final double height;
  final double strokeWidth;
  const RectanglePainter({
    required this.width,
    required this.height,
    this.strokeWidth = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();

    path.moveTo(-width / 2, -height / 2);
    path.lineTo(-width / 2, height / 2);
    path.lineTo(width / 2, height / 2);
    path.lineTo(width / 2, -height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
