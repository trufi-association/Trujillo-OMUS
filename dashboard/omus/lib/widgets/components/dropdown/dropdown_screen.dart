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
                  // TODO GT migrate component
                  // _DropdownContainer(
                  //   title: "",
                  //   width: 0,
                  //   child: SingleSelectFormDropdown(
                  //     labelText: textLabel,
                  //     items: items
                  //         .map(
                  //           (e) => DropdownItem(id: e.id, text: e.text),
                  //         )
                  //         .toList(),
                  //     onChanged: (value) {},
                  //     // validator: (value) {
                  //     //   return value != null ? null : 'Error Notification';
                  //     // },
                  //   ),
                  // ),
                  // Text(
                  //   "Single Select Dropdown(Search):",
                  //   style: theme.textTheme.bodyLarge,
                  // ),
                  // _DropdownContainer(
                  //   title: "",
                  //   width: 0,
                  //   child: SingleSelectFormDropdown(
                  //     labelText: textLabel,
                  //     items: items
                  //         .map(
                  //           (e) => DropdownItem(id: e.id, text: e.text),
                  //         )
                  //         .toList(),
                  //     onChanged: (value) {},
                  //     selectedItem: "Option 1",
                  //     required: true,
                  //   ),
                  // ),
                  // Text(
                  //   "Multi Select Dropdown:",
                  //   style: theme.textTheme.bodyLarge,
                  // ),
                  // _DropdownContainer(
                  //   title: "",
                  //   width: 0,
                  //   child: MultiSelectFormDropdown(
                  //     labelText: textLabel,
                  //     items: items
                  //         .map(
                  //           (e) => DropdownItem(id: e.id, text: e.text),
                  //         )
                  //         .toList(),
                  //     onSelectionItems: (_) {},
                  //     onItemChange: (_, __) {},
                  //     minSelectionRequired: 2,
                  //     required: true,
                  //   ),
                  // ),
                  // Text(
                  //   "Multi Select Dropdown:",
                  //   style: theme.textTheme.bodyLarge,
                  // ),
                  // _DropdownContainer(
                  //   title: "",
                  //   width: 0,
                  //   child: YearPickerTextFormField(
                  //     labelText: "YearPicker",
                  //     // initialDate: DateTime.now(),
                  //     startDateTime: DateTime(2024),
                  //     endDateTime: DateTime(2025),
                  //     // enabled: true,
                  //     required: true,
                  //     onChanged: null,
                  //     // readOnly: true,
                  //     autofocus: true,
                  //   ),
                  // ),
                  // _DropdownContainer(
                  //   title: "",
                  //   width: 0,
                  //   child: DatePickerTextFormField(
                  //     labelText: "UpdatedOn",
                  //     // initialDate: DateTime.now(),
                  //     // startDateTime: DateTime(2024),
                  //     // endDateTime: DateTime(2025),
                  //     // enabled: true,
                  //     onChanged: null,
                  //     required: true,
                  //     // readOnly: true,
                  //     autofocus: true,
                  //   ),
                  // ),
                  // _DropdownContainer(
                  //   title: "",
                  //   width: 0,
                  //   child: DateRangePickerTextFormField(
                  //     labelText: "RangeDatePicker",
                  //     required: true,
                  //     onChanged: null,
                  //     // readOnly: true,
                  //     // initialDateRange: DateTimeRange(
                  //     //   start: DateTime.now(),
                  //     //   end: DateTime.now().add(const Duration(days: 5)),
                  //     // ),
                  //   ),
                  // ),
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
