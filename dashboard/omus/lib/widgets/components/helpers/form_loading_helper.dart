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
