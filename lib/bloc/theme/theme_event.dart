part of 'theme_bloc.dart';

sealed class ThemeEvent {}

final class ThemeEventToggleToLight extends ThemeEvent {}

final class ThemeEventToggleToDark extends ThemeEvent {}
