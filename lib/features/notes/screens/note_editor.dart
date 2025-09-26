import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_taker/features/notes/cubit/notes_cubit.dart';
import 'package:notes_taker/features/notes/screens/study_notes_editor.dart';
import 'package:notes_taker/models/note.dart';
import 'package:animate_do/animate_do.dart';

class NoteEditor extends StatefulWidget {
  final String? noteId;

  const NoteEditor({super.key, this.noteId});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      context.read<NotesCubit>().streamNotes();
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (content.isEmpty || title.isEmpty) {
      showModernMessage(
        context,
        "Note title and content cannot be empty",
        isError: true,
      );

      return;
    }

    try {
      if (widget.noteId == null) {
        await context.read<NotesCubit>().addNote(title, content);
      } else {
        await context.read<NotesCubit>().updateNote(
          widget.noteId!,
          title,
          content,
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      showModernMessage(context, "Failed to save note: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.noteId != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: FadeInLeft(
          child: IconButton(
            icon: Icon(Icons.close, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: FadeInDown(
          child: Text(
            isEditing ? "Edit Note" : "New Note",
            style: theme.textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        actions: [
          FadeInRight(
            child: IconButton(
              onPressed: _saveNote,
              icon: Icon(
                Icons.check_circle,
                color: Colors.green.shade600, // green is okay as accent
                size: 30,
              ),
              tooltip: "Save",
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary.withOpacity(0.1), colorScheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocConsumer<NotesCubit, NotesState>(
          listener: (context, state) {
            if (state is NotesFailure) {
              showModernMessage(
                context,
                "Error: ${state.message}",
                isError: true,
              );
            }
            if (state is NotesSuccess && widget.noteId != null) {
              final note = state.notes.firstWhere(
                (n) => n.id == widget.noteId,
                orElse: () => Note(
                  tokens: [],
                  id: "",
                  title: "",
                  content: "",
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );

              if (_titleController.text.isEmpty &&
                  _contentController.text.isEmpty) {
                _titleController.text = note.title;
                _contentController.text = note.content;
              }
            }
          },
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, kToolbarHeight + 20, 16, 16),
              child: Column(
                children: [
                  /// Title field
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: Hero(
                      tag: widget.noteId ?? "new_note",
                      child: Material(
                        color: Colors.transparent,
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: "Title",
                            filled: true,
                            fillColor: colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: theme.textTheme.headlineSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Content field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: "Start writing your note...",
                          hintStyle: theme.textTheme.bodyMedium!.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                        ),
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
