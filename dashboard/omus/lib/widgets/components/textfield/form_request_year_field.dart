// import "package:flutter/material.dart";
// import "package:omus/widgets/components/textfield/form_request_field.dart";
// import "package:omus/widgets/components/textfield/helpers/tooltip_container.dart";
// import "package:omus/widgets/components/tooltips/tooltip_widget.dart";
// import "package:omus/widgets/date_time_tools.dart";

// class FormRequestYearPickerField extends StatelessWidget {
//   const FormRequestYearPickerField({
//     super.key,
//     required this.field,
//     required this.label,
//     required this.enabled,
//     this.autofocus = false,
//     this.startDateTime,
//     this.endDateTime,
//     this.margin,
//     required this.update,
//   });

//   final FormItemContainer<int> field;
//   final String label;
//   final bool enabled;
//   final bool autofocus;
//   final DateTime? startDateTime;
//   final DateTime? endDateTime;
//   final EdgeInsetsGeometry? margin;
//   final void Function(void Function()) update;

//   @override
//   Widget build(BuildContext context) => FormElementYearPicker(
//         labelText: label,
//         required: field.required,
//         initialValue: field.value,
//         onChanged: (value) => update(() => field.value = value),
//         errorCode: field.errorCode,
//         onError: (value) => update(() => field.errorCode = value),
//         validator: field.validator,
//         enabled: enabled,
//         autofocus: autofocus,
//         startDateTime: startDateTime,
//         endDateTime: endDateTime,
//         margin: margin,
//       );
// }

// class FormElementYearPicker extends FormField<int> {
//   FormElementYearPicker({
//     super.key,
//     super.initialValue,
//     required void Function(int?) onChanged,
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
//     FormFieldValidator<String?>? validator,
//   }) : super(
//           validator: (value) {
//             final errorCodeResult = validateRequired(value, required) ??
//                 validator?.call(value.toString());
//             if (errorCode != errorCodeResult) onError(errorCodeResult);
//             return errorCodeResult;
//           },
//           builder: (field) => _YearPickerTextField(
//             key: key,
//             labelText: labelText,
//             initialYear: initialValue,
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
//           ),
//         );

//   static String? validateRequired(int? value, bool required) =>
//       required && (value == null) ? "" : null;
// }

// class _YearPickerTextField extends StatefulWidget {
//   const _YearPickerTextField({
//     super.key,
//     required this.labelText,
//     this.initialYear,
//     this.onChanged,
//     required this.required,
//     required this.enabled,
//     required this.readOnly,
//     required this.autofocus,
//     required this.hasValidator,
//     required this.errorCode,
//     required this.startDateTime,
//     required this.endDateTime,
//     this.margin,
//   });

//   final String labelText;
//   final int? initialYear;
//   final ValueChanged<int?>? onChanged;
//   final bool required;
//   final bool enabled;
//   final bool readOnly;
//   final bool autofocus;
//   final bool hasValidator;
//   final String? errorCode;
//   final DateTime startDateTime;
//   final DateTime endDateTime;
//   final EdgeInsetsGeometry? margin;

//   @override
//   State<_YearPickerTextField> createState() => _YearPickerTextFieldState();
// }

// class _YearPickerTextFieldState extends State<_YearPickerTextField> {
//   final tooltipTextFieldKey = GlobalKey<TooltipMaterialState>();
//   int? selectedYear;

//   @override
//   void initState() {
//     super.initState();
//     selectedYear = widget.initialYear;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return TooltipContainer(
//       tooltipMaterialStateKey: tooltipTextFieldKey,
//       labelText: widget.labelText,
//       inputText: selectedYear?.toString(),
//       required: widget.required,
//       enabled: widget.enabled,
//       readOnly: widget.readOnly,
//       autofocus: widget.autofocus,
//       hasValidator: widget.hasValidator,
//       errorCode: widget.errorCode,
//       heightMessage: 300,
//       widthMessage: 302,
//       offsetYBottom: 4,
//       offsetYTop: -2,
//       tooltipAlignment: TooltipAlignment.bottomRight,
//       messageWidget: (context, messageWidth, _, __) => InkWell(
//         child: Container(
//           height: 300,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: theme.brightness == Brightness.dark
//                     ? Colors.white.withOpacity(0.2)
//                     : Colors.black.withOpacity(0.2),
//                 offset: const Offset(0, 2),
//                 blurRadius: 2,
//               ),
//             ],
//             borderRadius: BorderRadius.circular(4),
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                 top: -12,
//                 bottom: -12,
//                 width: 300,
//                 child: YearPicker(
//                   firstDate: widget.startDateTime,
//                   lastDate: widget.endDateTime,
//                   selectedDate: DateTime(selectedYear ?? DateTime.now().year),
//                   onChanged: (selectedTime) {
//                     setState(() {
//                       selectedYear = selectedTime.year;
//                     });
//                     widget.onChanged?.call(selectedTime.year);
//                     Future.delayed(
//                       const Duration(milliseconds: 10),
//                       () => tooltipTextFieldKey.currentState?.hideTooltip(),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
