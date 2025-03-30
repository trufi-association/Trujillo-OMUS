import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:omus/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DataLoader extends StatefulWidget {
  const DataLoader({super.key});

  @override
  State<DataLoader> createState() => _DataLoaderState();
}

class _DataLoaderState extends State<DataLoader> {
  Map<String, dynamic>? data;
  bool hover = false;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await ApiHelper.get(path: '/ChartConfig/config');

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
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
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError || data == null) {
      return const Center(child: Text("Error al cargar datos"));
    }
    return ChartAdminScreen(
      data: data!,
    );
  }
}

class ChartAdminScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const ChartAdminScreen({super.key, required this.data});

  @override
  _ChartAdminScreenState createState() => _ChartAdminScreenState();
}

class _ChartAdminScreenState extends State<ChartAdminScreen> {
  late Map<String, dynamic> _editableData;
  final Map<String, TextEditingController> _titleControllers = {};
  final Map<String, TextEditingController> _descriptionControllers = {};
  final Map<String, TextEditingController> _urlControllers = {};

  @override
  void initState() {
    super.initState();
    _editableData = jsonDecode(jsonEncode(widget.data));
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var sectionKey in _editableData.keys) {
      final items = _editableData[sectionKey]["items"] as List<dynamic>? ?? [];
      for (int i = 0; i < items.length; i++) {
        String key = "$sectionKey-$i";
        _titleControllers[key] = TextEditingController(text: items[i]["title"]);
        _descriptionControllers[key] = TextEditingController(text: items[i]["description"]);
        _urlControllers[key] = TextEditingController(text: items[i]["url"]);
      }
    }
  }

  void _updateItem(String sectionKey, int index, String field, String newValue) {
    setState(() {
      _editableData[sectionKey]["items"][index][field] = newValue;
    });
  }

  Future<void> _saveChanges() async {
    try {
      final response = await ApiHelper.post(path: '/ChartConfig/update', body: jsonEncode(_editableData), useToken: true);
      if (response.statusCode == 200) {
        _showMessage("Datos guardados correctamente.");
      } else {
        _showMessage("Error al guardar los datos.");
      }
    } catch (e) {
      _showMessage("Error en la conexión: $e");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showMessage("No se pudo abrir el enlace.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: _editableData.entries.map((entry) {
          final sectionKey = entry.key;
          final sectionTitle = entry.value["title"];
          final items = entry.value["items"] as List<dynamic>?;

          return ExpansionTile(
            title: Text(sectionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            children: items?.asMap().entries.map((itemEntry) {
                  final index = itemEntry.key;
                  final item = itemEntry.value;
                  return _buildEditableItem(sectionKey, index, item);
                }).toList() ??
                [],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveChanges,
        child: const Icon(Icons.save),
        tooltip: "Guardar cambios",
      ),
    );
  }

  Widget _buildEditableItem(String sectionKey, int index, Map<String, dynamic> item) {
    String key = "$sectionKey-$index";
    final titleController = _titleControllers[key]!;
    final descriptionController = _descriptionControllers[key]!;
    final urlController = _urlControllers[key]!;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Título:", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: titleController,
              onChanged: (value) => _updateItem(sectionKey, index, "title", value),
            ),
            Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: descriptionController,
              onChanged: (value) => _updateItem(sectionKey, index, "description", value),
            ),
            const SizedBox(height: 8),
            Text("URL y Tipo:", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: urlController,
                    onChanged: (value) => _updateItem(sectionKey, index, "url", value),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.open_in_new, color: Colors.blue),
                        onPressed: () => _openUrl(urlController.text),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: item["type"],
                  onChanged: (newValue) => _updateItem(sectionKey, index, "type", newValue!),
                  items: ["PowerBI", "PDF"].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleControllers.forEach((_, controller) => controller.dispose());
    _descriptionControllers.forEach((_, controller) => controller.dispose());
    _urlControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
