import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:omus/admin.dart';
import 'package:omus/authentication/authentication_bloc.dart';
import 'package:omus/login.dart';
import 'package:omus/map_viewer.dart';
import 'package:omus/stats_viewer.dart';
import 'gtfs_service.dart';
import 'package:provider/provider.dart';
import 'gtfs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
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
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => AuthenticationBloc()),
            ],
            child: const AdminAuth(),
          ),
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
          builder: (context, state) => const StatsViewer(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'OMUS',
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''),
      ],
      locale: const Locale('es'),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  void _launchWhatsApp() async {
    const url = 'https://wa.me/0051959312613';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace de WhatsApp $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const GeneralAppBar(
          title: "",
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
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
          ),
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Bienvenido a OMUS',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        """Una plataforma de gestión, análisis y difusión de datos del transporte público urbano de la ciudad con enfoque de género y movilidad sostenible que permitirá contar con información actualizada y disponible para los agentes sociales, económicos, comunicacionales e institucionales, así como la ciudadanía en general.

¿Incidentes en el transporte público?""",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Repórtalo a Truxi, envía un WhatsApp al ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: '+51 959 312 613',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = _launchWhatsApp,
                            ),
                            const TextSpan(
                              text: '.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context.go("/map-viewer");
                            },
                            child: const Text(
                              'Visor geográfico',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.go("/stats-viewer");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
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
          child: SizedBox(
            height: 50,
            child: Image.asset(
              'assets/Logo_OMUS.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          width: 500,
          child: Image.asset(
            'assets/logos.png',
            fit: BoxFit.contain,
          ),
        )
      ],
    );
  }
}

class AdminAuth extends StatelessWidget {
  const AdminAuth({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.watch<AuthenticationBloc>().state.isAuthenticated) {
      return const AdminScreen();
    } else {
      return const LoginScreen();
    }
  }
}
