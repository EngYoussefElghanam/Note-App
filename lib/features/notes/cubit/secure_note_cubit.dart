import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:notes_taker/core/services/firestore_service.dart';
import 'package:notes_taker/features/auth/services/auth_service.dart';
import 'package:notes_taker/models/note.dart';
import 'package:notes_taker/models/study_note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'secure_note_state.dart';

class SecureNoteCubit extends Cubit<SecureNoteState> {
  final AuthServicesImpl authService = AuthServicesImpl();

  SecureNoteCubit() : super(SecureNoteInitial());

  Future<void> lockNote(String password, String noteId, String category) async {
    emit(SecureNoteLoading());
    try {
      final user = await authService.getUserData();
      final hash = sha256.convert(utf8.encode(password)).toString();
      await FirestoreServices.updateData(
        collectionName: 'users/${user!.id}/$category',
        docName: noteId,
        data: {'password': hash},
      );
      emit(SecureNoteSuccess());
    } catch (e) {
      emit(SecureNoteFailure(e.toString()));
    }
  }

  Future<void> unlockNote(
    String password,
    String noteId,
    String category,
  ) async {
    emit(SecureNoteLoading());
    try {
      final user = await authService.getUserData();
      // If password is empty => assume biometrics validated, skip check
      final hash = password.isNotEmpty
          ? sha256.convert(utf8.encode(password)).toString()
          : '';

      final noteData = await FirestoreServices.getDocData(
        collectionName: 'users/${user!.id}/$category',
        docName: noteId,
        fromMap: (data, docId) => category == 'notes'
            ? Note.fromMap(data, docId)
            : StudyNote.fromMap(data, docId),
      );

      final storedHash = category == 'studyNotes'
          ? (noteData as StudyNote).password
          : (noteData as Note).password;

      if (storedHash == null ||
          storedHash.isEmpty ||
          (password.isEmpty || storedHash == hash)) {
        await FirestoreServices.updateData(
          collectionName: 'users/${user.id}/$category',
          docName: noteId,
          data: {'password': FieldValue.delete()},
        );
        emit(SecureNoteSuccess());
      } else {
        emit(SecureNoteFailure('Incorrect password'));
      }
    } catch (e) {
      emit(SecureNoteFailure(e.toString()));
    }
  }
}
