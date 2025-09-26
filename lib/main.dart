import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notes_taker/core/app_constants.dart';
import 'package:notes_taker/core/cubit/theme_cubit.dart';
import 'package:notes_taker/core/utils/router/app_router.dart';
import 'package:notes_taker/core/utils/router/app_routes.dart';
import 'package:notes_taker/features/auth/cubit/auth_cubit.dart';
import 'package:notes_taker/features/auth/services/auth_service.dart';
import 'package:notes_taker/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await MobileAds.instance.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthServicesImpl();
  final isLoggedIn = authService.currentUser() != null;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(authService)),
        BlocProvider(create: (context) => ThemeCubit(prefs)..loadTheme()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        // default to light if state not loaded yet
        bool isLight = true;
        if (state is ThemeLoaded) {
          isLight = state.isLight;
        }
        final lightTheme = AppConstants.lightTheme;

        final darkTheme = AppConstants.darkTheme;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: isLight ? ThemeMode.light : ThemeMode.dark,
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: isLoggedIn ? AppRoutes.home : AppRoutes.onBoarding,
        );
      },
    );
  }
}
