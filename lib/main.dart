import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/blocs/driver/driver_bloc.dart';
import 'core/blocs/race/race_bloc.dart';
import 'core/blocs/result/result_bloc.dart';
import 'core/blocs/scoring/scoring_bloc.dart';
import 'core/blocs/team/team_bloc.dart';
import 'core/database/database_helper.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Database Helper
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database; // Ensure DB is opened

  runApp(MyApp(dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const MyApp({super.key, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ScoringBloc()),
        BlocProvider(
          create: (context) =>
              DriverBloc(dbHelper: dbHelper)..add(LoadDrivers()),
        ),
        BlocProvider(
          create: (context) => TeamBloc(dbHelper: dbHelper)..add(LoadTeams()),
        ),
        BlocProvider(
          create: (context) => RaceBloc(dbHelper: dbHelper)..add(LoadRaces()),
        ),
        BlocProvider(create: (context) => ResultBloc(dbHelper: dbHelper)),
      ],
      child: MaterialApp.router(
        title: 'Gestão de Corridas F1',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
