import 'package:go_router/go_router.dart';

import '../../features/drivers/screens/driver_form_screen.dart';
import '../../features/drivers/screens/driver_list_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/races/screens/race_form_screen.dart';
import '../../features/races/screens/race_list_screen.dart';
import '../../features/races/screens/race_result_screen.dart';
import '../../features/teams/screens/team_form_screen.dart';
import '../../features/teams/screens/team_list_screen.dart';
import '../../features/telemetry/screens/telemetry_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/drivers',
        name: 'drivers',
        builder: (context, state) => const DriverListScreen(),
        routes: [
          GoRoute(
            path: 'form',
            name: 'driver_form',
            builder: (context, state) =>
                DriverFormScreen(driver: state.extra as dynamic),
          ),
        ],
      ),
      GoRoute(
        path: '/teams',
        name: 'teams',
        builder: (context, state) => const TeamListScreen(),
        routes: [
          GoRoute(
            path: 'form',
            name: 'team_form',
            builder: (context, state) =>
                TeamFormScreen(team: state.extra as dynamic),
          ),
        ],
      ),
      GoRoute(
        path: '/races',
        name: 'races',
        builder: (context, state) => const RaceListScreen(),
        routes: [
          GoRoute(
            path: 'form',
            name: 'race_form',
            builder: (context, state) =>
                RaceFormScreen(race: state.extra as dynamic),
          ),
          GoRoute(
            path: 'results',
            name: 'race_results',
            builder: (context, state) =>
                RaceResultScreen(race: state.extra as dynamic),
          ),
        ],
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/telemetry',
        name: 'telemetry',
        builder: (context, state) => const TelemetryScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
