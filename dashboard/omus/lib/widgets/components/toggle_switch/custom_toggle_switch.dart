import "package:flutter/material.dart";
import "package:omus/widgets/components/helpers/form_loading_helper_new.dart";
import "package:omus/widgets/components/spacing/space_values.dart";
import "package:omus/widgets/components/textfield/form_request_field.dart";
import "package:omus/widgets/components/textfield/helpers/form_container.dart";
import "package:omus/widgets/components/tooltips/tooltip_widgets.dart";

class FormRequestToggleSwitch extends StatelessWidget {
  const FormRequestToggleSwitch({
    super.key,
    required this.update,
    required this.field,
    this.label,
    this.description,
    required this.enabled,
    this.validator,
    this.onChanged,
    this.nullable = false,
    this.tooltipText,
    this.tooltipRich,
    this.maxWidthTooltip,
    this.margin,
    this.alignmentFormField,
  });

  final FormRequestUpdate update;
  final FormItemContainer<bool> field;
  final String? label;
  final String? description;
  final bool enabled;
  final FormFieldValidator<bool>? validator;
  final ValueChanged<bool?>? onChanged;
  final bool nullable;
  final String? tooltipText;
  final InlineSpan? tooltipRich;
  final double? maxWidthTooltip;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignmentFormField;

  @override
  Widget build(BuildContext context) => FormItemToggleSwitch(
        title: label,
        description: description,
        onChanged: (value) {
          update(() => field.value = value);
          onChanged?.call(nullable ? value : value ?? false);
        },
        initialValue: field.value ?? false,
        enabled: enabled,
        required: field.required,
        validator: validator,
        errorCode: field.errorCode,
        onError: (value) => update(() => field.errorCode = value),
        tooltipText: tooltipText,
        tooltipRich: tooltipRich,
        maxWidthTooltip: maxWidthTooltip,
        margin: margin,
        alignmentFormField: alignmentFormField,
      );
}

class FormItemToggleSwitch extends FormField<bool?> {
  FormItemToggleSwitch({
    super.key,
    String? title,
    String? description,
    required bool initialValue,
    required ValueChanged<bool?> onChanged,
    required void Function(String?) onError,
    required FormFieldValidator<bool?>? validator,
    String? errorCode,
    bool enabled = true,
    bool required = true,
    String? tooltipText,
    InlineSpan? tooltipRich,
    double? maxWidthTooltip,
    EdgeInsetsGeometry? margin,
    AlignmentGeometry? alignmentFormField,
    super.onSaved,
  }) : super(
          validator: (_) {
            final value = initialValue;
            final errorCodeResult = validateRequired(
                  value: initialValue,
                  required: required,
                ) ??
                validator?.call(value);
            if (errorCode != errorCodeResult) onError(errorCodeResult);
            return errorCodeResult;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (_) => CustomToggleSwitch(
            enabled: enabled,
            title: title,
            errorCode: errorCode,
            description: description,
            onChanged: onChanged,
            value: initialValue,
            tooltipText: tooltipText,
            tooltipRich: tooltipRich,
            maxWidthTooltip: maxWidthTooltip,
            margin: margin,
            alignmentFormField: alignmentFormField,
          ),
        );

  static String? validateRequired(
          {required bool? value, required bool required}) =>
      required
          ? value == null
              ? ""
              : null
          : null;
}

class CustomToggleSwitch extends StatefulWidget {
  const CustomToggleSwitch({
    super.key,
    this.value = false,
    this.onChanged,
    this.errorCode,
    this.autofocus = false,
    this.title,
    this.description,
    this.tooltipText,
    this.tooltipRich,
    this.maxWidthTooltip,
    this.margin,
    this.alignmentFormField,
    this.enabled = true,
  });

  final bool value;
  final String? errorCode;
  final ValueChanged<bool>? onChanged;
  final bool autofocus;
  final String? title;
  final String? description;
  final String? tooltipText;
  final InlineSpan? tooltipRich;
  final double? maxWidthTooltip;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignmentFormField;
  final bool enabled;
  @override
  State<CustomToggleSwitch> createState() => _CustomToggleSwitchState();
}

class _CustomToggleSwitchState extends State<CustomToggleSwitch> {
  late bool value;
  late bool isFocus;

  @override
  void initState() {
    value = widget.value;
    isFocus = widget.autofocus;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlignmentFormField(
      alignment: widget.alignmentFormField,
      child: GestureDetector(
        onTap: widget.enabled
            ? () {
                setState(() {
                  value = !value;
                });
                widget.onChanged?.call(value);
              }
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: widget.title != null ? 54 : null,
                  child: Center(
                    child: Container(
                      height: 30,
                      width: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isFocus
                              ? theme.colorScheme.primary.withOpacity(.15)
                              : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          inactiveThumbColor: theme.colorScheme.surface,
                          inactiveTrackColor:
                              theme.colorScheme.surfaceContainerHigh,
                          activeTrackColor: const Color(0xFF35B611),
                          activeColor: theme.colorScheme.surface,
                          trackOutlineColor: WidgetStatePropertyAll(
                              isFocus && !value
                                  ? theme.colorScheme.primary
                                  : null),
                          value: value,
                          onChanged: widget.enabled
                              ? widget.onChanged != null
                                  ? (newValue) {
                                      setState(() => value = newValue);
                                      widget.onChanged?.call(newValue);
                                    }
                                  : null
                              : null,
                          onFocusChange: (newFocus) {
                            setState(() {
                              isFocus = newFocus;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.title != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(left: 4),
                      child: widget.description != null
                          ? Text(
                              widget.title!,
                            )
                          : Text(
                              widget.title!,
                            ),
                    ),
                  ),
                if (widget.tooltipText != null || widget.tooltipRich != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: TooltipInfoWidget(
                      message: widget.tooltipText,
                      richMessage: widget.tooltipRich,
                      maxWidthMessage: widget.maxWidthTooltip,
                    ),
                  ),
              ],
            ),
            if (widget.description != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.only(left: 58),
                  child: Text(
                    widget.description!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
