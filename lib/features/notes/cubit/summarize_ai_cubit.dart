import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_taker/core/services/chat_service.dart';

part 'summarize_ai_state.dart';

class SummarizeAiCubit extends Cubit<SummarizeAiState> {
  final ChatService _chatService;
  SummarizeAiCubit(this._chatService) : super(SummarizeAiInitial());

  Future<void> sendMessage(String message) async {
    emit(SendingMessage());
    try {
      final response = await _chatService.sendMessage(
        "Summarize the following text into clear, concise bullet points suitable for studying. Focus on key concepts, definitions, and important details:\n\n$message",
      );

      if (response != null) {
        emit(MessageReceived(response));
      } else {
        emit(MessageError("No response from AI"));
      }
    } catch (e) {
      emit(MessageError("Error: $e"));
    }
  }

  Future<void> sendMessageWithImage(String message, List<File> images) async {
    emit(SendingMessage());
    try {
      final response = await _chatService.sendMessageWithImage(message, images);
      if (response != null) {
        emit(MessageReceived(response));
      } else {
        emit(MessageError("No response from AI"));
      }
    } catch (e) {
      emit(MessageError("Error: $e"));
    }
  }
}
