import "package:flutter/material.dart";

enum DividerThickness { thin, medium, bold }

extension DividerThicknessExtension on DividerThickness {
  static const Map<DividerThickness, double> _values = {
    DividerThickness.thin: .5,
    DividerThickness.medium: 1,
    DividerThickness.bold: 2,
  };

  double get value => _values[this]!;
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({
    super.key,
    this.color,
    this.thickness = DividerThickness.medium,
    this.width,
    this.margin = const EdgeInsets.all(8),
  });

  final Color? color;
  final DividerThickness thickness;
  final double? width;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: color ?? theme.colorScheme.outlineVariant,
      width: width,
      margin: margin,
      height: thickness.value,
    );
  }
}
