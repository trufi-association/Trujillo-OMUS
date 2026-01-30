import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';

/// Widget that displays a pie chart of report statistics by category.
class ReportPieChart extends StatefulWidget {
  final List<Report> reports;
  final Map<int, Category> categories;
  final void Function() onClose;

  const ReportPieChart({
    super.key,
    required this.reports,
    required this.categories,
    required this.onClose,
  });

  @override
  State<ReportPieChart> createState() => _ReportPieChartState();
}

class _ReportPieChartState extends State<ReportPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Estadisticas de reportes',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(
                  Icons.close,
                  size: 30,
                ),
              ),
            ],
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final shortesSide = constraints.biggest.shortestSide;
              return PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex =
                            pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 20,
                  sections: _showingSections(shortesSide / 2.5),
                ),
              );
            }),
          ),
          Column(
            children: widget.categories.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Indicator(
                  color: entry.value.color,
                  text: entry.value.categoryName ?? 'Unknown',
                  isSquare: true,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections(double shortesSide) {
    Map<int, int> categoryCounts = {};
    for (var report in widget.reports) {
      int? subCategoryId = report.categoryId;
      Category? category = widget.categories[subCategoryId];
      if (category == null) {
        for (final categoryItem in widget.categories.values) {
          for (final subCategory in categoryItem.subcategories) {
            if (subCategory.id == subCategoryId) {
              category = categoryItem;
              break;
            }
          }
          if (category != null) break;
        }
      }
      if (category != null) {
        int mainCategoryId = category.parentId ?? category.id;
        categoryCounts[mainCategoryId] =
            (categoryCounts[mainCategoryId] ?? 0) + 1;
      }
    }

    int index = 0;
    return categoryCounts.entries.map((entry) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? shortesSide + 10 : shortesSide;
      final double percentage =
          entry.value.toDouble() / widget.reports.length * 100;
      index++;

      return PieChartSectionData(
        color: widget.categories[entry.key]?.color ?? Colors.grey,
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }
}

/// Widget that displays a color indicator with text.
class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
