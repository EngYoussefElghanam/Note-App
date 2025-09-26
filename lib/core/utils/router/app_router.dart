import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_taker/features/auth/screens/forget_password_screen.dart';
import 'package:notes_taker/features/auth/screens/login_screen.dart';
import 'package:notes_taker/features/auth/screens/on_boarding_screen.dart';
import 'package:notes_taker/features/auth/screens/register_screen.dart';
import 'package:notes_taker/features/auth/services/auth_service.dart';
import 'package:notes_taker/features/notes/cubit/notes_cubit.dart';
import 'package:notes_taker/features/notes/cubit/search_cubit.dart';
import 'package:notes_taker/features/notes/cubit/secure_note_cubit.dart';
import 'package:notes_taker/features/notes/cubit/study_notes_cubit.dart';
import 'package:notes_taker/features/notes/cubit/summarize_ai_cubit.dart';
import 'package:notes_taker/features/notes/screens/about_page.dart';
import 'package:notes_taker/features/notes/screens/note_editor.dart';
import 'package:notes_taker/features/notes/screens/notes_list.dart';
import 'package:notes_taker/features/notes/screens/study_notes_editor.dart';
import 'package:notes_taker/features/user/screens/profile_page.dart';
import 'package:notes_taker/features/user/screens/settings_page.dart';
import 'package:notes_taker/models/note.dart';
import 'package:notes_taker/models/study_note.dart';
import 'package:notes_taker/core/services/chat_service.dart';
import 'package:notes_taker/core/utils/router/app_routes.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    NotesCubit(authService: AuthServicesImpl())..streamNotes(),
              ),
              BlocProvider<SearchCubit<Note>>(
                create: (context) => SearchCubit<Note>(),
              ),
              BlocProvider<SearchCubit<StudyNote>>(
                create: (context) => SearchCubit<StudyNote>(),
              ),
              BlocProvider(
                create: (context) =>
                    StudyNotesCubit(AuthServicesImpl())..streamNotes(),
              ),

              BlocProvider(create: (context) => SecureNoteCubit()),
            ],
            child: const NotesList(),
          ),
        );
      case AppRoutes.about:
        return MaterialPageRoute(builder: (context) => const AboutPage());

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    NotesCubit(authService: AuthServicesImpl())..streamNotes(),
              ),
              BlocProvider(
                create: (context) =>
                    StudyNotesCubit(AuthServicesImpl())..streamNotes(),
              ),
            ],
            child: const ProfilePage(),
          ),
        );

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.noteEditor:
        final args = settings.arguments;
        final noteId = args is String ? args : null;

        return MaterialPageRoute(
          builder: (_) {
            final auth = AuthServicesImpl();
            if (auth.currentUser() == null) {
              throw Exception("Tried to open notes without being logged in");
            }
            return BlocProvider(
              create: (context) => NotesCubit(authService: auth),
              child: NoteEditor(noteId: noteId),
            );
          },
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) =>
                      NotesCubit(authService: AuthServicesImpl())
                        ..streamNotes(),
                ),
                BlocProvider(
                  create: (context) =>
                      StudyNotesCubit(AuthServicesImpl())..streamNotes(),
                ),
              ],

              child: const SettingsPage(),
            );
          },
        );

      case AppRoutes.studyNoteEditor:
        final args = settings.arguments;
        final noteId = args is String ? args : null;

        return MaterialPageRoute(
          builder: (_) {
            final auth = AuthServicesImpl();
            if (auth.currentUser() == null) {
              throw Exception(
                "Tried to open study notes without being logged in",
              );
            }
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => StudyNotesCubit(auth)),
                BlocProvider(
                  create: (context) => SummarizeAiCubit(ChatServiceImpl()),
                ),
              ],
              child: StudyNoteEditor(noteId: noteId),
            );
          },
        );

      case AppRoutes.onBoarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.forgetPassword:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Error: Route ${settings.name} not found!'),
            ),
          ),
        );
    }
  }
}
