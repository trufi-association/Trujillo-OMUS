import "package:flutter/material.dart";
import "package:omus/widgets/async_handler.dart";
import "package:omus/widgets/components/helpers/form_request_container.dart";
import "package:omus/widgets/components/textfield/form_request_field.dart";

class ResponseModelContainer<R, H> {
  const ResponseModelContainer({
    required this.response,
    required this.responseHelper,
  });

  final R? response;
  final H? responseHelper;
}

typedef FormRequestUpdate = void Function(void Function());

class FormRequestHelperParams<R, M extends FormRequest, H> {
  FormRequestHelperParams({
    required this.responseModel,
    required this.model,
    required this.saveChanges,
    required this.reloadData,
    required this.asyncHelperParams,
    required this.formRequestParams,
  });

  final ResponseModelContainer<R, H> responseModel;
  final M model;
  final Future<void> Function({Future<void> Function() postCall}) saveChanges;
  final void Function() reloadData;

  final AsyncState asyncHelperParams;
  final FormRequestParams<M> formRequestParams;
}

class FormRequestManager<R, M extends FormRequest, H> extends StatelessWidget {
  const FormRequestManager({
    super.key,
    required this.id,
    this.offline = false,
    required this.fromScratch,
    required this.loadModel,
    required this.fromResponse,
    this.loadExtraModel,
    required this.saveModel,
    required this.onSaveChanges,
    required this.builder,
  });

  final String? id;
  final bool offline;
  final M Function() fromScratch;
  final Future<R> Function(String id)? loadModel;
  final M Function(R) fromResponse;
  final Future<H> Function()? loadExtraModel;

  final Future<void> Function(M model, {String? id}) saveModel;
  final void Function()? onSaveChanges;

  final Widget Function(FormRequestHelperParams<R, M, H> params) builder;

  @override
  Widget build(BuildContext context) => AsyncHelper(
        builder: (params) => FormRequestHelper<R, M, H>(
          asyncHelperParams: params,
          id: id,
          builder: builder,
          convertModel: fromResponse,
          defaultCreate: fromScratch,
          loadModel: loadModel,
          onSaveChanges: onSaveChanges,
          saveModel: saveModel,
          loadExtraModel: loadExtraModel,
        ),
      );
}

class FormRequestHelper<R, M extends FormRequest, H> extends StatefulWidget {
  const FormRequestHelper({
    super.key,
    required this.asyncHelperParams,
    required this.id,
    required this.defaultCreate,
    required this.loadModel,
    required this.convertModel,
    this.loadExtraModel,
    required this.saveModel,
    required this.onSaveChanges,
    required this.builder,
  });
  final AsyncState asyncHelperParams;
  final String? id;

  final M Function() defaultCreate;
  final Future<R> Function(String id)? loadModel;
  final M Function(R) convertModel;
  final Future<H> Function()? loadExtraModel;

  final Future<void> Function(M model, {String? id}) saveModel;
  final void Function()? onSaveChanges;

  final Widget Function(FormRequestHelperParams<R, M, H> params) builder;

  @override
  State createState() => _FormRequestHelperState<R, M, H>();
}

class _FormRequestHelperState<R, M extends FormRequest, H> extends State<FormRequestHelper<R, M, H>> {
  ResponseModelContainer<R, H>? responseModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadModel();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asyncHelperParams.loadingStatus.isLoading && responseModel?.response == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.asyncHelperParams.loadingStatus.errorCode != null) {
      return Center(
        child: Column(
          children: [
            Text(widget.asyncHelperParams.loadingStatus.errorCode!),
            ElevatedButton(
              onPressed: loadModel,
              child: const Text("Try again"),
            ),
          ],
        ),
      );
    }
    if (responseModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FormRequestContainer<M>(
      create: () => responseModel!.response == null ? widget.defaultCreate() : widget.convertModel(responseModel!.response as R),
      builder: (formRequestParams) => AsyncHelper(
        builder: (params) => widget.builder(
          FormRequestHelperParams<R, M, H>(
            responseModel: responseModel!,
            asyncHelperParams: params,
            formRequestParams: formRequestParams,
            saveChanges: ({Future<void> Function()? postCall}) async {
              if (!formRequestParams.isFormCompleted()) return;
              params.runAsync(() async {
                await widget.saveModel(formRequestParams.model, id: widget.id);
                await postCall?.call();
                widget.onSaveChanges?.call();
              });
            },
            reloadData: () async {
              await loadModel();
              formRequestParams.resetData();
            },
            model: formRequestParams.model,
          ),
        ),
      ),
    );
  }

  Future<void> loadModel() => widget.asyncHelperParams.runAsync(() async {
        if (widget.id == null || widget.loadModel == null) {
          final helperModelResponse = await widget.loadExtraModel?.call();
          setState(() {
            responseModel = ResponseModelContainer(
              response: null,
              responseHelper: helperModelResponse,
            );
          });
        } else {
          final loadModelRequest = widget.loadModel!(widget.id!);
          final response = await Future.wait([
            loadModelRequest,
            if (widget.loadExtraModel != null) widget.loadExtraModel!(),
          ]);
          final modelResponse = response[0] as R;
          final helperModelResponse = widget.loadExtraModel != null ? response[1] as H : null;
          setState(() {
            responseModel = ResponseModelContainer(
              response: modelResponse,
              responseHelper: helperModelResponse,
            );
          });
        }
      });
}
