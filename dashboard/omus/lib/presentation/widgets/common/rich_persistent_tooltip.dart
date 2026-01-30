import 'package:flutter/material.dart';

/// Tooltip widget that stays visible when hovering over it.
class RichPersistentTooltip extends StatefulWidget {
  final Widget child;
  final Widget tooltipContent;
  final Duration hoverDelay;

  const RichPersistentTooltip({
    super.key,
    required this.child,
    required this.tooltipContent,
    this.hoverDelay = const Duration(milliseconds: 200),
  });

  @override
  State<RichPersistentTooltip> createState() => _RichPersistentTooltipState();
}

class _RichPersistentTooltipState extends State<RichPersistentTooltip> {
  OverlayEntry? _overlayEntry;
  bool _isHovered = false;
  bool _tooltipHovered = false;

  void _showTooltip() {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final targetGlobal = renderBox.localToGlobal(
      renderBox.size.topRight(Offset.zero),
      ancestor: overlay,
    );

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: targetGlobal.dy + 8,
        left: targetGlobal.dx,
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _tooltipHovered = true);
          },
          onExit: (_) {
            setState(() {
              _tooltipHovered = false;
              _hideTooltipIfNeeded();
            });
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white),
                child: widget.tooltipContent,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _hideTooltipIfNeeded() {
    Future.delayed(widget.hoverDelay, () {
      if (!_isHovered && !_tooltipHovered) {
        _hideTooltip();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _showTooltip();
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _hideTooltipIfNeeded();
        });
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }
}

/// Simple tooltip widget that disappears on mouse exit.
class RichTooltip extends StatefulWidget {
  final Widget child;
  final Widget tooltipContent;

  const RichTooltip({
    super.key,
    required this.child,
    required this.tooltipContent,
  });

  @override
  State<RichTooltip> createState() => _RichTooltipState();
}

class _RichTooltipState extends State<RichTooltip> {
  OverlayEntry? _overlayEntry;

  void _showTooltip(BuildContext context) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final targetGlobalCenter =
        renderBox.localToGlobal(renderBox.size.center(Offset.zero));

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: targetGlobalCenter.dy + 10,
        left: targetGlobalCenter.dx,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: widget.tooltipContent,
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _showTooltip(context),
      onExit: (_) => _hideTooltip(),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }
}
