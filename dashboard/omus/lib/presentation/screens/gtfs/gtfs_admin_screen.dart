import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:omus/services/api_service.dart';

/// Admin screen for GTFS management with tabs for execution, status, and routes.
class GTFSAdminScreen extends StatefulWidget {
  const GTFSAdminScreen({super.key});

  @override
  State<GTFSAdminScreen> createState() => _GTFSAdminScreenState();
}

class _GTFSAdminScreenState extends State<GTFSAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ejecutar'),
            Tab(text: 'Estado'),
            Tab(text: 'Rutas'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _ExecutePostTab(),
              _JsonStatusTab(),
              _HtmlRoutesTab(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tab for executing GTFS generation POST request.
class _ExecutePostTab extends StatefulWidget {
  const _ExecutePostTab();

  @override
  State<_ExecutePostTab> createState() => _ExecutePostTabState();
}

class _ExecutePostTabState extends State<_ExecutePostTab> {
  String? _responseMessage;
  bool _isLoading = false;

  Future<void> _executePost() async {
    setState(() => _isLoading = true);
    final response = await ApiHelper.post(
      path: '/GenerateGTFS/run',
      useToken: true,
    );

    setState(() {
      _responseMessage = response.body;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _executePost,
          child: const Text('Ejecutar POST'),
        ),
        const SizedBox(height: 20),
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_responseMessage != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_responseMessage!, textAlign: TextAlign.center),
          ),
      ],
    );
  }
}

/// Tab for displaying GTFS generation status as JSON.
class _JsonStatusTab extends StatefulWidget {
  const _JsonStatusTab();

  @override
  State<_JsonStatusTab> createState() => _JsonStatusTabState();
}

class _JsonStatusTabState extends State<_JsonStatusTab> {
  Map<String, dynamic>? _jsonResponse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJson();
  }

  Future<void> _fetchJson() async {
    final url = Uri.parse('https://omus.tmt.gob.pe/api/GenerateGTFS/status');
    final response = await http.get(url);

    setState(() {
      _jsonResponse = json.decode(response.body);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchJson,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_jsonResponse == null) {
      return const Center(
        child: Text('Algo salió mal, intente de nuevo.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Status: ${_jsonResponse!["status"]}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text('Última ejecución: ${_jsonResponse!["lastTimeRun"]}'),
          const SizedBox(height: 10),
          const Text(
            'Logs:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: SingleChildScrollView(
              child: Text(
                (_jsonResponse!['output'] as List<dynamic>).join('\n'),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab for displaying GTFS routes as HTML using InAppWebView.
class _HtmlRoutesTab extends StatelessWidget {
  const _HtmlRoutesTab();

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri('https://omus.tmt.gob.pe/api/GenerateGTFS/render-markdown'),
      ),
    );
  }
}
