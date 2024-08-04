// import "package:flutter/material.dart";
// import "package:omus/widgets/components/custom_icons.dart";
// import "package:omus/widgets/components/tooltips/tooltip_widgets.dart";
// import "package:intl/intl.dart";

// class IconDatePicker extends StatefulWidget {
//   const IconDatePicker({
//     super.key,
//     required this.initialDate,
//     required this.onChanged,
//     this.startDate,
//     this.endDate,
//   });

//   final DateTime? initialDate;
//   final ValueChanged<String> onChanged;
//   final DateTime? startDate;
//   final DateTime? endDate;

//   @override
//   State createState() => _IconDatePickerState();
// }

// class _IconDatePickerState extends State<IconDatePicker> {
//   DateTime? selectedDate;

//   @override
//   void initState() {
//     super.initState();
//     selectedDate = widget.initialDate;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return CustomIconButton(
//       message: "edit",
//       icon: CustomIcons.calendar,
//       color: theme.colorScheme.primary,
//       onPressed: _pickDate,
//     );
//   }

//   Future<void> _pickDate() async {
//     final selected = await showDatePicker(
//       context: context,
//       initialDate: selectedDate ?? DateTime.now(),
//       firstDate: widget.startDate ?? DateTime(2000),
//       lastDate: widget.endDate ?? DateTime(2100),
//     );
//     if (selected != null && selected != selectedDate) {
//       setState(() {
//         selectedDate = selected;
//       });
//       final formattedDate = DateFormat("yyyy-MM-dd").format(selected);
//       widget.onChanged(formattedDate);
//     }
//   }
// }
