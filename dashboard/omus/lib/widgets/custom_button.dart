import 'package:flutter/material.dart';

enum ButtonShape {
  rounded,
  extraRounded,
  rectangular,
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onTap,
    required this.label,
    this.height = 50,
    this.width,
    this.enabled = true,
    this.isPrimary = true,
    this.isLargeText = false,
    this.textColor,
    this.fontSize,
    this.showShadow = false,
    this.buttonShape = ButtonShape.rounded, // Default to rounded shape
    this.borderColor,
    this.loading = false,
    this.buttonColor,
  });

  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final bool enabled;
  final String label;
  final bool isPrimary;
  final bool isLargeText;
  final Color? textColor;
  final double? fontSize;
  final bool showShadow;
  final ButtonShape buttonShape; // Add shape property
  final Color? borderColor;
  final bool loading;
  final Color? buttonColor;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = buttonColor ??
        (isPrimary ? const Color.fromARGB(255, 0, 159, 225) : Colors.white);
    const Color defaultBorderColor = Color.fromARGB(255, 0, 159, 225);
    final Color actualBorderColor = borderColor ?? defaultBorderColor;
    final Color defaultTextColor = isPrimary ? Colors.white : actualBorderColor;
    final double defaultFontSize = isLargeText ? 18.0 : 14.0;

    final Map<ButtonShape, double> borderRadiusMap = {
      ButtonShape.extraRounded: 40.0,
      ButtonShape.rectangular: 8.0,
      ButtonShape.rounded: 20.0,
    };

    final borderRadiusValue = borderRadiusMap[buttonShape] ?? 20.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: enabled ? backgroundColor : Colors.grey[300],
            border: Border.all(
              color: !enabled
                  ? Colors.grey[300]!
                  : isPrimary
                      ? Colors.transparent
                      : actualBorderColor,
              width: 2.5,
            ),
            borderRadius: BorderRadius.circular(borderRadiusValue),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                    width: 40,
                    child: Center(child: CircularProgressIndicator())),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: enabled
                      ? (textColor ?? defaultTextColor)
                      : Colors.grey[400],
                  fontSize: fontSize ?? defaultFontSize,
                ),
              ),
              if (loading)
                Container(
                  width: 40,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
