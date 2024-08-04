import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:omus/widgets/components/helpers/input_formatters_helper.dart";
import "package:omus/widgets/components/spacing/space_values.dart";
import "package:omus/widgets/components/textfield/helpers/form_container.dart";
import "package:omus/widgets/components/tooltips/tooltip_text_widget.dart";
import "package:omus/widgets/components/tooltips/tooltip_widgets.dart";

class FormItemContainer<T> {
  FormItemContainer({
    required this.fieldKey,
    this.required = false,
    this.validator,
    this.inputFormatters,
    this.value,
    this.errorCode,
  });

  final String fieldKey;
  bool required;
  String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  T? value;
  String? errorCode;
}

abstract class FormRequest extends ChangeNotifier {
  void update(void Function() callback) {
    callback.call();
    notifyListeners();
  }
}

enum TextFieldThemeEnum {
  base,
  blue,
  green,
  yellow,
}

extension TextFieldThemeEnumExtension on TextFieldThemeEnum {
  static final Map<TextFieldThemeEnum, Color?> _toColorMap = {
    TextFieldThemeEnum.base: null,
    TextFieldThemeEnum.blue: const Color.fromARGB(255, 239, 245, 255),
    TextFieldThemeEnum.green: const Color.fromARGB(255, 248, 254, 244),
    TextFieldThemeEnum.yellow: const Color.fromARGB(255, 255, 255, 224),
  };

  Color? get color => _toColorMap[this];
}

class ReferencedFieldValue<T> {
  ReferencedFieldValue({
    required this.value,
    this.referencedBackgroundColor = const Color.fromARGB(255, 239, 245, 255),
    this.modifiedBackgroundColor,
  });

  final T? value;
  final Color? referencedBackgroundColor;
  final Color? modifiedBackgroundColor;
}

class FormRequestField<T> extends StatelessWidget {
  const FormRequestField({
    super.key,
    required this.field,
    required this.label,
    required this.enabled,
    this.readOnly = false,
    this.obscureText = false,
    this.prefixText,
    this.suffixText,
    this.suffixIcon,
    this.autofillHints,
    this.keyboardType,
    this.tooltipConfig,
    required this.update,
    this.backgroundColor,
    this.referencedFieldValue,
    this.hideError = false,
    this.hideClean = false,
    this.hideTextLabel = false,
    this.hintText,
    this.textAlign,
    this.margin,
    this.onChanged,
    this.minLines,
    this.maxLines,
    this.isTextArea = false,
  }) : assert(referencedFieldValue == null || backgroundColor == null,
            "Only one of referencedFieldValue or backgroundColor can be non-null");
  final FormItemContainer<T> field;
  final String label;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final String? prefixText;
  final String? suffixText;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboardType;
  final TooltipConfig? tooltipConfig;
  final void Function(void Function()) update;
  final ReferencedFieldValue<T>? referencedFieldValue;
  final Color? backgroundColor;
  final bool hideError;
  final bool hideClean;
  final bool hideTextLabel;
  final String? hintText;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry? margin;
  final ValueChanged<T?>? onChanged;
  final int? minLines;
  final int? maxLines;
  final bool isTextArea;
  @override
  Widget build(BuildContext context) => FormElementTextField(
        minLines: isTextArea ? minLines ?? 4 : 1,
        maxLines: isTextArea ? maxLines ?? 4 : 1,
        hideError: hideError,
        margin: margin,
        hideClean: hideClean,
        hideTextLabel: hideTextLabel,
        textAlign: textAlign,
        hintText: hintText,
        textLabel: label,
        required: field.required,
        initialValue:
            field.value?.toString() ?? referencedFieldValue?.value?.toString(),
        onChanged: (value) {
          final parsedValue = parse(value);
          update(() => field.value = parsedValue);
          onChanged?.call(parsedValue);
        },
        errorCode: field.errorCode,
        onError: (value) => update(() => field.errorCode = value),
        validator: field.validator,
        inputFormatters: field.inputFormatters ?? getTextInputFormatter(),
        enabled: enabled,
        readOnly: readOnly,
        obscureText: obscureText,
        prefixText: prefixText,
        suffixText: suffixText,
        suffixIcon: suffixIcon,
        autofillHints: autofillHints,
        keyboardType: getKeyboardType(),
        tooltipConfig: tooltipConfig,
        backgroundColor: referencedFieldValue != null
            ? field.value == null || field.value == ""
                ? referencedFieldValue!.referencedBackgroundColor
                : referencedFieldValue!.modifiedBackgroundColor
            : backgroundColor,
      );

  static Type stringType = FormItemContainer<String>(fieldKey: "").runtimeType;
  static Type doubleType = FormItemContainer<double>(fieldKey: "").runtimeType;
  static Type intType = FormItemContainer<int>(fieldKey: "").runtimeType;

  T? parse(String? value) {
    if (value == null) return null;

    final type = field.runtimeType;

    if (type == stringType) {
      return value as T?;
    } else if (type == doubleType) {
      return double.tryParse(value) as T?;
    } else if (type == intType) {
      return int.tryParse(value) as T?;
    } else {
      throw Exception("(parse) Unsupported Type $type");
    }
  }

