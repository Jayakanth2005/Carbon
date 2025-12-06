import 'dart:io';
import 'package:flutter/material.dart';
import '../models/tree_model.dart';

class TreeDetailsPage extends StatelessWidget {
  final Tree tree;

  const TreeDetailsPage({Key? key, required this.tree}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tree Details"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tree photo
                if (tree.photoPath.isNotEmpty && File(tree.photoPath).existsSync())
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(tree.photoPath),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                  ),
                const SizedBox(height: 16),

                Text("ID: ${tree.id}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Species: ${tree.species}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Height: ${tree.height} m", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("DBH: ${tree.dbh} cm", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Alive: ${tree.isAlive ? "Yes" : "No"}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Plot: ${tree.plot}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Comments: ${tree.comments}", style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
