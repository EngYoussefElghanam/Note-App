import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_taker/features/auth/services/auth_service.dart';
import 'package:notes_taker/models/note.dart';
import 'package:notes_taker/core/services/firestore_service.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final AuthServicesImpl authService;
  StreamSubscription? _notesSubscription;

  NotesCubit({required this.authService}) : super(NotesInitial());

  /// Stream notes (works offline too, Firestore caches locally)
  void streamNotes() {
    emit(NotesLoading());
    final uid = authService.currentUser()?.uid;
    if (uid == null) {
      emit(NotesFailure("User not logged in"));
      return;
    }

    _notesSubscription =
        FirestoreServices.streamData<Note>(
          collectionName: 'users/$uid/notes',
          fromMap: (data, docId) => Note.fromMap(data, docId),
        ).listen(
          (notes) => emit(NotesSuccess(notes)),
          onError: (e) => emit(NotesFailure(e.toString())),
        );
  }

  /// Delete Note (fire-and-forget, works offline)
  Future<void> deleteNote(String noteId) async {
    try {
      final uid = authService.currentUser()!.uid;
      FirestoreServices.deleteData(
        collectionName: 'users/$uid/notes',
        documentId: noteId,
      ); // 🔹 removed await
    } catch (e) {
      emit(NotesFailure(e.toString()));
    }
  }

  /// Update Note (fire-and-forget, works offline)
  Future<void> updateNote(String noteId, String title, String content) async {
    try {
      final uid = authService.currentUser()!.uid;

      final updatedData = {
        'tokens': _generateSearchTokens(title, content),
        'title': title,
        'content': content,
        'updatedAt': DateTime.now(),
      };

      FirestoreServices.updateData(
        collectionName: 'users/$uid/notes',
        docName: noteId,
        data: updatedData,
      ); // 🔹 removed await
    } catch (e) {
      emit(NotesFailure(e.toString()));
    }
  }

  /// Add Note (fire-and-forget, works offline)
  Future<void> addNote(String title, String content) async {
    try {
      final note = Note(
        tokens: _generateSearchTokens(title, content),
        id: DateTime.now().toIso8601String(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final uid = authService.currentUser()!.uid;

      FirestoreServices.addData(
        collectionName: 'users/$uid/notes',
        data: note.toMap(),
        id: note.id,
      ); // 🔹 removed await
    } catch (e) {
      emit(NotesFailure(e.toString()));
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
