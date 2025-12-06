import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/complaint_model.dart';
import '../services/hive_service.dart';
import '../widgets/complaint_card.dart';
import '../theme/app_theme.dart';

class ComplaintsPage extends StatefulWidget {
  final Function(String action)? onAction;
  ComplaintsPage({this.onAction});

  @override
  _ComplaintsPageState createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  List<Complaint> complaints = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    complaints = HiveService.getAllComplaints();
    setState(() {});
  }

  void _openAddDialog() {
    final _formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    String project = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('New Complaint'),
        content: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
              onSaved: (v) => title = v ?? '',
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              onSaved: (v) => description = v ?? '',
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Project/Plot (optional)'),
              onSaved: (v) => project = v ?? '',
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              _formKey.currentState?.save();
              final c = Complaint(
                id: Uuid().v4(),
                title: title,
                description: description,
                projectId: project,
                status: 'Pending',
              );
              await HiveService.addComplaint(c);
              if (widget.onAction != null) widget.onAction!("Added complaint: $title");
              _load();
              Navigator.pop(context);
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(String id) async {
    final c = complaints.firstWhere((e) => e.id == id);
    String next;
    if (c.status == 'Pending') next = 'In Progress';
    else if (c.status == 'In Progress') next = 'Resolved';
    else next = 'Resolved';

    await HiveService.updateComplaintStatus(id, next);
    if (widget.onAction != null) widget.onAction!("Updated complaint: ${c.title} -> $next");
    _load();
  }

  void _delete(String id, String title) async {
    await HiveService.deleteComplaint(id);
    if (widget.onAction != null) widget.onAction!("Deleted complaint: $title");
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints'),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.gradient)),
      ),
      body: complaints.isEmpty
          ? Center(child: Text('No complaints yet.'))
          : ListView.separated(
              padding: EdgeInsets.all(12),
              itemCount: complaints.length,
              separatorBuilder: (_, __) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final c = complaints[index];
                return ComplaintCard(
                  complaint: c,
                  onTapStatus: () => _updateStatus(c.id),
                  onDelete: () => _delete(c.id, c.title),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
