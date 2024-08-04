import "package:flutter/material.dart";
import "package:omus/widgets/components/textfield/form_request_field.dart";
import "package:provider/provider.dart";

class FormRequestParams<T> {
  FormRequestParams({
    required this.model,
    required this.isFormCompleted,
    required this.resetData,
  });

  final T model;
  final bool Function() isFormCompleted;
  final void Function() resetData;
}

class FormRequestContainer<T extends FormRequest> extends StatefulWidget {
  const FormRequestContainer(
      {super.key, required this.create, required this.builder});
  final T Function() create;
  final Widget Function(FormRequestParams<T> params) builder;

  @override
  State<FormRequestContainer<T>> createState() =>
      _FormRequestContainerState<T>();
}

class _FormRequestContainerState<T extends FormRequest>
    extends State<FormRequestContainer<T>> {
  final formKey = GlobalKey<FormState>();
  late T model;

  @override
  void initState() {
    super.initState();
    model = widget.create();
  }

  @override
  Widget build(BuildContext _) => ChangeNotifierProvider<T>.value(
        value: model,
        child: Form(
          key: formKey,
          child: Builder(
            builder: (context) => widget.builder(
              FormRequestParams<T>(
                model: context.watch<T>(),
                isFormCompleted: () {
                  formKey.currentState!.save();
                  return formKey.currentState!.validate();
                },
                resetData: () => setState(() => model = widget.create()),
              ),
            ),
          ),
        ),
      );
}
