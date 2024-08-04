import "package:flutter/material.dart";
import "package:responsive_toolkit/breakpoints.dart";
import "package:responsive_toolkit/responsive_grid.dart";

class CustomResponsiveContainer extends StatelessWidget {
  const CustomResponsiveContainer({
    super.key,
    required this.children,
    this.verticalSpacing = 0,
    this.horizontalSpacing = 0,
  });

  final List<CustomResponsiveItem> children;
  final double verticalSpacing;
  final double horizontalSpacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, boxConstraints) => ResponsiveRow(
          runSpacing: verticalSpacing,
          spacing: horizontalSpacing,
          columns: children
              .map(
                (value) => ResponsiveColumn.span(
                  span: value.breakpoints.choose(boxConstraints.maxWidth),
                  crossAxisAlignment: value.crossAxisAlignment,
                  child: value.child,
                ),
              )
              .toList(),
        ),
      );
}

/// Represents a custom responsive item that adapts to different screen sizes
/// based on defined breakpoints.
///
/// The default breakpoints are defined as:
/// - `xs` (extra small): < 576
/// - `sm` (small): >= 576
/// - `md` (medium): >= 768
/// - `lg` (large): >= 992
/// - `xl` (extra large): >= 1200
/// - `xxl` (extra extra large): >= 1400
class CustomResponsiveItem {
  CustomResponsiveItem({
    required this.breakpoints,
    required this.child,
    this.crossAxisAlignment,
    this.type = CustomResponsiveType.span,
  });
  factory CustomResponsiveItem.extraSmall({
    required Widget child,
    ResponsiveCrossAlignment? crossAxisAlignment,
    int xs = 6,
    int? sm = 6,
    int? md = 4,
    int? lg = 3,
    int? xl = 2,
    int? xxl = 2,
  }) =>
      CustomResponsiveItem(
        breakpoints: Breakpoints(
          xs: xs,
          sm: sm,
          md: md,
          lg: lg,
          xl: xl,
          xxl: xxl,
        ),
        child: child,
        crossAxisAlignment: crossAxisAlignment,
      );

  factory CustomResponsiveItem.small({
    required Widget child,
    ResponsiveCrossAlignment? crossAxisAlignment,
    int xs = 12,
    int? sm = 12,
    int? md = 6,
    int? lg = 6,
    int? xl = 4,
    int? xxl = 4,
  }) =>
      CustomResponsiveItem(
        breakpoints: Breakpoints(
          xs: xs,
          sm: sm,
          md: md,
          lg: lg,
          xl: xl,
          xxl: xxl,
        ),
        child: child,
        crossAxisAlignment: crossAxisAlignment,
      );

  factory CustomResponsiveItem.medium({
    required Widget child,
    ResponsiveCrossAlignment? crossAxisAlignment,
    int xs = 12,
    int? sm = 12,
    int? md = 12,
    int? lg = 6,
    int? xl = 4,
    int? xxl = 4,
  }) =>
      CustomResponsiveItem(
        breakpoints: Breakpoints(
          xs: xs,
          sm: sm,
          md: md,
          lg: lg,
          xl: xl,
          xxl: xxl,
        ),
        child: child,
        crossAxisAlignment: crossAxisAlignment,
      );

  factory CustomResponsiveItem.large({
    required Widget child,
    ResponsiveCrossAlignment? crossAxisAlignment,
    int xs = 12,
    int? sm = 12,
    int? md = 12,
    int? lg = 12,
    int? xl = 6,
    int? xxl = 6,
  }) =>
      CustomResponsiveItem(
        breakpoints: Breakpoints(
          xs: xs,
          sm: sm,
          md: md,
          lg: lg,
          xl: xl,
          xxl: xxl,
        ),
        child: child,
        crossAxisAlignment: crossAxisAlignment,
      );

  factory CustomResponsiveItem.extraLarge({
    required Widget child,
    ResponsiveCrossAlignment? crossAxisAlignment,
    int xs = 12,
    int? xxl = 6,
  }) =>
      CustomResponsiveItem(
        breakpoints: Breakpoints(
          xs: xs,
          xxl: xxl,
        ),
        child: child,
        crossAxisAlignment: crossAxisAlignment,
      );

  factory CustomResponsiveItem.fill({
    required Widget child,
    ResponsiveCrossAlignment? crossAxisAlignment,
  }) =>
      CustomResponsiveItem(
        breakpoints: Breakpoints(
          xs: 12,
        ),
        child: child,
        type: CustomResponsiveType.fill,
        crossAxisAlignment: crossAxisAlignment,
      );

  factory CustomResponsiveItem.smFixed({
    required Widget child,
    ResponsiveCrossAlignment? crossAxisAlignment,
    int sm = 4,
  }) =>
      CustomResponsiveItem(
        breakpoints: Breakpoints(
          xs: 12,
          sm: sm,
        ),
        child: child,
        crossAxisAlignment: crossAxisAlignment,
      );

  factory CustomResponsiveItem.dynamic({
    required Widget child,
    ResponsiveCrossAlignment? crossAxisAlignment,
    int xs = 12,
    int? sm = 6,
    int? md,
    int? lg,
    int? xl,
    int? xxl,
  }) {
    sm ??= xs;
    md ??= sm;
    lg ??= md;
    xl ??= lg;
    xxl ??= xl;
    return CustomResponsiveItem(
      breakpoints: Breakpoints(
        xs: xs,
        sm: sm,
        md: md,
        lg: lg,
        xl: xl,
        xxl: xxl,
      ),
      child: child,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  factory CustomResponsiveItem.separator({double? height}) =>
      CustomResponsiveItem(
        breakpoints: Breakpoints(
          xs: 12,
        ),
        child: SizedBox(
          height: height,
        ),
      );

  final Breakpoints<int> breakpoints;
  final Widget child;
  final ResponsiveCrossAlignment? crossAxisAlignment;
  final CustomResponsiveType type;
}

enum CustomResponsiveType { span, fill, auto }
