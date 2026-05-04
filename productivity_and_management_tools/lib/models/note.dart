class Note {
  final int? id;
  final String title;
  final String body;
  final String createdAt;

  Note({
    this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  // Convert Note object to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': createdAt,
    };
  }

  // Convert Map from database to Note object
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      createdAt: map['createdAt'],
    );
  }

  // Create a copy of Note with modified fields
  Note copyWith({
    int? id,
    String? title,
    String? body,
    String? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
