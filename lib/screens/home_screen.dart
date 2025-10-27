import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/note_model.dart';
import 'add_note_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final data = await DBHelper.getNotes();
    setState(() => _notes = data);
  }

  void _deleteNote(int id) async {
    await DBHelper.delete(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Notes')),
      body: _notes.isEmpty
          ? Center(child: Text('No Notes Found'))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, i) {
                final note = _notes[i];
               return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    onTap: () async {
                      // Open AddNoteScreen in edit mode
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddNoteScreen(note: note), // pass the note
                        ),
                      );
                      _loadNotes(); // reload notes after editing
                    },
                    leading: note.imagePath != null
                        ? Image.file(File(note.imagePath!), width: 50, fit: BoxFit.cover)
                        : Icon(Icons.note, size: 40, color: Colors.teal),
                    title: Text(note.title),
                    subtitle: Text(note.description),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNote(note.id!),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddNoteScreen()),
          );
          if (result == true) {
            _loadNotes(); // refresh after saving
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
