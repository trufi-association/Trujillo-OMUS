import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:omus/authentication/authentication_bloc.dart';
import 'package:omus/data/models/gtfs_models.dart';
import 'package:omus/data/services/gtfs_service.dart';
import 'package:omus/presentation/screens/admin/admin_screen.dart';
import 'package:omus/presentation/screens/login/login_screen.dart';
import 'package:omus/presentation/screens/map_viewer/map_viewer_screen.dart';
import 'package:omus/presentation/screens/stats_viewer/stats_viewer_screen.dart';
import 'package:omus/presentation/widgets/common/home_screen.dart';
import 'package:provider/provider.dart';

/// Application route paths.
class AppRoutes {
  static const String home = '/';
  static const String admin = '/admin';
  static const String mapViewer = '/map-viewer';
  static const String statsViewer = '/stats-viewer';
}

/// Creates and configures the application router.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AuthenticationBloc()),
          ],
          child: const AdminAuth(),
        ),
      ),
      GoRoute(
        path: AppRoutes.mapViewer,
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
          child: const MapViewerScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.statsViewer,
        builder: (context, state) => const StatsViewerScreen(),
      ),
    ],
  );
}

/// Widget that shows AdminScreen or LoginScreen based on auth state.
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
