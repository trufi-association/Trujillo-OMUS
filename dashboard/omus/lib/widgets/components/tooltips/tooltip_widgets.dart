import "package:flutter/material.dart";
import "package:omus/widgets/components/tooltips/tooltip_text_widget.dart";

class TooltipInfoWidget extends StatelessWidget {
  const TooltipInfoWidget({
    super.key,
    this.message,
    this.richMessage,
    this.maxWidthMessage,
    this.margin,
  });
  final String? message;
  final InlineSpan? richMessage;
  final double? maxWidthMessage;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) => TooltipTextWidget(
        config: TooltipConfig(
          message: message,
          richMessage: richMessage,
          maxWidthMessage: maxWidthMessage ?? 300,
        ),
        child: Container(
          margin: margin,
          child: const Icon(Icons.info),
        ),
      );
}

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
    this.message,
    this.richMessage,
    this.maxWidthMessage,
    this.color,
  });
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;
  final String? message;
  final InlineSpan? richMessage;
  final double? maxWidthMessage;
  final Color? color;

  @override
  Widget build(BuildContext context) => TooltipTextWidget(
        config: TooltipConfig(
          message: message,
          richMessage: richMessage,
          maxWidthMessage: maxWidthMessage ?? 300,
        ),
        child: IconButton(
          icon: Icon(
            icon,
            size: 30,
            color: color,
          ),
          padding: EdgeInsets.zero,
          splashRadius: 20,
          onPressed: enabled ? onPressed : null,
        ),
      );
}
