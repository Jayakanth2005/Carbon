import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/tree_model.dart';
import 'package:image_picker/image_picker.dart';

class AddTreePage extends StatefulWidget {
  @override
  _AddTreePageState createState() => _AddTreePageState();
}

class _AddTreePageState extends State<AddTreePage> {
  final _formKey = GlobalKey<FormState>();
  String species = '';
  double height = 0;
  double dbh = 0;
  bool isAlive = true;
  String plot = '';
  String comments = '';
  String photoPath = '';

  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) photoPath = pickedFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Tree')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Species'),
                onSaved: (val) => species = val ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Height (m)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => height = double.tryParse(val ?? '0') ?? 0,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'DBH (cm)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => dbh = double.tryParse(val ?? '0') ?? 0,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Plot/Grid'),
                onSaved: (val) => plot = val ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Comments'),
                onSaved: (val) => comments = val ?? '',
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: pickImage,
                child: Text('Capture Photo'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
  onPressed: () {
    _formKey.currentState?.save();
    final tree = Tree(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      species: species,
      height: height,
      dbh: dbh,
      isAlive: isAlive,
      plot: plot,
      photoPath: photoPath,
      comments: comments,
    );
    HiveService.addTree(tree);
    Navigator.pop(context); // ✅ after save
  },
  child: Text('Save Tree'),
),

            ],
          ),
        ),
      ),
    );
  }
}
