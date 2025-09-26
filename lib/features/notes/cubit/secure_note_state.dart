part of 'secure_note_cubit.dart';

sealed class SecureNoteState {}

final class SecureNoteInitial extends SecureNoteState {}

final class SecureNoteLoading extends SecureNoteState {}

final class SecureNoteSuccess extends SecureNoteState {}

final class SecureNoteFailure extends SecureNoteState {
  final String errorMessage;

  SecureNoteFailure(this.errorMessage);
}
