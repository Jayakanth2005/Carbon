import 'package:flutter/material.dart';

class CircularAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CircularAddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.green,
      child: Icon(Icons.add),
      onPressed: onPressed,
    );
  }
}
