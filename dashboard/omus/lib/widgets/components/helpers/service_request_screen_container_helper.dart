// import "package:flutter/material.dart";
// import "package:gizpdp/widgets/components/helpers/form_request_container.dart";
// import "package:gizpdp/widgets/components/progress_indicator/custom_linear_progress.dart";
// import "package:gizpdp/widgets/components/spacing/space_values.dart";
// import "package:gizpdp/widgets/components/typography/custom_typography.dart";
// import "package:provider/provider.dart";

// class ServiceRequestScreenContainerHelper extends StatelessWidget {
//   const ServiceRequestScreenContainerHelper({
//     super.key,
//     this.title,
//     this.description,
//     required this.content,
//     this.actions = const [],
//     this.leftActions = const [],
//     this.loading = false,
//     this.trailingWidget,
//   });

//   final String? title;
//   final String? description;
//   final Widget content;
//   final List<Widget> actions;
//   final List<Widget> leftActions;
//   final bool loading;
//   final Widget? trailingWidget;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return ColoredBox(
//       color: theme.colorScheme.surfaceBright,
//       child: Column(
//         children: [
//           Expanded(
//             child: Container(
//               // left: SpacingValue.px40.value,
//               // right: SpacingValue.px40.value,
//               // top: SpacingValue.px32.value,
//               // bottom: SpacingValue.px40.value,
//               padding: EdgeInsets.zero,
//               child: Column(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.only(
//                       top: SpacingValue.px24.value,
//                       left: SpacingValue.px40.value,
//                       right: SpacingValue.px40.value,
//                     ),
//                     child: Column(
//                       children: [
//                         if (title != null && title!.isNotEmpty || description != null) ...[
//                           if (title != null)
//                             Row(
//                               children: [
//                                 CustomTypography.headline1(title!),
//                                 const Spacer(),
//                                 if (trailingWidget != null) trailingWidget!,
//                               ],
//                             ),
//                           if (description != null)
//                             Row(
//                               children: [
//                                 CustomTypography.paragraph1(description!),
//                               ],
//                             ),
//                           SizedBox(height: SpacingValue.px16.value),
//                         ],
//                       ],
//                     ),
//                   ),
//                   Expanded(child: content),
//                 ],
//               ),
//             ),
//           ),
//           DecoratedBox(
//             decoration: BoxDecoration(
//               color: theme.colorScheme.surface,
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

// class CustomAccordionContainerHelper extends StatelessWidget {
//   const CustomAccordionContainerHelper({
//     super.key,
//     this.title,
//     this.description,
//     required this.content,
//     this.actions = const [],
//     this.leftActions = const [],
//     this.loading = false,
//     this.trailingWidget,
//   });

//   final String? title;
//   final String? description;
//   final Widget content;
//   final List<Widget> actions;
//   final List<Widget> leftActions;
//   final bool loading;
//   final Widget? trailingWidget;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Column(
//       children: [
//         Expanded(
//           child: Container(
//             padding: EdgeInsets.zero,
//             child: Column(
//               children: [
//                 Container(
//                   padding: EdgeInsets.only(
//                     top: SpacingValue.px24.value,
//                     left: SpacingValue.px40.value,
//                     right: SpacingValue.px40.value,
//                   ),
//                   child: Column(
//                     children: [
//                       if (title != null && title!.isNotEmpty || description != null) ...[
//                         if (title != null)
//                           Row(
//                             children: [
//                               CustomTypography.headline1(title!),
//                               const Spacer(),
//                               if (trailingWidget != null) trailingWidget!,
//                             ],
//                           ),
//                         if (description != null)
//                           Row(
//                             children: [
//                               CustomTypography.paragraph1(description!),
//                             ],
//                           ),
//                         SizedBox(height: SpacingValue.px16.value),
//                       ],
//                     ],
//                   ),
//                 ),
//                 Expanded(child: content),
//               ],
//             ),
//           ),
//         ),
//         DecoratedBox(
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surface,
//             boxShadow: ScreenContainerStyleHelper.createBoxShadow(
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 child: loading ? const CustomLinearProgressIndicator() : const SizedBox(height: 4),
//               ),
//               if (actions.isNotEmpty)
//                 Container(
//                   padding: EdgeInsets.all(SpacingValue.px16.value),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [...leftActions],
//                       ),
//                       Row(
//                         children: [...actions],
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
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

// class ServiceRequestScreenContainerHelperNew<T extends ChangeNotifier> extends StatefulWidget {
//   const ServiceRequestScreenContainerHelperNew({
//     super.key,
//     this.title,
//     this.description,
//     required this.create,
//     required this.contentBuilder,
//     this.actions = const [],
//     this.leftActions = const [],
//     this.loading = false,
//   });

//   final String? title;
//   final String? description;
//   final T Function() create;
//   final Widget Function(FormRequestParams<T> params) contentBuilder;
//   final List<Widget> actions;
//   final List<Widget> leftActions;
//   final bool loading;

//   @override
//   ServiceRequestScreenContainerHelperNewState<T> createState() => ServiceRequestScreenContainerHelperNewState<T>();
// }

// class ServiceRequestScreenContainerHelperNewState<T extends ChangeNotifier> extends State<ServiceRequestScreenContainerHelperNew<T>> {
//   final formKey = GlobalKey<FormState>();
//   late T model;

//   @override
//   void initState() {
//     super.initState();
//     model = widget.create();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return ChangeNotifierProvider<T>.value(
//       value: model,
//       child: Form(
//         key: formKey,
//         child: Builder(
//           builder: (context) {
//             final formParams = FormRequestParams<T>(
//               model: context.watch<T>(),
//               isFormCompleted: () {
//                 formKey.currentState!.save();
//                 return formKey.currentState!.validate();
//               },
//               resetData: () => setState(() => model = widget.create()),
//             );

//             return ColoredBox(
//               color: theme.colorScheme.surfaceBright,
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: EdgeInsets.zero,
//                       child: Column(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.only(
//                               top: SpacingValue.px24.value,
//                               left: SpacingValue.px40.value,
//                               right: SpacingValue.px40.value,
//                             ),
//                             child: Column(
//                               children: [
//                                 if (widget.title != null && widget.title!.isNotEmpty || widget.description != null) ...[
//                                   if (widget.title != null)
//                                     Row(
//                                       children: [CustomTypography.headline1(widget.title!)],
//                                     ),
//                                   if (widget.description != null)
//                                     Row(
//                                       children: [
//                                         CustomTypography.paragraph1(widget.description!),
//                                       ],
//                                     ),
//                                   SizedBox(height: SpacingValue.px16.value),
//                                 ],
//                               ],
//                             ),
//                           ),
//                           Expanded(child: widget.contentBuilder(formParams)),
//                         ],
//                       ),
//                     ),
//                   ),
//                   DecoratedBox(
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.surface,
//                       boxShadow: ScreenContainerStyleHelper.createBoxShadow(
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Container(
//                           child: widget.loading ? const CustomLinearProgressIndicator() : const SizedBox(height: 4),
//                         ),
//                         if (widget.actions.isNotEmpty)
//                           Container(
//                             padding: EdgeInsets.all(SpacingValue.px16.value),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(
//                                   children: [...widget.leftActions],
//                                 ),
//                                 Row(
//                                   children: [...widget.actions],
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// abstract class ScreenContainerStyleHelperNew {
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
