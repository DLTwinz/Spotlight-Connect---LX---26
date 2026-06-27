import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/providers/supabase_auth_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Move all variables INSIDE the class
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;

Future<void> _submit() async {
    debugPrint("Submit button pressed!"); // New debug print
    
    final authProvider = Provider.of<SupabaseAuthProvider>(context, listen: false);
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    debugPrint("Attempting to login with: $email"); // New debug print

    if (email.isEmpty || password.isEmpty) {
      debugPrint("Email or password empty!");
      return;
    }

    try {
      if (_isLogin) {
        await authProvider.login(email, password);
      } else {
        await authProvider.signup(email, password);
      }
      debugPrint("Login request successful!");
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      debugPrint("CAUGHT ERROR: $e"); // New debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ElevatedButton(
              onPressed: _submit, // This now calls your fixed _submit
              child: Text(_isLogin ? 'Login' : 'Sign Up'),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin ? 'Create Account' : 'Have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
