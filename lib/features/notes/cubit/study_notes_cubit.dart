import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_taker/features/auth/services/auth_service.dart';
import 'package:notes_taker/models/study_note.dart';
import 'package:notes_taker/core/services/firestore_service.dart';

part 'study_notes_state.dart';

class StudyNotesCubit extends Cubit<StudyNotesState> {
  final AuthServicesImpl authService;
  StreamSubscription<List<StudyNote>>? _notesSubscription;

  /// Store all notes (always kept updated from Firestore)
  List<StudyNote> allNotes = [];

  /// Track currently selected subject (for UI highlight)
  String? activeSubject;

  StudyNotesCubit(this.authService) : super(StudyNotesInitial());

  /// Stream ALL notes (syncs with Firestore + works offline)
  void streamNotes() {
    emit(StudyNotesLoading());
    final uid = authService.currentUser()?.uid;
    if (uid == null) {
      emit(StudyNotesFailure("User not logged in"));
      return;
    }

    _notesSubscription?.cancel();
    _notesSubscription =
        FirestoreServices.streamData<StudyNote>(
          collectionName: 'users/$uid/studyNotes',
          fromMap: (data, docId) => StudyNote.fromMap(data, docId),
        ).listen((notes) {
          allNotes = notes;

          if (activeSubject != null) {
            final filtered = allNotes
                .where((n) => n.subject == activeSubject)
                .toList();

            if (filtered.isEmpty) {
              // 🔹 Auto-reset when subject becomes empty
              activeSubject = null;
              emit(StudyNotesSuccess(allNotes));
            } else {
              emit(StudyNotesSuccess(filtered));
            }
          } else {
            emit(StudyNotesSuccess(allNotes));
          }
        }, onError: (e) => emit(StudyNotesFailure(e.toString())));
  }

  /// Add Note
  Future<void> addNote({
    required String title,
    required String subject,
    required String topic,
    required List<String> tags,
    required String content,
  }) async {
    try {
      final uid = authService.currentUser()!.uid;
      final id = DateTime.now().toIso8601String();

      final newNote = StudyNote(
        tokens: _generateSearchTokens(title, content),
        id: id,
        title: title,
        subject: subject,
        topic: topic,
        tags: tags,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreServices.addData(
        collectionName: 'users/$uid/studyNotes',
        id: id,
        data: newNote.toMap(),
      );
    } catch (e) {
      emit(StudyNotesFailure(e.toString()));
    }
  }

  /// Update Note
  Future<void> updateNote({
    required String id,
    required String title,
    required String subject,
    required String topic,
    required List<String> tags,
    required String content,
  }) async {
    try {
      final uid = authService.currentUser()!.uid;
      final updatedData = {
        'tokens': _generateSearchTokens(title, content),
        'title': title,
        'subject': subject,
        'topic': topic,
        'tags': tags,
        'content': content,
        'updatedAt': DateTime.now(),
      };

      await FirestoreServices.updateData(
        collectionName: 'users/$uid/studyNotes',
        docName: id,
        data: updatedData,
      );
    } catch (e) {
      emit(StudyNotesFailure(e.toString()));
    }
  }

  /// Delete Note
  Future<void> deleteNote(String id) async {
    try {
      final uid = authService.currentUser()!.uid;
      await FirestoreServices.deleteData(
        collectionName: 'users/$uid/studyNotes',
        documentId: id,
      );
    } catch (e) {
      emit(StudyNotesFailure(e.toString()));
    }
  }

  /// Filter notes by subject (local filter only)
  void filterBySubject(String? subject) {
    activeSubject = subject;

    if (subject == null) {
      emit(StudyNotesSuccess(allNotes));
      return;
    }

    final filtered = allNotes.where((n) => n.subject == subject).toList();

    if (filtered.isEmpty) {
      // 🔹 If empty immediately, reset
      activeSubject = null;
      emit(StudyNotesSuccess(allNotes));
    } else {
      emit(StudyNotesSuccess(filtered));
    }
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }

  /// Helpers for search tokens
  List<String> _generatePrefixes(String word) {
    final prefixes = <String>[];
    for (var i = 1; i <= word.length; i++) {
      prefixes.add(word.substring(0, i));
    }
    return prefixes;
  }

  List<String> _generateSearchTokens(String title, String content) {
    final words = [..._tokenize(title), ..._tokenize(content)];
    return words.expand((w) => _generatePrefixes(w)).toList();
  }

  String _normalize(String text) {
    return text
        .replaceAll(
          RegExp(
            r'[\u0610-\u061A\u064B-\u065F\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]',
          ),
          '',
        )
        .replaceAll(RegExp(r'[إأآا]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[يى]'), 'ي')
        .toLowerCase();
  }

  List<String> _tokenize(String text) {
    final normalized = _normalize(text);
    final regex = RegExp(r"[\p{L}\p{N}]+", unicode: true);
    return regex.allMatches(normalized).map((m) => m.group(0)!).toList();
  }
}
