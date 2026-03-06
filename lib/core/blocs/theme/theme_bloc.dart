import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(_initialState()) {
    on<ToggleTheme>((event, emit) {
      if (event.isDark) {
        emit(ThemeState(_darkTheme, true));
      } else {
        emit(ThemeState(_lightTheme, false));
      }
    });
  }

  static ThemeState _initialState() {
    // Starting with dark as it was the default in main.dart
    return ThemeState(_darkTheme, true);
  }

  static final ThemeData _lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static final ThemeData _darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
