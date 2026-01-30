/// Enum representing gender categories for heatmap data.
enum Gender {
  men,
  woman,
}

extension GenderExtension on Gender {
  static const Map<String, Gender> _valueMap = {
    'hombre': Gender.men,
    'mujer': Gender.woman,
  };

  static Gender fromValue(String value) => _valueMap[value.toLowerCase()]!;

  String toValue() =>
      _valueMap.entries.firstWhere((entry) => entry.value == this).key;

  String toText() {
    String value = toValue();
    return value[0].toUpperCase() + value.substring(1);
  }
}
