import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_taker/core/utils/router/app_routes.dart';
import 'package:notes_taker/features/notes/cubit/notes_cubit.dart';
import 'package:notes_taker/features/notes/cubit/search_cubit.dart';
import 'package:notes_taker/features/notes/cubit/secure_note_cubit.dart';
import 'package:notes_taker/features/notes/screens/study_notes_editor.dart';
import 'package:notes_taker/models/note.dart';
import 'package:notes_taker/core/services/firestore_service.dart';
import 'package:local_auth/local_auth.dart';

class GeneralNotesView extends StatefulWidget {
  const GeneralNotesView({super.key});

  @override
  State<GeneralNotesView> createState() => _GeneralNotesViewState();
}

class _GeneralNotesViewState extends State<GeneralNotesView> {
  late final TextEditingController searchEditingController;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    searchEditingController = TextEditingController();
  }

  @override
  void dispose() {
    searchEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          _buildSearchBar(theme, colorScheme),
          Expanded(
            child: BlocBuilder<SearchCubit<Note>, SearchState<Note>>(
              builder: (context, state) {
                if (state is SearchInitial<Note>) {
                  return BlocBuilder<NotesCubit, NotesState>(
                    builder: (context, notesState) {
                      if (notesState is NotesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (notesState is NotesFailure) {
                        return Center(
                          child: Text(
                            notesState.message,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        );
                      } else if (notesState is NotesSuccess) {
                        final notes = notesState.notes;
                        if (notes.isEmpty) {
                          return _buildEmptyNotes(theme, colorScheme);
                        }
                        return _buildNotesList(notes, theme, colorScheme);
                      }
                      return const SizedBox.shrink();
                    },
                  );
                } else if (state is SearchEmpty<Note>) {
                  return _buildEmptySearch(theme, colorScheme);
                } else if (state is SearchError<Note>) {
                  return Center(
                    child: Text(
                      state.message,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  );
                } else if (state is SearchLoading<Note>) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchSuccess<Note>) {
                  return _buildNotesList(state.results, theme, colorScheme);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: searchEditingController,
        decoration: InputDecoration(
          hintText: "Search your notes...",
          prefixIcon: Icon(Icons.search, color: theme.hintColor),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: theme.hintColor),
            onPressed: () {
              searchEditingController.clear();
              context.read<SearchCubit<Note>>().search('', (_) async => []);
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
          context.read<SearchCubit<Note>>().search(
            value,
            (q) => FirestoreServices.searchNotes<Note>(
              query: q,
              about: "notes",
              fromMap: (data, docId) => Note.fromMap(data, docId),
              getTitle: (note) => note.title,
              getContent: (note) => note.content,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotesList(
    List<Note> notes,
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
                      AppRoutes.noteEditor,
                      arguments: note.id,
                    );
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.18,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
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
                        note.title,
                        style: theme.textTheme.titleLarge!.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (!isLocked)
                        Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.9),
                          ),
                        )
                      else
                        Text(
                          "🔒 Locked",
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Updated: ${note.updatedAt.toLocal().toString().split('.').first}",
                            style: theme.textTheme.bodySmall!.copyWith(
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
                                    context.read<NotesCubit>().deleteNote(
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

  Future<void> _handleLockTap(Note note, bool isLocked) async {
    if (isLocked) {
      // First try biometrics
      final bioSuccess = await _tryBiometricUnlock();
      if (bioSuccess) {
        context.read<SecureNoteCubit>().unlockNote(
          '', // password is ignored when using biometrics
          note.id,
          "notes",
        );
        return;
      }
      // Fallback to password dialog
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

  void _showLockDialog(BuildContext context, Note note, bool isLocked) {
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
                  cubit.unlockNote(text, note.id, "notes");
                } else {
                  cubit.lockNote(text, note.id, "notes");
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

  Widget _buildEmptyNotes(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.doc,
            size: 150,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            "No notes yet. Tap + to create one!",
            style: theme.textTheme.titleMedium!.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch(ThemeData theme, ColorScheme colorScheme) {
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
            "No word or sentence in your notes matches this search.",
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
