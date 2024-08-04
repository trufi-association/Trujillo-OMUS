// import "package:flutter/material.dart";
// import "package:gizpdp/widgets/components/buttons/text_button.dart";
// import "package:gizpdp/widgets/components/progress_indicator/custom_circular_progress.dart";

// // R is Response model
// // H is the extra model with Help the mail model
// @immutable
// class LoadingStatus {
//   const LoadingStatus({
//     required this.errorCode,
//     required this.loading,
//   });

//   const LoadingStatus.byDefault()
//       : errorCode = null,
//         loading = false;

//   const LoadingStatus.loading()
//       : errorCode = null,
//         loading = true;

//   const LoadingStatus.error(String this.errorCode) : loading = false;

//   const LoadingStatus.success()
//       : errorCode = null,
//         loading = false;
//   final String? errorCode;
//   final bool loading;
// }

// typedef ExtraAsyncFunction = Future<void> Function(
//   Future<void> Function() function,
// );

// @immutable
// class ValueContainer<R, H> {
//   const ValueContainer({
//     required this.original,
//     required this.helperModel,
//   });

//   final R original;
//   final H? helperModel;
// }

// class SingleLoadingHelper<R, H> extends StatefulWidget {
//   const SingleLoadingHelper({
//     super.key,
//     required this.id,
//     required this.defaultCreate,
//     required this.loadModel,
//     this.loadExtraModel,
//     required this.builder,
//   });

//   final String? id;

//   final R Function() defaultCreate;
//   final Future<R> Function(String id) loadModel;
//   final Future<H> Function()? loadExtraModel;

//   final Widget Function(
//     ValueContainer<R, H> value,
//     LoadingStatus loading,
//     ExtraAsyncFunction extraFunction,
//   ) builder;

//   @override
//   State createState() => _SingleLoadingHelperState<R, H>();
// }

// class _SingleLoadingHelperState<R, H> extends State<SingleLoadingHelper<R, H>> {
//   LoadingStatus initialLoadingStatus = const LoadingStatus.byDefault();
//   LoadingStatus saveLoadingStatus = const LoadingStatus.byDefault();
//   ValueContainer<R, H>? valueContainer;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       loadModel();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (initialLoadingStatus.loading) {
//       return const Center(
//         child: CustomCircularProgressIndicator(),
//       );
//     }
//     if (initialLoadingStatus.errorCode != null) {
//       return Center(
//         child: Column(
//           children: [
//             Text(initialLoadingStatus.errorCode!),
//             TextButtonPrimary(
//               title: const Text("Try again"),
//               onPressed: loadModel,
//             ),
//           ],
//         ),
//       );
//     }
//     if (valueContainer == null) {
//       return Center(
//         child: Column(
//           children: [
//             const Text("Model not found"),
//             TextButtonPrimary(
//               title: const Text("Fatal error"),
//               onPressed: loadModel,
//             ),
//           ],
//         ),
//       );
//     }
//     return widget.builder(
//       valueContainer!,
//       saveLoadingStatus,
//       extraAsyncFunction,
//     );
//   }

//   Future<void> extraAsyncFunction(Future<void> Function() function) async {
//     setState(() {
//       saveLoadingStatus = const LoadingStatus.loading();
//     });
//     try {
//       await function();
//       // widget.onExtraFunction?.call();
//       setState(() {
//         saveLoadingStatus = const LoadingStatus.success();
//       });
//     } catch (e) {
//       setState(() {
//         saveLoadingStatus = LoadingStatus.error("$e");
//       });
//       rethrow;
//     }
//   }

//   Future<void> loadModel() async {
//     setState(() {
//       initialLoadingStatus = const LoadingStatus.loading();
//     });
//     try {
//       if (widget.id == null) {
//         final helperModelResponse = (widget.loadExtraModel != null) ? await widget.loadExtraModel!() : null;
//         final modelResponse = widget.defaultCreate();
//         setState(() {
//           initialLoadingStatus = const LoadingStatus.success();
//           valueContainer = ValueContainer(
//             original: modelResponse,
//             helperModel: helperModelResponse,
//           );
//         });
//       } else {
//         final loadModelRequest = widget.loadModel(widget.id!);
//         final response = await Future.wait([
//           loadModelRequest,
//           if (widget.loadExtraModel != null) widget.loadExtraModel!(),
//         ]);
//         final modelResponse = response[0] as R;
//         final helperModelResponse = widget.loadExtraModel != null ? response[1] as H : null;
//         setState(() {
//           initialLoadingStatus = const LoadingStatus.success();
//           valueContainer = ValueContainer(
//             original: modelResponse,
//             helperModel: helperModelResponse,
//           );
//         });
//       }
//     } catch (e) {
//       setState(() {
//         initialLoadingStatus = LoadingStatus.error("$e");
//       });
//     }
//   }
// }
