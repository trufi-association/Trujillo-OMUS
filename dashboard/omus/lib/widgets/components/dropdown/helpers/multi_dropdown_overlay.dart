import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:omus/widgets/components/custom_divider.dart";
import "package:omus/widgets/components/dropdown/helpers/dropdown_item.dart";
import "package:omus/widgets/components/tooltips/tooltip_text_widget.dart";

class MultiDropdownOverlay extends StatefulWidget {
  const MultiDropdownOverlay({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onItemChange,
    required this.onSelectionItems,
    required this.filteredItemsCount,
    this.searchController,
    required this.width,
    required this.enableFilter,
  });

  final List<DropdownItem> items;
  final List<DropdownItem> selectedItems;
  final Function(DropdownItem item, bool isChecked)? onItemChange;
  final ValueChanged<List<DropdownItem>> onSelectionItems;
  final ValueChanged<int> filteredItemsCount;
  final TextEditingController? searchController;
  final double width;
  final bool enableFilter;

  @override
  State<MultiDropdownOverlay> createState() => _MultiDropdownOverlayState();
}

class _MultiDropdownOverlayState extends State<MultiDropdownOverlay> {
  final textFocusNode = FocusNode();
  final startFocusNode = FocusNode();
  final endFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;
  List<DropdownItem> _selectedValues = [];
  List<DropdownItem> _baseItems = [];
  List<DropdownItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _baseItems = [...widget.items];
    _filteredItems = [...widget.items];
    _selectedValues = [...widget.selectedItems];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.enableFilter) {
        _searchController.addListener(_filterItems);
        textFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    if (widget.searchController == null) {
      _searchController.dispose();
    }
    endFocusNode.dispose();
    startFocusNode.dispose();
    textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.enableFilter)
          Container(
            padding:
                const EdgeInsets.only(bottom: 4, left: 4, right: 4, top: 4),
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(1),
              child: CallbackShortcuts(
                bindings: <ShortcutActivator, VoidCallback>{
                  const SingleActivator(LogicalKeyboardKey.arrowUp): () {
                    _scrollController.animateTo(
                      _filteredItems.length * 41,
                      duration: const Duration(milliseconds: 10),
                      curve: Curves.linear,
                    );
                    endFocusNode.requestFocus();
                  },
                  const SingleActivator(LogicalKeyboardKey.arrowDown): () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 10),
                      curve: Curves.linear,
                    );
                    startFocusNode.requestFocus();
                  },
                },
                child: TextField(
                  controller: _searchController,
                  focusNode: textFocusNode,
                  autofocus: true,
                  onTapOutside: (event) {},
                  onSubmitted: (value) {},
                  onEditingComplete: () {},
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                    ),
                    hintText: "Search...",
                    suffixIcon: _searchController.text.isNotEmpty
                        ? FocusScope(
                            canRequestFocus: false,
                            child: TooltipTextWidget(
                              config: const TooltipConfig(
                                message: "Clear text",
                              ),
                              child: InkWell(
                                onTap: () {
                                  _searchController.text = "";
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: const Icon(
                                  Icons.clear,
                                  size: 20,
                                ),
                              ),
                            ),
                          )
                        : null,
                    filled: true,
                    isCollapsed: true,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.only(right: 16),
                    fillColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        const CustomDivider(margin: EdgeInsets.zero),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(right: 1),
            child: Scrollbar(
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final textTranslations = item.text;
                  final isChecked = _selectedValues.contains(item);
                  return Column(
                    children: [
                      if (index > 0)
                        const CustomDivider(
                          margin: EdgeInsets.zero,
                        ),
                      TooltipTextWidget(
                        config: null,
                        // config: TooltipConfig(
                        //   message: textTranslations,
                        // ),
                        child: MenuItemButton(
                          key: ValueKey(item.id),
                          focusNode: index == 0
                              ? startFocusNode
                              : index == _filteredItems.length - 1
                                  ? endFocusNode
                                  : null,
                          requestFocusOnHover: false,
                          closeOnActivate: false,
                          onPressed: () {
                            _handleItemChanged(item, !isChecked);
                          },
                          style: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.transparent),
                          ),
                          child: SizedBox(
                            width: widget.width - 18 - 1,
                            child: Row(
                              children: [
                                ExcludeFocus(
                                  child: IgnorePointer(
                                    child: Checkbox(
                                      value: isChecked,
                                      onChanged: (_) {},
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    textTranslations,
                                    style: theme.textTheme.bodyLarge,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _filterItems() {
    setState(() {
      _filteredItems = _baseItems
          .where(
            (item) => item.text
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()),
          )
          .toList();
    });
    widget.filteredItemsCount(_filteredItems.length);
  }

  void _handleItemChanged(DropdownItem item, bool isChecked) {
    setState(() {
      if (isChecked) {
        _selectedValues.add(item);
      } else {
        _selectedValues.remove(item);
      }
    });
    widget.onItemChange?.call(item, isChecked);
    widget.onSelectionItems([..._selectedValues]);
  }
}
