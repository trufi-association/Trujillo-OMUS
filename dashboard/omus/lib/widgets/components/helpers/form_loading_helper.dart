import "package:flutter/material.dart";

@immutable
class LoadingStatus {
  const LoadingStatus({
    required this.errorCode,
    required this.loading,
  });

  const LoadingStatus.byDefault()
      : errorCode = null,
        loading = false;

  const LoadingStatus.loading()
      : errorCode = null,
        loading = true;

  const LoadingStatus.error(String this.errorCode) : loading = false;

  const LoadingStatus.success()
      : errorCode = null,
        loading = false;
  final String? errorCode;
  final bool loading;
}

typedef ExtraAsyncFunction = Future<void> Function(
  Future<void> Function() function,
);

// // R is Response model
// // M is request Model with mutate during the manipulation of the form
// // H is the extra model with Help the mail model
// @immutable
// class ValueContainer<R, M, H> {
//   const ValueContainer({
//     required this.original,
//     required this.model,
//     required this.helperModel,
//   });

//   final R original;
//   final M model;
//   final H? helperModel;

//   ValueContainer<R, M, H> updateModel(M model) => ValueContainer<R, M, H>(
//         original: this.original,
//         model: model,
//         helperModel: this.helperModel,
//       );
// }

// class FormLoadingHelper<R, M, H> extends StatefulWidget {
//   const FormLoadingHelper({
//     super.key,
//     required this.id,
//     required this.defaultCreate,
//     required this.loadModel,
//     required this.convertModel,
//     this.loadExtraModel,
//     // this.onExtraFunction,
//     required this.saveModel,
//     required this.onSaveChanges,
//     this.formValidate,
//     required this.builder,
//   });

//   final String? id;

//   final Function() defaultCreate;
//   final Future<R> Function(String id) loadModel;
//   final M Function(R) convertModel;
//   final Future<H> Function()? loadExtraModel;

//   // final void Function()? onExtraFunction;
//   final Future<void> Function(M notificationRule, {String? id}) saveModel;
//   final void Function() onSaveChanges;
//   final bool Function()? formValidate;

//   final Widget Function(
//     ValueContainer<R, M, H> value,
//     void Function(M) updateModel,
//     Future<void> Function() saveChanges,
//     LoadingStatus loading,
//     ExtraAsyncFunction extraFunction,
//     void Function() refetchData,
//   ) builder;

//   @override
//   State createState() => _FormLoadingHelperState<R, M, H>();
// }

// class _FormLoadingHelperState<R, M, H> extends State<FormLoadingHelper<R, M, H>> {
//   LoadingStatus initialLoadingStatus = const LoadingStatus.byDefault();
//   LoadingStatus saveLoadingStatus = const LoadingStatus.byDefault();
//   ValueContainer<R, M, H>? valueContainer;

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
//       (modelToUpdate) {
//         setState(() {
//           valueContainer = valueContainer!.updateModel(modelToUpdate);
//         });
//       },
//       saveChanges,
//       saveLoadingStatus,
//       extraAsyncFunction,
//       loadModel,
//     );
//   }

//   Future<void> saveChanges() async {
//     if (widget.formValidate != null && !widget.formValidate!()) return;
//     setState(() {
//       saveLoadingStatus = const LoadingStatus.loading();
//     });
//     try {
//       await widget.saveModel(valueContainer!.model, id: widget.id);
//       widget.onSaveChanges();
//       setState(() {
//         saveLoadingStatus = const LoadingStatus.success();
//       });
//     } catch (e) {
//       setState(() {
//         saveLoadingStatus = LoadingStatus.error("$e");
//       });
//     }
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
//         final requestModel = widget.convertModel(modelResponse);
//         setState(() {
//           initialLoadingStatus = const LoadingStatus.success();
//           valueContainer = ValueContainer(
//             original: modelResponse,
//             model: requestModel,
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
//         final requestModel = widget.convertModel(modelResponse);
//         final helperModelResponse = widget.loadExtraModel != null ? response[1] as H : null;
//         setState(() {
//           initialLoadingStatus = const LoadingStatus.success();
//           valueContainer = ValueContainer(
//             original: modelResponse,
//             model: requestModel,
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
