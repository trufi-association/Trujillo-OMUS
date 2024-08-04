// import "package:flutter/material.dart";
// import "package:omus/widgets/components/textfield/form_request_field.dart";
// import "package:omus/widgets/components/textfield/helpers/dialog_container.dart";
// import "package:omus/widgets/date_time_tools.dart";

// class FormRequestDatePickerField extends StatelessWidget {
//   const FormRequestDatePickerField({
//     super.key,
//     required this.field,
//     required this.label,
//     required this.enabled,
//     this.readOnly = false,
//     this.autofocus = false,
//     this.startDateTime,
//     this.endDateTime,
//     this.margin,
//     this.hideError = false,
//     required this.update,
//     this.onChanged,
//   });

//   final FormItemContainer<DateTime> field;
//   final String label;
//   final bool enabled;
//   final bool readOnly;
//   final bool autofocus;
//   final DateTime? startDateTime;
//   final DateTime? endDateTime;
//   final EdgeInsetsGeometry? margin;
//   final bool hideError;
//   final void Function(void Function()) update;
//   final void Function(DateTime?)? onChanged;

//   @override
//   Widget build(BuildContext context) => FormElementDatePicker(
//         labelText: label,
//         required: field.required,
//         initialValue: field.value,
//         onChanged: (value) {
//           update(() {
//             field.value = value;
//           });
//           onChanged?.call(value);
//         },
//         errorCode: field.errorCode,
//         onError: (value) => update(() => field.errorCode = value),
//         validator: field.validator,
//         enabled: enabled,
//         autofocus: autofocus,
//         startDateTime: startDateTime,
//         endDateTime: endDateTime,
//         readOnly: readOnly,
//         margin: margin,
//         hideError: hideError,
//       );
// }

// class FormElementDatePicker extends FormField<DateTime> {
//   FormElementDatePicker({
//     super.key,
//     super.initialValue,
//     required void Function(DateTime?) onChanged,
//     required void Function(String?) onError,
//     String? errorCode,
//     required String labelText,
//     required bool enabled,
//     required bool required,
//     bool readOnly = false,
//     bool autofocus = false,
//     DateTime? startDateTime,
//     DateTime? endDateTime,
//     EdgeInsetsGeometry? margin,
//     required bool hideError,
//     FormFieldValidator<String?>? validator,
//   }) : super(
//           validator: (value) {
//             final errorCodeResult = validateRequired(
//                   value,
//                   required,
//                 ) ??
//                 validator?.call(value.toString());
//             if (errorCode != errorCodeResult) onError(errorCodeResult);
//             return errorCodeResult;
//           },
//           builder: (field) => _DatePickerTextField(
//             key: key,
//             labelText: labelText,
//             initialDate: initialValue,
//             onChanged: (value) {
//               field.didChange(value);
//               onChanged(value);
//             },
//             required: required,
//             enabled: enabled,
//             readOnly: readOnly,
//             autofocus: autofocus,
//             hasValidator: validator != null,
//             errorCode: errorCode,
//             startDateTime: startDateTime ?? DateTimeTools.defaultStartDateTime,
//             endDateTime: endDateTime ?? DateTimeTools.defaultEndDateTime,
//             margin: margin,
//             hideError: hideError,
//           ),
//         );

//   static String? validateRequired(DateTime? value, bool required) =>
//       required && (value == null) ? "" : null;
// }

// class _DatePickerTextField extends StatefulWidget {
//   const _DatePickerTextField({
//     super.key,
//     required this.labelText,
//     this.initialDate,
//     this.onChanged,
//     required this.required,
//     required this.enabled,
//     required this.readOnly,
//     required this.autofocus,
//     required this.hasValidator,
//     this.errorCode,
//     required this.startDateTime,
//     required this.endDateTime,
//     this.margin,
//     required this.hideError,
//   });

//   final String labelText;
//   final DateTime? initialDate;
//   final ValueChanged<DateTime>? onChanged;
//   final bool required;
//   final bool enabled;
//   final bool readOnly;
//   final bool autofocus;
//   final bool hasValidator;
//   final String? errorCode;
//   final DateTime startDateTime;
//   final DateTime endDateTime;
//   final EdgeInsetsGeometry? margin;
//   final bool hideError;

//   @override
//   State<_DatePickerTextField> createState() => _DatePickerTextFieldState();
// }

// class _DatePickerTextFieldState extends State<_DatePickerTextField> {
//   DateTime? selectedDate;

//   @override
//   void initState() {
//     super.initState();
//     selectedDate = widget.initialDate;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final localizations = MaterialLocalizations.of(context);
//     return DialogContainer(
//       labelText: widget.labelText,
//       inputText: selectedDate != null
//           ? localizations.formatCompactDate(selectedDate!)
//           : null,
//       required: widget.required,
//       enabled: widget.enabled,
//       readOnly: widget.readOnly,
//       autofocus: widget.autofocus,
//       margin: widget.margin,
//       hideError: widget.hideError,
//       hasValidator: widget.hasValidator,
//       errorCode: widget.errorCode,
//       openDialog: () async {
//         final userSelectedDate = await showDatePicker(
//           context: context,
//           useRootNavigator: false,
//           initialDate: selectedDate ?? DateTime.now(),
//           firstDate: selectedDate != null &&
//                   widget.startDateTime.isAfter(selectedDate!)
//               ? selectedDate!
//               : widget.startDateTime,
//           lastDate:
//               selectedDate != null && widget.endDateTime.isBefore(selectedDate!)
//                   ? selectedDate!
//                   : widget.endDateTime,
//           builder: (context, child) => Theme(
//             data: theme.copyWith(
//               datePickerTheme: DatePickerThemeData(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ),
//             child: child!,
//           ),
//         );
//         if (userSelectedDate != null) {
//           setState(() {
//             selectedDate = userSelectedDate;
//           });
//           widget.onChanged?.call(userSelectedDate);
//           return true;
//         }
//         return false;
//       },
//     );
//   }
// }

