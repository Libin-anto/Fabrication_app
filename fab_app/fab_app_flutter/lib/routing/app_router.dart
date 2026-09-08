import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/worker.dart';
import '../models/machine.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/search/search_results_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/workers/workers_screen.dart';
import '../screens/workers/worker_form_screen.dart';
import '../screens/machines/machines_screen.dart';
import '../screens/machines/machine_form_screen.dart';
import '../screens/assignments/assignments_screen.dart';
import '../screens/assignments/assign_tool_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../providers/auth_provider.dart';
import 'main_scaffold.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';
      
      final authState = ref.read(authStateProvider);

      if (isSplash) return null; // Splash screen handles its own navigation after animation

      final isAuthenticated = authState.value ?? false;

      if (!isAuthenticated && !isLoggingIn && !isRegistering) return '/login';
      if (isAuthenticated && (isLoggingIn || isRegistering)) return '/dashboard';
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SearchResultsScreen(),
      ),
      GoRoute(
        path: '/workers/add',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const WorkerFormScreen(),
      ),
      GoRoute(
        path: '/workers/edit/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final worker = state.extra as Worker;
          return WorkerFormScreen(worker: worker);
        },
      ),
      GoRoute(
        path: '/machines/add',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MachineFormScreen(),
      ),
      GoRoute(
        path: '/machines/edit/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final machine = state.extra as Machine;
          return MachineFormScreen(machine: machine);
        },
      ),
      GoRoute(
        path: '/assignments/new',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AssignToolScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workers',
                builder: (context, state) => const WorkersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/machines',
                builder: (context, state) => const MachinesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assignments',
                builder: (context, state) => const AssignmentsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.listen(authStateProvider, (_, unused) {
    router.refresh();
  });

  return router;
});

final rootNavigatorKey = GlobalKey<NavigatorState>();
