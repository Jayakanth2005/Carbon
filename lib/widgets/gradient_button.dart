// lib/widgets/gradient_button.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(gradient: AppTheme.gradient, borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
