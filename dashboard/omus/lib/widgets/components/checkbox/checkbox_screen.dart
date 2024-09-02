// import "package:flutter/material.dart";
// import "package:flutter/services.dart";
// import "package:gizpdp/widgets/components/checkbox/custom_checkbox.dart";
// import "package:gizpdp/widgets/components/helpers/form_request_container.dart";
// import "package:gizpdp/widgets/components/helpers/responsive_container.dart";
// import "package:gizpdp/widgets/components/spacing/space_values.dart";
// import "package:gizpdp/widgets/components/textfield/form_request_field.dart";
// import "package:responsive_toolkit/responsive_toolkit.dart";

// class _SampleRequest extends FormRequest {
//   _SampleRequest({
//     required this.field,
//   });

//   factory _SampleRequest.fromScratch() => _SampleRequest(
//         field: FormItemContainer<bool>(
//           fieldKey: "field",
//           value: false,
//           required: true,
//         ),
//       );

//   final FormItemContainer<bool> field;
// }

// class CheckboxScreenCustom extends StatelessWidget {
//   CheckboxScreenCustom({super.key});

//   final FocusNode mainFocusNode = FocusNode();
//   final FocusNode duplicateFocusNode = FocusNode();

//   final TextStyle style = const TextStyle(
//     fontSize: 20,
//     fontWeight: FontWeight.bold,
//   );

//   @override
//   Widget build(BuildContext context) => FormRequestContainer<_SampleRequest>(
//         create: _SampleRequest.fromScratch,
//         builder: (params) {
//           final model = params.model;
//           return SingleChildScrollView(
//             child: Focus(
//               focusNode: mainFocusNode,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: SpacingValue.px32.value,
//                   ),
//                   CustomResponsiveContainer(
//                     children: [
//                       CustomResponsiveItem.small(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 200,
//                               child: Text("Checkbox Sample", style: style),
//                             ),
//                             const SizedBox(height: 20),
//                             FormRequestCheckBox(
//                               update: model.update,
//                               field: model.field,
//                             ),
//                             FormRequestCheckBox(
//                               update: model.update,
//                               label: "Option Sample",
//                               field: model.field,
//                             ),
//                             FormRequestCheckBox(
//                               update: model.update,
//                               label: "Option Sample",
//                               description: "some description",
//                               nullable: true,
//                               field: model.field,
//                             ),
//                             FormRequestCheckBox(
//                               update: model.update,
//                               label: "Option Sample",
//                               description: "some description",
//                               field: model.field,
//                             ),
//                             FormRequestCheckBox(
//                               update: model.update,
//                               label: "solo label some description",
//                               field: model.field,
//                             ),
//                             // FormRequestCheckBox<_SampleRequest>(
//                             //   description: "solo description some description",
//                             //   field: model.field,
//                             // ),
//                             // _FormItemCheckBox(
//                             //   title: "Option Sample",
//                             //   initialValue: false,
//                             //   onChanged: (value) {},
//                             //   onError: (error) {},
//                             //   validator: (value) => null,
//                             // ),
//                             CustomCheckbox(
//                               onChanged: (_) {},
//                               title: "Option Sample",
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 params.isFormCompleted();
//                               },
//                               child: const Text("validate"),
//                             ),
//                           ],
//                         ),
//                       ),
//                       CustomResponsiveItem.small(
//                         child: Container(
//                           margin: EdgeInsets.only(
//                             top: ResponsiveLayout.value(
//                               context,
//                               Breakpoints(
//                                 xs: SpacingValue.px32.value,
//                                 md: 0,
//                               ),
//                             ),
//                           ),
//                           child: Focus(
//                             onKeyEvent: (node, event) {
//                               if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
//                                 return KeyEventResult.handled;
//                               }
//                               mainFocusNode.requestFocus();
//                               return KeyEventResult.ignored;
//                             },
//                             child: IgnorePointer(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: <Widget>[
//                                   SizedBox(
//                                     width: 200,
//                                     child: Text("Checkbox", style: style),
//                                   ),
//                                   const SizedBox(height: 20),
//                                   const Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Expanded(
//                                         child: CustomCheckbox(
//                                           title: "Option 1",
//                                         ),
//                                       ),
//                                       Text("Unchecked"),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   const Row(
//                                     children: [
//                                       Expanded(
//                                         child: CustomCheckbox(
//                                           value: true,
//                                           title: "Option 2",
//                                         ),
//                                       ),
//                                       Text("Checked"),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   const Row(
//                                     children: [
//                                       Expanded(
//                                         child: CustomCheckbox(
//                                           // autofocus: true,
//                                           // focusNode: duplicateFocusNode,
//                                           title: "Option 3",
//                                         ),
//                                       ),
//                                       Text("Unchecked / Focus"),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   const Row(
//                                     children: [
//                                       Expanded(
//                                         child: CustomCheckbox(
//                                           value: true,
//                                           // autofocus: true,
//                                           // focusNode: duplicateFocusNode,
//                                           title: "Option 4",
//                                         ),
//                                       ),
//                                       Text("Checked / Focus"),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   const Row(
//                                     children: [
//                                       Expanded(
//                                         child: CustomCheckbox(
//                                           enabled: true,
//                                           title: "Option 5",
//                                         ),
//                                       ),
//                                       Text("Unchecked / Disabled"),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   const Row(
//                                     children: [
//                                       Expanded(
//                                         child: CustomCheckbox(
//                                           value: true,
//                                           enabled: true,
//                                           title: "Option 6",
//                                         ),
//                                       ),
//                                       Text("Checked / Disabled"),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
// }
