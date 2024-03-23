part of 'theme_bloc.dart';

final class ThemeState {
  final ThemeData themeData;

  ThemeState(this.themeData);
  static final lightTheme = ThemeState(ThemeData(
    colorScheme: lightColorScheme,
    useMaterial3: true,
  ));

  static final darkTheme = ThemeState(ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
  ));
}
