import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:polyrythms/functions/calculate_radius.dart';
import 'package:polyrythms/widgets/selection_container.dart';

class Info {
  final Color color;
  final String sound;

  const Info({
    required this.color,
    required this.sound,
  });
}

class BoxMetronome extends StatefulWidget {
  static const destination = "box-metronome";

  const BoxMetronome({super.key});

  @override
  State<BoxMetronome> createState() => _BoxMetronomeState();
}

class _BoxMetronomeState extends State<BoxMetronome> {
  double _velocity = 0.0001;
  int _verticalRythm = 1;
  int _horizontalRythm = 1;

  @override
  Widget build(BuildContext context) {
    final radius = calculateRadius(MediaQuery.sizeOf(context));
    final width = radius * 2;
    final height = radius * 2 * 9 / 16;
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
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
                      startTime: DateTime.now(),
                      width: width,
                      height: height,
                      velocity: _velocity,
                      horizontalRythm: _horizontalRythm,
                      verticalRythm: _verticalRythm,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class _RythmSelector extends StatefulWidget {
  final bool active;
  final void Function(int verticalRythm, int horizontalRythm, double velocity)
      onConfirm;
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
  late int verticalRythm = widget.verticalRythm;
  late int horizontalRythm = widget.horizontalRythm;
  late double velocity = widget.velocity;

  late double sliderValue = getSliderValue(velocity);

  final double minVelocity = 0.00001;
  final double maxVelocity = 0.1;

  late final double minLog = math.log(minVelocity);
  late final double maxLog = math.log(maxVelocity);

  late final maxDisplayValue = (1 * maxVelocity) ~/ minVelocity;

  // Convert the linear slider value to logarithmic scale
  double getLogValue(double value) {
    double scaledValue = minLog + (maxLog - minLog) * value;
    return math.exp(scaledValue);
  }

  // Convert the velocity to a linear value for the slider
  double getSliderValue(double velocity) {
    return (math.log(velocity) - minLog) / (maxLog - minLog);
  }

  // Convert the velocities into nicely displayable value
  int getDisplayValue(double velocity) {
    return (1 * velocity) ~/ minVelocity;
  }

  String padWithZeros(int number) {
    final maxDigits = maxDisplayValue.toString().length;
    return number.toString().padLeft(maxDigits, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(padWithZeros(getDisplayValue(velocity))),
          Padding(
              padding: const EdgeInsets.only(right: 32.0),
              child: Slider(
                  value: sliderValue,
                  onChanged: (value) => setState(() {
                        sliderValue = value;
                        velocity = getLogValue(value);
                      }))),
          _RythmTextField((p0) {
            setState(() {
              verticalRythm = p0;
            });
          }),
          _RythmTextField((p0) {
            setState(() {
              horizontalRythm = p0;
            });
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: GestureDetector(
              onTap: () {
                print(
                    "velocity: $velocity, vertical: $verticalRythm, horizontal: $horizontalRythm");
                widget.onConfirm(verticalRythm, horizontalRythm, velocity);
              },
              child: const SelectContainer(
                child: Center(
                  child: Text(
                    "Set",
                  ),
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
  const _RythmTextField(this.onChanged);

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
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
          ),
          initialValue: "1",
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
  const _MovingWidget({
    required this.height,
    required this.width,
    required this.velocity,
    required this.startTime,
    required this.horizontalRythm,
    required this.verticalRythm,
  });

  @override
  State<_MovingWidget> createState() => _MovingWidgetState();
}

class _MovingWidgetState extends State<_MovingWidget> {
  late double width;
  late double height;

  late int horizontalRythm;
  late int verticalRythm;

  late double xFraction;
  late double yFraction;
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
    xFraction = horizontalRythm > verticalRythm
        ? width
        : width * horizontalRythm / verticalRythm;
    yFraction = verticalRythm > horizontalRythm
        ? height
        : height * horizontalRythm / verticalRythm;
    angleAlpha = math.atan(xFraction / yFraction);
    angleBeta = math.pi / 2 - angleAlpha;
    velocityY = widget.velocity * yFraction;
    velocityX = widget.velocity * xFraction;
    startTime = widget.startTime;
    timePassedInMs;
    verticalSoundTimer = Timer.periodic(
        Duration(milliseconds: widget.height ~/ velocityY), (timer) {});
    horizontalSoundTimer = Timer.periodic(
        Duration(milliseconds: widget.height ~/ velocityY), (timer) {});
    // 60 fps
    renderTimer =
        Timer.periodic(const Duration(milliseconds: 1000 ~/ 60), (timer) {
      setState(() {
        timePassedInMs = DateTime.now().difference(startTime).inMilliseconds;
      });
    });
  }

  @override
  void didUpdateWidget(_MovingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    init();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
    for (final timer in [
      renderTimer,
      verticalSoundTimer,
      horizontalSoundTimer
    ]) {
      timer.cancel();
    }
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
  const DVDLogoPainter({
    required this.timePassedInMs,
    required this.height,
    required this.width,
    required this.velocityY,
    required this.velocityX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final xCount = (velocityX * timePassedInMs) ~/ width;
    final xComponent = (velocityX * timePassedInMs) % width;
    final x = xCount.isEven ? -width / 2 + xComponent : width / 2 - xComponent;
    final yCount = (velocityY * timePassedInMs) ~/ height;
    final yComponent = (velocityY * timePassedInMs) % height;
    final y =
        yCount.isEven ? -height / 2 + yComponent : height / 2 - yComponent;

    canvas.drawCircle(
      Offset(x, y),
      20,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
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