  TextInputType? getKeyboardType() {
    final type = field.runtimeType;
    if (type == stringType) {
      return null;
    } else if (type == doubleType) {
      return TextInputType.number;
    } else if (type == intType) {
      return const TextInputType.numberWithOptions(decimal: true);
    } else {
      throw Exception("(getKeyboardType) Unsupported Type $type");
    }
  }

  List<TextInputFormatter>? getTextInputFormatter() {
    final type = field.runtimeType;

    if (type == stringType) {
      return null;
    } else if (type == doubleType) {
      return [InputFormattersHelper.doubleInputFormatter];
    } else if (type == intType) {
      return [InputFormattersHelper.digitsOnly];
    } else {
      throw Exception("(getTextInputFormatter) Unsupported Type $type");
    }
  }
}

// Form field base
class FormElementTextField extends FormField<String> {
  FormElementTextField({
    super.key,
    String? initialValue,
    required void Function(String?) onChanged,
    required void Function(String?) onError,
    String? errorCode,
    required String textLabel,
    required bool enabled,
    required bool required,
    bool readOnly = false,
    required EdgeInsetsGeometry? margin,
    String? prefixText,
    String? suffixText,
    Widget? suffixIcon,
    Color? backgroundColor,
    TooltipConfig? tooltipConfig,
    bool obscureText = false,
    required bool hideClean,
    required TextInputType? keyboardType,
    required Iterable<String>? autofillHints,
    required List<TextInputFormatter>? inputFormatters,
    required FormFieldValidator<String>? validator,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onFieldSubmitted,
    required bool hideError,
    required bool hideTextLabel,
    required String? hintText,
    required TextAlign? textAlign,
    required int? minLines,
    required int? maxLines,
  }) : super(
          validator: (_) {
            final value = initialValue;
            final errorCodeResult = validateRequired(
                  value: value,
                  required: required,
                ) ??
                validator?.call(value);
            if (errorCode != errorCodeResult) onError(errorCodeResult);
            return errorCodeResult;
          },
          builder: (_) => CustomFormBaseTextField(
            maxLines: maxLines,
            minLines: minLines,
            hideError: hideError,
            hideTextLabel: hideTextLabel,
            controller: controller,
            hintText: hintText,
            initialValue: initialValue,
            errorCode: errorCode,
            onChanged: (value) {
              onChanged(value);
              if (errorCode != null) {
                final errorCodeResult = validateRequired(
                      value: value,
                      required: required,
                    ) ??
                    validator?.call(value);

                onError(errorCodeResult);
              }
            },
            onShowFocusHighlight: (isFocus) {
              if (isFocus) return;
              final value = initialValue;
              final errorCodeResult = validateRequired(
                    value: value,
                    required: required,
                  ) ??
                  validator?.call(value);
              if (errorCode != errorCodeResult) onError(errorCodeResult);
            },
            tooltipConfig: tooltipConfig,
            // Custom params
            textLabel: textLabel,
            prefixText: prefixText,
            suffixText: suffixText,
            suffixIcon: suffixIcon,
            required: required,
            margin: margin,
            backgroundColor: backgroundColor,
            enabled: enabled,
            focusNode: focusNode,
            useObscureText: obscureText,
            hideClean: hideClean,
            textAlign: textAlign ??
                (suffixText == null ? TextAlign.start : TextAlign.end),
            readOnly: readOnly,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            inputFormatters: inputFormatters,
            onFieldSubmitted: onFieldSubmitted,
          ),
        );

  static String? validateRequired({String? value, required bool required}) =>
      required
          ? value == null || value.isEmpty
              ? ""
              : null
          : null;
}

// Text field base
class CustomFormBaseTextField extends StatefulWidget {
  const CustomFormBaseTextField({
    super.key,
    // Custom params
    required this.textLabel,
    required this.hideTextLabel,
    this.textAreaHeight = 110,
    this.prefixText,
    this.suffixText,
    this.suffixIcon,
    this.errorCode,
    required this.required,
    required this.hideClean,
    this.backgroundColor,
    required this.margin,
    this.tooltipConfig,
    // TextFormField native params
    this.initialValue,
    this.enabled = true,
    this.focusNode,
    this.useObscureText = false,
    this.readOnly = false,
    required this.minLines,
    required this.maxLines,
    required this.textAlign,
    this.keyboardType,
    this.autofillHints,
    this.inputFormatters,
    // Callbacks
    this.onChanged,
    this.onShowFocusHighlight,
    this.onFieldSubmitted,
    this.controller,
    required this.hideError,
    required this.hintText,
  });

  // Custom params
  final String textLabel;
  final bool hideTextLabel;
  final double textAreaHeight;
  final String? prefixText;
  final String? suffixText;
  final Widget? suffixIcon;
  final String? errorCode;
  final bool required;
  final bool hideClean;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  final TooltipConfig? tooltipConfig;
  // TextFormField native params
  final String? initialValue;
  final bool enabled;
  final FocusNode? focusNode;
  final bool useObscureText;
  final bool readOnly;
  // final bool expands;
  final int? minLines;
  final int? maxLines;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String?>? onChanged;
  final void Function(bool)? onShowFocusHighlight;
  final ValueChanged<String>? onFieldSubmitted;
  final TextEditingController? controller;
  final bool hideError;
  final String? hintText;

