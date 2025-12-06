// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _remember = true;
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _tryAutoLogin() async {
    // If an auth box exists and has a saved user, navigate straight to dashboard.
    if (Hive.isBoxOpen('auth')) {
      final box = Hive.box('auth');
      final saved = box.get('user');
      if (saved != null) {
        // small delay so splash feels natural
        await Future.delayed(const Duration(milliseconds: 250));
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // safe to call, Hive was initialized in main()
    _tryAutoLogin();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // Simulate an authentication delay (replace with real API)
    await Future.delayed(const Duration(milliseconds: 900));

    // Example simple auth: accept any non-empty username/password
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;

    // Replace with real validation
    final success = username.isNotEmpty && password.isNotEmpty;

    if (success) {
      // Save username if "remember me" checked
      if (!Hive.isBoxOpen('auth')) {
        await Hive.openBox('auth');
      }
      final box = Hive.box('auth');
      if (_remember) {
        await box.put('user', username);
      } else {
        await box.delete('user');
      }

      if (mounted) {
        setState(() => _loading = false);
       Navigator.pushReplacementNamed(context, '/home');

      }
    } else {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials — try anything non-empty for demo')),
        );
      }
    }
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Replace with AssetImage or Network image if you have a logo
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.white24,
          child: Icon(Icons.nature, size: 36, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text('Field Worker', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Offline-first • Hive • Green + Blue', style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final cardWidth = media.size.width * (media.size.width > 600 ? 0.5 : 0.92);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top spacing + logo
                  _buildLogo(),
                  const SizedBox(height: 28),

                  // Card
                  Container(
                    width: cardWidth,
                    constraints: const BoxConstraints(maxWidth: 720),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Sign in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                        ),
                        const SizedBox(height: 12),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _userCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter username' : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
                                onFieldSubmitted: (_) => _onLogin(),
                              ),
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Checkbox(
                                    value: _remember,
                                    onChanged: (v) => setState(() => _remember = v ?? true),
                                    activeColor: Colors.green,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('Remember me'),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      // simple placeholder; implement forgot-password flow if required
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Forgot password flow (not implemented)')));
                                    },
                                    child: const Text('Forgot?'),
                                  )
                                ],
                              ),

                              const SizedBox(height: 8),
                              // Login button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    // create gradient-like feel using primary + onPrimary handled by theme
                                  ),
                                  onPressed: _loading ? null : _onLogin,
                                  child: _loading
                                      ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text('Sign in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Quick links / demo creds
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(child: Text('Demo: use any non-empty credentials', style: TextStyle(color: Colors.grey[700], fontSize: 12))),
                            TextButton(
                              onPressed: () {
                                // fill demo credentials for convenience
                                setState(() {
                                  _userCtrl.text = 'worker01';
                                  _passCtrl.text = 'password';
                                });
                              },
                              child: const Text('Fill demo'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Small footer
                  Text('Powered by CarbonLith • Offline-ready', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
