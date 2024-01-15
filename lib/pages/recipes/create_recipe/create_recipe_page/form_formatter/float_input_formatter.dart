import 'package:flutter/services.dart';

class FloatInputFormatter extends TextInputFormatter {
  final RegExp _floatRegExp = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (_floatRegExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
