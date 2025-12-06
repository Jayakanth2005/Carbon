import 'package:carbon/pages/tree_details_page.dart';
import 'package:flutter/material.dart';
import '../widgets/circular_add_button.dart';
import '../widgets/tree_card.dart';
import '../models/tree_model.dart';
import '../services/hive_service.dart';

class DashboardPage extends StatefulWidget {
  final Function(String)? onAction; // callback for logs

  DashboardPage({this.onAction});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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

  void _deleteTree(Tree tree) async {
  await HiveService.deleteTree(tree.id);
  _loadTrees();
  if (widget.onAction != null) {
    widget.onAction!("Deleted tree: ${tree.species}");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Field Worker Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: trees.isEmpty
                ? const Center(child: Text("No trees added yet"))
                : ListView.builder(
                    itemCount: trees.length,
                    itemBuilder: (context, index) {
                      final tree = trees[index];
                      return TreeCard(
                        tree: tree,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TreeDetailsPage(tree: tree),
                            ),
                          );
                        },
                        onDelete: () => _deleteTree(tree),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: CircularAddButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addTree').then((_) {
            _loadTrees(); // reload list
            if (widget.onAction != null) widget.onAction!("Opened Add Tree Page");
          });
        },
      ),
    );
  }
}
