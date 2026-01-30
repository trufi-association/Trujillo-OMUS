import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:omus/core/enums/category_enum.dart';
import 'package:omus/data/models/category_report.dart';

/// Widget that displays a category button in the stats viewer.
class CategoryButton extends StatefulWidget {
  const CategoryButton({
    super.key,
    required this.category,
    required this.categoryReports,
  });

  final CategoryEnum category;
  final Map<String, CategoryReport> categoryReports;

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 200,
      child: MouseRegion(
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: InkWell(
          onTap: () => _showFullScreenPopup(
            context,
            widget.category.title,
            builder: (_, __) =>
                widget.category.buildBody(widget.categoryReports),
          ),
          child: Tooltip(
            message: widget.category.tooltip,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: hover
                    ? const Color(0xFF0077AE)
                    : const Color.fromRGBO(255, 255, 255, 0.8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.string(
                    theme: const SvgTheme(currentColor: Colors.red),
                    widget.category.svgString,
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    widget.category.title,
                    style: TextStyle(
                      color: hover ? Colors.white : Colors.black,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows a full screen popup dialog with a builder.
void _showFullScreenPopup(
  BuildContext context,
  String title, {
  required Widget Function(BuildContext, BoxConstraints) builder,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: const Color(0xFFD4DFE9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(builder: builder),
              ),
            ],
          ),
        ),
      );
    },
  );
}
