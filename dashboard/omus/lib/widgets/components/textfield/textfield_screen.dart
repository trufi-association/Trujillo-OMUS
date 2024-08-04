// import "package:flutter/material.dart";
// import "package:omus/widgets/components/helpers/form_request_container.dart";
// import "package:omus/widgets/components/textfield/form_request_field.dart";
// import "package:omus/widgets/components/tooltips/tooltip_text_widget.dart";

// class _SampleRequest extends FormRequest {
//   _SampleRequest({
//     required this.text,
//     required this.doubleNumber,
//     required this.intNumber,
//   });

//   factory _SampleRequest.fromScratch() => _SampleRequest(
//         text: FormItemContainer<String>(
//           fieldKey: "text",
//         ),
//         doubleNumber: FormItemContainer<double>(
//           fieldKey: "doubleNumber",
//         ),
//         intNumber: FormItemContainer<int>(
//           fieldKey: "intNumber",
//         ),
//       );

//   final FormItemContainer<String> text;
//   final FormItemContainer<double> doubleNumber;
//   final FormItemContainer<int> intNumber;
// }

// class TextfieldScreen extends StatefulWidget {
//   const TextfieldScreen({super.key});

//   @override
//   State<TextfieldScreen> createState() => _TextfieldScreenState();
// }

// class _TextfieldScreenState extends State<TextfieldScreen> {
//   @override
//   Widget build(BuildContext context) => FormRequestContainer<_SampleRequest>(
//         create: _SampleRequest.fromScratch,
//         builder: (params) {
//           final model = params.model;
//           print("text ${model.text.value}");
//           print("doubleNumber ${model.doubleNumber.value}");
//           print("intNumber ${model.intNumber.value}");
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 FormRequestField(
//                   field: model.text,
//                   label: "String",
//                   enabled: true,
//                   update: model.update,
//                 ),
//                 FormRequestField(
//                   field: model.doubleNumber,
//                   label: "Double",
//                   enabled: true,
//                   update: model.update,
//                 ),
//                 FormRequestField(
//                   field: model.intNumber,
//                   label: "Int",
//                   enabled: true,
//                   update: model.update,
//                 ),
//                 const Text("Text area"),
//                 FormRequestField(
//                   tooltipConfig: const TooltipConfig(message: "tooltip"),
//                   field: model.text,
//                   label: "String",
//                   enabled: true,
//                   isTextArea: true,
//                   update: model.update,
//                 ),
//               ],
//             ),
//           );
//         },
//       );
// }
