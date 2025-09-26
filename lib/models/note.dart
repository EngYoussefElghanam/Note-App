import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tokens;
  final String? password;

  Note({
    this.password,
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.tokens,
  });

  factory Note.fromMap(Map<String, dynamic> map, String documentId) {
    return Note(
      password: map['password'] ?? '',
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      tokens: List<String>.from(map['tokens'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'password': password,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tokens': tokens,
    };
  }
}
