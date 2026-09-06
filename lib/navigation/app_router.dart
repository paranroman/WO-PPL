import 'package:eventure/screens/auth/register_screen.dart';
import 'package:eventure/screens/event/edit_event_screen.dart';
import 'package:eventure/screens/event/event_details_screen.dart';
import 'package:eventure/screens/qr/qr_scanner_screen.dart';
import 'package:eventure/utils/exit_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/event/create_event_screen.dart';
import '../screens/event/event_dashboard_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/about_app_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String editProfile = '/editProfile';
  static const String aboutApp = '/about';
  static const String createEvent = '/createEvent';
  static const String eventDetail = '/event/:eventId/details';
  static const String eventDashboard = '/event/:eventId/dashboard';
  static const String scanner = '/event/:eventId/scanner';
  static const String editEvent = '/event/:eventId/edit';
}

GoRouter createRouter() {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
        name: "splash",
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
        name: "login",
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
        name: "register",
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ExitConfirmation(
            child: BottomNavigationShell(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
        name: "editProfile",
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutAppScreen(),
      ),
      GoRoute(
        path: '/createEvent',
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: AppRoutes.eventDetail,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;

          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.eventDashboard,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;

          return EventDashboardScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.scanner,
        builder: (context, state) {
          final eventId = (state.pathParameters['eventId'] ?? '').trim();
          return ScanQrScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: AppRoutes.editEvent,
        builder: (context, state) {
          final eventId = (state.pathParameters['eventId'] ?? '').trim();
          return EditEventScreen(eventId: eventId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('Path: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    ),
  );
}
