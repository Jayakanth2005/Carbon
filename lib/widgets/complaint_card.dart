// lib/widgets/complaint_card.dart
import 'package:flutter/material.dart';
import '../models/complaint_model.dart';

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback? onTapStatus;
  final VoidCallback? onDelete;

  const ComplaintCard({required this.complaint, this.onTapStatus, this.onDelete});

  Color _statusColor(String s) {
    switch (s) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(complaint.title),
        subtitle: Text(complaint.description),
        trailing: Wrap(
          spacing: 8,
          children: [
            InkWell(
              onTap: onTapStatus,
              child: Chip(
                label: Text(complaint.status),
                backgroundColor: _statusColor(complaint.status).withOpacity(0.15),
              ),
            ),
            IconButton(icon: Icon(Icons.delete_outline), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
