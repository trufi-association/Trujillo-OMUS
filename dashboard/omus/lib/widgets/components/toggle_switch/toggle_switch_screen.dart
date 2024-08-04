// import "package:flutter/material.dart";
// import "package:flutter/services.dart";
// import "package:gizpdp/widgets/components/helpers/form_request_container.dart";
// import "package:gizpdp/widgets/components/helpers/responsive_container.dart";
// import "package:gizpdp/widgets/components/spacing/space_values.dart";
// import "package:gizpdp/widgets/components/textfield/form_request_field.dart";
// import "package:gizpdp/widgets/components/toggle_switch/custom_toggle_switch.dart";
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

// class ToggleSwitchScreen extends StatefulWidget {
//   const ToggleSwitchScreen({super.key});

//   @override
//   State<ToggleSwitchScreen> createState() => _ToggleSwitchScreenState();
// }

// class _ToggleSwitchScreenState extends State<ToggleSwitchScreen> {
//   bool switchValue = false;

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
//               child: CustomResponsiveContainer(
//                 children: [
//                   CustomResponsiveItem.medium(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         FormRequestToggleSwitch(
//                           update: model.update,
//                           field: model.field,
//                           enabled: true,
//                         ),
//                         FormRequestToggleSwitch(
//                           update: model.update,
//                           label: "Option Sample",
//                           field: model.field,
//                           enabled: true,
//                         ),
//                         FormRequestToggleSwitch(
//                           update: model.update,
//                           label: "Option Sample",
//                           description: "some description",
//                           field: model.field,
//                           enabled: true,
//                         ),
//                         FormRequestToggleSwitch(
//                           update: model.update,
//                           label: "solo label some description",
//                           field: model.field,
//                           enabled: true,
//                         ),
//                         SizedBox(
//                           width: 200,
//                           child: Text("Toggle Switch Sample", style: style),
//                         ),
//                         SizedBox(
//                           height: SpacingValue.px32.value,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             CustomToggleSwitch(
//                               value: switchValue,
//                               onChanged: (value) {
//                                 setState(() {
//                                   switchValue = value;
//                                 });
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   CustomResponsiveItem.medium(
//                     child: Container(
//                       margin: EdgeInsets.only(
//                         top: ResponsiveLayout.value(
//                           context,
//                           Breakpoints(
//                             xs: SpacingValue.px32.value,
//                             md: 0,
//                           ),
//                         ),
//                       ),
//                       child: Focus(
//                         onKeyEvent: (node, event) {
//                           if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
//                             return KeyEventResult.handled;
//                           }
//                           mainFocusNode.requestFocus();
//                           return KeyEventResult.ignored;
//                         },
//                         child: IgnorePointer(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: <Widget>[
//                               SizedBox(
//                                 width: 200,
//                                 child: Text("Toggle Switch Options", style: style),
//                               ),
//                               const SizedBox(height: 20),
//                               CustomToggleSwitch(
//                                 onChanged: (_) {},
//                                 title: "Toggle Off",
//                               ),
//                               const SizedBox(height: 20),
//                               CustomToggleSwitch(
//                                 onChanged: (_) {},
//                                 autofocus: true,
//                                 title: "Toggle Off / Focus",
//                               ),
//                               const SizedBox(height: 20),
//                               CustomToggleSwitch(
//                                 value: true,
//                                 onChanged: (_) {},
//                                 title: "Toggle On",
//                               ),
//                               const SizedBox(height: 20),
//                               CustomToggleSwitch(
//                                 value: true,
//                                 onChanged: (_) {},
//                                 autofocus: true,
//                                 title: "Toggle On / Focus",
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );

//   Widget buildTitle(String title) => Padding(
//         padding: const EdgeInsets.only(bottom: 8),
//         child: Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       );
// }
