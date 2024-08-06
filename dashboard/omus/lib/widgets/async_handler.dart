import "package:flutter/material.dart";

class AsyncHelper extends StatefulWidget {
  const AsyncHelper({super.key, required this.builder});

  final Widget Function(AsyncState params) builder;

  @override
  State<AsyncHelper> createState() => _AsyncHelperState();
}

class _AsyncHelperState extends State<AsyncHelper> {
  LoadingStatus loadingStatus = const LoadingStatus.initial();

  @override
  Widget build(BuildContext context) => widget.builder(
        AsyncState(
          runAsync: _executeAsyncFunction,
          loadingStatus: loadingStatus,
        ),
      );

  Future<void> _executeAsyncFunction(Future<void> Function() asyncFunction) async {
    assert(!loadingStatus.isLoading);
    setState(() {
      loadingStatus = const LoadingStatus.loading();
    });
    try {
      await asyncFunction();
      setState(() {
        loadingStatus = const LoadingStatus.success();
      });
    } catch (e) {
      setState(() {
        loadingStatus = LoadingStatus.error(e.toString());
      });
    }
  }
}

@immutable
class AsyncState {
  const AsyncState({
    required this.runAsync,
    required this.loadingStatus,
  });

  final Future<void> Function(Future<void> Function() asyncFunction) runAsync;
  final LoadingStatus loadingStatus;
}

@immutable
class LoadingStatus {
  const LoadingStatus._({this.errorCode, required this.isLoading});

  const LoadingStatus.initial() : this._(isLoading: false);
  const LoadingStatus.loading() : this._(isLoading: true);
  const LoadingStatus.success() : this._(isLoading: false);
  const LoadingStatus.error(String errorCode) : this._(errorCode: errorCode, isLoading: false);

  final String? errorCode;
  final bool isLoading;

  @override
  String toString() {
    if (isLoading) return "Loading";
    if (errorCode != null) return "Error: $errorCode";
    return "Success";
  }
}
