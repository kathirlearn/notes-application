import 'package:flutter/material.dart';
import 'package:notes_application/models/note_model.dart';
import '../utils/database_helper.dart';
import 'note_editor_dialog.dart';

class NotesHomeScreen extends StatefulWidget {
  const NotesHomeScreen({Key? key}) : super(key: key);

  @override
  State<NotesHomeScreen> createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> {
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.readAllNotes();
    setState(() {
      _notes = data;
      _isLoading = false;
    });
  }

  Future<void> _openEditorDialog([Note? note]) async {
    final result = await showDialog<Note>(
      context: context,
      builder: (context) => NoteEditorDialog(note: note),
    );

    if (result != null) {
      if (note == null) {
        await DatabaseHelper.instance.createNote(result);
      } else {
        await DatabaseHelper.instance.updateNote(result);
      }
      _refreshNotes();
    }
  }

  Future<void> _confirmDelete(BuildContext context, Note note) async {
    final wantDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text('Are you sure you want to permanently delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (wantDelete == true) {
      await DatabaseHelper.instance.deleteNote(note.id);
      _refreshNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Notes App'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? const Center(
        child: Text(
          'No notes stored locally yet.\nTap "+" to create one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: ListTile(
              title: Text(
                note.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Modified: ${note.updatedAt.toLocal().toString().substring(0, 16)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.indigo),
                    onPressed: () => _openEditorDialog(note),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context, note),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditorDialog(),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
