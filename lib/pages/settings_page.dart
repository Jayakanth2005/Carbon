// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _syncing = false;

  Future<void> _sync() async {
    setState(() => _syncing = true);
    final ok = await HiveService.syncAll();
    setState(() => _syncing = false);
    final snack = ok ? 'Sync complete' : 'Sync failed';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snack)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.gradient)),
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.sync),
              title: Text('Sync now'),
              subtitle: Text('Push local data and fetch server updates'),
              trailing: _syncing ? CircularProgressIndicator() : Icon(Icons.chevron_right),
              onTap: _sync,
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              },
            ),
          ),
          SizedBox(height: 20),
          Text('App theme preview', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Container(
            height: 120,
            decoration: BoxDecoration(gradient: AppTheme.gradient, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('Green + Blue Theme', style: TextStyle(color: Colors.white, fontSize: 18))),
          ),
        ],
      ),
    );
  }
}
