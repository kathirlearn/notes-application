import 'package:flutter/material.dart';
import 'package:notes_application/models/note_model.dart';
import 'package:uuid/uuid.dart';

class NoteEditorDialog extends StatefulWidget {
  final Note? note; // If null, we are in CREATE mode. Otherwise, UPDATE mode.

  const NoteEditorDialog({Key? key, this.note}) : super(key: key);

  @override
  State<NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<NoteEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Note' : 'New Note'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Please enter some content' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final note = Note(
                // Use existing ID if editing, otherwise generate a fresh unique UUID string
                id: widget.note?.id ?? const Uuid().v4(),
                title: _titleController.text.trim(),
                content: _contentController.text.trim(),
                updatedAt: DateTime.now(),
              );
              Navigator.of(context).pop(note);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
