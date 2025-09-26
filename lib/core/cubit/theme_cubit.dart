import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences prefs;
  ThemeCubit(this.prefs) : super(ThemeInitial());
  Future<void> loadTheme() async {
    try {
      final isLight = prefs.getBool('isLight') ?? true;
      emit(ThemeLoaded(isLight: isLight));
    } catch (e) {
      emit(ThemeError(message: e.toString()));
    }
  }

  Future<void> toggleTheme() async {
    try {
      if (state is ThemeLoaded) {
        final currentTheme = (state as ThemeLoaded).isLight;
        final newTheme = !currentTheme;
        await prefs.setBool('isLight', newTheme);
        emit(ThemeLoaded(isLight: newTheme));
      }
    } catch (e) {
      emit(ThemeError(message: e.toString()));
    }
  }
}
