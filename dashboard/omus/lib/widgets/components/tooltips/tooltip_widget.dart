import "package:flutter/material.dart";
import "package:flutter/services.dart";

typedef WidgetMessageBuilder = Widget Function(
  BuildContext context,
  double messageWidth,
  bool isBetterBottom,
  bool showScrollBar,
);
typedef TooltipChildBuilder = Widget Function(
  BuildContext context,
  FocusNode childFocusNode,
  VoidCallback showTooltip,
);

enum CustomTooltipTriggerMode {
  hover,
  onPressed,
}

enum TooltipAlignment {
  leftTop,
  leftCenter,
  leftBottom,
  rightTop,
  rightCenter,
  rightBottom,
  bottomLeft,
  bottomCenter,
  bottomRight,
  topLeft,
  topCenter,
  topRight,
}

class TooltipWidget extends StatefulWidget {
  const TooltipWidget({
    super.key,
    required this.messageWidget,
    this.child,
    this.childBuilder,
    this.childFocusNode,
    this.widthMessage = 300,
    this.heightMessage = 400,
    this.messageDecoration,
    this.messageBorderRadius,
    this.messageCanRequestFocus,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.tooltipTriggerMode = CustomTooltipTriggerMode.hover,
    this.tooltipAlignment = TooltipAlignment.topLeft,
    this.isMenuAnchor = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.offset = Offset.zero,
    this.backgroundColor,
    this.backgroundMessageColor,
    this.showDuration,
    this.showArrow = true,
    this.onOpen,
    this.onShowBottom,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.overlayColor,
  });

  final Widget? child;
  final TooltipChildBuilder? childBuilder;
  final FocusNode? childFocusNode;
  final CustomTooltipTriggerMode tooltipTriggerMode;
  final double widthMessage;
  final double heightMessage;
  final BoxDecoration? messageDecoration;
  final double? messageBorderRadius;
  final bool? messageCanRequestFocus;
  final Duration transitionDuration;
  final TooltipAlignment tooltipAlignment;
  final WidgetMessageBuilder messageWidget;
  final bool isMenuAnchor;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final Offset offset;
  final Color? backgroundColor;
  final Color? backgroundMessageColor;
  final Duration? showDuration;
  final bool showArrow;
  final ValueChanged<bool>? onOpen;
  final void Function(bool isBetterBottom, bool showScrollBar)? onShowBottom;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? splashColor;
  final Color? overlayColor;

  @override
  State<TooltipWidget> createState() => TooltipMaterialState();
}

