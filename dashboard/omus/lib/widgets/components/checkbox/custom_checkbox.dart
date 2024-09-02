import "package:flutter/material.dart";
import "package:omus/widgets/components/helpers/form_loading_helper_new.dart";
import "package:omus/widgets/components/textfield/form_request_field.dart";
import "package:omus/widgets/components/tooltips/tooltip_widgets.dart";

class FormRequestCheckBox extends StatelessWidget {
  const FormRequestCheckBox({
    super.key,
    required this.update,
    required this.field,
    this.label,
    this.description,
    this.enabled = true,
    this.dialogConfirmation,
    this.onChanged,
    this.nullable = false,
    this.tooltipText,
    this.tooltipRich,
    this.maxWidthTooltip,
  });
  final FormRequestUpdate update;
  final FormItemContainer<bool> field;
  final String? label;
  final String? description;
  final bool enabled;
  final Future<bool> Function(bool? value)? dialogConfirmation;
  final ValueChanged<bool?>? onChanged;
  final bool nullable;
  final String? tooltipText;
  final InlineSpan? tooltipRich;
  final double? maxWidthTooltip;
  @override
  Widget build(BuildContext context) => _FormItemCheckBox(
        title: label,
        description: description,
        onChanged: (value) async {
          final valueCalculate = dialogConfirmation != null ? await dialogConfirmation!(value) : value;
          update(() => field.value = valueCalculate);
          onChanged?.call(nullable ? value : valueCalculate ?? false);
        },
        initialValue: field.value,
        enabled: enabled,
        required: field.required,
        validator: (value) => field.validator?.call(value.toString()),
        errorCode: field.errorCode,
        onError: (value) => update(() => field.errorCode = value),
        nullable: nullable,
        tooltipText: tooltipText,
        tooltipRich: tooltipRich,
        maxWidthTooltip: maxWidthTooltip,
      );
}

class _FormItemCheckBox extends FormField<bool?> {
  _FormItemCheckBox({
    String? title,
    String? description,
    required bool? initialValue,
    required ValueChanged<bool?> onChanged,
    required void Function(String?) onError,
    required FormFieldValidator<bool?>? validator,
    String? errorCode,
    bool enabled = true,
    bool required = true,
    bool nullable = false,
    String? tooltipText,
    InlineSpan? tooltipRich,
    double? maxWidthTooltip,
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
          builder: (_) => CustomCheckbox(
            enabled: enabled,
            required: required,
            title: title,
            errorCode: errorCode,
            description: description,
            onChanged: onChanged,
            value: initialValue,
            nullable: nullable,
            tooltipText: tooltipText,
            tooltipRich: tooltipRich,
            maxWidthTooltip: maxWidthTooltip,
          ),
        );

  static String? validateRequired({required bool? value, required bool required}) => required
      ? value == null
          ? ""
          : null
      : null;
}

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({
    super.key,
    this.onChanged,
    this.title,
    this.description,
    this.enabled = true,
    this.required = false,
    this.value = false,
    this.errorCode,
    this.nullable = false,
    this.tooltipText,
    this.tooltipRich,
    this.maxWidthTooltip,
  });

  final ValueChanged<bool?>? onChanged;
  final String? title;
  final String? description;
  final bool enabled;
  final bool required;
  final bool? value;
  final String? errorCode;
  final bool nullable;
  final String? tooltipText;
  final InlineSpan? tooltipRich;
  final double? maxWidthTooltip;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool? value;
  bool isFocus = false;

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(CustomCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != value) {
      if (widget.nullable) {
        value = value == null
            ? false
            : value == false
                ? true
                : null;
      } else {
        value = !(value ?? false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FocusableActionDetector(
      focusNode: FocusNode(skipTraversal: true),
      onShowFocusHighlight: (value) {
        setState(() {
          isFocus = value;
        });
      },
      child: GestureDetector(
        onTap: widget.enabled
            ? () {
                setState(() {
                  if (widget.nullable) {
                    value = value == null
                        ? false
                        : value == false
                            ? true
                            : null;
                  } else {
                    value = !(value ?? false);
                  }
                });
                widget.onChanged?.call(widget.nullable ? value : value ?? false);
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
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isFocus ? theme.colorScheme.primary.withOpacity(.15) : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Checkbox(
                        tristate: widget.nullable,
                        value: (widget.nullable) ? value : value ?? false,
                        onChanged: widget.enabled
                            ? (newValue) {
                                setState(() {
                                  value = newValue;
                                });
                                widget.onChanged?.call(widget.nullable ? value : value ?? false);
                              }
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        splashRadius: 0,
                      ),
                    ),
                  ),
                ),
                if (widget.title != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
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
