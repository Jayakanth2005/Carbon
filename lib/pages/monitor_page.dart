import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/tree_model.dart';

class MonitorTreePage extends StatefulWidget {
  final void Function(String action)? onAction; // 👈 callback field

  const MonitorTreePage({Key? key, this.onAction}) : super(key: key);

  @override
  State<MonitorTreePage> createState() => _MonitorTreePageState();
}

class _MonitorTreePageState extends State<MonitorTreePage> {
  List<Tree> trees = [];

  @override
  void initState() {
    super.initState();
    _loadTrees();
  }

  void _loadTrees() {
    setState(() {
      trees = HiveService.getAllTrees();
    });
  }

  void _editTree(Tree tree) {
    final speciesController = TextEditingController(text: tree.species);
    final plotController = TextEditingController(text: tree.plot);
    final heightController = TextEditingController(text: tree.height.toString());
    final dbhController = TextEditingController(text: tree.dbh.toString());
    final isAliveController = TextEditingController(text: tree.isAlive ? 'true' : 'false');
    final photoPathController = TextEditingController(text: tree.photoPath);
    final commentsController = TextEditingController(text: tree.comments);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tree'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: speciesController, decoration: const InputDecoration(labelText: 'Species / Name')),
              TextField(controller: plotController, decoration: const InputDecoration(labelText: 'Plot / Location')),
              TextField(controller: heightController, decoration: const InputDecoration(labelText: 'Height (m)'), keyboardType: TextInputType.number),
              TextField(controller: dbhController, decoration: const InputDecoration(labelText: 'DBH (cm)'), keyboardType: TextInputType.number),
              TextField(controller: isAliveController, decoration: const InputDecoration(labelText: 'Is Alive (true/false)')),
              TextField(controller: photoPathController, decoration: const InputDecoration(labelText: 'Photo Path')),
              TextField(controller: commentsController, decoration: const InputDecoration(labelText: 'Comments')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              // Update all fields
              tree.species = speciesController.text;
              tree.plot = plotController.text;
              tree.height = double.tryParse(heightController.text) ?? tree.height;
              tree.dbh = double.tryParse(dbhController.text) ?? tree.dbh;
              tree.isAlive = isAliveController.text.toLowerCase() == 'true';
              tree.photoPath = photoPathController.text;
              tree.comments = commentsController.text;

              await tree.save();
              _loadTrees();
              Navigator.pop(context);

              // Log the action
              widget.onAction?.call("Edited tree: ${tree.species}");
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteTree(Tree tree) async {
    await tree.delete();
    _loadTrees();

    // Log the action
    widget.onAction?.call("Deleted tree: ${tree.species}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitor Trees"),
        centerTitle: true,
      ),
      body: trees.isEmpty
          ? const Center(child: Text("No trees added yet"))
          : ListView.builder(
              itemCount: trees.length,
              itemBuilder: (context, index) {
                final tree = trees[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(tree.species),
                    subtitle: Text(tree.plot),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editTree(tree)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteTree(tree)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
