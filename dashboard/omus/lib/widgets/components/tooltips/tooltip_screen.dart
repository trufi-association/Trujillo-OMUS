import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:omus/widgets/components/spacing/space_values.dart";
import "package:omus/widgets/components/tooltips/tooltip_widgets.dart";

class TooltipScreen extends StatelessWidget {
  const TooltipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(
              "Tooltips Sample",
              style: theme.textTheme.displaySmall,
            ),
            SizedBox(height: SpacingValue.px32.value),
            const TooltipInfoWidget(
              message: "Project metadata",
              maxWidthMessage: 600,
            ),
            SizedBox(height: SpacingValue.px32.value),
            const TooltipInfoWidget(
              message:
                  "Certainly!\n\n To ensure that the widthMessage and heightMessage are dynamically calculated based on the content, we can improve the existing code to handle text wrapping more efficiently.\n\nHeres the updated code:",
              maxWidthMessage: 500,
            ),
            SizedBox(height: SpacingValue.px32.value),
            TooltipInfoWidget(
              richMessage: TextSpan(
                text: "Project metadata   ",
                style: TextStyle(color: Colors.pink[50]),
                children: [
                  TextSpan(
                    text: "Link",
                    recognizer: TapGestureRecognizer()..onTap = () {},
                    style: TextStyle(color: Colors.blue[100]!),
                  ),
                ],
              ),
              maxWidthMessage: 600,
            ),
            SizedBox(height: SpacingValue.px32.value),
            const TooltipInfoWidget(
              message: "Connection with On-Site Generation",
              maxWidthMessage: 300,
            ),
          ],
        ),
      ),
    );
  }
}