// // class CustomDatePickerTextFormField extends FormField<DateTime> {
// //   CustomDatePickerTextFormField({
// //     super.key,
// //     required FormItemModelBase<DateTime> formItem,
// //     required void Function(FormItemModelBase<DateTime>) onChanged,
// //     // Base configuration
// //     required String labelText,
// //     bool enabled = true,
// //     bool required = false,
// //     bool readOnly = false,
// //     bool autofocus = false,
// //     FormFieldValidator<DateTime?>? validator,
// //     // Additional configuration
// //     // For default is startDateTime = DateTimeTools.defaultStartDateTime
// //     DateTime? startDateTime,
// //     // For default is endDateTime = DateTimeTools.defaultEndDateTime
// //     DateTime? endDateTime,
// //     EdgeInsetsGeometry? margin,
// //     super.onSaved,
// //   }) : super(
// //           initialValue: formItem.value,
// //           validator: (_) {
// //             final value = formItem.value;
// //             final error = validateRequired(value, required) ?? validator?.call(value);
// //             onChanged(formItem.updateError(error));
// //             return error;
// //           },
// //           builder: (field) => _DatePickerTextField(
// //             key: key,
// //             labelText: labelText,
// //             initialDate: formItem.value,
// //             onChanged: (value) {
// //               onChanged(formItem.updateValue(value).updateError(null));
// //             },
// //             required: required,
// //             enabled: enabled,
// //             readOnly: readOnly,
// //             autofocus: autofocus,
// //             hasValidator: validator != null,
// //             errorCode: formItem.error,
// //             startDateTime: startDateTime ?? DateTimeTools.defaultStartDateTime,
// //             endDateTime: endDateTime ?? DateTimeTools.defaultEndDateTime,
// //             margin: margin,
// //           ),
// //         );

// //   static String? validateRequired(DateTime? value, bool required) => value == null && required ? "" : null;
// // }

// // class _DatePickerTextField extends StatefulWidget {
// //   const _DatePickerTextField({
// //     super.key,
// //     // Base configuration
// //     required this.labelText,
// //     this.initialDate,
// //     this.onChanged,
// //     required this.required,
// //     required this.enabled,
// //     required this.readOnly,
// //     required this.autofocus,
// //     required this.hasValidator,
// //     this.errorCode,
// //     // Additional configuration
// //     required this.startDateTime,
// //     required this.endDateTime,
// //     this.margin,
// //   });

// //   // Base configuration
// //   final String labelText;
// //   final DateTime? initialDate;
// //   final ValueChanged<DateTime>? onChanged;
// //   final bool required;
// //   final bool enabled;
// //   final bool readOnly;
// //   final bool autofocus;
// //   final bool hasValidator;
// //   final String? errorCode;

// //   // Additional configuration
// //   final DateTime startDateTime;
// //   final DateTime endDateTime;
// //   final EdgeInsetsGeometry? margin;

// //   @override
// //   State<_DatePickerTextField> createState() => _DatePickerTextFieldState();
// // }

// // class _DatePickerTextFieldState extends State<_DatePickerTextField> {
// //   DateTime? selectedDate;

// //   @override
// //   void initState() {
// //     super.initState();
// //     selectedDate = widget.initialDate;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final localizations = MaterialLocalizations.of(context);
// //     return DialogTextFieldContent(
// //       labelText: widget.labelText,
// //       inputText: selectedDate != null ? localizations.formatCompactDate(selectedDate!) : null,
// //       required: widget.required,
// //       enabled: widget.enabled,
// //       readOnly: widget.readOnly,
// //       autofocus: widget.autofocus,
// //       hasValidator: widget.hasValidator,
// //       errorCode: widget.errorCode,
// //       openDialog: () async {
// //         final userSelectedDate = await showDatePicker(
// //           context: context,
// //           useRootNavigator: false,
// //           initialDate: selectedDate ?? DateTime.now(),
// //           firstDate: selectedDate != null && widget.startDateTime.isAfter(selectedDate!) ? selectedDate! : widget.startDateTime,
// //           lastDate: selectedDate != null && widget.endDateTime.isBefore(selectedDate!) ? selectedDate! : widget.endDateTime,
// //           builder: (context, child) => Theme(
// //             data: theme.copyWith(
// //               datePickerTheme: DatePickerThemeData(
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(4),
// //                 ),
// //               ),
// //             ),
// //             child: child!,
// //           ),
// //         );
// //         if (userSelectedDate != null) {
// //           setState(() {
// //             selectedDate = userSelectedDate;
// //           });
// //           widget.onChanged?.call(userSelectedDate);
// //           return true;
// //         }
// //         return false;
// //       },
// //     );
// //   }
// // }
