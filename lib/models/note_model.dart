class Note {
  final int? id;
  final String title;
  final String description;
  final String? imagePath;
  final String? reminderTime; // <-- new field

  Note({
    this.id,
    required this.title,
    required this.description,
    this.imagePath,
    this.reminderTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'reminderTime': reminderTime, // new field
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imagePath: map['imagePath'],
      reminderTime: map['reminderTime'],
    );
  }
}
