import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LandingAuthPage extends StatefulWidget {
  final String? initialEmail;
  final bool earlyAccessFlow;

  const LandingAuthPage({
    super.key,
    this.initialEmail,
    this.earlyAccessFlow = false,
  });

  @override
  State<LandingAuthPage> createState() => _LandingAuthPageState();
}

class _LandingAuthPageState extends State<LandingAuthPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();

  bool _isSignUpMode = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthentication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      if (_isSignUpMode) {
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification link sent! Check your email.'),
              backgroundColor: Colors.teal,
            ),
          );
          setState(() => _isSignUpMode = false);
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Close the auth bottom sheet after a successful login so the route
        // redirect can show the authenticated app state.
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    } on AuthException catch (error) {
      if (mounted) _showErrorSnackBar(error.message);
    } catch (error) {
      if (mounted) _showErrorSnackBar('An unexpected authentication error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showAuthFormSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isSignUpMode ? 'CREATE ACCOUNT' : 'SECURE SIGN IN',
                        style: const TextStyle(
                          color: Color(0xFF39FF14),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(hint: 'Email', icon: Icons.email_outlined),
                        validator: (val) => (val == null || !val.contains('@')) ? 'Invalid email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(hint: 'Password', icon: Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setModalState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (val) => (val == null || val.length < 6) ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF39FF14), foregroundColor: Colors.black),
                        onPressed: _isLoading ? null : () async {
                          setModalState(() => _isLoading = true);
                          await _handleAuthentication();
                          if (mounted) setModalState(() => _isLoading = false);
                        },
                        child: _isLoading ? const CircularProgressIndicator() : Text(_isSignUpMode ? 'REGISTER' : 'LOGIN'),
                      ),
                      TextButton(
                        onPressed: () => setModalState(() => _isSignUpMode = !_isSignUpMode),
                        child: Text(_isSignUpMode ? 'LOGIN INSTEAD' : 'CREATE ACCOUNT'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
      filled: true,
      fillColor: const Color(0xFF111111),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('SPOTLIGHT', style: TextStyle(color: Color(0xFF39FF14), fontSize: 32, fontWeight: FontWeight.bold)),
            const Text('CONNECT', style: TextStyle(color: Color(0xFFD4AF37), letterSpacing: 4)),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () => _showAuthFormSheet(context),
              child: const Text('INITIALIZE ACCESS'),
            ),
          ],
        ),
      ),
    );
  }
}