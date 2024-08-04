enum SpacingValue {
  px4,
  px8,
  px16,
  px24,
  px32,
  px40,
  px56,
  px80,
  px120,
  px152,
  px200,
}

extension SpacingValueExtension on SpacingValue {
  static const Map<SpacingValue, double> _values = {
    SpacingValue.px4: 4,
    SpacingValue.px8: 8,
    SpacingValue.px16: 16,
    SpacingValue.px24: 24,
    SpacingValue.px32: 32,
    SpacingValue.px40: 40,
    SpacingValue.px56: 56,
    SpacingValue.px80: 80,
    SpacingValue.px120: 120,
    SpacingValue.px152: 152,
    SpacingValue.px200: 200,
  };

  double get value => _values[this]!;
}
