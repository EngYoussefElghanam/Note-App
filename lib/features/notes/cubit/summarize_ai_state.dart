part of 'summarize_ai_cubit.dart';

sealed class SummarizeAiState {}

final class SummarizeAiInitial extends SummarizeAiState {}

final class SendingMessage extends SummarizeAiState {}

final class MessageReceived extends SummarizeAiState {
  final String response;

  MessageReceived(this.response);
}

final class MessageError extends SummarizeAiState {
  final String error;

  MessageError(this.error);
}
