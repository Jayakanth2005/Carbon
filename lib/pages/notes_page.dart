import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import '../services/hive_service.dart';
import '../widgets/note_card.dart';
import '../theme/app_theme.dart';

class NotesPage extends StatefulWidget {
  final Function(String action)? onAction;
  NotesPage({this.onAction});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    notes = HiveService.getAllNotes();
    setState(() {});
  }

  void _openEditor({Note? existing}) {
    final _formKey = GlobalKey<FormState>();
    String content = existing?.content ?? '';
    String projectId = existing?.projectId ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'New Note' : 'Edit Note'),
        content: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              initialValue: content,
              decoration: InputDecoration(labelText: 'Note'),
              maxLines: 4,
              onSaved: (v) => content = v ?? '',
            ),
            TextFormField(
              initialValue: projectId,
              decoration: InputDecoration(labelText: 'Project/Plot (optional)'),
              onSaved: (v) => projectId = v ?? '',
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              _formKey.currentState?.save();
              if (existing == null) {
                final n = Note(id: Uuid().v4(), content: content, projectId: projectId);
                await HiveService.addNote(n);
                if (widget.onAction != null) widget.onAction!("Added note: $content");
              } else {
                final n = Note(id: existing.id, content: content, projectId: projectId);
                await HiveService.updateNote(n);
                if (widget.onAction != null) widget.onAction!("Edited note: $content");
              }
              _load();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _delete(String id, String content) async {
    await HiveService.deleteNote(id);
    if (widget.onAction != null) widget.onAction!("Deleted note: $content");
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.gradient)),
      ),
      body: notes.isEmpty
          ? Center(child: Text('No notes yet.'))
          : ListView.separated(
              padding: EdgeInsets.all(12),
              itemCount: notes.length,
              separatorBuilder: (_, __) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = notes[index];
                return NoteCard(
                  note: n,
                  onEdit: () => _openEditor(existing: n),
                  onDelete: () => _delete(n.id, n.content),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: Icon(Icons.add),
      ),
    );
  }
}
