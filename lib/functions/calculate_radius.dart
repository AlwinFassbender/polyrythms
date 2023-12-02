import 'dart:ui';

const _screenSizeFactor = 0.4;

double calculateRadius(Size size) {
  return size.height > size.width
      ? size.width * _screenSizeFactor
      : size.height * _screenSizeFactor;
}
