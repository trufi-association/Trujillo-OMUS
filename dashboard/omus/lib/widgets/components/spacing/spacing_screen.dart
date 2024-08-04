import "package:flutter/material.dart";
import "package:omus/widgets/components/spacing/space_values.dart";

class SpacingScreen extends StatelessWidget {
  const SpacingScreen({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "Spacing samples",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Text(
                  "4 px",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 30),
                CustomSpacing(size: SpacingValue.px4),
              ],
            ),
            Row(
              children: [
                Text(
                  "8 px",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 30),
                CustomSpacing(size: SpacingValue.px8),
              ],
            ),
            Row(
              children: [
                Text(
                  "16 px",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 20),
                CustomSpacing(size: SpacingValue.px16),
              ],
            ),
            Row(
              children: [
                Text(
                  "24 px",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 20),
                CustomSpacing(size: SpacingValue.px16),
              ],
            ),
            Row(
              children: [
                Text(
                  "32 px",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 20),
                CustomSpacing(size: SpacingValue.px32),
              ],
            ),
            Row(
              children: [
                Text(
                  "40 px",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 20),
                CustomSpacing(size: SpacingValue.px40),
              ],
            ),
            Row(
              children: [
                Text(
                  "56 px",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 20),
                CustomSpacing(size: SpacingValue.px56),
              ],
            ),
            Row(
              children: [
                Text(
                  "80 px",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 20),
                CustomSpacing(size: SpacingValue.px80),
              ],
            ),
            Row(
              children: [
                Text(
                  "120 px",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                CustomSpacing(size: SpacingValue.px120),
              ],
            ),
            Row(
              children: [
                Text(
                  "152 px",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                CustomSpacing(size: SpacingValue.px152),
              ],
            ),
            Row(
              children: [
                Text(
                  "200 px",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                CustomSpacing(size: SpacingValue.px200),
              ],
            ),
          ],
        ),
      );
}

class CustomSpacing extends StatelessWidget {
  const CustomSpacing({
    super.key,
    required this.size,
  });

  final SpacingValue size;

  @override
  Widget build(BuildContext context) => Container(
        height: 2,
        width: size.value,
        color: Colors.grey,
      );
}
