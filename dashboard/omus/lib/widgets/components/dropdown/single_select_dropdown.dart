import "package:flutter/material.dart";
import "package:omus/widgets/components/dropdown/helpers/dropdown_item.dart";
import "package:omus/widgets/components/dropdown/helpers/single_dropdown_overlay.dart";
import "package:omus/widgets/components/textfield/form_request_field.dart";
import "package:omus/widgets/components/textfield/helpers/tooltip_container.dart";
import "package:omus/widgets/components/tooltips/tooltip_widget.dart";

class FormRequestSingleSelectField extends StatelessWidget {
  const FormRequestSingleSelectField({
    super.key,
    required this.update,
    required this.field,
    required this.label,
    required this.enabled,
    this.obscureText = false,
    this.autofillHints,
    this.keyboardType,
    required this.items,
    this.onChanged,
    this.onOnlySelected,
    this.readOnly = false,
    this.noItemsText,
    this.hideError = false,
  });
  final FormItemContainer<String> field;
  final String label;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final String? noItemsText;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboardType;
  final void Function(String?)? onChanged;
  final void Function(void Function()) update;
  final ValueChanged<DropdownItem?>? onOnlySelected;
  final bool hideError;

  final List<DropdownItem> items;
  @override
  Widget build(BuildContext context) => _SingleSelectFormDropdown(
        labelText: label,
        hideError: hideError,
        required: field.required,
        selectedItem: field.value,
        readOnly: readOnly,
        onChanged: (value) {
          update(() {
            field.value = value?.id;
          });
          onChanged?.call(value?.id);
        },
        errorCode: field.errorCode,
        noItemsText: noItemsText,
        onError: (value) => update(() => field.errorCode = value),
        enabled: enabled,
        items: items,
      );
}

class _SingleSelectFormDropdown extends FormField<DropdownItem> {
  _SingleSelectFormDropdown({
    super.key,
    // Base configuration
    required String labelText,
    String? selectedItem,
    String? errorCode,
    required List<DropdownItem> items,
    required this.onChanged,
    bool required = false,
    bool readOnly = false,
    bool autofocus = false,
    // Additional configuration
    int minItemsForSearch = 10,
    EdgeInsetsGeometry? margin,
    bool enabled = true,
    String? noItemsText,
    required bool hideError,
    void Function(String?)? onError,
  }) : super(
          validator: (_) {
            final value = selectedItem;
            final errorCodeResult = validateRequired(value: value, required: required, items: items);
            if (errorCode != errorCodeResult) onError?.call(errorCodeResult);
            return errorCodeResult;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (_) => _SingleSelectDropdown(
            key: key,
            // Base configuration
            labelText: labelText,
            hideError: hideError,
            items: items,
            selectedValue: selectedItem != null ? DropdownItem(id: selectedItem) : null,
            onChanged: (value) {
              onChanged?.call(value);
              if (errorCode != null) {
                final errorCodeResult = validateRequired(value: value?.id, required: required, items: items);
                if (errorCode != errorCodeResult) {
                  onError?.call(errorCodeResult);
                }
              }
            },
            enabled: enabled,
            required: required,
            readOnly: readOnly,
            autofocus: autofocus,
            hasValidator: required,
            errorCode: errorCode,
            noItemsText: noItemsText,
            // Additional configuration
            minItemsForSearch: minItemsForSearch,
            margin: margin,
          ),
        );
  final ValueChanged<DropdownItem?>? onChanged;

  static String? validateRequired({
    String? value,
    required bool required,
    required List<DropdownItem> items,
  }) {
    if (!required) return null;

    if (value == null) return "formValidator.error.fieldSelectAnOption";

    return items.where((item) => item.id == value).isNotEmpty ? null : "formValidator.error.fieldSelectAnOption";
  }
}

class _SingleSelectDropdown extends StatefulWidget {
  const _SingleSelectDropdown({
    super.key,
    // Base configuration
    required this.labelText,
    required this.items,
    this.selectedValue,
    this.onChanged,
    required this.required,
    required this.hideError,
    required this.enabled,
    required this.readOnly,
    required this.autofocus,
    required this.hasValidator,
    required this.errorCode,
    required this.noItemsText,
    // Additional configuration
    required this.minItemsForSearch,
    this.margin,
  });

