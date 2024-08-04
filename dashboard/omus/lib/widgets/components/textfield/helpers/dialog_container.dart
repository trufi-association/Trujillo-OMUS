// import "package:flutter/material.dart";
// import "package:omus/blocs/localization/app_localization.dart";
// import "package:omus/widgets/components/custom_icons.dart";
// import "package:omus/widgets/components/spacing/space_values.dart";
// import "package:omus/widgets/components/textfield/helpers/form_container.dart";
// import "package:omus/widgets/components/typography/custom_typography.dart";

// class DialogContainer extends StatefulWidget {
//   const DialogContainer({
//     super.key,
//     required this.labelText,
//     this.inputText,
//     required this.required,
//     required this.enabled,
//     required this.readOnly,
//     required this.autofocus,
//     required this.hasValidator,
//     this.errorCode,
//     required this.openDialog,
//     this.margin,
//     required this.hideError,
//     this.backgroundColor,
//   });

//   final String labelText;
//   final String? inputText;
//   final bool required;
//   final bool enabled;
//   final bool readOnly;
//   final bool autofocus;
//   final bool hasValidator;
//   final String? errorCode;
//   final Future<bool> Function() openDialog;
//   final EdgeInsetsGeometry? margin;
//   final bool hideError;
//   final Color? backgroundColor;

//   @override
//   State<DialogContainer> createState() => _DialogContainerState();
// }

// class _DialogContainerState extends State<DialogContainer> {
//   final focusNode = FocusNode();

//   bool isOpen = false;
//   bool isFocus = false;
//   bool isHover = false;
//   bool isBetterBottom = true;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final localization = AppLocalization.of(context);
//     final errorCodeTranslated = widget.errorCode != null &&
//             localization.translateWithParams(widget.errorCode!) !=
//                 LocalizationKey.formValidatorErrorFieldSelectAnOption.key
//         ? localization.translateWithParams(widget.errorCode!)
//         : "";
//     return FocusableActionDetector(
//       focusNode: FocusNode(skipTraversal: true),
//       onShowFocusHighlight: (value) {
//         setState(() {
//           isFocus = value;
//         });
//       },
//       onShowHoverHighlight: (value) {
//         setState(() {
//           isHover = value;
//         });
//       },
//       child: Container(
//         margin: widget.margin ??
//             EdgeInsets.only(
//               top: SpacingValue.px4.value,
//               left: SpacingValue.px8.value,
//               right: SpacingValue.px8.value,
//             ),
//         child: Column(
//           children: [
//             FormContainer(
//               height: 51,
//               hasError: widget.errorCode != null,
//               isFocus: isFocus,
//               backgroundColor:
//                   !widget.enabled ? theme.hoverColor : widget.backgroundColor,
//               padding: const EdgeInsets.only(bottom: 2),
//               child: InkWell(
//                 mouseCursor: widget.readOnly ? SystemMouseCursors.basic : null,
//                 focusNode: focusNode,
//                 autofocus: widget.autofocus,
//                 onTap: widget.enabled
//                     ? () async {
//                         if (widget.readOnly) return;
//                         _setOpen(true);
//                         final isFilled = await widget.openDialog.call();
//                         focusNode.requestFocus();
//                         _setOpen(isFilled);
//                       }
//                     : null,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Stack(
//                           fit: StackFit.expand,
//                           alignment: Alignment.centerLeft,
//                           children: [
//                             Align(
//                               alignment: Alignment.centerLeft,
//                               child: Transform.translate(
//                                 offset: Offset(
//                                   0,
//                                   widget.inputText == null ? 2 : -13,
//                                 ),
//                                 child: Transform.scale(
//                                   scale: widget.inputText == null ? 1 : 0.75,
//                                   alignment: Alignment.centerLeft,
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         widget.labelText,
//                                       ),
//                                       if (widget.required)
//                                         Text(
//                                           " *",
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             if (widget.inputText != null)
//                               Positioned(
//                                 top: 24,
//                                 left: 0,
//                                 right: 0,
//                                 child: Text(
//                                   localization.translateWithKey(
//                                     widget.inputText!,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                       if (!widget.enabled)
//                         Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 8),
//                           child: Icon(
//                             Icons.lock,
//                             color: theme.disabledColor,
//                           ),
//                         )
//                       else
//                         const SizedBox(
//                           width: 8,
//                         ),
//                       Icon(
//                         isOpen ? CustomIcons.arrowUp : CustomIcons.arrowDown,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             if (!widget.hideError)
//               Row(
//                 children: [
//                   Icon(
//                     Icons.warning,
//                     color: errorCodeTranslated.isNotEmpty
//                         ? theme.colorScheme.error
//                         : Colors.transparent,
//                     size: 20,
//                   ),
//                   const SizedBox(
//                     width: 8,
//                   ),
//                   Text(
//                     errorCodeTranslated,
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _setOpen(bool isOpen) {
//     setState(() {
//       this.isOpen = isOpen;
//     });
//   }
// }
