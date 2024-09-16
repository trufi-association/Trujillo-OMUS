import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:omus/widgets/components/custom_divider.dart";
import "package:omus/widgets/components/dropdown/helpers/dropdown_item.dart";
import "package:omus/widgets/components/tooltips/tooltip_text_widget.dart";

class SingleDropdownOverlay extends StatefulWidget {
  const SingleDropdownOverlay({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemChange,
    required this.filteredItemsCount,
    this.searchController,
    required this.width,
    required this.enableFilter,
  });

  final List<DropdownItem> items;
  final DropdownItem? selectedItem;
  final Function(DropdownItem item)? onItemChange;
  final ValueChanged<int> filteredItemsCount;
  final TextEditingController? searchController;
  final double width;
  final bool enableFilter;

  @override
  State<SingleDropdownOverlay> createState() => _SingleDropdownOverlayState();
}

class _SingleDropdownOverlayState extends State<SingleDropdownOverlay> {
  final textFocusNode = FocusNode();
  final startFocusNode = FocusNode();
  final endFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;
  DropdownItem? _selectedValue;
  List<DropdownItem> _baseItems = [];
  List<DropdownItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _baseItems = [...widget.items];
    _filteredItems = [...widget.items];
    _selectedValue = widget.selectedItem != null ? DropdownItem(id: widget.selectedItem!.id) : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.enableFilter) {
        textFocusNode.requestFocus();
        _searchController.addListener(_filterItems);
      }
      if (_selectedValue != null) {
        final indexSelected = _baseItems.indexOf(_selectedValue!);
        if (!widget.enableFilter) {
          callNextFocus(context, indexSelected, indexSelected + 1);
        } else {
          _scrollController.animateTo(
            indexSelected * 41,
            duration: const Duration(milliseconds: 10),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
            padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4, top: 4),
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(1),
              child: CallbackShortcuts(
                bindings: <ShortcutActivator, VoidCallback>{
                  const SingleActivator(LogicalKeyboardKey.arrowUp): () {
                    endFocusNode.requestFocus();
                    _scrollController.animateTo(
                      _filteredItems.length * 41,
                      duration: const Duration(milliseconds: 10),
                      curve: Curves.linear,
                    );
                  },
                  const SingleActivator(LogicalKeyboardKey.arrowDown): () {
                    startFocusNode.requestFocus();
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 10),
                      curve: Curves.linear,
                    );
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
                    hintText: "Buscar...",
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
        // if (widget.enableFilter)
        const CustomDivider(margin: EdgeInsets.zero),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(right: 1),
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final textTranslations = item.text;
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
                        onPressed: () {
                          _handleItemChanged(item);
                        },
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                        ),
                        child: SizedBox(
                          width: widget.width - 19,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  textTranslations,
                                  style: theme.textTheme.bodyLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_selectedValue?.id == item.id)
                                Icon(
                                  Icons.check,
                                  color: Theme.of(context).primaryColor,
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
      ],
    );
  }

  void _filterItems() {
    setState(() {
      _filteredItems = _baseItems
          .where(
            (item) => item.text.toLowerCase().contains(_searchController.text.toLowerCase()),
          )
          .toList();
    });
    widget.filteredItemsCount(_filteredItems.length);
  }

  void _handleItemChanged(DropdownItem item) {
    setState(() {
      _selectedValue = item;
    });
    widget.onItemChange?.call(item);
  }

  void callNextFocus(BuildContext context, int indexSelected, int n) {
    if (n <= 0) {
      _scrollController.animateTo(
        indexSelected * 41,
        duration: const Duration(milliseconds: 10),
        curve: Curves.linear,
      );
      return;
    }
    FocusScope.of(context).nextFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callNextFocus(context, indexSelected, n - 1);
    });
  }
}
