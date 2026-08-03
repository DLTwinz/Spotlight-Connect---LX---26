import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotlight_connect/core/routing/app_routes.dart';
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
  /// audience | talent | business — drives post-signup onboarding
  String _intendedRole = 'audience';
  bool _roleSeeded = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_roleSeeded) return;
    _roleSeeded = true;
    final role = GoRouterState.of(context).uri.queryParameters['role'];
    if (role == 'talent' || role == 'business' || role == 'audience') {
      _intendedRole = role!;
      _isSignUpMode = true;
    }
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
        final result = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!mounted) return;

        // Session present (email confirm off) → onboarding with intended role.
        // Otherwise ask user to verify email, then sign in.
        if (result.session != null) {
          final role = _intendedRole;
          final target = (role == 'audience')
              ? AppRoutes.onboarding
              : '${AppRoutes.onboarding}?role=$role';
          context.go(target);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification link sent! Check your email.'),
              backgroundColor: SpotlightAccents.success,
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
          context.go('/');
        }
      }
    } on AuthException catch (error) {
      if (mounted) _showErrorSnackBar(error.message);
    } catch (_) {
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
      hintStyle: context.textStyles.labelMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.38),
        letterSpacing: 0.2,
      ),
      prefixIcon: Icon(icon, color: SpotlightAccents.cyan, size: 20),
      filled: true,
      fillColor: SpotlightAccents.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.95),
          width: 1.25,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;
    final isTablet = width >= 760;
    final horizontalPadding = isDesktop ? 40.0 : (isTablet ? 24.0 : 16.0);

    return Scaffold(
      backgroundColor: SpotlightAccents.bg,
      body: Stack(
        children: [
          const _LandingBackground(),
          SafeArea(
            child: Column(
              children: [
                _LandingTopBar(
                  isDesktop: isTablet,
                  onSignInTap: () {
                    if (_isSignUpMode) {
                      setState(() => _isSignUpMode = false);
                    }
                  },
                  onJoinTap: () {
                    setState(() {
                      _isSignUpMode = true;
                      _intendedRole = 'audience';
                    });
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isDesktop ? 28 : 18,
                      horizontalPadding,
                      24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1380),
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 11,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _LandingHeroSection(
                                          isSignUpMode: _isSignUpMode,
                                          onCreatorTap: () {
                                            setState(() {
                                              _isSignUpMode = true;
                                              _intendedRole = 'talent';
                                            });
                                          },
                                          onBrandTap: () {
                                            setState(() {
                                              _isSignUpMode = true;
                                              _intendedRole = 'business';
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        const _LandingSignalStrip(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 22),
                                  Expanded(
                                    flex: 8,
                                    child: Column(
                                      children: [
                                        _LandingAuthCard(
                                          formKey: _formKey,
                                          emailController: _emailController,
                                          passwordController:
                                              _passwordController,
                                          isSignUpMode: _isSignUpMode,
                                          isLoading: _isLoading,
                                          obscurePassword: _obscurePassword,
                                          buildInputDecoration:
                                              ({
                                                required String hint,
                                                required IconData icon,
                                              }) => _buildInputDecoration(
                                                context,
                                                hint: hint,
                                                icon: icon,
                                              ),
                                          onSubmit: _handleAuthentication,
                                          onToggleMode: () {
                                            setState(() {
                                              _isSignUpMode = !_isSignUpMode;
                                            });
                                          },
                                          onToggleObscure: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 18),
                                        const _LandingPreviewPanel(),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _LandingHeroSection(
                                    isSignUpMode: _isSignUpMode,
                                    onCreatorTap: () {
                                      setState(() {
                                        _isSignUpMode = true;
                                        _intendedRole = 'talent';
                                      });
                                    },
                                    onBrandTap: () {
                                      setState(() {
                                        _isSignUpMode = true;
                                        _intendedRole = 'business';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _LandingAuthCard(
                                    formKey: _formKey,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    isSignUpMode: _isSignUpMode,
                                    isLoading: _isLoading,
                                    obscurePassword: _obscurePassword,
                                    buildInputDecoration:
                                        ({
                                          required String hint,
                                          required IconData icon,
                                        }) => _buildInputDecoration(
                                          context,
                                          hint: hint,
                                          icon: icon,
                                        ),
                                    onSubmit: _handleAuthentication,
                                    onToggleMode: () {
                                      setState(() {
                                        _isSignUpMode = !_isSignUpMode;
                                      });
                                    },
                                    onToggleObscure: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  const _LandingPreviewPanel(),
                                  const SizedBox(height: 16),
                                  const _LandingSignalStrip(),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingBackground extends StatelessWidget {
  const _LandingBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: SpotlightAccents.bg),
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  SpotlightAccents.surface,
                  SpotlightAccents.bg,
                  SpotlightAccents.bg,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          left: -80,
          child: _GlowBlob(
            size: 340,
            color: SpotlightAccents.cyan.withValues(alpha: 0.14),
          ),
        ),
        Positioned(
          top: 90,
          right: -40,
          child: _GlowBlob(
            size: 360,
            color: SpotlightAccents.purple.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: -50,
          right: 180,
          child: _GlowBlob(
            size: 280,
            color: SpotlightAccents.magenta.withValues(alpha: 0.10),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _GridPainter())),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.44,
            spreadRadius: size * 0.10,
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const gap = 40.0;

    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LandingTopBar extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback onSignInTap;
  final VoidCallback onJoinTap;

  const _LandingTopBar({
    required this.isDesktop,
    required this.onSignInTap,
    required this.onJoinTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1380),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Row(
              children: [
                const _BrandLockup(),
                const SizedBox(width: 18),
                if (isDesktop) ...[
                  const _NavText('Platform'),
                  const SizedBox(width: 18),
                  const _NavText('Creators'),
                  const SizedBox(width: 18),
                  const _NavText('Brands'),
                  const SizedBox(width: 18),
                  const _NavText('Community'),
                  const Spacer(),
                ] else
                  const Spacer(),
                TextButton(
                  onPressed: onSignInTap,
                  child: Text(
                    'Sign in',
                    style: textStyles.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onJoinTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: SpotlightAccents.cyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Join now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [SpotlightAccents.cyan, SpotlightAccents.purple, SpotlightAccents.magenta],
            ),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SPOTLIGHT',
              style: textStyles.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
              ),
            ),
            Text(
              'Connect',
              style: textStyles.bodySmall?.copyWith(
                color: SpotlightAccents.cyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavText extends StatelessWidget {
  final String label;

  const _NavText(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.textStyles.bodySmall?.copyWith(
        color: Colors.white.withValues(alpha: 0.68),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _LandingHeroSection extends StatelessWidget {
  final bool isSignUpMode;
  final VoidCallback onCreatorTap;
  final VoidCallback onBrandTap;

  const _LandingHeroSection({
    required this.isSignUpMode,
    required this.onCreatorTap,
    required this.onBrandTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1100;
    final textStyles = context.textStyles;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isWide ? 34 : 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.black.withValues(alpha: 0.18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: SpotlightAccents.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: SpotlightAccents.cyan.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  'THE CREATOR ECOSYSTEM, CONNECTED',
                  style: textStyles.labelMedium?.copyWith(
                    color: SpotlightAccents.cyan,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Where Passion\nMeets Possibility.',
                style: textStyles.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 0.92,
                  fontSize: isWide ? 72 : 46,
                  letterSpacing: -2.6,
                ),
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  'SPOTLIGHT Connect gives creators, fans, and brands a premium digital home for discovery, collaboration, monetization, and community growth.',
                  style: textStyles.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  FilledButton.icon(
                    onPressed: onCreatorTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: SpotlightAccents.cyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      isSignUpMode ? 'Creator sign up' : 'Join as a creator',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onBrandTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.apartment_rounded, size: 18),
                    label: Text(
                      isSignUpMode ? 'Switch to sign in' : 'For brands',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingAuthCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSignUpMode;
  final bool isLoading;
  final bool obscurePassword;
  final VoidCallback onToggleMode;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final InputDecoration Function({required String hint, required IconData icon})
  buildInputDecoration;

  const _LandingAuthCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isSignUpMode,
    required this.isLoading,
    required this.obscurePassword,
    required this.onToggleMode,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.buildInputDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1017).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 32,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isSignUpMode ? 'JOIN SPOTLIGHT' : 'WELCOME BACK',
                  style: textStyles.labelLarge?.copyWith(
                    color: SpotlightAccents.cyan,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  isSignUpMode
                      ? 'Create your account and enter the SPOTLIGHT ecosystem.'
                      : 'Sign in to access your SPOTLIGHT workspace.',
                  style: textStyles.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.64),
                    height: 1.55,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                  decoration: buildInputDecoration(
                    hint: 'Email address',
                    icon: Icons.alternate_email_rounded,
                  ),
                  validator: (val) {
                    if (val == null || !val.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                  decoration:
                      buildInputDecoration(
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: onToggleObscure,
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white.withValues(alpha: 0.40),
                          ),
                        ),
                      ),
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: isLoading ? null : onSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: SpotlightAccents.cyan,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            isSignUpMode ? 'Create account' : 'Sign in',
                            style: textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onToggleMode,
                  child: Text(
                    isSignUpMode
                        ? 'Already have an account? Sign in'
                        : 'Need an account? Join SPOTLIGHT',
                    style: textStyles.bodySmall?.copyWith(
                      color: SpotlightAccents.magenta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (widgetEarlyAccess(context)) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Early access priority routing enabled.',
                    textAlign: TextAlign.center,
                    style: textStyles.labelSmall?.copyWith(
                      color: const Color(0xFFD4AF37),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool widgetEarlyAccess(BuildContext context) {
    final route = GoRouterState.of(context).uri.toString();
    return route.contains('ea=1');
  }
}

class _LandingPreviewPanel extends StatelessWidget {
  const _LandingPreviewPanel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0F15).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(
            children: [
              Row(
                children: const [
                  Expanded(
                    child: _MiniSignalCard(
                      label: 'Creator growth',
                      value: '+28%',
                      accent: SpotlightAccents.cyan,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MiniSignalCard(
                      label: 'Brand ROI',
                      value: '4.7x',
                      accent: SpotlightAccents.magenta,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 220,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.black.withValues(alpha: 0.22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform momentum',
                      style: context.textStyles.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Prototype-inspired dashboard signal panel',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        _BarSignal(height: 46, color: Color(0xFF2B5567)),
                        SizedBox(width: 10),
                        _BarSignal(height: 74, color: SpotlightAccents.cyan),
                        SizedBox(width: 10),
                        _BarSignal(height: 58, color: Color(0xFF7A61FF)),
                        SizedBox(width: 10),
                        _BarSignal(height: 102, color: SpotlightAccents.magenta),
                        SizedBox(width: 10),
                        _BarSignal(height: 88, color: Color(0xFFD4AF37)),
                        SizedBox(width: 10),
                        _BarSignal(height: 120, color: SpotlightAccents.cyan),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarSignal extends StatelessWidget {
  final double height;
  final Color color;

  const _BarSignal({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [color, color.withValues(alpha: 0.45)],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniSignalCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _MiniSignalCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.54),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.textStyles.titleLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingSignalStrip extends StatelessWidget {
  const _LandingSignalStrip();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.black.withValues(alpha: 0.14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Wrap(
            spacing: 26,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _SignalStat(
                label: 'Active creators',
                value: '50K+',
                accent: SpotlightAccents.cyan,
              ),
              _SignalStat(
                label: 'Brand partners',
                value: '1K+',
                accent: SpotlightAccents.magenta,
              ),
              _SignalStat(
                label: 'Fan communities',
                value: '15K+',
                accent: SpotlightAccents.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignalStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _SignalStat({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: context.textStyles.headlineSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textStyles.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
        ],
      ),
    );
  }
}
