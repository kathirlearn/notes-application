import 'dart:convert';

class Note {
  // Properties
  final String id;
  String title;
  String content;
  DateTime updatedAt;

  // Constructor - Named Constructor
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  // ENCODING
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // DECODING
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'].toString(),
      title: map['title'].toString(),
      content: map['content'].toString(),
      updatedAt: DateTime.parse(map['updatedAt'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) =>
      Note.fromMap(json.decode(source) as Map<String, dynamic>);
}