  // Base configuration
  final String labelText;
  final DropdownItem? selectedValue;
  final List<DropdownItem> items;
  final ValueChanged<DropdownItem?>? onChanged;
  final bool required;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool hasValidator;
  final String? errorCode;
  final String? noItemsText;
  final bool hideError;
  // Additional configuration
  final int minItemsForSearch;
  final EdgeInsetsGeometry? margin;

  @override
  State<_SingleSelectDropdown> createState() => _SingleSelectDropdownState();
}

class _SingleSelectDropdownState extends State<_SingleSelectDropdown> with SingleTickerProviderStateMixin {
  final tooltipTextFieldKey = GlobalKey<TooltipMaterialState>();
  DropdownItem? selectedItem;

  late int filteredItemsCount;
  bool showSearchText = false;

  @override
  void initState() {
    super.initState();
    filteredItemsCount = widget.items.length;
    if (widget.selectedValue != null) {
      final index = widget.items.indexOf(widget.selectedValue!);
      selectedItem = index != -1 ? widget.items[index] : null;
    }
  }

  @override
  void didUpdateWidget(_SingleSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      final index = widget.items.indexOf(widget.selectedValue!);
      selectedItem = index != -1 ? widget.items[index] : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TooltipContainer(
      tooltipMaterialStateKey: tooltipTextFieldKey,
      labelText: widget.labelText,
      inputText: selectedItem?.text,
      required: widget.required,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      hideError: widget.hideError,
      autofocus: widget.autofocus,
      hasValidator: widget.hasValidator,
      errorCode: widget.errorCode,
      //Additional Tooltip Configuration
      // Calculate heightMessage:
      // Sum of all filtered items'heights (filteredItemsCount * 41.0),
      // TextField height (48.0), and border thickness (2.0).
      heightMessage: widget.items.isEmpty
          ? 41
          : filteredItemsCount != widget.items.length || showSearchText
              ? (filteredItemsCount > 0 ? filteredItemsCount * 41.0 : 1) + 48 + 2.0
              : widget.items.length >= widget.minItemsForSearch
                  ? (widget.items.length * 41.0) + 48 + 2
                  : (widget.items.isNotEmpty ? (widget.items.length * 41.0) + 2 : 1),
      isMenuAnchor: true,
      widthMessage: 0,
      messageWidget: (context, messageWidth, isBetterBottom, showScrollBar) {
        showSearchText = showScrollBar;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.primary,
            ),
            borderRadius: isBetterBottom
                ? const BorderRadius.vertical(
                    bottom: Radius.circular(4),
                  )
                : const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
          ),
          child: widget.items.isEmpty
              ? Container(
                  width: messageWidth,
                  height: 41,
                  padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4, top: 4),
                  child: Center(
                    child: Text(
                      widget.noItemsText ?? "No hay items",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleDropdownOverlay(
                  width: messageWidth,
                  enableFilter: filteredItemsCount != widget.items.length || showSearchText ? true : widget.items.length >= widget.minItemsForSearch,
                  items: widget.items,
                  selectedItem: selectedItem,
                  onItemChange: (item) {
                    setState(() {
                      selectedItem = item;
                    });
                    Future.delayed(
                      const Duration(milliseconds: 10),
                      () => tooltipTextFieldKey.currentState?.hideTooltip(),
                    );
                    widget.onChanged?.call(item);
                  },
                  filteredItemsCount: (value) {
                    setState(() {
                      filteredItemsCount = value;
                    });
                  },
                ),
        );
      },
    );
  }
}
