import 'package:flutter/material.dart';

class ControlToggle extends StatefulWidget {
  final Function(bool) onToggle;
  const ControlToggle(this.onToggle, {super.key});

  @override
  State<ControlToggle> createState() => _ControlToggleState();
}

class _ControlToggleState extends State<ControlToggle> {
  bool isHovered = false;
  bool active = false;

  Color get textColor => isHovered ? Colors.white : Colors.grey.withAlpha(100);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: GestureDetector(
          onTap: () {
            setState(() {
              active = !active;
            });
            widget.onToggle(active);
          },
          child: Text(active ? "hide controls" : "show controls", style: TextStyle(color: textColor, fontSize: 20)),
        ),
      ),
    );
  }
}
