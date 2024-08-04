import "package:flutter/material.dart";
import "package:omus/widgets/components/dropdown/helpers/dropdown_item.dart";
import "package:omus/widgets/components/dropdown/helpers/multi_dropdown_overlay.dart";
import "package:omus/widgets/components/textfield/form_request_field.dart";
import "package:omus/widgets/components/textfield/helpers/tooltip_container.dart";

class FormRequestMultiSelectField extends StatelessWidget {
  const FormRequestMultiSelectField({
    super.key,
    required this.update,
    required this.field,
    required this.label,
    required this.enabled,
    this.readOnly = false,
    required this.items,
    this.noItemsText,
    this.onChanged,
    this.minSelectionRequired = 1,
  });
  final FormItemContainer<List<String>> field;
  final String label;
  final int minSelectionRequired;
  final bool enabled;
  final bool readOnly;
  final String? noItemsText;
  final void Function(List<String>)? onChanged;
  final void Function(void Function()) update;

  final List<DropdownItem> items;
  @override
  Widget build(BuildContext context) => _MultiSelectFormDropdown(
        labelText: label,
        minSelectionRequired: minSelectionRequired,
        required: field.required,
        selectedItems: field.value ?? [],
        items: items,
        readOnly: readOnly,
        onSelectionItems: (value) {
          update(() => field.value = value);
          onChanged?.call(value);
        },
        errorCode: field.errorCode,
        noItemsText: noItemsText,
        onError: (value) => update(() => field.errorCode = value),
      );
}

class _MultiSelectFormDropdown extends FormField<List<String>> {
  _MultiSelectFormDropdown({
    super.key,
    // Base configuration
    required String labelText,
    List<String> selectedItems = const [],
    required List<DropdownItem> items,
    required ValueChanged<List<String>>? onSelectionItems,
    required int minSelectionRequired,
    required bool required,
    bool readOnly = false,
    bool autofocus = false,
    Function(String item, bool isChecked)? onItemChange,
    // Additional configuration
    int minItemsForSearch = 10,
    EdgeInsetsGeometry? margin,
    String? errorCode,
    required String? noItemsText,
    void Function(String?)? onError,
  }) : super(
          validator: (_) {
            final value = selectedItems;
            final errorCodeResult = required
                ? validateRequired(minSelectionRequired, value.length)
                : null;
            if (errorCode != errorCodeResult) onError?.call(errorCodeResult);
            return errorCodeResult;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (_) => MultiSelectDropdown(
            key: key,
            // Base configuration
            labelText: labelText,
            items: items,
            selectedItems: selectedItems
                .map(
                  (value) => items.firstWhere(
                    (item) => item.id == value,
                    orElse: () => const DropdownItem(
                      id: "unknown",
                      text: "unknown",
                    ),
                  ),
                )
                .toList(),
            onSelectionItems: (value) {
              onSelectionItems?.call(value);
              if (errorCode != null) {
                final errorCodeResult = required
                    ? validateRequired(minSelectionRequired, value.length)
                    : null;
                if (errorCode != errorCodeResult)
                  onError?.call(errorCodeResult);
              }
            },
            enabled: onSelectionItems != null,
            required: required,
            readOnly: readOnly,
            autofocus: autofocus,
            hasValidator: required,
            errorCode: errorCode,
            noItemsText: noItemsText,
            onItemChange: onItemChange,
            // Additional configuration
            minItemsForSearch: minItemsForSearch,
            margin: margin,
          ),
        );

  static String? validateRequired(int minSelectionRequired, int numSelected) =>
      minSelectionRequired > numSelected
          ? "formValidator.error.fieldSelectAtLeastNroOptions:$minSelectionRequired"
          : null;
}

class MultiSelectDropdown extends StatefulWidget {
  const MultiSelectDropdown({
    super.key,
    // Base configuration
    required this.labelText,
    required this.items,
    this.selectedItems = const [],
    this.onSelectionItems,
    required this.required,
    required this.enabled,
    required this.readOnly,
    required this.autofocus,
    required this.hasValidator,
    required this.errorCode,
    required this.noItemsText,
    this.onItemChange,
    // Base configuration
    required this.minItemsForSearch,
    this.margin,
  });

  // Base configuration
  final String labelText;
  final List<DropdownItem> selectedItems;
  final List<DropdownItem> items;
  final ValueChanged<List<String>>? onSelectionItems;
  final bool required;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool hasValidator;
  final String? errorCode;
  final String? noItemsText;
  final Function(String, bool)? onItemChange;

  // Additional configuration
  final EdgeInsetsGeometry? margin;
  final int minItemsForSearch;

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown>
    with SingleTickerProviderStateMixin {
  bool showSearchText = false;
  late int filteredItemsCount;
  List<DropdownItem> selectedItems = [];

  @override
  void initState() {
    super.initState();
    filteredItemsCount = widget.items.length;
    selectedItems = widget.selectedItems;
  }

  @override
  void didUpdateWidget(MultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItems != oldWidget.selectedItems) {
      setState(() {
        selectedItems = widget.selectedItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TooltipContainer(
      hideError: true,
      labelText: widget.labelText,
      inputText: selectedItems.isNotEmpty
          ? selectedItems.map((e) => e.text).join(", ")
          : null,
      required: widget.required,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
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
              ? (filteredItemsCount > 0 ? filteredItemsCount * 41.0 : 1) +
                  48 +
                  2.0
              : widget.items.length >= widget.minItemsForSearch
                  ? (widget.items.length * 41.0) + 48 + 2
                  : (widget.items.isNotEmpty
                      ? (widget.items.length * 41.0) + 2
                      : 1),
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
                  padding: const EdgeInsets.only(
                      bottom: 4, left: 4, right: 4, top: 4),
                  child: Center(
                    // TODO LocalizationKey.withoutTranslate
                    child: Text(
                      widget.noItemsText ?? "No items available",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : MultiDropdownOverlay(
                  width: messageWidth,
                  items: widget.items,
                  selectedItems: selectedItems,
                  enableFilter: filteredItemsCount != widget.items.length ||
                          showSearchText
                      ? true
                      : widget.items.length >= widget.minItemsForSearch,
                  onItemChange: (item, value) {
                    _setCheck(item: item, value: value);
                    widget.onItemChange?.call(item.id, value);
                  },
                  filteredItemsCount: (value) {
                    setState(() {
                      filteredItemsCount = value;
                    });
                  },
                  onSelectionItems: (value) {
                    widget.onSelectionItems?.call(
                      [...value.map((e) => e.id)],
                    );
                  },
                ),
        );
      },
    );
  }

  void _setCheck({
    required DropdownItem item,
    required bool value,
  }) {
    if (value) {
      selectedItems.add(item);
    } else {
      selectedItems.remove(item);
    }
    setState(() {});
  }
}
