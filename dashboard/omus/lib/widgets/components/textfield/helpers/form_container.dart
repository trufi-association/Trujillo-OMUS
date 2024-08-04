import "package:flutter/material.dart";

class FormContainer extends StatelessWidget {
  const FormContainer({
    super.key,
    this.height,
    required this.isFocus,
    required this.hasError,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(5),
    required this.child,
  });
  final double? height;
  final bool isFocus;
  final bool hasError;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  static const defaultHeight = 51.0;
  static const defaultMarginTop = 4.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          strokeAlign: BorderSide.strokeAlignCenter,
          color: isFocus ? theme.colorScheme.primary.withOpacity(.15) : Colors.transparent,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            strokeAlign: BorderSide.strokeAlignOutside,
            color: isFocus
                ? theme.colorScheme.primary
                : hasError
                    ? theme.colorScheme.error
                    : Colors.transparent,
            width: .5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.surface,
            border: Border.all(
              color: isFocus
                  ? theme.colorScheme.primary
                  : hasError
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface.withOpacity(.6),
              width: .5,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AlignmentFormField extends StatelessWidget {
  const AlignmentFormField({
    super.key,
    required this.child,
    required this.alignment,
  });
  final Widget child;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    if (alignment == null) return child;
    return Container(
      height: FormContainer.defaultHeight,
      alignment: alignment,
      margin: const EdgeInsets.only(top: FormContainer.defaultMarginTop),
      child: child,
    );
  }
}

class MarginFormField extends StatelessWidget {
  const MarginFormField({
    super.key,
    required this.child,
    this.hasMargin = true,
  });
  final Widget child;
  final bool hasMargin;

  @override
  Widget build(BuildContext context) {
    if (!hasMargin) return child;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: child,
    );
  }
}
