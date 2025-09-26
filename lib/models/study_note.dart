import 'package:cloud_firestore/cloud_firestore.dart';

class StudyNote {
  final String id;
  final String title;
  final String subject;
  final String topic;
  final List<String> tags;
  final List<String> tokens;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? password;

  StudyNote({
    required this.id,
    required this.title,
    required this.subject,
    required this.topic,
    required this.tags,
    required this.tokens,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.password,
  });

  /// Empty instance for defaults
  factory StudyNote.empty() {
    return StudyNote(
      id: '',
      title: '',
      subject: '',
      topic: '',
      tags: const [],
      tokens: const [],
      content: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      password: null,
    );
  }

  /// Create a copy with modifications
  StudyNote copyWith({
    String? password,
    String? id,
    String? title,
    String? subject,
    String? topic,
    List<String>? tags,
    List<String>? tokens,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyNote(
      password: password ?? this.password,
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      tags: tags ?? this.tags,
      tokens: tokens ?? this.tokens,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 🔹 Convert Firestore/JSON Map → StudyNote
  factory StudyNote.fromMap(Map<String, dynamic> map, String docId) {
    return StudyNote(
      password: map['password'] ?? '',
      id: docId,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      topic: map['topic'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      tokens: List<String>.from(map['tokens'] ?? []),
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 🔹 Convert StudyNote → Map for Firestore/JSON
  Map<String, dynamic> toMap() {
    return {
      'password': password,
      'title': title,
      'subject': subject,
      'topic': topic,
      'tags': tags,
      'tokens': tokens,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
