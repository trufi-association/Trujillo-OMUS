// import "package:flutter/material.dart";
// import "package:omus/widgets/components/textfield/form_request_field.dart";
// import "package:omus/widgets/components/textfield/helpers/dialog_container.dart";

// class FormRequestTimePickerField extends StatelessWidget {
//   const FormRequestTimePickerField({
//     super.key,
//     required this.field,
//     required this.label,
//     required this.enabled,
//     this.autofocus = false,
//     this.margin,
//     this.hideError = false,
//     required this.update,
//   });
//   final FormItemContainer<DateTime> field;
//   final String label;
//   final bool enabled;
//   final bool autofocus;
//   final EdgeInsetsGeometry? margin;
//   final bool hideError;
//   final void Function(void Function()) update;

//   @override
//   Widget build(BuildContext context) => FormElementTimePicker(
//         labelText: label,
//         required: field.required,
//         initialValue: field.value,
//         onChanged: (value) => update(() => field.value = value),
//         errorCode: field.errorCode,
//         onError: (value) => update(() => field.errorCode = value),
//         validator: field.validator,
//         enabled: enabled,
//         autofocus: autofocus,
//         margin: margin,
//         hideError: hideError,
//       );
// }

// class FormElementTimePicker extends FormField<DateTime> {
//   FormElementTimePicker({
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
//           builder: (field) => _TimePickerTextField(
//             key: key,
//             labelText: labelText,
//             initialTime: initialValue,
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
//             margin: margin,
//             hideError: hideError,
//           ),
//         );

//   static String? validateRequired(DateTime? value, bool required) =>
//       required && (value == null) ? "" : null;
// }

// class _TimePickerTextField extends StatefulWidget {
//   const _TimePickerTextField({
//     super.key,
//     required this.labelText,
//     this.initialTime,
//     this.onChanged,
//     required this.required,
//     required this.enabled,
//     required this.readOnly,
//     required this.autofocus,
//     required this.hasValidator,
//     this.errorCode,
//     this.margin,
//     required this.hideError,
//   });

//   final String labelText;
//   final DateTime? initialTime;
//   final ValueChanged<DateTime?>? onChanged;
//   final bool required;
//   final bool enabled;
//   final bool readOnly;
//   final bool autofocus;
//   final bool hasValidator;
//   final String? errorCode;
//   final EdgeInsetsGeometry? margin;
//   final bool hideError;

//   @override
//   State<_TimePickerTextField> createState() => _TimePickerTextFieldState();
// }

// class _TimePickerTextFieldState extends State<_TimePickerTextField> {
//   TimeOfDay? selectedTime;

//   @override
//   void initState() {
//     super.initState();
//     selectedTime = widget.initialTime != null
//         ? TimeOfDay.fromDateTime(widget.initialTime!)
//         : null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final localizations = MaterialLocalizations.of(context);
//     return DialogContainer(
//       labelText: widget.labelText,
//       inputText: selectedTime != null
//           ? localizations.formatTimeOfDay(selectedTime!)
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
//         final userSelectedTime = await showTimePicker(
//           context: context,
//           useRootNavigator: false,
//           initialTime: selectedTime ?? TimeOfDay.now(),
//           builder: (context, child) => Theme(
//             data: theme.copyWith(
//               materialTapTargetSize: MaterialTapTargetSize.padded,
//               timePickerTheme: TimePickerThemeData(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ),
//             child: MediaQuery(
//               data:
//                   MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
//               child: child!,
//             ),
//           ),
//         );

//         if (userSelectedTime != null) {
//           setState(() {
//             selectedTime = userSelectedTime;
//           });
//           widget.onChanged?.call(
//             DateTime.now().copyWith(
//               hour: userSelectedTime.hour,
//               minute: userSelectedTime.minute,
//               second: 0,
//             ),
//           );
//           return true;
//         }
//         return false;
//       },
//     );
//   }
// }