  @override
  State<CustomFormBaseTextField> createState() =>
      _CustomFormBaseTextFieldState();
}

class _CustomFormBaseTextFieldState extends State<CustomFormBaseTextField> {
  late TextEditingController _controller;
  bool obscureText = true;
  bool isFocus = false;

  @override
  void initState() {
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    super.initState();
  }

  @override
  void didUpdateWidget(CustomFormBaseTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      final selection = _controller.selection;
      _controller.text = widget.initialValue ?? "";
      if (selection.baseOffset <= _controller.text.length)
        _controller.selection = selection;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorCodeTranslated = widget.errorCode ?? "";
    final isTextArea = widget.minLines != null || widget.maxLines != null;
    return FocusableActionDetector(
      focusNode: FocusNode(skipTraversal: true),
      onShowFocusHighlight: (value) {
        setState(() {
          isFocus = value;
        });
        widget.onShowFocusHighlight?.call(value);
      },
      child: Container(
        margin: widget.margin ??
            EdgeInsets.only(
              top: 2,
              left: SpacingValue.px8.value,
              right: SpacingValue.px8.value,
            ),
        child: Column(
          children: [
            TooltipTextWidget(
              config: widget.tooltipConfig?.copyWith(isMenuAnchor: true),
              child: Container(
                margin: const EdgeInsets.only(
                  top: 2,
                ),
                child: FormContainer(
                  hasError: widget.errorCode != null,
                  isFocus: isFocus,
                  backgroundColor: widget.backgroundColor,
                  child: TextField(
                    controller: _controller,
                    focusNode: widget.focusNode,
                    obscureText: widget.useObscureText ? obscureText : false,
                    readOnly: widget.readOnly,
                    keyboardType: widget.keyboardType,
                    enabled: widget.enabled,
                    autofillHints: widget.autofillHints,
                    inputFormatters: widget.inputFormatters,
                    onChanged: (value) {
                      widget.onChanged?.call(value);
                    },
                    onSubmitted: widget.onFieldSubmitted,
                    // expands: false,
                    minLines: widget.minLines,
                    maxLines: widget.maxLines,
                    textAlign: widget.textAlign,
                    cursorHeight: 19,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      enabled: widget.enabled,
                      fillColor: widget.enabled
                          ? Colors.transparent
                          : theme.hoverColor,
                      border: InputBorder.none,
                      label: widget.hideTextLabel
                          ? null
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.textLabel,
                                ),
                                if (widget.required)
                                  Text(
                                    " *",
                                  ),
                              ],
                            ),
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurface,
                      ),
                      floatingLabelStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(.8),
                      ),
                      contentPadding:
                          const EdgeInsets.only(top: 3, left: 7, right: 7),
                      prefixText: widget.prefixText,
                      suffix: widget.suffixText != null
                          ? Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: SpacingValue.px4.value),
                              child: Text(widget.suffixText!),
                            )
                          : null,
                      suffixIcon: widget.suffixIcon != null ||
                              widget.textAlign == TextAlign.end
                          ? widget.suffixIcon != null
                              ? Container(
                                  margin: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                  ),
                                  width: 24,
                                  height: 24,
                                  child: FittedBox(child: widget.suffixIcon),
                                )
                              : null
                          : widget.useObscureText
                              ? Container(
                                  margin: EdgeInsets.only(
                                    right: 8,
                                    top: isTextArea ? 8 : 0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: isTextArea
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      FocusScope(
                                        canRequestFocus: false,
                                        child: CustomIconButton(
                                          message:
                                              obscureText ? "Hide" : "Show",
                                          // hoverColor: Colors.transparent,
                                          // highlightColor: Colors.transparent,
                                          onPressed: () {
                                            setState(
                                              () => obscureText = !obscureText,
                                            );
                                          },
                                          icon: obscureText
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          enabled: widget.enabled,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : isFocus && !widget.readOnly && !widget.hideClean
                                  ? Column(
                                      mainAxisAlignment: isTextArea
                                          ? MainAxisAlignment.start
                                          : MainAxisAlignment.center,
                                      children: [
                                        FocusScope(
                                          canRequestFocus: false,
                                          child: CustomIconButton(
                                            message: "close",
                                            // hoverColor: Colors.transparent,
                                            // highlightColor: Colors.transparent,
                                            onPressed: () {
                                              widget.onChanged?.call(null);
                                              _controller.clear();
                                            },
                                            icon: Icons.close,
                                            enabled: widget.enabled,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(.5),
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                      errorStyle: const TextStyle(fontSize: 0),
                      errorText: widget.errorCode != null ? "" : null,
                    ),
                  ),
                ),
              ),
            ),
            if (!widget.hideError)
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: errorCodeTranslated.isNotEmpty
                        ? theme.colorScheme.error
                        : Colors.transparent,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    errorCodeTranslated,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
