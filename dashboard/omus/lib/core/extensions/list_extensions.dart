/// Extension to find an element or return null if not found.
extension FindOrNullExtension<T> on List<T> {
  T? findOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
