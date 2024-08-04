import "package:flutter/material.dart";

@immutable
class DropdownItem {
  const DropdownItem({
    required this.id,
    this.text = "",
  });

  final String id;
  final String text;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DropdownCheckItem {
  const DropdownCheckItem({
    required this.id,
    required this.text,
    this.isChecked = false,
  });

  final String id;
  final String text;
  final bool isChecked;

  DropdownCheckItem copyWith({
    String? id,
    String? text,
    bool? isChecked,
  }) =>
      DropdownCheckItem(
        id: id ?? this.id,
        text: text ?? this.text,
        isChecked: isChecked ?? this.isChecked,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownCheckItem && other.id == id && other.isChecked == isChecked;
  }

  @override
  int get hashCode => id.hashCode;
}
