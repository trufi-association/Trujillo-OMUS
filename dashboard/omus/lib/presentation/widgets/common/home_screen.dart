import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omus/core/router/app_router.dart';
import 'package:omus/presentation/widgets/common/general_app_bar.dart';
import 'package:omus/presentation/widgets/common/rich_persistent_tooltip.dart';
import 'package:url_launcher/url_launcher.dart';

/// Home screen with welcome message and navigation buttons.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _launchWhatsApp() async {
    const url = 'https://wa.me/+51959312613';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'No se pudo abrir el enlace de WhatsApp $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const GeneralAppBar(title: ''),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              _buildBackground(),
              _buildGradientOverlay(),
              _buildContent(context),
              if (constraints.maxWidth >= 850) _buildAssistant(context),
            ],
          );
        },
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

  Widget _buildContent(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
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
                        '''Una plataforma de gestión, análisis y difusión de datos del transporte público urbano de la ciudad con enfoque de género y movilidad sostenible que permitirá contar con información actualizada y disponible para los agentes sociales, económicos, comunicacionales e institucionales, así como la ciudadanía en general.

          ¿Incidentes en el transporte público?''',
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
                              recognizer: TapGestureRecognizer()
                                ..onTap = _launchWhatsApp,
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
                            onPressed: () => context.go(AppRoutes.mapViewer),
                            child: const Text('Visor geográfico'),
                          ),
                          ElevatedButton(
                            onPressed: () => context.go(AppRoutes.statsViewer),
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
          );
        },
      ),
    );
  }

  Widget _buildAssistant(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 10,
      child: RichPersistentTooltip(
        tooltipContent: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              const TextSpan(
                text: '''Soy Truxi, tu asistente virtual.

          Estoy aquí para ayudarte a reportar cualquier problema relacionado con el transporte público en Trujillo.
          Escríbeme y cuéntame lo que pasó. Tu reporte nos ayuda a mejorar el transporte para todos.

          Envíame un mensaje al WhatsApp: ''',
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
        child: SizedBox(
          width: 200,
          child: Image.asset(
            'assets/AsistenteVirtual.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
