import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/services/notification_service.dart';
import '../models/note_model.dart';
import '../services/db_helper.dart';
import 'package:permission_handler/permission_handler.dart';

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
  DateTime? _selectedReminderTime; // use only one variable
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descController = TextEditingController(text: widget.note?.description ?? '');

    if (widget.note?.imagePath != null && widget.note!.imagePath!.isNotEmpty) {
      _image = File(widget.note!.imagePath!);
    }

    // Parse stored reminder time (if any)
    if (widget.note?.reminderTime != null && widget.note!.reminderTime!.isNotEmpty) {
      try {
        _selectedReminderTime = DateTime.parse(widget.note!.reminderTime!);
      } catch (_) {
        _selectedReminderTime = null;
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _pickReminderDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedReminderTime ?? DateTime.now().add(const Duration(minutes: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedReminderTime ?? DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _selectedReminderTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _checkNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }
  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and description')),
      );
      return;
    }

    final reminderIso = _selectedReminderTime?.toIso8601String();

    if (widget.note == null) {
      // New note
      final newNote = Note(
        title: _titleController.text,
        description: _descController.text,
        imagePath: _image?.path,
        reminderTime: reminderIso,
      );

      await DBHelper.insert(newNote);

      // Schedule notification
      if (_selectedReminderTime != null && _selectedReminderTime!.isAfter(DateTime.now())) {
        final notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await NotificationService.scheduleNotification(
          id: notifId,
          title: newNote.title,
          body: newNote.description,
          scheduledTime: _selectedReminderTime!,
        );
      }
    } else {
      // Update existing note
      final updatedNote = Note(
        id: widget.note!.id,
        title: _titleController.text,
        description: _descController.text,
        imagePath: _image?.path ?? widget.note!.imagePath,
        reminderTime: reminderIso,
      );

      await DBHelper.update(updatedNote);

      if (_selectedReminderTime != null && _selectedReminderTime!.isAfter(DateTime.now())) {
        final notifId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await NotificationService.scheduleNotification(
          id: notifId,
          title: updatedNote.title,
          body: updatedNote.description,
          scheduledTime: _selectedReminderTime!,
        );
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
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

            const SizedBox(height: 20),
            ListTile(
              title: Text(
                _selectedReminderTime == null
                    ? 'No reminder set'
                    : 'Reminder: ${_selectedReminderTime.toString().substring(0, 16)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.alarm),
                onPressed: _pickReminderDateTime,
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
