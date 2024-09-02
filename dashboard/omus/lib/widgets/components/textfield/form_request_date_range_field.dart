import "package:calendar_date_picker2/calendar_date_picker2.dart";
import "package:flutter/material.dart";
import "package:omus/widgets/components/textfield/form_request_field.dart";
import "package:omus/widgets/components/textfield/helpers/date_time_tools.dart";
import "package:omus/widgets/components/textfield/helpers/tooltip_container.dart";
import "package:omus/widgets/components/tooltips/tooltip_widget.dart";

extension DateTimeRangeExtension on DateTimeRange {
  // Convert DateTimeRange to String
  String toFormattedString() => "${start.toIso8601String()} to ${end.toIso8601String()}";

  // Create DateTimeRange from String
  static DateTimeRange fromFormattedString(String range) {
    final parts = range.split(" to ");
    final start = DateTime.parse(parts[0]);
    final end = DateTime.parse(parts[1]);
    return DateTimeRange(start: start, end: end);
  }
}

class FormDateRangePickerField extends StatelessWidget {
  const FormDateRangePickerField({
    super.key,
    required this.field,
    required this.label,
    required this.enabled,
    this.autofocus = false,
    this.startDateTime,
    this.endDateTime,
    this.margin,
    required this.update,
    this.onChanged,
  });

  final FormItemContainer<DateTimeRange> field;
  final String label;
  final bool enabled;
  final bool autofocus;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final EdgeInsetsGeometry? margin;
  final void Function(void Function()) update;
  final void Function(DateTimeRange?)? onChanged;

  @override
  Widget build(BuildContext context) => FormElementDateRangePicker(
        labelText: label,
        required: field.required,
        initialValue: field.value,
        onChanged: (value) => update(() {
          field.value = value;
          onChanged?.call(value);
        }),
        errorCode: field.errorCode,
        onError: (value) => update(() => field.errorCode = value),
        validator: (dateTimeRange) => field.validator?.call(dateTimeRange?.toFormattedString()),
        enabled: enabled,
        autofocus: autofocus,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        margin: margin,
      );
}

class FormElementDateRangePicker extends FormField<DateTimeRange> {
  FormElementDateRangePicker({
    super.key,
    super.initialValue,
    required void Function(DateTimeRange?) onChanged,
    required void Function(String?) onError,
    String? errorCode,
    required String labelText,
    required bool enabled,
    required bool required,
    bool readOnly = false,
    bool autofocus = false,
    DateTime? startDateTime,
    DateTime? endDateTime,
    EdgeInsetsGeometry? margin,
    FormFieldValidator<DateTimeRange?>? validator,
  }) : super(
          validator: (value) {
            final errorCodeResult = validateRequired(value, required) ??
                validator?.call(
                  value,
                );
            if (errorCode != errorCodeResult) onError(errorCodeResult);
            return errorCode;
          },
          builder: (field) => _DateRangePickerTextField(
            key: key,
            labelText: labelText,
            initialDateRange: initialValue,
            onChanged: (value) {
              field.didChange(value);
              onChanged(value);
            },
            required: required,
            enabled: enabled,
            readOnly: readOnly,
            autofocus: autofocus,
            hasValidator: validator != null,
            errorCode: errorCode,
            startDateTime: startDateTime ?? DateTimeTools.defaultStartDateTime,
            endDateTime: endDateTime ?? DateTimeTools.defaultEndDateTime,
            margin: margin,
          ),
        );

  static String? validateRequired(
    DateTimeRange? dateTimeRange,
    bool required,
  ) =>
      dateTimeRange == null && required ? "" : null;
}

class _DateRangePickerTextField extends StatefulWidget {
  const _DateRangePickerTextField({
    super.key,
    // Base configuration
    required this.labelText,
    this.initialDateRange,
    this.onChanged,
    required this.required,
    required this.enabled,
    required this.readOnly,
    required this.autofocus,
    required this.hasValidator,
    required this.errorCode,
    // Additional configuration
    required this.startDateTime,
    required this.endDateTime,
    this.margin,
  });

  // Base configuration
  final String labelText;
  final DateTimeRange? initialDateRange;
  final ValueChanged<DateTimeRange?>? onChanged;
  final bool required;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool hasValidator;
  final String? errorCode;

  // Additional configuration
  final DateTime startDateTime;
  final DateTime endDateTime;
  final EdgeInsetsGeometry? margin;

  @override
  State<_DateRangePickerTextField> createState() => _DateRangePickerTextFieldState();
}

class _DateRangePickerTextFieldState extends State<_DateRangePickerTextField> {
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    selectedDateRange = widget.initialDateRange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TooltipContainer(
      hideError: true,
      labelText: widget.labelText,
      inputText: selectedDateRange != null ? getRangeDateText(selectedDateRange!) : null,
      required: widget.required,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      hasValidator: widget.hasValidator,
      errorCode: widget.errorCode,
      //Additional Tooltip Configuration
      heightMessage: 350,
      widthMessage: 330,
      offsetYBottom: 4,
      offsetYTop: -2,
      tooltipAlignment: TooltipAlignment.bottomRight,
      messageWidget: (context, messageWidth, _, __) => Container(
        height: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          padding: const EdgeInsets.only(right: 1),
          child: SingleChildScrollView(
            child: CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.range,
                rangeBidirectional: true,
                firstDate: widget.startDateTime,
                lastDate: widget.endDateTime,
              ),
              value: selectedDateRange != null
                  ? [
                      selectedDateRange!.start,
                      selectedDateRange!.end,
                    ]
                  : [],
              onValueChanged: (value) {
                if (value.length > 1) {
                  setState(() {
                    selectedDateRange = DateTimeRange(
                      start: value.first,
                      end: value.last,
                    );
                  });
                  widget.onChanged?.call(selectedDateRange);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  String getRangeDateText(DateTimeRange dateTimeRange) {
    final localizations = MaterialLocalizations.of(context);
    final firstDate = localizations.formatCompactDate(dateTimeRange.start);
    final lastDate = localizations.formatCompactDate(dateTimeRange.end);
    return "$firstDate - $lastDate";
  }
}
