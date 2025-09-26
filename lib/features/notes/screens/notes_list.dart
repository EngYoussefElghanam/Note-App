import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_taker/core/cubit/theme_cubit.dart';
import 'package:notes_taker/features/notes/cubit/notes_cubit.dart';
import 'package:notes_taker/features/notes/cubit/study_notes_cubit.dart';
import 'package:notes_taker/features/notes/widget/app_drawer.dart';
import 'package:notes_taker/features/notes/widget/general_notes_view.dart';
import 'package:notes_taker/features/notes/widget/study_notes_view.dart';
import 'package:notes_taker/core/utils/router/app_routes.dart';

class NotesList extends StatefulWidget {
  const NotesList({super.key});

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList>
    with SingleTickerProviderStateMixin {
  final searchEditingController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    context.read<NotesCubit>().streamNotes();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: DrawerButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
            foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
          ),
        ),
        title: Text(
          "My Notes",
          style: theme.textTheme.displaySmall!.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              bool isLight = true;
              if (state is ThemeLoaded) isLight = state.isLight;

              return IconButton(
                icon: Icon(
                  isLight ? Icons.dark_mode : Icons.light_mode,
                  color: colorScheme.onSurface,
                ),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
                foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
              ),
              onPressed: () {
                if (_tabController.index == 0) {
                  Navigator.pushNamed(context, AppRoutes.noteEditor);
                } else {
                  Navigator.pushNamed(context, AppRoutes.studyNoteEditor);
                }
              },
              icon: const Icon(Icons.add),
              tooltip: "Add Note",
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 2.5,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: "General"),
            Tab(text: "Study"),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [GeneralNotesView(), StudyNotesView()],
      ),
      bottomNavigationBar: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, notesState) {
          return BlocBuilder<StudyNotesCubit, StudyNotesState>(
            builder: (context, studyState) {
              int generalCount = 0;
              int studyCount = 0;

              if (notesState is NotesSuccess) {
                generalCount = notesState.notes.length;
              }
              if (studyState is StudyNotesSuccess) {
                studyCount = studyState.notes.length;
              }

              final totalCount = generalCount + studyCount;

              return ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.2),
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.onSurface.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sticky_note_2_outlined,
                            color: colorScheme.onSurface.withOpacity(0.9),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$totalCount notes",
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
