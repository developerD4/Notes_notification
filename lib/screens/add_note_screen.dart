import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/services/notification_service.dart';
import '../models/note_model.dart';
import '../services/db_helper.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note; // null = new note, not null = edit existing
  

  const AddNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  File? _image;
  DateTime? _reminderTime;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descController = TextEditingController(text: widget.note?.description ?? '');
    if (widget.note?.imagePath != null) {
      _image = File(widget.note!.imagePath!);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveNote() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and description')),
      );
      return;
    }

    if (widget.note == null) {
      // New note
      final newNote = Note(
        title: _titleController.text,
        description: _descController.text,
        imagePath: _image?.path,
      );
      await DBHelper.insert(newNote);
    } else {
      // Update existing note
      final updatedNote = Note(
        id: widget.note!.id,
        title: _titleController.text,
        description: _descController.text,
        imagePath: _image?.path ?? widget.note!.imagePath,
      );
      await DBHelper.update(updatedNote);
    }

    if (!mounted) return;
    Navigator.of(context).pop(true); // send result to refresh list
    if (_reminderTime != null) {
    await NotificationService.scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: _titleController.text,
      body: _descController.text,
      time: _reminderTime!,
    );
}

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            _image != null
                ? Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover)
                : const Text('No image selected'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text('Gallery'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
            ListTile(
  title: Text(
    _reminderTime == null
        ? 'No reminder set'
        : 'Reminder: ${_reminderTime.toString().substring(0, 16)}',
  ),
  trailing: IconButton(
    icon: const Icon(Icons.alarm),
    onPressed: () async {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (date != null) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          setState(() {
            _reminderTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          });
        }
      }
    },
  ),
),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveNote,
              child: Text(widget.note == null ? 'Save Note' : 'Update Note'),
            ),
          ],
        ),
      ),
    );
  }
}
