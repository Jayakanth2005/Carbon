// lib/widgets/note_card.dart
import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NoteCard({required this.note, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(note.projectId.isEmpty ? 'General Note' : note.projectId),
        subtitle: Text(note.content),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: Icon(Icons.edit_outlined), onPressed: onEdit),
          IconButton(icon: Icon(Icons.delete_outline), onPressed: onDelete),
        ]),
      ),
    );
  }
}
