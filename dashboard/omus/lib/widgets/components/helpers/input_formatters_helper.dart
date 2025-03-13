import "package:flutter/services.dart";

abstract class InputFormattersHelper {
  static final lettersOnly = FilteringTextInputFormatter.allow(RegExp(r"^[a-zA-Z]+$"));

  static final digitsOnly = FilteringTextInputFormatter.digitsOnly;

  static final lettersAndSpacesOnly = _InputFormatter(r"^[^\x00-\x1F\x7F0-9]*$");

  static final noNumbersOrSpaces = _InputFormatter(r"^[^\d\s]*$");

  static final lettersAndNumbersWithSpaces = _InputFormatter(r"[^\x00-\x1F\x7F]*");

  static final phoneWithMandatoryCountryCode = _InputFormatter(r"^\+?\d{0,14}$");

  static final callingCode = CallingCodeInputFormatter();

  static final doubleInputFormatter = _InputFormatter(r"^-?(\d+)?\.?\d*$");

  static final iso2CountryCode = _InputFormatter(r"^[A-Z]{0,2}$");

  static final iso3CountryCode = _InputFormatter(r"^[A-Z]{0,3}$");

  static final convertToUpperCase = _UpperCaseTextFormatter();

  static final convertToLowerCase = _LowerCaseTextFormatter();

  static TextInputFormatter defineLengthFormatter(int n) => _InputFormatter(r"^.{0," + n.toString() + r"}$");

  static final numbersOrGuid = _InputFormatter(r"^(\d+|\d{8}-\d{4}-\d{4}-\d{4}-\d{12})$");

  static final projectNumberFormat = _InputFormatter(r"^[\d\.\[\]\-]*$");

  static final slugFormat = _InputFormatter(r"^[a-z0-9\-]*$");

  static TextInputFormatter doubleInputFormatterWithNDecimals(int n) => _InputFormatter(r"^-?(\d+)?\.?\d{0," + n.toString() + r"}$");

  static TextInputFormatter integerInputFormatter({
    int? digits,
    bool allowNegative = false,
  }) {
    final digitsPattern = digits != null ? "\\d{0,$digits}" : r"\d*";
    final pattern = allowNegative ? "^-?$digitsPattern\$" : "^$digitsPattern\$";
    return _InputFormatter(pattern);
  }

  static TextInputFormatter decimalInputFormatter({
    int? digits,
    int? decimalDigits,
    bool allowNegative = true,
  }) {
    final digitsPattern = digits != null ? "\\d{0,$digits}" : r"\d*";
    final decimalDigitsPattern = decimalDigits != null ? "\\d{0,$decimalDigits}" : r"\d*";

    final pattern = allowNegative ? "^-?$digitsPattern(\\.$decimalDigitsPattern)?\$" : "^$digitsPattern(\\.$decimalDigitsPattern)?\$";

    return _InputFormatter(pattern);
  }
}

class CallingCodeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    if (newText.length > 5) return oldValue;

    if (newText.isEmpty || newText == "+") {
      return newValue.copyWith(text: '');
    }

    newText = newText.replaceAll(RegExp(r'[^0-9]'), '').replaceAll('+', "");

    return newValue.copyWith(
      text: '+$newText',
    );
  }
}

class _InputFormatter extends TextInputFormatter {
  _InputFormatter(String regex) : _regExp = RegExp(regex);
  final RegExp _regExp;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text.length > newValue.text.length) return newValue;
    return _regExp.hasMatch(newValue.text) ? newValue : oldValue;
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
      );
}

class _LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      TextEditingValue(
        text: newValue.text.toLowerCase(),
        selection: newValue.selection,
      );
}
