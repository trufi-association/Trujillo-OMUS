import "package:flutter/services.dart";

abstract class InputFormattersHelper {
  // Digits Only Input Formatter
  static final lettersOnly = FilteringTextInputFormatter.allow(RegExp(r"^[a-zA-Z]+$"));

  // Digits Only Input Formatter
  static final digitsOnly = FilteringTextInputFormatter.digitsOnly;

  // Only Text Formatter
  static final lettersAndSpacesOnly = _InputFormatter(r"^[^\x00-\x1F\x7F0-9]*$");

  // Strings but spaces or numbers
  static final noNumbersOrSpaces = _InputFormatter(r"^[^\d\s]*$");

  // Text and numbers only
  static final lettersAndNumbersWithSpaces = _InputFormatter(r"[^\x00-\x1F\x7F]*");

  // Mobile and Telephone Formatter
  static final phoneWithMandatoryCountryCode = _InputFormatter(r"^\+?\d{0,14}$");

  // Calling Code Formatter
  static final callingCode = CallingCodeInputFormatter();

  // Double Input Formatter
  static final doubleInputFormatter = _InputFormatter(r"^-?(\d+)?\.?\d*$");

  // ISO 2 Country Code Input Formatter
  static final iso2CountryCode = _InputFormatter(r"^[A-Z]{0,2}$");

  // ISO 3 Country Code Input Formatter
  static final iso3CountryCode = _InputFormatter(r"^[A-Z]{0,3}$");

  // Upper Case Formatter
  static final convertToUpperCase = _UpperCaseTextFormatter();

  // Upper Case Formatter
  static final convertToLowerCase = _LowerCaseTextFormatter();

  // Excel Range InputFormatter
  // ignore: unnecessary_raw_strings
  static TextInputFormatter defineLengthFormatter(int n) => _InputFormatter(r"^.{0," + n.toString() + r"}$");

  // Id or GUID Formatter
  static final numbersOrGuid = _InputFormatter(r"^(\d+|\d{8}-\d{4}-\d{4}-\d{4}-\d{12})$");

  // Project Number Formatter
  static final projectNumberFormat = _InputFormatter(r"^[\d\.\[\]\-]*$");

  // Slug Formatter
  static final slugFormat = _InputFormatter(r"^[a-z0-9\-]*$");

  static TextInputFormatter doubleInputFormatterWithNDecimals(int n) => _InputFormatter(r"^-?(\d+)?\.?\d{0," + n.toString() + r"}$");

  /// Returns an input formatter that allows only integers with up to N digits.
  ///
  /// [digits] The maximum number of digits allowed. If not specified, no limit is applied.
  /// [allowNegative] Whether negative numbers are allowed.
  static TextInputFormatter integerInputFormatter({
    int? digits,
    bool allowNegative = false,
  }) {
    final digitsPattern = digits != null ? "\\d{0,$digits}" : r"\d*";
    final pattern = allowNegative ? "^-?$digitsPattern\$" : "^$digitsPattern\$";
    return _InputFormatter(pattern);
  }

  /// Returns an input formatter that allows only decimal numbers with the specified number of digits
  /// and decimal digits.
  ///
  /// [digits] The maximum number of digits allowed before the decimal point. If not specified, no limit is applied.
  /// [decimalDigits] The maximum number of decimal digits allowed. If not specified, no limit is applied.
  /// [allowNegative] Whether negative numbers are allowed.
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

// // Commission or Service Package Formatter
//   static TextInputFormatter commissionOrServicePackageFormatter({required bool bracketsOptional}) {
//     String pattern;
//     if (bracketsOptional) {
//       pattern = r"^\d{0,2}\.?\d{0,4}\.?\d?(?:\[-?\d{0,3}\.?\d{0,2}\])?$";
//     } else {
//       pattern = r"^\d{0,2}\.?\d{0,4}\.?\d?\[-?\d{0,3}\.?\d{0,2}\]?$";
//     }
//     return _InputFormatter(pattern);
//   }
}

class CallingCodeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // if (oldValue.text.length > newValue.text.length) return newValue;
    String newText = newValue.text;

    if (newText.length > 5) return oldValue;

    if (newText.isEmpty || newText == "+") {
      return newValue.copyWith(text: '');
    }

    newText = newText.replaceAll(RegExp(r'[^0-9]'), '').replaceAll('+', "");

    // Retornar el nuevo valor de texto, manteniendo el cursor al final
    return newValue.copyWith(
      text: '+' + newText,
      // selection: isdsd
      //     ? newValue.selection.copyWith(
      //         baseOffset: newValue.selection.baseOffset + 1,
      //         extentOffset: newValue.selection.extentOffset + 1,
      //       )
      //     : null,
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
