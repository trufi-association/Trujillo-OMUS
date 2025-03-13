import "package:flutter/material.dart";
import "package:omus/widgets/components/tooltips/tooltip_widget.dart";

class MenuTooltip extends StatelessWidget {
  const MenuTooltip({
    super.key,
    required this.child,
    required this.items,
    this.width = 200,
  });

  final Widget child;
  final List<Widget> items;
  final double width;

  @override
  Widget build(BuildContext context) => TooltipWidget(
        tooltipAlignment: TooltipAlignment.bottomLeft,
        tooltipTriggerMode: CustomTooltipTriggerMode.onPressed,
        showArrow: false,
        widthMessage: width,
        heightMessage: (items.isNotEmpty ? items.length * 48.0 : 1),
        messageWidget: (context, _, __, ___) => SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: items,
          ),
        ),
        child: Align(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: child,
          ),
        ),
      );
}
