String padWithZeros(num number, num maxDisplayValue) {
  final maxDigits = maxDisplayValue.toString().length;
  return number.toString().padLeft(maxDigits, '0');
}
