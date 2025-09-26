import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:notes_taker/core/app_constants.dart';

abstract class ChatService {
  Future<String?> sendMessage(String message);
  Future<String?> sendMessageWithImage(String message, List<File> images);
}

class ChatServiceImpl implements ChatService {
  late final GenerativeModel _model;

  ChatServiceImpl() {
    final apiKey = AppConstants.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception("Missing Gemini API key in .env");
    }

    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  @override
  Future<String?> sendMessage(String message) async {
    try {
      // Start a new chat for each message
      final chat = _model.startChat();
      final response = await chat.sendMessage(Content.text(message));
      return response.text;
    } catch (e) {
      return "Error: $e";
    }
  }

  @override
  Future<String?> sendMessageWithImage(
    String message,
    List<File> images,
  ) async {
    try {
      final chat = _model.startChat(); // new chat for this message
      final contents = [
        Content.multi([
          TextPart(message),
          for (final image in images)
            DataPart('image/jpeg', image.readAsBytesSync()),
        ]),
      ];

      final response = await chat.sendMessage(contents.first);
      return response.text;
    } catch (e) {
      return "Error: $e";
    }
  }
}
