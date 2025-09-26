import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:notes_taker/core/utils/router/app_routes.dart';
import 'package:notes_taker/features/notes/cubit/study_notes_cubit.dart';
import 'package:notes_taker/features/notes/cubit/search_cubit.dart';
import 'package:notes_taker/features/notes/cubit/secure_note_cubit.dart';
import 'package:notes_taker/features/notes/screens/study_notes_editor.dart';
import 'package:notes_taker/models/study_note.dart';
import 'package:notes_taker/core/services/firestore_service.dart';
import 'package:local_auth/local_auth.dart';

class StudyNotesView extends StatefulWidget {
  const StudyNotesView({super.key});

  @override
  State<StudyNotesView> createState() => _StudyNotesViewState();
}

class _StudyNotesViewState extends State<StudyNotesView> {
  final searchEditingController = TextEditingController();

  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    var selectedSubject = context.read<StudyNotesCubit>().activeSubject;

    return BlocListener<SecureNoteCubit, SecureNoteState>(
      listener: (context, state) {
        if (state is SecureNoteFailure) {
          showModernMessage(
            context,
            "Error: ${state.errorMessage}",
            isError: true,
          );
        }
      },
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchEditingController,
              decoration: InputDecoration(
                hintText: "Search study notes (title, content)",
                prefixIcon: Icon(Icons.search, color: theme.hintColor),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: theme.hintColor),
                  onPressed: () {
                    searchEditingController.clear();
                    context.read<SearchCubit<StudyNote>>().search(
                      '',
                      (_) async => [],
                    );
                    FocusScope.of(context).unfocus();
                  },
                ),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              style: theme.textTheme.bodyMedium,
              onChanged: (value) {
                context.read<SearchCubit<StudyNote>>().search(
                  value,
                  (q) => FirestoreServices.searchNotes<StudyNote>(
                    query: q,
                    about: 'studyNotes',
                    fromMap: (data, docId) => StudyNote.fromMap(data, docId),
                    getTitle: (note) => note.title,
                    getContent: (note) => note.content,
                  ),
                );
              },
            ),
          ),

          // Subjects filter row
          BlocBuilder<StudyNotesCubit, StudyNotesState>(
            builder: (context, state) {
              final cubit = context.read<StudyNotesCubit>();
              final subjects = _uniqueSubjects(cubit.allNotes);

              // show nothing if there are no subjects at all
              if (subjects.isEmpty) return const SizedBox.shrink();

              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.06,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final isSelected = selectedSubject == subject;

                    return GestureDetector(
                      onTap: () {
                        // toggle selection + tell cubit to filter/unfilter
                        if (isSelected) {
                          setState(() => selectedSubject = null);
                          context.read<StudyNotesCubit>().filterBySubject(null);
                        } else {
                          setState(() => selectedSubject = subject);
                          context.read<StudyNotesCubit>().filterBySubject(
                            subject,
                          );
                        }
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    Colors.indigo.shade400,
                                    Colors.blue.shade300,
                                  ],
                                )
                              : null,
                          color: isSelected ? null : colorScheme.surface,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            subject,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Notes List
          Expanded(
            child: BlocBuilder<SearchCubit<StudyNote>, SearchState<StudyNote>>(
              builder: (context, state) {
                if (state is SearchInitial<StudyNote>) {
                  return BlocConsumer<StudyNotesCubit, StudyNotesState>(
                    listener: (context, state) {
                      if (state is StudyNotesFailure) {
                        showModernMessage(
                          context,
                          "Error: ${state.message}",
                          isError: true,
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is StudyNotesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is StudyNotesFailure) {
                        return Center(
                          child: Text(
                            state.message,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        );
                      } else if (state is StudyNotesSuccess) {
                        final notes = state.notes;

                        if (notes.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.book,
                                  size: 150,
                                  color: colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No study notes yet. Tap + to create one!",
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return _buildNotesList(
                          context,
                          notes,
                          theme,
                          colorScheme,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                } else if (state is SearchEmpty<StudyNote>) {
                  return _emptySearchView(theme, colorScheme);
                } else if (state is SearchError<StudyNote>) {
                  return Center(
                    child: Text(
                      state.message,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  );
                } else if (state is SearchLoading<StudyNote>) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchSuccess<StudyNote>) {
                  return _buildNotesList(
                    context,
                    state.results,
                    theme,
                    colorScheme,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(
    BuildContext context,
    List<StudyNote> notes,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final isLocked = note.password != null && note.password!.isNotEmpty;

        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          animate: ModalRoute.of(context)?.isCurrent ?? true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                onTap: () {
                  if (!isLocked) {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.studyNoteEditor,
                      arguments: note.id,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.green.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${note.subject} • ${note.topic}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      if (!isLocked)
                        MarkdownBody(
                          data: truncateWithEllipsis(100, note.content),
                          shrinkWrap: true,
                          styleSheet: MarkdownStyleSheet(
                            p: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.9),
                            ),
                            h1: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Text(
                          "🔒 Locked",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Updated: ${note.updatedAt.toLocal().toString().split('.').first}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isLocked
                                      ? Icons.lock_outline
                                      : Icons.lock_open_outlined,
                                  color: colorScheme.onPrimary.withOpacity(0.7),
                                ),
                                onPressed: () => _handleLockTap(note, isLocked),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: isLocked
                                      ? theme.disabledColor
                                      : colorScheme.onPrimary.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  if (!isLocked) {
                                    context.read<StudyNotesCubit>().deleteNote(
                                      note.id,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLockTap(StudyNote note, bool isLocked) async {
    if (isLocked) {
      final bioSuccess = await _tryBiometricUnlock();
      if (bioSuccess) {
        context.read<SecureNoteCubit>().unlockNote('', note.id, "studyNotes");
        return;
      }
      _showLockDialog(context, note, true);
    } else {
      _showLockDialog(context, note, false);
    }
  }

  Future<bool> _tryBiometricUnlock() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final available = await _localAuth.isDeviceSupported();
      if (!canCheck || !available) return false;
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock note',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return didAuth;
    } catch (_) {
      return false;
    }
  }

  void _showLockDialog(BuildContext context, StudyNote note, bool isLocked) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(isLocked ? "Unlock Note" : "Lock Note"),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Enter password",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                final cubit = context.read<SecureNoteCubit>();
                if (isLocked) {
                  cubit.unlockNote(text, note.id, "studyNotes");
                } else {
                  cubit.lockNote(text, note.id, "studyNotes");
                }
                Navigator.pop(context);
              },
              child: Text(isLocked ? "Unlock" : "Lock"),
            ),
          ],
        );
      },
    );
  }

  Widget _emptySearchView(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 150,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            "No study note matches this search.",
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium!.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

String truncateWithEllipsis(int cutoff, String text) {
  return (text.length <= cutoff) ? text : '${text.substring(0, cutoff)}...';
}

List<String> _uniqueSubjects(List<StudyNote> notes) {
  final subjects = notes
      .map((n) => n.subject)
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();
  subjects.sort();
  return subjects;
}
