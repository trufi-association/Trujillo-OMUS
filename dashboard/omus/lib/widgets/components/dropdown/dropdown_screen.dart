import "package:flutter/material.dart";
import "package:omus/widgets/components/dropdown/helpers/dropdown_item.dart";
import "package:omus/widgets/components/helpers/responsive_container.dart";
import "package:omus/widgets/components/spacing/space_values.dart";

class DropdownScreen extends StatefulWidget {
  const DropdownScreen({super.key});

  @override
  State<DropdownScreen> createState() => _DropdownScreenState();
}

class _DropdownScreenState extends State<DropdownScreen> {
  final formKey = GlobalKey<FormState>();
  final String textLabel = "Label";
  final items = List.generate(
    20,
    (index) {
      final valueIndex = index + 1;
      return DropdownItem(
        id: "Option $valueIndex",
        text: "Option $valueIndex",
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: CustomResponsiveContainer(
          children: [
            CustomResponsiveItem.extraLarge(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      formKey.currentState!.save();
                      if (!formKey.currentState!.validate()) return;
                    },
                    child: const Text("Upload"),
                  ),
                  Text(
                    "Dropdown Sample",
                    style: theme.textTheme.displaySmall,
                  ),
                  SizedBox(height: SpacingValue.px56.value),
                  Text(
                    "Single Select Dropdown:",
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(
                    height: 500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
