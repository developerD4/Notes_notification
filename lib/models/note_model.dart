class Note {
  int? id;
  String title;
  String description;
  String? imagePath;

  Note({
    this.id,
    required this.title,
    required this.description,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imagePath': imagePath,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imagePath: map['imagePath'],
    );
  }
}
