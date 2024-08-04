// import "package:gizpdp/blocs/localization/app_localization.dart";

// class ValidatorHelper {
//   ValidatorHelper(this.value);

//   String? value;
//   String? errorCode;

//   String? validate() => errorCode;

//   bool continueValidating() => errorCode != null || value == null || value!.isEmpty;

//   ValidatorHelper validateNoSpaces() {
//     if (continueValidating()) return this;
//     if (RegExp(r"\s").hasMatch(value!)) {
//       errorCode = LocalizationKey.formValidatorErrorNoSpaces.key;
//     }
//     return this;
//   }

//   ValidatorHelper validateOnlyText() {
//     if (continueValidating()) return this;
//     if (!RegExp(r"^[\p{L}\s]+$", unicode: true).hasMatch(value!)) {
//       errorCode = LocalizationKey.formValidatorErrorOnlyText.key;
//     }
//     return this;
//   }

//   ValidatorHelper validateOnlyNumbers() {
//     if (continueValidating()) return this;

//     if (!RegExp(r"^\d+$").hasMatch(value!)) {
//       errorCode = LocalizationKey.formValidatorErrorOnlyNumbers.key;
//     }
//     return this;
//   }

//   ValidatorHelper validateParagraph() {
//     if (continueValidating()) return this;
//     if (!RegExp(r"^[\p{L}\d\s\p{P}\p{S}\p{Z}\p{M}\p{N}\p{C}]+$", unicode: true).hasMatch(value!)) {
//       errorCode = LocalizationKey.formValidatorErrorParagraph.key;
//     }
//     return this;
//   }

//   ValidatorHelper validateYear({int? maxYear}) {
//     if (continueValidating()) return this;

//     final currentYear = DateTime.now().year;
//     final yearLimit = maxYear ?? currentYear;
//     if (!RegExp(r"^\d{4}$").hasMatch(value!) || int.parse(value!) > yearLimit) {
//       errorCode = LocalizationKey.formValidatorErrorValidateYear.key;
//     }
//     return this;
//   }

//   ValidatorHelper validateDecimalNumbers() {
//     if (continueValidating()) return this;
//     if (!RegExp(r"^[+-]?(\d+(\.\d*)?|\.\d+)$").hasMatch(value!)) {
//       errorCode = LocalizationKey.formValidatorErrorOnlyNumbers.key;
//     }
//     return this;
//   }

//   ValidatorHelper validateDecimal({int numberDecimals = 2}) {
//     if (continueValidating()) return this;
//     final pattern = "^\\d+\\.\\d{$numberDecimals}\$";
//     final regex = RegExp(pattern);
//     if (!regex.hasMatch(value!)) {
//       errorCode = LocalizationKey.formValidatorErrorInvalidDecimal.key;
//     }
//     return this;
//   }

//   ValidatorHelper validateRangeNumberOrNull({
//     double minNumber = 0,
//     double maxNumber = 100,
//   }) {
//     if (continueValidating()) return this;

//     final numberValue = double.tryParse(value!);
//     if (numberValue == null || numberValue < minNumber || numberValue > maxNumber) {
//       errorCode = "${LocalizationKey.formValidatorErrorValidateRangeNumberOrNull.key}: $minNumber - $maxNumber";
//     }
//     return this;
//   }

//   ValidatorHelper validateEmail() {
//     if (continueValidating()) return this;
//     const pattern =
//         r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
//     final regex = RegExp(pattern);
//     if (!regex.hasMatch(value!)) {
//       errorCode = LocalizationKey.formValidatorErrorEmailInvalid.key;
//     }

//     return this;
//   }

//   ValidatorHelper validatePassword(String passwordValidation) {
//     if (continueValidating()) return this;

//     final pattern = passwordValidation;
//     final regex = RegExp(pattern);
//     if (!regex.hasMatch(value!)) {
//       errorCode = LocalizationKey.formValidatorErrorPasswordInvalid.key;
//     }

//     return this;
//   }

//   ValidatorHelper validatePhoneNumber() {
//     if (continueValidating()) return this;
//     const pattern = r"^\+?[0-9]{8,15}$";
//     final regex = RegExp(pattern);
//     if (!regex.hasMatch(value!)) {
//       errorCode = LocalizationKey.formValidatorErrorInvalidPhoneNumber.key;
//     }
//     return this;
//   }

//   ValidatorHelper validateMinLength(int minLength) {
//     if (continueValidating()) return this;
//     if (value!.length < minLength) {
//       errorCode = "${LocalizationKey.formValidatorErrorMinLength.key}: $minLength";
//     }
//     return this;
//   }

//   ValidatorHelper validateMaxLength(int maxLength) {
//     if (continueValidating()) return this;
//     if (value!.length > maxLength) {
//       errorCode = "${LocalizationKey.formValidatorErrorMaxLength.key}: $maxLength";
//     }
//     return this;
//   }

//   ValidatorHelper validatePercentage() {
//     if (continueValidating()) return this;
//     final numberValue = double.tryParse(value!);
//     if (numberValue == null || numberValue < 0 || numberValue > 100) {
//       errorCode = LocalizationKey.formValidatorErrorInvalidPercentage.key;
//     }
//     return this;
//   }

//   ValidatorHelper validateEqualsTo(String password) {
//     if (continueValidating()) return this;
//     if (value != password) {
//       errorCode = LocalizationKey.formValidatorErrorPasswordDoesNotMatch.key;
//     }
//     return this;
//   }

//   ValidatorHelper validateURL() {
//     if (continueValidating()) return this;
//     const pattern = r"^(https?:\/\/)?([\da-z\.-]+\.[a-z\.]{2,6})([\/\w \.-]*)*\/?$";
//     final regex = RegExp(pattern);
//     if (!regex.hasMatch(value!)) {
//       errorCode = LocalizationKey.formValidatorErrorInvalidUrl.key;
//     }
//     return this;
//   }

//   ValidatorHelper validateProjectNumber({required bool optional}) {
//     if (continueValidating()) return this;

//     String pattern;
//     if (optional) {
//       pattern = r"^\d{2}\.\d{4}\.\d(-\d{3}\.\d{2})?$";
//     } else {
//       pattern = r"^\d{2}\.\d{4}\.\d$";
//     }

//     final regex = RegExp(pattern);
//     if (!regex.hasMatch(value!)) {
//       errorCode = optional
//           ? LocalizationKey.formValidatorErrorCommissionProjectNumberFormat.key
//           : LocalizationKey.formValidatorErrorServicePackageProjectNumberFormat.key;
//     }
//     return this;
//   }

//   ValidatorHelper validateSlug() {
//     if (continueValidating()) return this;
//     const pattern = r"^[a-z0-9\-]+$";
//     final regex = RegExp(pattern);
//     if (!regex.hasMatch(value!)) {
//       errorCode = LocalizationKey.formValidatorErrorSlugFormat.key;
//     }
//     return this;
//   }
// }
