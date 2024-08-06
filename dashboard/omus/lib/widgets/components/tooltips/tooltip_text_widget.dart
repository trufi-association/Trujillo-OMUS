import "package:flutter/material.dart";
import "package:omus/widgets/components/tooltips/tooltip_widget.dart";

class TooltipConfig {
  const TooltipConfig({
    this.message,
    this.richMessage,
    this.maxWidthMessage = 300,
    this.isMenuAnchor = false,
  }) : assert(
          (message == null) != (richMessage == null),
          "Either `message` or `richMessage` must be specified",
        );

  final String? message;
  final InlineSpan? richMessage;
  final double maxWidthMessage;
  final bool isMenuAnchor;

  TooltipConfig copyWith({
    String? message,
    InlineSpan? richMessage,
    double? maxWidthMessage,
    bool? isMenuAnchor,
  }) =>
      TooltipConfig(
        message: message ?? this.message,
        richMessage: richMessage ?? this.richMessage,
        maxWidthMessage: maxWidthMessage ?? this.maxWidthMessage,
        isMenuAnchor: isMenuAnchor ?? this.isMenuAnchor,
      );
}

class TooltipTextWidget extends StatelessWidget {
  const TooltipTextWidget({
    super.key,
    required this.child,
    required this.config,
  });

  final Widget child;
  final TooltipConfig? config;

  @override
  Widget build(BuildContext context) {
    if (config == null) return child;
    final textScaler = MediaQuery.of(context).textScaler;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = config!.isMenuAnchor ? constraints.maxWidth : config!.maxWidthMessage;
        Size messageSize;
        if (config!.message != null) {
          messageSize = _calculateTextSize(config!.message!, width, const TextStyle(), textScaler);
        } else {
          messageSize = _calculateInlineSpanSize(config!.richMessage!, width, textScaler);
        }
        final calculatedWidth = messageSize.width <= width ? messageSize.width + 16 : width + 16;
        final calculatedHeight = messageSize.height + 12;
        return TooltipWidget(
          widthMessage: calculatedWidth,
          heightMessage: calculatedHeight,
          tooltipAlignment: TooltipAlignment.topCenter,
          hoverColor: Colors.transparent,
          overlayColor: Colors.transparent,
          focusColor: Colors.transparent,
          splashColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          messageDecoration: BoxDecoration(
            color: Colors.grey[700]!.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          isMenuAnchor: config!.isMenuAnchor,
          showArrow: false,
          messageWidget: (context, messageWidth, isBetterBottom, showScrollBar) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            width: config!.isMenuAnchor ? messageWidth : null,
            child: config!.message != null
                ? Text(
                    config!.message!,
                  )
                : RichText(
                    text: config!.richMessage!,
                    textScaler: textScaler,
                  ),
          ),
          child: child,
        );
      },
    );
  }

  Size _calculateTextSize(
    String text,
    double maxWidth,
    TextStyle style,
    TextScaler textScaler,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      // ignore: avoid_redundant_argument_values
      maxLines: null,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      strutStyle: StrutStyle(
        fontFamily: style.fontFamily,
        fontSize: style.fontSize,
        height: style.height,
      ),
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.size;
  }

  Size _calculateInlineSpanSize(
    InlineSpan text,
    double maxWidth,
    TextScaler textScaler,
  ) {
    final tempTextPainter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    );
    tempTextPainter.layout(maxWidth: maxWidth);
    return tempTextPainter.size;
  }
}
