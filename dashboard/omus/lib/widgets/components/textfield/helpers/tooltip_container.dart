import "package:flutter/material.dart";
import "package:omus/widgets/components/spacing/space_values.dart";
import "package:omus/widgets/components/textfield/helpers/form_container.dart";
import "package:omus/widgets/components/tooltips/tooltip_widget.dart";

class TooltipContainer extends StatefulWidget {
  const TooltipContainer({
    super.key,
    required this.labelText,
    this.inputText,
    required this.required,
    required this.enabled,
    required this.readOnly,
    required this.autofocus,
    required this.hasValidator,
    this.hideError = false,
    this.errorCode,
    // this.margin,
    this.backgroundColor,
    required this.messageWidget,
    required this.heightMessage,
    required this.widthMessage,
    this.offsetYTop = 0,
    this.offsetYBottom = 0,
    this.isMenuAnchor = false,
    this.tooltipAlignment = TooltipAlignment.bottomCenter,
    this.tooltipMaterialStateKey,
    this.onShowFocusHighlight,
  });

  //Base Configuration
  final String labelText;
  final String? inputText;
  final bool required;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool hasValidator;
  final bool hideError;
  final String? errorCode;
  // final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  //Additional Tooltip Configuration
  final double heightMessage;
  final double widthMessage;
  final double offsetYTop;
  final double offsetYBottom;
  final bool isMenuAnchor;
  final WidgetMessageBuilder messageWidget;
  final TooltipAlignment tooltipAlignment;
  final GlobalKey<TooltipMaterialState>? tooltipMaterialStateKey;
  final void Function(bool)? onShowFocusHighlight;

  @override
  State<TooltipContainer> createState() => _TooltipContainerState();
}

class _TooltipContainerState extends State<TooltipContainer> {
  bool isOpen = false;
  bool isFocus = false;
  bool isHover = false;
  bool isBetterBottom = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorCodeTranslated = widget.errorCode ?? "";
    return Container(
      child: Column(
        children: [
          FocusableActionDetector(
            focusNode: FocusNode(skipTraversal: true),
            onShowFocusHighlight: (value) {
              setState(() {
                isFocus = value;
              });
              widget.onShowFocusHighlight?.call(value);
            },
            onShowHoverHighlight: (value) {
              setState(() {
                isHover = value;
              });
            },
            child: FormContainer(
              height: 51,
              hasError: widget.errorCode != null,
              isFocus: isFocus,
              backgroundColor:
                  !widget.enabled ? theme.hoverColor : widget.backgroundColor,
              padding: const EdgeInsets.only(bottom: 2),
              child: TooltipWidget(
                key: widget.tooltipMaterialStateKey,
                heightMessage: widget.heightMessage,
                widthMessage: widget.widthMessage,
                messageCanRequestFocus: true,
                tooltipAlignment: widget.tooltipAlignment,
                tooltipTriggerMode: CustomTooltipTriggerMode.onPressed,
                transitionDuration: Duration.zero,
                messageBorderRadius: 0,
                offset: Offset(
                  0,
                  isBetterBottom ? widget.offsetYBottom : widget.offsetYTop,
                ),
                showArrow: false,
                autofocus: widget.autofocus,
                messageDecoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                      offset: Offset(0, isBetterBottom ? 1 : -1),
                    ),
                  ],
                ),
                isMenuAnchor: widget.isMenuAnchor,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                backgroundMessageColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                overlayColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                messageWidget: widget.messageWidget,
                onShowBottom: (isBetterBottom2, _) {
                  isBetterBottom = isBetterBottom2;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.centerLeft,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  widget.inputText == null ? 2 : -13,
                                ),
                                child: Transform.scale(
                                  scale: widget.inputText == null ? 1.0 : 0.75,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.labelText,
                                      ),
                                      if (widget.required)
                                        Text(
                                          " *",
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (widget.inputText != null)
                              Positioned(
                                top: 22,
                                left: 0,
                                right: 0,
                                child: Text(
                                  widget.inputText!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!widget.enabled)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.lock,
                            color: theme.disabledColor,
                          ),
                        )
                      else
                        const SizedBox(
                          width: 8,
                        ),
                      Icon(
                        isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
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
    );
  }
}
