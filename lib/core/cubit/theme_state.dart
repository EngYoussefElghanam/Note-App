part of 'theme_cubit.dart';

sealed class ThemeState {}

final class ThemeInitial extends ThemeState {}

final class ThemeLoading extends ThemeState {}

final class ThemeLoaded extends ThemeState {
  final bool isLight;

  ThemeLoaded({required this.isLight});
}

final class ThemeError extends ThemeState {
  final String message;

  ThemeError({required this.message});
}
