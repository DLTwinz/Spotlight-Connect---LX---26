import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotlight_connect/core/routing/app_routes.dart';
import 'package:spotlight_connect/theme/spotlight_tokens.dart';

/// Public marketing front door — aligned to Figma / screenshot composition.
class SpotlightMarketingLandingPage extends StatelessWidget {
  const SpotlightMarketingLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpotlightTokens.bgPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: const [
          SliverToBoxAdapter(child: _NavBar()),
          SliverToBoxAdapter(child: _Hero()),
          SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverToBoxAdapter(child: _FeatureCards()),
          SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverToBoxAdapter(child: _TrustStrip()),
          SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ── tokens (locked to DESIRED.WELCOME.PAGE.png via SpotlightTokens) ───────────
class _L {
  static const bg = SpotlightTokens.bgPrimary;
  static const surface = SpotlightTokens.bgSurface;
  static const text = SpotlightTokens.textPrimary;
  static const muted = SpotlightTokens.textSecondary;
  static const dim = SpotlightTokens.textMuted;
  static const cyan = SpotlightTokens.cyan;
  static const magenta = SpotlightTokens.magenta;
  static const purple = SpotlightTokens.purple;
  static const border = SpotlightTokens.borderSubtle;
}

ImageProvider _img(String asset, String network) {
  // Prefer local asset when present; fall back to network.
  return AssetImage(asset);
}

// ── NAV ──────────────────────────────────────────────────────────────────────
class _NavBar extends StatefulWidget {
  const _NavBar();
  @override
  State<_NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<_NavBar> {
  String? _hover;

  static const _links = [
    'Platform',
    'For Creators',
    'For Brands',
    'Community',
    'Resources',
    'Pricing',
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16),
      decoration: BoxDecoration(
        color: SpotlightTokens.bgPrimary.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [SpotlightTokens.purple, _L.cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _L.cyan.withValues(alpha: 0.35),
                      blurRadius: 12,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'S',
                  style: TextStyle(
                    color: SpotlightTokens.bgPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SPOTLIGHT',
                    style: TextStyle(
                      color: _L.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.2,
                      height: 1.05,
                    ),
                  ),
                  Text(
                    'Connect',
                    style: TextStyle(
                      color: _L.muted,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (wide) ...[
            const SizedBox(width: 36),
            Expanded(
              child: Row(
                children: [
                  for (final l in _links)
                    Padding(
                      padding: const EdgeInsets.only(right: 22),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _hover = l),
                        onExit: (_) => setState(() => _hover = null),
                        child: Text(
                          l,
                          style: TextStyle(
                            color: _hover == l ? _L.text : SpotlightTokens.textMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ] else
            const Spacer(),
          // Sign in
          TextButton(
            onPressed: () => context.go(AppRoutes.login),
            style: TextButton.styleFrom(
              foregroundColor: SpotlightTokens.textMuted,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Sign in', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          // Join Spotlight
          _CyanCta(
            label: 'Join Spotlight',
            onTap: () => context.go(AppRoutes.login),
            compact: true,
          ),
        ],
      ),
    );
  }
}

// ── HERO ─────────────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= 1000;

    return Padding(
      padding: EdgeInsets.fromLTRB(wide ? 40 : 20, 28, wide ? 40 : 20, 8),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: _HeroCopy()),
                const SizedBox(width: 28),
                Expanded(flex: 6, child: _HeroVisual()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCopy(),
                const SizedBox(height: 28),
                _HeroVisual(),
              ],
            ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _L.cyan.withValues(alpha: 0.28)),
            color: _L.cyan.withValues(alpha: 0.06),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: _L.cyan,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'THE CREATOR ECOSYSTEM, CONNECTED',
                style: TextStyle(
                  color: _L.cyan.withValues(alpha: 0.95),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        // Headline — single authoritative gradient version
        const _Headline(),
        const SizedBox(height: 16),
        const Text(
          'SPOTLIGHT Connect brings fans, creators, and brands together to discover, collaborate, and grow—together.',
          style: TextStyle(
            color: SpotlightTokens.textMuted,
            fontSize: 15.5,
            height: 1.65,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 26),
        // CTAs
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _CyanCta(
              label: 'Join as a Creator',
              trailing: Icons.arrow_forward_rounded,
              onTap: () => context.go(AppRoutes.login),
            ),
            _OutlineCta(
              label: 'Partner with Brands',
              trailing: Icons.arrow_forward_rounded,
              onTap: () => context.go(AppRoutes.login),
            ),
          ],
        ),
        const SizedBox(height: 22),
        // Social proof
        Row(
          children: [
            SizedBox(
              width: 108,
              height: 32,
              child: Stack(
                children: [
                  for (var i = 0; i < 4; i++)
                    Positioned(
                      left: i * 22.0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _L.bg, width: 2),
                          image: DecorationImage(
                            image: NetworkImage(
                              [
                                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=64&h=64&fit=crop&auto=format',
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=64&h=64&fit=crop&auto=format',
                                'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=64&h=64&fit=crop&auto=format',
                                'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=64&h=64&fit=crop&auto=format',
                              ][i],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: List.generate(
                5,
                (_) => const Icon(Icons.star_rounded, size: 14, color: SpotlightTokens.warning),
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Trusted by 50K+ creators and brands',
                style: TextStyle(color: SpotlightTokens.textMuted, fontSize: 12.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width >= 1000 ? 52.0 : 36.0;
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          height: 1.05,
          letterSpacing: -1.2,
        ),
        children: [
          const TextSpan(text: 'Where Passion\nMeets ', style: TextStyle(color: _L.text)),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (b) => const LinearGradient(
                colors: [SpotlightTokens.cyanSoft, SpotlightTokens.purple, SpotlightTokens.magenta],
              ).createShader(b),
              child: Text(
                'Possibility.',
                style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -1.2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.35,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Base collage
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/landing/hero_collage.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _L.surface),
                  ),
                  // Cyan/purple lighting overlays
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          SpotlightTokens.purple.withValues(alpha: 0.25),
                          Colors.transparent,
                          _L.cyan.withValues(alpha: 0.18),
                        ],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          _L.bg.withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating: Total Earnings
          Positioned(
            top: 16,
            right: 12,
            child: _GlassStat(
              label: 'Total Earnings',
              value: '\$128,610',
              change: '+24.8%',
              up: true,
              spark: true,
            ),
          ),
          // Floating: New Followers
          Positioned(
            top: 110,
            left: 8,
            child: _GlassStat(
              label: 'New Followers',
              value: '24,590',
              change: '+18.6%',
              up: true,
              bars: true,
            ),
          ),
          // Floating: Campaign ROI
          Positioned(
            bottom: 88,
            right: 8,
            child: _GlassStat(
              label: 'Campaign ROI',
              value: '4.7x',
              change: '+32.1%',
              up: true,
              spark: true,
            ),
          ),
          // Floating post card
          Positioned(
            left: 24,
            right: 48,
            bottom: 16,
            child: _PostCard(),
          ),
        ],
      ),
    );
  }
}

class _GlassStat extends StatelessWidget {
  const _GlassStat({
    required this.label,
    required this.value,
    required this.change,
    required this.up,
    this.spark = false,
    this.bars = false,
  });
  final String label, value, change;
  final bool up, spark, bars;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 148,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: const Color(0xCC0A0F1A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(color: _L.dim, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    change,
                    style: TextStyle(
                      color: up ? SpotlightTokens.success : _L.magenta,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: _L.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (spark || bars) ...[
                const SizedBox(height: 6),
                SizedBox(
                  height: 28,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: bars ? _BarsPainter() : _SparkPainter(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final pts = [0.1, 0.45, 0.3, 0.55, 0.4, 0.35, 0.55, 0.6, 0.7, 0.4, 0.85, 0.2, 1.0, 0.15];
    for (var i = 0; i < pts.length; i += 2) {
      final x = pts[i] * size.width;
      final y = pts[i + 1] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = _L.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final vals = [0.35, 0.55, 0.4, 0.7, 0.5, 0.85, 0.6, 0.95];
    final gap = 3.0;
    final barW = (size.width - gap * (vals.length - 1)) / vals.length;
    final paint = Paint()..color = _L.cyan.withValues(alpha: 0.85);
    for (var i = 0; i < vals.length; i++) {
      final h = vals[i] * size.height;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * (barW + gap), size.height - h, barW, h),
        const Radius.circular(2),
      );
      canvas.drawRRect(r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PostCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: const Color(0xD00A0F1A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _L.cyan.withValues(alpha: 0.4)),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=64&h=64&fit=crop&auto=format',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '@dreamwithkayla',
                          style: TextStyle(color: _L.text, fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.verified, size: 13, color: _L.cyan),
                        Spacer(),
                        Text('2m ago', style: TextStyle(color: _L.dim, fontSize: 10)),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Just dropped a new behind-the-scenes ✨',
                      style: TextStyle(color: _L.muted, fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.favorite_border, size: 13, color: _L.dim),
                        SizedBox(width: 3),
                        Text('3.2K', style: TextStyle(color: _L.dim, fontSize: 11)),
                        SizedBox(width: 12),
                        Icon(Icons.chat_bubble_outline, size: 13, color: _L.dim),
                        SizedBox(width: 3),
                        Text('201', style: TextStyle(color: _L.dim, fontSize: 11)),
                        SizedBox(width: 12),
                        Icon(Icons.share_outlined, size: 13, color: _L.dim),
                        SizedBox(width: 3),
                        Text('120', style: TextStyle(color: _L.dim, fontSize: 11)),
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

// ── FEATURE CARDS ────────────────────────────────────────────────────────────
class _FeatureCards extends StatelessWidget {
  const _FeatureCards();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 1100 ? 4 : (w >= 700 ? 2 : 1);
    final cards = const [
      _FeatureData(
        eyebrow: 'FOR FANS',
        title: 'Discover. Connect.\nSupport.',
        body: 'Find creators you love, engage with their content, and support their journey.',
        stats: [('1M+', 'Active Fans'), ('15K+', 'Communities'), ('2.5M+', 'Interactions Daily')],
        image: 'https://images.unsplash.com/photo-1459749411175-047fc749d9b0?w=800&h=500&fit=crop&auto=format&q=80',
        accent: _L.cyan,
      ),
      _FeatureData(
        eyebrow: 'FOR CREATORS',
        title: 'Create. Grow.\nMonetize.',
        body: 'Build your audience, create impact, and unlock new revenue streams.',
        stats: [('50K+', 'Active Creators'), ('\$20M+', 'Paid to Creators'), ('200+', 'Monetization Tools')],
        image: 'assets/landing/card_creators.png',
        accent: _L.purple,
      ),
      _FeatureData(
        eyebrow: 'FOR BRANDS',
        title: 'Connect. Collaborate.\nCreate Impact.',
        body: 'Partner with authentic creators and drive real results.',
        stats: [('1K+', 'Partner Brands'), ('3K+', 'Campaigns Live'), ('4.7x', 'Average ROI')],
        image: 'assets/landing/card_brands.png',
        accent: const Color(0xFF3B82F6),
      ),
      _FeatureData(
        eyebrow: 'THE ECOSYSTEM LOOP',
        title: 'Stronger Together',
        body: 'A connected cycle that powers growth for everyone.',
        stats: const [],
        image: 'assets/landing/card_loop.png',
        accent: _L.magenta,
        isLoop: true,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w >= 1000 ? 40 : 16),
      child: LayoutBuilder(
        builder: (context, c) {
          final gap = 14.0;
          final cardW = cols == 1 ? c.maxWidth : (c.maxWidth - gap * (cols - 1)) / cols;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final d in cards)
                SizedBox(
                  width: cardW,
                  height: 320,
                  child: _FeatureCard(data: d),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FeatureData {
  const _FeatureData({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.stats,
    required this.image,
    required this.accent,
    this.isLoop = false,
  });
  final String eyebrow, title, body, image;
  final List<(String, String)> stats;
  final Color accent;
  final bool isLoop;
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.data});
  final _FeatureData data;
  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hover ? d.accent.withValues(alpha: 0.35) : _L.border,
          ),
          boxShadow: _hover
              ? [BoxShadow(color: d.accent.withValues(alpha: 0.12), blurRadius: 24)]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            d.image.startsWith('assets/')
                ? Image.asset(
                    d.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _L.surface),
                  )
                : Image.network(
                    d.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _L.surface),
                  ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x99050508),
                    const Color(0xE6050508),
                    const Color(0xF2050508),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.eyebrow,
                    style: TextStyle(
                      color: d.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    d.title,
                    style: const TextStyle(
                      color: _L.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    d.body,
                    style: const TextStyle(color: _L.muted, fontSize: 12.5, height: 1.45),
                  ),
                  const Spacer(),
                  if (d.isLoop)
                    const _EcosystemLoop()
                  else
                    Row(
                      children: [
                        for (var i = 0; i < d.stats.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.stats[i].$1,
                                  style: TextStyle(
                                    color: d.accent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  d.stats[i].$2,
                                  style: const TextStyle(color: _L.dim, fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EcosystemLoop extends StatelessWidget {
  const _EcosystemLoop();

  @override
  Widget build(BuildContext context) {
    Widget node(IconData icon, String label, Color c) {
      return Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.withValues(alpha: 0.12),
              border: Border.all(color: c.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, size: 16, color: c),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        node(Icons.people_outline, 'FANS', _L.cyan),
        const Icon(Icons.arrow_forward, size: 14, color: _L.dim),
        node(Icons.rocket_launch_outlined, 'CREATORS', _L.purple),
        const Icon(Icons.arrow_forward, size: 14, color: _L.dim),
        node(Icons.business_center_outlined, 'BRANDS', _L.magenta),
      ],
    );
  }
}

// ── TRUST STRIP ──────────────────────────────────────────────────────────────
class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final brands = ['Nike', 'Red Bull', 'SAMSUNG', 'SONY', "L'ORÉAL", 'Adobe'];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: w >= 1000 ? 40 : 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _L.border),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        spacing: 24,
        runSpacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TRUSTED BY LEADING BRANDS',
                style: TextStyle(
                  color: _L.dim,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 18),
              for (final b in brands)
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Text(
                    b,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.28),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 72,
                height: 28,
                child: Stack(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Positioned(
                        left: i * 18.0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _L.bg, width: 2),
                            image: DecorationImage(
                              image: NetworkImage(
                                [
                                  'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=48&h=48&fit=crop&auto=format',
                                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=48&h=48&fit=crop&auto=format',
                                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=48&h=48&fit=crop&auto=format',
                                ][i],
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JOIN A GLOBAL COMMUNITY',
                    style: TextStyle(color: _L.cyan, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                  ),
                  Text(
                    '5M+ members worldwide',
                    style: TextStyle(color: _L.text, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── BUTTONS ──────────────────────────────────────────────────────────────────
class _CyanCta extends StatefulWidget {
  const _CyanCta({
    required this.label,
    required this.onTap,
    this.trailing,
    this.compact = false,
  });
  final String label;
  final VoidCallback onTap;
  final IconData? trailing;
  final bool compact;

  @override
  State<_CyanCta> createState() => _CyanCtaState();
}

class _CyanCtaState extends State<_CyanCta> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _hover ? const Color(0xFF00C4A8) : _L.cyan,
          boxShadow: [
            BoxShadow(
              color: _L.cyan.withValues(alpha: _hover ? 0.55 : 0.40),
              blurRadius: _hover ? 22 : 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.compact ? 14 : 18,
                vertical: widget.compact ? 9 : 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: SpotlightTokens.bgPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: widget.compact ? 12.5 : 13.5,
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 6),
                    Icon(widget.trailing, size: 16, color: SpotlightTokens.bgPrimary),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineCta extends StatefulWidget {
  const _OutlineCta({
    required this.label,
    required this.onTap,
    this.trailing,
  });
  final String label;
  final VoidCallback onTap;
  final IconData? trailing;

  @override
  State<_OutlineCta> createState() => _OutlineCtaState();
}

class _OutlineCtaState extends State<_OutlineCta> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _hover ? Colors.white.withValues(alpha: 0.04) : Colors.transparent,
          border: Border.all(
            color: _hover ? SpotlightTokens.purple : Colors.white.withValues(alpha: 0.16),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Color(0xFFC8D0E0),
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 6),
                    Icon(widget.trailing, size: 16, color: _L.cyan),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
