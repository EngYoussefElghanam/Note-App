part of 'study_notes_cubit.dart';

sealed class StudyNotesState {}

final class StudyNotesInitial extends StudyNotesState {}

final class StudyNotesLoading extends StudyNotesState {}

final class StudyNotesSuccess extends StudyNotesState {
  final List<StudyNote> notes;
  StudyNotesSuccess(this.notes);
}

final class StudyNotesFailure extends StudyNotesState {
  final String message;
  StudyNotesFailure(this.message);
}
