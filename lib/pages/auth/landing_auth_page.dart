import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme.dart';

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

        if (mounted) {
          // Explicitly redirect using GoRouter to bypass the loop
          // Swap '/' for your actual dashboard route if different in nav.dart
          context.go('/');
        }
      }
    } on AuthException catch (error) {
      if (mounted) _showErrorSnackBar(error.message);
    } catch (error) {
      if (mounted) {
        _showErrorSnackBar('An unexpected authentication error occurred.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: context.textStyles.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        letterSpacing: 1.0,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
      filled: true,
      fillColor: const Color(0xFF020204),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = context.textStyles;

    return Scaffold(
      backgroundColor: const Color(0xFF000105),
      body: SafeArea(
        child: Stack(
          children: [
            // Top Status Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF1E1E1E).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'NODE NETWORK: ACTIVE',
                          style: textStyles.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                            letterSpacing: 1.5,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'v1.0.10 // CORE',
                      style: textStyles.labelSmall?.copyWith(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                        letterSpacing: 1.0,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Web Split/Centered Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      'SPOTLIGHT',
                      style: textStyles.displayMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'CONNECT',
                      style: textStyles.labelLarge?.copyWith(
                        color: const Color(0xFFD4AF37),
                        letterSpacing: 8.0,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Embedded Form Container (Matches Clean Web SaaS Layout)
                    Container(
                      constraints: const BoxConstraints(maxWidth: 460),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: const Color(0xFF09090B),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: const Color(0xFF1C1C1E),
                          width: 1.0,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isSignUpMode
                                  ? 'INITIALIZE NODE REGISTRATION'
                                  : 'SECURE SYSTEM AUTHORIZATION',
                              style: context.textStyles.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Email Input Field Inline
                            TextFormField(
                              controller: _emailController,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontFamily: 'Inter',
                              ),
                              decoration: _buildInputDecoration(
                                context,
                                hint: 'IDENTITY REQUEST (EMAIL)',
                                icon: Icons.alternate_email,
                              ),
                              validator: (val) =>
                                  (val == null || !val.contains('@'))
                                  ? 'Invalid entry token'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Password Input Field Inline
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontFamily: 'Inter',
                              ),
                              decoration:
                                  _buildInputDecoration(
                                    context,
                                    hint: 'ACCESS KEY (PASSWORD)',
                                    icon: Icons.key_outlined,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: theme
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withValues(alpha: 0.4),
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                              validator: (val) =>
                                  (val == null || val.length < 6)
                                  ? 'Insecure key size (Min 6)'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Submit Button Inline
                            SizedBox(
                              height: 48,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                    side: BorderSide(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : _handleAuthentication,
                                child: _isLoading
                                    ? SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: theme.colorScheme.onPrimary,
                                          strokeWidth: 1.5,
                                        ),
                                      )
                                    : Text(
                                        _isSignUpMode
                                            ? 'EXECUTE SIGN UP'
                                            : 'ESTABLISH SESSION',
                                        style: context
                                            .textStyles
                                            .labelLarge
                                            ?.bold
                                            .copyWith(letterSpacing: 1.0),
                                      ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // Context Mode Switcher Inline
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.secondary,
                              ),
                              onPressed: () => setState(
                                () => _isSignUpMode = !_isSignUpMode,
                              ),
                              child: Text(
                                _isSignUpMode
                                    ? 'RETURN TO LOGIN PREROUTE'
                                    : 'REQUEST INFRASTRUCTURE HANDSHAKE',
                                style: context.textStyles.labelSmall?.copyWith(
                                  letterSpacing: 0.5,
                                  color: const Color(0xFFD4AF37),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
