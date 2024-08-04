// import "package:flutter/material.dart";
// import "package:flutter_bloc/flutter_bloc.dart";
// import "package:gizpdp/blocs/screen_responsive_models.dart";
// import "package:gizpdp/widgets/components/progress_indicator/custom_linear_progress.dart";
// import "package:gizpdp/widgets/components/spacing/space_values.dart";
// import "package:gizpdp/widgets/components/typography/custom_typography.dart";

// class ScreenContainerHelper extends StatelessWidget {
//   const ScreenContainerHelper({
//     super.key,
//     this.title,
//     this.description,
//     required this.content,
//     this.actions = const [],
//     this.leftActions = const [],
//     this.loading = false,
//   });

//   final String? title;
//   final String? description;
//   final Widget content;
//   final List<Widget> actions;
//   final List<Widget> leftActions;
//   final bool loading;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isMobile = context.watch<ScreenTypeNotifier>().isMobile;
//     return ColoredBox(
//       color: theme.colorScheme.surfaceContainer,
//       child: Column(
//         children: [
//           Expanded(
//             child: Container(
//               padding: isMobile ? EdgeInsets.all(SpacingValue.px8.value) : EdgeInsets.all(SpacingValue.px40.value),
//               child: Container(
//                 padding: isMobile ? EdgeInsets.all(SpacingValue.px8.value) : EdgeInsets.all(SpacingValue.px24.value),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.surfaceContainerLowest,
//                   boxShadow: ScreenContainerStyleHelper.createBoxShadow(
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: SpacingValue.px8.value,
//                       ),
//                       child: Column(
//                         children: [
//                           if (title != null || description != null) ...[
//                             if (title != null)
//                               isMobile
//                                   ? AppBar(
//                                       backgroundColor: Colors.transparent,
//                                       title: Row(
//                                         children: [
//                                           CustomTypography.headline3(
//                                             title!,
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   : Row(
//                                       children: [CustomTypography.headline1(title!)],
//                                     ),
//                             if (description != null)
//                               Row(
//                                 children: [
//                                   CustomTypography.paragraph1(description!),
//                                 ],
//                               ),
//                             SizedBox(height: SpacingValue.px16.value),
//                           ],
//                         ],
//                       ),
//                     ),
//                     Expanded(child: content),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           DecoratedBox(
//             decoration: BoxDecoration(
//               color: theme.colorScheme.surfaceContainerLowest,
//               boxShadow: ScreenContainerStyleHelper.createBoxShadow(
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//             child: Column(
//               children: [
//                 Container(
//                   child: loading ? const CustomLinearProgressIndicator() : const SizedBox(height: 4),
//                 ),
//                 if (actions.isNotEmpty)
//                   Container(
//                     padding: EdgeInsets.all(SpacingValue.px16.value),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [...leftActions],
//                         ),
//                         Row(
//                           children: [...actions],
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// abstract class ScreenContainerStyleHelper {
//   static List<BoxShadow> createBoxShadow({
//     required Color color,
//   }) =>
//       [
//         BoxShadow(
//           color: color.withOpacity(.1),
//           spreadRadius: 1,
//           blurRadius: 3,
//         ),
//       ];
// }
