import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:latlong2/latlong.dart';
import 'package:omus/env.dart';
import 'package:omus/logo.dart';
import 'package:omus/map_viewer.dart';
import 'package:omus/services/api_service.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';
import 'package:omus/stats_viewer.dart';
import 'package:omus/widgets/components/checkbox/custom_checkbox.dart';
import 'package:omus/widgets/components/dropdown/helpers/dropdown_item.dart';
import 'package:omus/widgets/components/dropdown/multi_select_dropdown.dart';
import 'package:omus/widgets/components/fleaflet_map_controller.dart';
import 'package:omus/widgets/components/helpers/form_loading_helper_new.dart';
import 'package:omus/widgets/components/textfield/form_request_date_range_field.dart';
import 'package:omus/widgets/components/textfield/form_request_field.dart';
import 'package:omus/widgets/components/toggle_switch/custom_toggle_switch.dart';
import 'package:omus/widgets/components/zoom_map_button.dart';
import 'gtfs_service.dart';
import 'package:provider/provider.dart';
import 'gtfs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

void main() {
  runApp(const MyApp());
}

extension FindOrNullExtension<T> on List<T> {
  T? findOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
      tileProvider: CancellableNetworkTileProvider(),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuración del router
    final GoRouter _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => UnderConstructionPage(),
        ),
        GoRoute(
          path: '/map-viewer',
          builder: (context, state) => MultiProvider(
            providers: [
              Provider(create: (_) => GtfsService()),
              FutureProvider<Gtfs>(
                create: (context) => context.read<GtfsService>().loadGtfsData(),
                initialData: Gtfs(
                  agencies: [],
                  routes: [],
                  stops: [],
                  shapes: [],
                  frequencies: [],
                  calendars: [],
                  stopTimes: [],
                  trips: [],
                ),
              ),
            ],
            child: const MainMap(),
          ),
        ),
        GoRoute(
          path: '/stats-viewer',
          builder: (context, state) => StatsViewer(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'OMUS',
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
        ),
      ),
    );
  }
}

// Página de construcción
class UnderConstructionPage extends StatelessWidget {
  UnderConstructionPage({super.key});
  // Función para abrir el enlace de WhatsApp
  void _launchWhatsApp() async {
    const url = 'https://wa.me/0051959312613'; // Reemplaza con el enlace de tu chatbot de WhatsApp
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace de WhatsApp $url';
    }
  } // Función para manejar la acción de "Visor geográfico"

// final Uint8List bytes = base64Decode(logo);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: GeneralAppBar(
          title: "",
        ),
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg', // Ruta de la imagen
              fit: BoxFit.cover, // Ajusta la imagen para que cubra toda la pantalla
            ),
          ), // Gradiente sobre la imagen
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(153, 17, 81, 134), // Celeste con transparencia en la parte inferior
                    const Color.fromARGB(125, 0, 0, 0), // Parte superior sin color
                  ],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
              ),
            ),
          ),
          // Contenido sobre la imagen
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bienvenido a OMUS',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        """Una plataforma de gestión, análisis y difusión de datos del transporte público urbano de la ciudad con enfoque de género y movilidad sostenible que permitirá contar con información actualizada y disponible para los agentes sociales, económicos, comunicacionales e institucionales, así como la ciudadanía en general.

¿Incidentes en el transporte público?""",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      // Texto con el enlace de WhatsApp
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Repórtalo a Truxi, envía un WhatsApp al ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: '+51 959 312 613',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white, // Color del enlace
                                decoration: TextDecoration.underline, // Subrayado del enlace
                              ),
                              // Hace que el texto sea clicable
                              recognizer: TapGestureRecognizer()..onTap = _launchWhatsApp,
                            ),
                            TextSpan(
                              text: '.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Opción 1: Visor geográfico
                          ElevatedButton(
                            onPressed: () {
                              context.go("/map-viewer");
                            }, // Acción al presionar
                            child: Text(
                              'Visor geográfico',
                            ),
                          ),
                          // Opción 2: Estadísticas de movilidad
                          ElevatedButton(
                            onPressed: () {
                              context.go("/stats-viewer");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // La propiedad actual
                            ), // Acción al presionar
                            child: Text(
                              'Estadísticas de movilidad',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GeneralAppBar extends StatelessWidget {
  const GeneralAppBar({
    super.key,
    required this.title,
  });
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            context.go("/");
          },
          child: Container(
            height: 50,
            child: Image.asset(
              'assets/Logo_OMUS.png', // Ruta de la imagen
              fit: BoxFit.cover, // Ajusta la imagen para que cubra toda la pantalla
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        Container(
          height: 50,
          width: 500,
          child: Image.asset(
            'assets/logos.png', // Ruta de la imagen
            fit: BoxFit.contain, // Ajusta la imagen para que cubra toda la pantalla
          ),
        )
      ],
    );
  }
}
