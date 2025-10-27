import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/note_model.dart';

class DBHelper {
  // Open the database
  static Future<Database> database() async {
    // Get default database folder path
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    // Open or create database
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, imagePath TEXT)',
        );
      },
    );
  }

  // Insert a note
  static Future<int> insert(Note note) async {
    final db = await database();
    return await db.insert('notes', note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all notes
  static Future<List<Note>> getNotes() async {
    final db = await database();
    final List<Map<String, dynamic>> data = await db.query('notes');
    return data.map((e) => Note.fromMap(e)).toList();
  }

  // Delete a note
  static Future<int> delete(int id) async {
    final db = await database();
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> update(Note note) async {
  final db = await database();
  return await db.update(
    'notes',
    note.toMap(),
    where: 'id = ?',
    whereArgs: [note.id],
  );
}

}
