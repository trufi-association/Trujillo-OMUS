import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:omus/core/enums/category_enum.dart';
import 'package:omus/data/models/category_report.dart';
import 'package:omus/presentation/widgets/common/general_app_bar.dart';
import 'package:omus/services/api_service.dart';

import 'widgets/category_button.dart';

/// Main screen for displaying mobility statistics.
class StatsViewerScreen extends StatefulWidget {
  const StatsViewerScreen({super.key});

  @override
  StatsViewerScreenState createState() => StatsViewerScreenState();
}

class StatsViewerScreenState extends State<StatsViewerScreen> {
  final List<CategoryEnum> categories = CategoryEnum.values;

  Map<String, CategoryReport>? categoryReports;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await ApiHelper.get(path: '/ChartConfig/config');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(json.decode(response.body));

        categoryReports = data.map(
          (key, value) => MapEntry(key, CategoryReport.fromJson(value)),
        );
        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || categoryReports == null) {
      return const Scaffold(
        body: Center(child: Text('Error al cargar datos')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const GeneralAppBar(
          title: 'Estadísticas de movilidad',
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          _buildGradientOverlay(),
          _buildCategoryGrid(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset(
        'assets/background.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(153, 17, 81, 134),
              Color.fromARGB(125, 0, 0, 0),
            ],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Positioned.fill(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            shrinkWrap: true,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: categories.map((category) {
                  return CategoryButton(
                    category: category,
                    categoryReports: categoryReports!,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
