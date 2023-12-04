import 'package:flutter/material.dart';

class SelectContainer extends StatelessWidget {
  final Widget child;
  final Color shadowColor;
  final void Function() onTap;
  const SelectContainer({
    super.key,
    required this.onTap,
    required this.child,
    this.shadowColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 4.0,
                spreadRadius: 2.0,
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
