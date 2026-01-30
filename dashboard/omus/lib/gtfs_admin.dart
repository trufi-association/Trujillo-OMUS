import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:omus/authentication/authentication_bloc.dart';
import 'package:omus/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class GTFSAdminScreen extends StatefulWidget {
  @override
  _GTFSAdminScreenState createState() => _GTFSAdminScreenState();
}

class _GTFSAdminScreenState extends State<GTFSAdminScreen> with SingleTickerProviderStateMixin {
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
          tabs: [
            Tab(text: 'Ejecutar'),
            Tab(text: 'Estado'),
            Tab(text: 'Rutas'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ExecutePostTab(),
              JsonTab(),
              HtmlTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class ExecutePostTab extends StatefulWidget {
  const ExecutePostTab({super.key});

  @override
  _ExecutePostTabState createState() => _ExecutePostTabState();
}

class _ExecutePostTabState extends State<ExecutePostTab> {
  String? responseMessage;
  bool isLoading = false;

  Future<void> executePost() async {
    setState(() => isLoading = true);
    final response = await ApiHelper.post(
      path: '/GenerateGTFS/run',
      useToken: true,
    );

    setState(() {
      responseMessage = response.body;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: executePost,
          child: Text('Ejecutar POST'),
        ),
        SizedBox(height: 20),
        isLoading
            ? CircularProgressIndicator()
            : responseMessage != null
                ? Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(responseMessage!, textAlign: TextAlign.center),
                  )
                : Container(),
      ],
    );
  }
}

class JsonTab extends StatefulWidget {
  @override
  _JsonTabState createState() => _JsonTabState();
}

class _JsonTabState extends State<JsonTab> {
  Map<String, dynamic>? jsonResponse;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchJson();
  }

  Future<void> fetchJson() async {
    final url = Uri.parse('https://omus.tmt.gob.pe/api/GenerateGTFS/status');
    final response = await http.get(url);

    setState(() {
      jsonResponse = json.decode(response.body);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : jsonResponse != null
              ? Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Status: ${jsonResponse!["status"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 10),
                      Text("Última ejecución: ${jsonResponse!["lastTimeRun"]}"),
                      SizedBox(height: 10),
                      Text("Logs:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            (jsonResponse!["output"] as List<dynamic>).join("\n"),
                            style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(child: Text('algo salio mal, intente de nuevo.')),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchJson,
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class HtmlTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri('https://omus.tmt.gob.pe/api/GenerateGTFS/render-markdown'),
      ),
    );
  }
}
