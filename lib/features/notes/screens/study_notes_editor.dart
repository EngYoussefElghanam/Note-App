import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:notes_taker/features/notes/cubit/study_notes_cubit.dart';
import 'package:notes_taker/features/notes/cubit/summarize_ai_cubit.dart';
import 'package:notes_taker/models/study_note.dart';
import 'package:animate_do/animate_do.dart';

class StudyNoteEditor extends StatefulWidget {
  final String? noteId;

  const StudyNoteEditor({super.key, this.noteId});

  @override
  State<StudyNoteEditor> createState() => _StudyNoteEditorState();
}

class _StudyNoteEditorState extends State<StudyNoteEditor> {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();
  final _tagsController = TextEditingController();
  final _contentController = TextEditingController();
  bool speaking = false;
  final FlutterTts flutterTts = FlutterTts();
  bool showAiBanner = false;
  bool previewMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      context.read<StudyNotesCubit>().streamNotes();
    }
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.2);
    await flutterTts.setVolume(1.0);

    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => speaking = false);
      }
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    _titleController.dispose();
    _subjectController.dispose();
    _topicController.dispose();
    _tagsController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final subject = _subjectController.text.trim();
    final topic = _topicController.text.trim();
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and content cannot be empty")),
      );
      return;
    }

    // show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (widget.noteId == null) {
        await context.read<StudyNotesCubit>().addNote(
          title: title,
          subject: subject,
          topic: topic,
          tags: tags,
          content: content,
        );
      } else {
        await context.read<StudyNotesCubit>().updateNote(
          id: widget.noteId!,
          title: title,
          subject: subject,
          topic: topic,
          tags: tags,
          content: content,
        );
      }

      if (mounted) {
        Navigator.pop(context); // close loading dialog
        Navigator.pop(context); // go back
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loading dialog
        showModernMessage(context, "Error : ${e.toString()}");
      }
    }
  }

  bool get isEditing => widget.noteId != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<SummarizeAiCubit, SummarizeAiState>(
      listener: (context, state) {
        if (state is MessageReceived) {
          _contentController.text = state.response;
          setState(() => showAiBanner = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => showAiBanner = false);
          });
        } else if (state is MessageError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
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
              isEditing ? "Edit Study Note" : "New Study Note",
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                previewMode ? Icons.edit_note : Icons.visibility,
                color: colorScheme.onSurface,
              ),
              tooltip: previewMode ? "Edit Mode" : "Preview Mode",
              onPressed: () => setState(() => previewMode = !previewMode),
            ),
            FadeInRight(
              child: IconButton(
                onPressed: _saveNote,
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.teal.shade600,
                  size: 30,
                ),
                tooltip: "Save",
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.withOpacity(0.08), colorScheme.surface],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: BlocConsumer<StudyNotesCubit, StudyNotesState>(
                listener: (context, state) {
                  if (state is StudyNotesFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${state.message}")),
                    );
                  }
                  if (state is StudyNotesSuccess && widget.noteId != null) {
                    final note = state.notes.firstWhere(
                      (n) => n.id == widget.noteId,
                      orElse: () => StudyNote.empty(),
                    );
                    if (_titleController.text.isEmpty &&
                        _contentController.text.isEmpty) {
                      _titleController.text = note.title;
                      _subjectController.text = note.subject;
                      _topicController.text = note.topic;
                      _tagsController.text = note.tags.join(", ");
                      _contentController.text = note.content;
                    }
                  }
                },
                builder: (context, state) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      kToolbarHeight +
                          MediaQuery.of(context).size.height * 0.08,
                      16,
                      16,
                    ),
                    child: Column(
                      children: [
                        _buildField(
                          _titleController,
                          "Title",
                          theme,
                          colorScheme,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          _subjectController,
                          "Subject",
                          theme,
                          colorScheme,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          _topicController,
                          "Topic",
                          theme,
                          colorScheme,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          _tagsController,
                          "Tags (comma separated)",
                          theme,
                          colorScheme,
                        ),
                        const SizedBox(height: 16),
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
                            child: previewMode
                                ? Markdown(
                                    data: _contentController.text,
                                    styleSheet: MarkdownStyleSheet(
                                      p: theme.textTheme.bodyLarge!.copyWith(
                                        color: colorScheme.onSurface,
                                        height: 1.5,
                                      ),
                                      strong: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      em: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      code: TextStyle(
                                        backgroundColor: Colors.grey.shade200,
                                        fontFamily: "monospace",
                                      ),
                                    ),
                                  )
                                : TextField(
                                    controller: _contentController,
                                    decoration: InputDecoration(
                                      hintText:
                                          "Write your study notes here...",
                                      hintStyle: theme.textTheme.bodyMedium!
                                          .copyWith(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.6),
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
            if (speaking)
              Positioned(
                bottom: 90,
                left: 16,
                right: 16,
                child: FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Speaking...",
                          style: TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop, color: Colors.white),
                          onPressed: () async {
                            await flutterTts.stop();
                            setState(() => speaking = false);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: showAiBanner ? 1 : 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.auto_fix_high, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Note summarized by AI",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "tts",
              onPressed: () async {
                if (!speaking) {
                  await flutterTts.speak(
                    "${_titleController.text} ......... ${_contentController.text}",
                  );
                  setState(() => speaking = true);
                } else {
                  await flutterTts.pause();
                  setState(() => speaking = false);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                speaking ? CupertinoIcons.pause : CupertinoIcons.speaker_3_fill,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<SummarizeAiCubit, SummarizeAiState>(
              builder: (context, state) {
                final isLoading = state is SendingMessage;
                return FloatingActionButton(
                  heroTag: "summarize",
                  onPressed: isLoading
                      ? null
                      : () {
                          final content = _contentController.text.trim();
                          if (content.isEmpty) return;
                          context.read<SummarizeAiCubit>().sendMessage(content);
                        },
                  backgroundColor: isLoading ? Colors.grey : Colors.teal,
                  tooltip: "Summarize AI",
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.auto_fix_high, color: Colors.white),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      style: theme.textTheme.bodyMedium!.copyWith(color: colorScheme.onSurface),
    );
  }
}

void showModernMessage(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      // Auto dismiss after 2s using dialogContext
      Future.delayed(const Duration(seconds: 2), () {
        if (Navigator.canPop(dialogContext)) {
          Navigator.pop(dialogContext);
        }
      });

      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            color: isError
                ? colorScheme.errorContainer
                : colorScheme.primaryContainer,
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: isError
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: isError
                            ? colorScheme.onErrorContainer
                            : colorScheme.onPrimaryContainer,
                      ),
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
}
