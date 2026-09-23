import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/login/login_bloc.dart';
import '../screens/dashboardScreen.dart';
import '../screens/fleetModeSelectionScreen.dart';
import '../screens/homeScreen.dart';
import '../screens/login.dart';
import '../screens/settingScreen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',

    routes: [
      // LOGIN
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => LoginBloc(),
            child: const LoginScreen(),
          );
        },
      ),

      // FLEET MODE
      GoRoute(
        path: '/fleet-mode',
        name: 'fleetMode',
        builder: (context, state) {
          return const FleetModeSelectionPage();
        },
      ),

      // GLOBAL HOME
      ShellRoute(
        builder: (context, state, child) {
          return HomeScreen(child: child);
        },

        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) {
              return const DashboardScreen();
            },
          ),

          // SETTINGS
          GoRoute(
            path: '/settings',
            name: 'settings',
            redirect: (context, state) {
              return '/settings/users';
            },
            builder: (context, state) {
              return const SettingsScreen(initialTab: 'users');
            },
          ),

          // USERS
          GoRoute(
            path: '/settings/users',
            name: 'settingsUsers',
            builder: (context, state) {
              return const SettingsScreen(initialTab: 'users');
            },
          ),

          // GROUPS
          GoRoute(
            path: '/settings/groups',
            name: 'settingsGroups',
            builder: (context, state) {
              return const SettingsScreen(initialTab: 'groups');
            },
          ),
          GoRoute(
            path: '/settings/orgs',
            name: 'settingsOrgs',
            builder: (context, state) {
              return const SettingsScreen(initialTab: 'orgs');
            },
          ),
          GoRoute(
            path: '/settings/roles',
            name: 'settingsRoles',
            builder: (context, state) {
              return const SettingsScreen(initialTab: 'roles');
            },
          ),
          GoRoute(
            path: '/settings/assetTypes',
            name: 'assetTypes',
            builder: (context, state) {
              return const SettingsScreen(initialTab: 'assetTypes');
            },
          ),
          GoRoute(
            path: '/settings/assets',
            name: 'assets',
            builder: (context, state) {
              return const SettingsScreen(initialTab: 'assets');
            },
          ),
        ],
      ),
    ],
  );
}