class TooltipMaterialState extends State<TooltipWidget> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final FocusNode childFocusNode;
  final _overlayController = OverlayPortalController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  Size? _viewSize;
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    childFocusNode = widget.childFocusNode ?? FocusNode();
    _animationController = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)..addListener(_refreshAnimation);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => hideBySliding(),
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    hideByResizing();
  }

  @override
  void dispose() {
    if (widget.childFocusNode == null) {
      childFocusNode.dispose();
    }
    _animation.removeListener(_refreshAnimation);
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (event) {
        if ([
          CustomTooltipTriggerMode.hover,
        ].contains(widget.tooltipTriggerMode)) {
          showTooltip();
        }
      },
      onExit: (event) {
        if ([
          CustomTooltipTriggerMode.hover,
        ].contains(widget.tooltipTriggerMode)) {
          hideTooltip();
        }
      },
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (overlayContext) {
          // TODO works for dropdowns, I need improve for all popupTooltips
          final childRenderBox = context.findRenderObject()! as RenderBox;
          final messageWidth = widget.isMenuAnchor ? childRenderBox.size.width + 2 : widget.widthMessage;
          final messageHeight = widget.heightMessage;
          final overlayRenderBox = Overlay.of(context).context.findRenderObject()! as RenderBox;
          final childPosition = childRenderBox.localToGlobal(
            Offset.zero,
            ancestor: overlayRenderBox,
          );
          var maxHeight = messageHeight;

          final bottomSpace = overlayRenderBox.size.height - childPosition.dy - childRenderBox.size.height;
          final topSpace = childPosition.dy;

          // TODO: Add params for dynamic 'showTop'/'showBottom' visibility by percent.
          final enableSpaceBottom = bottomSpace > messageHeight;
          final enableSpaceTop = topSpace > messageHeight;
          final isBetterBottom = enableSpaceBottom || topSpace < bottomSpace * 2;

          var showScrollBar = false;
          if (enableSpaceBottom) {
            maxHeight = messageHeight;
          } else if (isBetterBottom) {
            maxHeight = bottomSpace - 10;
            showScrollBar = true;
          } else {
            maxHeight = enableSpaceTop ? messageHeight : topSpace - 10;
            showScrollBar = !enableSpaceTop;
          }

          widget.onShowBottom?.call(isBetterBottom, showScrollBar);
          final tooltipLayout = calculateTooltipPosition(
            messageSize: Size(messageWidth, maxHeight),
            childSize: childRenderBox.size,
            childPosition: childPosition,
            tooltipAlignment: isBetterBottom
                ? widget.tooltipAlignment
                : widget.tooltipAlignment == TooltipAlignment.bottomCenter
                    ? TooltipAlignment.topCenter
                    : TooltipAlignment.topRight,
          );

          return Positioned(
            left: tooltipLayout.offset.dx + widget.offset.dx,
            top: tooltipLayout.offset.dy + widget.offset.dy,
            child: TapRegion(
              onTapOutside: (event) {
                if ([
                  CustomTooltipTriggerMode.onPressed,
                ].contains(widget.tooltipTriggerMode)) {
                  hideTooltip();
                }
              },
              child: MouseRegion(
                onEnter: (event) {
                  if ([
                    CustomTooltipTriggerMode.hover,
                  ].contains(widget.tooltipTriggerMode)) {
                    showTooltip();
                  }
                },
                onExit: (event) {
                  if ([
                    CustomTooltipTriggerMode.hover,
                  ].contains(widget.tooltipTriggerMode)) {
                    hideTooltip();
                  }
                },
                child: FadeTransition(
                  opacity: _animation,
                  child: Container(
                    color: Colors.transparent,
                    width: messageWidth,
                    height: maxHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (widget.showArrow)
                          Positioned(
                            left: tooltipLayout.arrowEdgeInsets.left,
                            right: tooltipLayout.arrowEdgeInsets.right,
                            top: tooltipLayout.arrowEdgeInsets.top,
                            bottom: tooltipLayout.arrowEdgeInsets.bottom,
                            child: Center(
                              child: Transform.rotate(
                                angle: 45 * 3.141592653589793238 / 180,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                                        blurRadius: 2,
                                      ),
                                    ],
                                    color: widget.backgroundMessageColor ?? theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        DecoratedBox(
                          // margin: tooltipLayout.messageEdgeInsets.toEdgeInsets(),
                          decoration: widget.messageDecoration ??
                              BoxDecoration(
                                color: widget.backgroundMessageColor ?? theme.colorScheme.surface,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              widget.messageBorderRadius ?? 4,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: FocusScope(
                                child: Builder(
                                  builder: (context) => CallbackShortcuts(
                                    bindings: <ShortcutActivator, VoidCallback>{
                                      const SingleActivator(
                                        LogicalKeyboardKey.escape,
                                      ): hideTooltip,
                                      LogicalKeySet(
                                        LogicalKeyboardKey.shift,
                                        LogicalKeyboardKey.tab,
                                      ): hideTooltip,
                                      const SingleActivator(
                                        LogicalKeyboardKey.tab,
                                      ): hideTooltip,
                                      const SingleActivator(
                                        LogicalKeyboardKey.arrowUp,
                                      ): () {
                                        FocusScope.of(context).previousFocus();
                                      },
                                      const SingleActivator(
                                        LogicalKeyboardKey.arrowDown,
                                      ): () {
                                        FocusScope.of(context).nextFocus();
                                      },
                                    },
                                    child: FocusTraversalGroup(
                                      policy: OrderedTraversalPolicy(),
                                      child: Focus(
                                        autofocus: true,
                                        skipTraversal: true,
                                        child: widget.messageWidget(
                                          context,
                                          messageWidth,
                                          isBetterBottom,
                                          showScrollBar,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        child: widget.childBuilder != null
            ? widget.childBuilder!.call(context, childFocusNode, showTooltip)
            : Material(
                color: Colors.transparent,
                child: IgnorePointer(
                  ignoring: [
                    CustomTooltipTriggerMode.onPressed,
                  ].contains(widget.tooltipTriggerMode)
                      ? _overlayController.isShowing
                      : false,
                  child: InkWell(
                    mouseCursor: widget.readOnly || !widget.enabled
                        ? SystemMouseCursors.basic
                        : widget.isMenuAnchor
                            ? (_overlayController.isShowing ? SystemMouseCursors.basic : SystemMouseCursors.click)
                            : null,
                    borderRadius: BorderRadius.circular(2),
                    focusNode: childFocusNode,
                    focusColor: widget.focusColor,
                    hoverColor: widget.hoverColor,
                    autofocus: widget.autofocus,
                    // Colors for splashColor, overlayColor
                    // TODO improve for dropdowns and popups
                    splashColor: widget.splashColor,
                    overlayColor: WidgetStatePropertyAll(widget.overlayColor),
                    onTap: widget.enabled
                        ? widget.readOnly
                            ? () {}
                            : [
                                CustomTooltipTriggerMode.onPressed,
                              ].contains(widget.tooltipTriggerMode)
                                ? showTooltip
                                : null
                        : null,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.backgroundColor ?? (_overlayController.isShowing ? theme.hoverColor.withOpacity(0.08) : null),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void hideBySliding() {
    _scrollPosition?.isScrollingNotifier.removeListener(_handleScroll);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.isScrollingNotifier.addListener(_handleScroll);
  }

  void _handleScroll() {
    hideTooltip(isExternalHide: true);
  }

  void hideByResizing() {
    final newSize = MediaQuery.sizeOf(context);
    if (_viewSize != null && newSize != _viewSize) {
      hideTooltip(isExternalHide: true);
    }
    _viewSize = newSize;
  }

  void showTooltip() {
    if (!_overlayController.isShowing) {
      _animationController.forward();
      _overlayController.show();
      widget.onOpen?.call(true);
    }
  }

  void hideTooltip({bool isExternalHide = false}) {
    if (_overlayController.isShowing) {
      childFocusNode.requestFocus();
      if (!isExternalHide) {
        _animationController.reverse();
      }
      widget.onOpen?.call(false);
      _overlayController.hide();
    }
  }

  void _refreshAnimation() {
    setState(() {});
  }

  TooltipLayout calculateTooltipPosition({
    required Size messageSize,
    required Size childSize,
    required Offset childPosition,
    required TooltipAlignment tooltipAlignment,
  }) {
    var xPosition = childPosition.dx;
    var yPosition = childPosition.dy;

    final widthMarker = (widget.showArrow) ? 10.0 : 0.0;
    final messageEdgeInsets = TooltipEdgeInsets();
    final arrowEdgeInsets = TooltipEdgeInsets();

    switch (tooltipAlignment) {
      case TooltipAlignment.rightTop:
      case TooltipAlignment.rightCenter:
      case TooltipAlignment.rightBottom:
        arrowEdgeInsets.left = 2;
        messageEdgeInsets.left = widthMarker;
        xPosition += childSize.width;
      case TooltipAlignment.leftTop:
      case TooltipAlignment.leftCenter:
      case TooltipAlignment.leftBottom:
        arrowEdgeInsets.right = 2;
        messageEdgeInsets.right = widthMarker;
        xPosition -= messageSize.width + widthMarker;
      case TooltipAlignment.topCenter:
      case TooltipAlignment.bottomCenter:
        arrowEdgeInsets.right = 0;
        arrowEdgeInsets.left = 0;
        xPosition += (childSize.width - messageSize.width) / 2;
      case TooltipAlignment.topRight:
      case TooltipAlignment.bottomRight:
        arrowEdgeInsets.left = (childSize.width) / 2;
        xPosition += -widthMarker;
      case TooltipAlignment.topLeft:
      case TooltipAlignment.bottomLeft:
        arrowEdgeInsets.right = (childSize.width) / 2;
        xPosition += childSize.width - messageSize.width + widthMarker;
    }

    switch (tooltipAlignment) {
      case TooltipAlignment.topLeft:
      case TooltipAlignment.topCenter:
      case TooltipAlignment.topRight:
        arrowEdgeInsets.bottom = 2;
        messageEdgeInsets.bottom = widthMarker;
        yPosition -= messageSize.height + widthMarker;
      case TooltipAlignment.bottomLeft:
      case TooltipAlignment.bottomCenter:
      case TooltipAlignment.bottomRight:
        arrowEdgeInsets.top = 2;
        messageEdgeInsets.top = widthMarker;
        yPosition += childSize.height;
      case TooltipAlignment.leftCenter:
      case TooltipAlignment.rightCenter:
        arrowEdgeInsets.top = 0;
        arrowEdgeInsets.bottom = 0;
        yPosition += (childSize.height - messageSize.height) / 2;
      case TooltipAlignment.leftTop:
      case TooltipAlignment.rightTop:
        arrowEdgeInsets.bottom = childSize.height / 2;
        yPosition += childSize.height - messageSize.height + widthMarker;
      case TooltipAlignment.leftBottom:
      case TooltipAlignment.rightBottom:
        arrowEdgeInsets.top = childSize.height / 2;
        yPosition += -widthMarker;
    }
    return TooltipLayout(
      arrowEdgeInsets: arrowEdgeInsets,
      messageEdgeInsets: messageEdgeInsets,
      offset: Offset(xPosition, yPosition),
    );
  }
}

class TooltipLayout {
  TooltipLayout({
    required this.offset,
    required this.arrowEdgeInsets,
    required this.messageEdgeInsets,
  });

  final Offset offset;
  final TooltipEdgeInsets arrowEdgeInsets;
  final TooltipEdgeInsets messageEdgeInsets;
}

class TooltipEdgeInsets {
  TooltipEdgeInsets({
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  double? left;
  double? top;
  double? right;
  double? bottom;

  TooltipEdgeInsets copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) =>
      TooltipEdgeInsets(
        left: left ?? this.left,
        top: top ?? this.top,
        right: right ?? this.right,
        bottom: bottom ?? this.bottom,
      );

  EdgeInsets toEdgeInsets() => EdgeInsets.fromLTRB(
        left ?? 0.0,
        top ?? 0.0,
        right ?? 0.0,
        bottom ?? 0.0,
      );
}
