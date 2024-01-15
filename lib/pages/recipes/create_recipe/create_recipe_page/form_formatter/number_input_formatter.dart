import 'package:flutter/services.dart';

class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final RegExp numberRegex = RegExp(r'[0-9]');
    if (numberRegex.allMatches(newValue.text).length == newValue.text.length) {
      return newValue;
    }
    return oldValue;
  }
}
