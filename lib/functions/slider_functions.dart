String padWithZeros(num number, num maxDisplayValue) {
  final maxDigits = maxDisplayValue.toString().length;
  return number.toString().padLeft(maxDigits, '0');
}

// Scale a normalized value back to the original range
double scaleValue(num value, num min, num max) {
  return (min + (max - min) * value).toDouble();
}

// Scale a value from the original range to a normalized value between 0 and 1
double normalizeValue(num value, num min, num max) {
  return (value - min) / (max - min);
}
