import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khiem_vais_test/common/shared_prefs.dart';
import 'package:khiem_vais_test/res/theme.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.darkTheme) {
    on<ThemeEvent>((event, emit) {
      switch (event) {
        case ThemeEventToggleToDark():
          emit(ThemeState.darkTheme);
          SharedPrefs.saveIsDarkMode(true);
          break;
        case ThemeEventToggleToLight():
          emit(ThemeState.lightTheme);
          SharedPrefs.saveIsDarkMode(false);
          break;
        default:
          break;
      }
    });
  }
}
