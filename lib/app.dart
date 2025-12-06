import 'pages/home_page.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/add_tree_page.dart';
import 'pages/complaint_page.dart';
import 'pages/notes_page.dart';
import 'pages/wallet_page.dart';
import 'pages/settings_page.dart';
import 'theme/app_theme.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Worker App',
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/dashboard': (context) => DashboardPage(),
        '/addTree': (context) => AddTreePage(),
        '/complaints': (context) => ComplaintsPage(),
        '/notes': (context) => NotesPage(),
        '/wallet': (context) => WalletPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
