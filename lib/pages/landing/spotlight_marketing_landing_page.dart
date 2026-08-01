import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../nav.dart';
import '../../theme.dart';

// Reference photography (same strategy as Figma Make prototype)
const _heroImg =
    'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=1200&h=900&fit=crop&crop=faces&auto=format&q=85';
const _fansImg =
    'https://images.unsplash.com/photo-1459749411175-047fc749d9b0?w=800&h=500&fit=crop&auto=format&q=80';
const _creatorsImg =
    'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=800&h=500&fit=crop&auto=format&q=80';
const _brandsImg =
    'https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=500&fit=crop&auto=format&q=80';
const _avatars = [
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=64&h=64&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=64&h=64&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=64&h=64&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=64&h=64&fit=crop&auto=format',
];
const _communityAvatars = [
  'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=48&h=48&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=48&h=48&fit=crop&auto=format',
  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=48&h=48&fit=crop&auto=format',
];

class SpotlightMarketingLandingPage extends StatelessWidget {
  const SpotlightMarketingLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: const [
          // Sticky-style top bar
          SliverToBoxAdapter(child: _NavBar()),
          // Hero
          SliverToBoxAdapter(child: _Hero()),
          SliverToBoxAdapter(child: SizedBox(height: 48)),
          // Feature grid
          SliverToBoxAdapter(child: _Features()),
          SliverToBoxAdapter(child: SizedBox(height: 32)),
          // Trust strip
          SliverToBoxAdapter(child: _Trust()),
          SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// NAV
// ═══════════════════════════════════════════
class _NavBar extends StatefulWidget {
  const _NavBar();
  @override
  State<_NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<_NavBar> {
  bool open = false;
  void login() => context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final desk = w >= 1100;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xE6050508),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: desk ? 40 : 16, vertical: 12),
              child: Column(children: [
                Row(children: [
                  _brand(),
                  const Spacer(),
                  if (desk) ...[
                    ...['Platform', 'For Creators', 'For Brands', 'Community', 'Resources', 'Pricing']
                        .map((l) => _link(l, chevron: l == 'Platform' || l == 'Resources')),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: login,
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF94A3B8)),
                      child: const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 8),
                    _Btn(label: 'Join Spotlight', onTap: login, primary: true, compact: true),
                  ] else
                    IconButton(
                      onPressed: () => setState(() => open = !open),
                      icon: Icon(open ? Icons.close : Icons.menu, color: Colors.white),
                    ),
                ]),
                if (!desk && open) ...[
                  const SizedBox(height: 8),
                  ...['Platform', 'For Creators', 'For Brands', 'Community', 'Resources', 'Pricing']
                      .map((l) => ListTile(
                            dense: true,
                            title: Text(l, style: const TextStyle(color: Colors.white)),
                            onTap: () => setState(() => open = false),
                          )),
                  _Btn(label: 'Join Spotlight', onTap: login, primary: true),
                  TextButton(onPressed: login, child: const Text('Sign in', style: TextStyle(color: Color(0xFF94A3B8)))),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand() => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFFA855F7)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17))),
        ),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SPOTLIGHT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.6, height: 1.1)),
          Text('Connect', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500, fontSize: 11, height: 1.1)),
        ]),
      ]);

  Widget _link(String label, {bool chevron = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5, fontWeight: FontWeight.w500)),
          if (chevron) const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
        ]),
      );
}

// ═══════════════════════════════════════════
// HERO
// ═══════════════════════════════════════════
class _Hero extends StatelessWidget {
  const _Hero();
  @override
  Widget build(BuildContext context) {
    final desk = MediaQuery.sizeOf(context).width >= 1050;
    return Padding(
      padding: EdgeInsets.fromLTRB(desk ? 48 : 20, desk ? 40 : 28, desk ? 48 : 20, 8),
      child: desk
          ? const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 5, child: _Copy(large: true)),
              SizedBox(width: 36),
              Expanded(flex: 6, child: _Visual()),
            ])
          : const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _Copy(large: false),
              SizedBox(height: 32),
              _Visual(),
            ]),
    );
  }
}

class _Copy extends StatelessWidget {
  final bool large;
  const _Copy({required this.large});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('THE CREATOR ECOSYSTEM, CONNECTED',
          style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
      const SizedBox(height: 16),
      RichText(
        text: TextSpan(
          style: TextStyle(fontSize: large ? 52 : 34, fontWeight: FontWeight.w800, height: 1.1, color: Colors.white, letterSpacing: -1),
          children: [
            const TextSpan(text: 'Where Passion\nMeets '),
            TextSpan(
              text: 'Possibility.',
              style: TextStyle(
                foreground: Paint()
                  ..shader = const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFFA855F7), Color(0xFFEC4899)])
                      .createShader(const Rect.fromLTWH(0, 0, 300, 70)),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: const Text(
          'SPOTLIGHT Connect brings fans, creators, and brands together to discover, collaborate, and grow—together.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15.5, height: 1.55),
        ),
      ),
      const SizedBox(height: 28),
      Wrap(spacing: 12, runSpacing: 12, children: [
        _Btn(label: 'Join as a Creator', onTap: () => context.go(AppRoutes.login), primary: true, icon: Icons.arrow_forward_rounded),
        _Btn(label: 'Partner with Brands', onTap: () => context.go(AppRoutes.login), primary: false, icon: Icons.arrow_forward_rounded),
      ]),
      const SizedBox(height: 28),
      Row(children: [
        SizedBox(
          width: 100, height: 34,
          child: Stack(children: List.generate(4, (i) {
            return Positioned(
              left: i * 22.0,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF050508), width: 2),
                  image: DecorationImage(image: NetworkImage(_avatars[i]), fit: BoxFit.cover),
                ),
              ),
            );
          })),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (_) => const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFBBF24))),
        const SizedBox(width: 8),
        const Flexible(child: Text('Trusted by 50K+ creators and brands', style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5, fontWeight: FontWeight.w500))),
      ]),
    ]);
  }
}

class _Visual extends StatelessWidget {
  const _Visual();
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    return AspectRatio(
      aspectRatio: compact ? 1.0 : 1.12,
      child: LayoutBuilder(builder: (context, c) {
        return Stack(clipBehavior: Clip.none, children: [
          // Main photo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: [BoxShadow(color: const Color(0xFFA855F7).withValues(alpha: 0.18), blurRadius: 48, spreadRadius: -6)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(fit: StackFit.expand, children: [
                  Image.network(_heroImg, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A1030))),
                  // cinematic overlays
                  Container(decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [const Color(0xFF00E5FF).withValues(alpha: 0.12), Colors.transparent, const Color(0xFFA855F7).withValues(alpha: 0.25)],
                  ))),
                  Container(decoration: BoxDecoration(gradient: RadialGradient(
                    center: Alignment.center, radius: 0.95,
                    colors: [Colors.transparent, const Color(0xFF050508).withValues(alpha: 0.45)],
                  ))),
                ]),
              ),
            ),
          ),
          // Floating KPI cards
          if (!compact) ...[
            Positioned(top: 14, right: 14, child: _GlassStat(
              title: 'Total Earnings', value: '\$128,610', delta: '+24.8%',
              chart: CustomPaint(size: const Size(140, 32), painter: _LinePainter(const Color(0xFF00E5FF))),
            )),
            Positioned(top: c.maxHeight * 0.30, left: 10, child: _GlassStat(
              title: 'New Followers', value: '24,590', delta: '+18.6%',
              chart: const SizedBox(height: 36, child: _Bars()),
            )),
            Positioned(bottom: c.maxHeight * 0.20, right: 6, child: _GlassStat(
              title: 'Campaign ROI', value: '4.7x', delta: '+32.1%',
              chart: CustomPaint(size: const Size(120, 28), painter: _LinePainter(const Color(0xFFEC4899))),
            )),
            Positioned(bottom: 14, left: c.maxWidth * 0.16, child: const _SocialCard()),
          ] else ...[
            const Positioned(top: 10, right: 10, child: _GlassStat(title: 'Total Earnings', value: '\$128,610', delta: '+24.8%', compact: true)),
            const Positioned(bottom: 10, left: 10, right: 10, child: _SocialCard(compact: true)),
          ],
        ]);
      }),
    );
  }
}

class _GlassStat extends StatelessWidget {
  final String title, value, delta;
  final Widget? chart;
  final bool compact;
  const _GlassStat({required this.title, required this.value, required this.delta, this.chart, this.compact = false});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: compact ? 148 : 170,
          padding: EdgeInsets.all(compact ? 10 : 12),
          decoration: BoxDecoration(
            color: const Color(0xE60C0C14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500))),
              Text(delta, style: const TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 3),
            Text(value, style: TextStyle(color: Colors.white, fontSize: compact ? 17 : 20, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
            if (chart != null && !compact) ...[const SizedBox(height: 8), chart!],
          ]),
        ),
      ),
    );
  }
}

class _SocialCard extends StatelessWidget {
  final bool compact;
  const _SocialCard({this.compact = false});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: compact ? null : 260,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xE60C0C14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: NetworkImage(_avatars[0]), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('@dreamwithkayla', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  SizedBox(width: 3),
                  Icon(Icons.verified, size: 13, color: Color(0xFF00E5FF)),
                ]),
                Text('2m ago', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              ])),
            ]),
            const SizedBox(height: 8),
            const Text('Just dropped a new behind-the-scenes 🎬', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35)),
            const SizedBox(height: 10),
            const Row(children: [
              Icon(Icons.favorite_border, size: 14, color: Color(0xFF64748B)), SizedBox(width: 4),
              Text('3.2K', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              SizedBox(width: 14),
              Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF64748B)), SizedBox(width: 4),
              Text('201', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              SizedBox(width: 14),
              Icon(Icons.share_outlined, size: 14, color: Color(0xFF64748B)), SizedBox(width: 4),
              Text('120', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars();
  @override
  Widget build(BuildContext context) {
    const h = [0.35, 0.55, 0.4, 0.7, 0.5, 0.85, 0.65, 0.9, 0.75, 1.0];
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: h.map((v) {
      return Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: FractionallySizedBox(
          heightFactor: v,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [const Color(0xFF00E5FF).withValues(alpha: 0.25), const Color(0xFF00E5FF)]),
            ),
          ),
        ),
      ));
    }).toList());
  }
}

class _LinePainter extends CustomPainter {
  final Color color;
  _LinePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    const pts = [0.4, 0.35, 0.5, 0.45, 0.6, 0.55, 0.7, 0.65, 0.8, 0.75, 0.9];
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final x = size.width * (i / (pts.length - 1));
      final y = size.height * (1 - pts[i]);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.25)..strokeWidth = 5..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════
// FEATURES
// ═══════════════════════════════════════════
class _Features extends StatelessWidget {
  const _Features();
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 1100 ? 4 : w >= 700 ? 2 : 1;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w >= 1100 ? 48 : 16),
      child: LayoutBuilder(builder: (context, c) {
        const gap = 14.0;
        final itemW = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(spacing: gap, runSpacing: gap, children: [
          _FCard(width: itemW, eyebrow: 'FOR FANS', title: 'Discover. Connect.\nSupport.',
              desc: 'Find creators you love, engage with their content, and support their journey.',
              accent: const Color(0xFF0EA5E9), icon: Icons.people_outline_rounded, image: _fansImg,
              stats: const [('1M+', 'Active Fans'), ('15K+', 'Communities'), ('2.5M+', 'Interactions Daily')]),
          _FCard(width: itemW, eyebrow: 'FOR CREATORS', title: 'Create. Grow.\nMonetize.',
              desc: 'Build your audience, create impact, and unlock new revenue streams.',
              accent: const Color(0xFFA855F7), icon: Icons.rocket_launch_outlined, image: _creatorsImg,
              stats: const [('50K+', 'Active Creators'), ('\$20M+', 'Paid to Creators'), ('200+', 'Monetization Tools')]),
          _FCard(width: itemW, eyebrow: 'FOR BRANDS', title: 'Connect. Collaborate.\nCreate Impact.',
              desc: 'Partner with authentic creators and drive real results.',
              accent: const Color(0xFFEC4899), icon: Icons.business_center_outlined, image: _brandsImg,
              stats: const [('1K+', 'Partner Brands'), ('3K+', 'Campaigns Live'), ('4.7x', 'Average ROI')]),
          _LoopCard(width: itemW),
        ]);
      }),
    );
  }
}

class _FCard extends StatefulWidget {
  final double width;
  final String eyebrow, title, desc, image;
  final Color accent;
  final IconData icon;
  final List<(String, String)> stats;
  const _FCard({required this.width, required this.eyebrow, required this.title, required this.desc, required this.accent, required this.icon, required this.image, required this.stats});
  @override
  State<_FCard> createState() => _FCardState();
}

class _FCardState extends State<_FCard> {
  bool h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => h = true),
      onExit: (_) => setState(() => h = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        transform: Matrix4.translationValues(0, h ? -4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: h ? widget.accent.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.08)),
          boxShadow: h ? [BoxShadow(color: widget.accent.withValues(alpha: 0.12), blurRadius: 28, offset: const Offset(0, 10))] : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Positioned.fill(child: Image.network(widget.image, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0D0D12)))),
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [const Color(0xFF050508).withValues(alpha: 0.55), const Color(0xFF050508).withValues(alpha: 0.92)],
          )))),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: widget.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(9)),
                  child: Icon(widget.icon, size: 17, color: widget.accent),
                ),
                const SizedBox(width: 8),
                Text(widget.eyebrow, style: TextStyle(color: widget.accent, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
              ]),
              const SizedBox(height: 14),
              Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700, height: 1.25)),
              const SizedBox(height: 8),
              Text(widget.desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.45)),
              const SizedBox(height: 18),
              Row(children: widget.stats.map((s) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.$1, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                Text(s.$2, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
              ]))).toList()),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _LoopCard extends StatelessWidget {
  final double width;
  const _LoopCard({required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: const Color(0xFF00E5FF).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.sync_rounded, size: 17, color: Color(0xFF00E5FF)),
          ),
          const SizedBox(width: 8),
          const Text('THE ECOSYSTEM LOOP', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        ]),
        const SizedBox(height: 14),
        const Text('Stronger Together', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('A connected cycle that powers growth for everyone.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.45)),
        const SizedBox(height: 20),
        SizedBox(
          height: 100,
          child: Stack(alignment: Alignment.center, children: [
            Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2)))),
            const Positioned(top: 0, child: _Node(label: 'FANS', sub: 'Discover & Support', color: Color(0xFF00E5FF), icon: Icons.people_outline)),
            const Positioned(bottom: 0, left: 8, child: _Node(label: 'CREATORS', sub: 'Create & Grow', color: Color(0xFFA855F7), icon: Icons.rocket_launch_outlined)),
            const Positioned(bottom: 0, right: 8, child: _Node(label: 'BRANDS', sub: 'Collaborate & Invest', color: Color(0xFFEC4899), icon: Icons.business_center_outlined)),
          ]),
        ),
      ]),
    );
  }
}

class _Node extends StatelessWidget {
  final String label, sub;
  final Color color;
  final IconData icon;
  const _Node({required this.label, required this.sub, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15), border: Border.all(color: color.withValues(alpha: 0.5))),
        child: Icon(icon, size: 14, color: color),
      ),
      const SizedBox(height: 3),
      Text(label, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
      Text(sub, style: const TextStyle(color: Color(0xFF64748B), fontSize: 8.5)),
    ]);
  }
}

// ═══════════════════════════════════════════
// TRUST
// ═══════════════════════════════════════════
class _Trust extends StatelessWidget {
  const _Trust();
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final desk = w >= 900;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w >= 1100 ? 48 : 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: desk
            ? Row(children: [
                const Expanded(child: _Brands()),
                Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.08), margin: const EdgeInsets.symmetric(horizontal: 28)),
                const _Community(),
              ])
            : const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _Brands(),
                SizedBox(height: 20),
                Divider(color: Color(0x22FFFFFF), height: 1),
                SizedBox(height: 20),
                _Community(),
              ]),
      ),
    );
  }
}

class _Brands extends StatelessWidget {
  const _Brands();
  @override
  Widget build(BuildContext context) {
    const brands = ['Nike', 'Red Bull', 'SAMSUNG', 'SONY', "L'ORÉAL", 'Adobe'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('TRUSTED BY LEADING BRANDS', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 1.1)),
      const SizedBox(height: 14),
      Wrap(spacing: 28, runSpacing: 10, children: brands.map((b) => Text(b, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3))).toList()),
    ]);
  }
}

class _Community extends StatelessWidget {
  const _Community();
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 72, height: 32,
        child: Stack(children: List.generate(3, (i) {
          return Positioned(
            left: i * 18.0,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0D0D12), width: 2),
                image: DecorationImage(image: NetworkImage(_communityAvatars[i]), fit: BoxFit.cover),
              ),
            ),
          );
        })),
      ),
      const SizedBox(width: 12),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('JOIN A GLOBAL COMMUNITY', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        SizedBox(height: 2),
        Text.rich(TextSpan(style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700), children: [
          TextSpan(text: '5M+ '),
          TextSpan(text: 'members worldwide', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500)),
        ])),
      ]),
    ]);
  }
}

// ═══════════════════════════════════════════
// BUTTON
// ═══════════════════════════════════════════
class _Btn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool compact;
  final IconData? icon;
  const _Btn({required this.label, required this.onTap, this.primary = true, this.compact = false, this.icon});
  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool h = false, p = false;
  @override
  Widget build(BuildContext context) {
    final bg = widget.primary
        ? (p ? const Color(0xFF00E5FF).withValues(alpha: 0.85) : h ? const Color(0xFF22F0FF) : const Color(0xFF00E5FF))
        : Colors.transparent;
    final border = widget.primary ? Colors.transparent : (h ? const Color(0xFFA855F7) : const Color(0xFFA855F7).withValues(alpha: 0.7));
    final fg = widget.primary ? const Color(0xFF041016) : Colors.white;
    return MouseRegion(
      onEnter: (_) => setState(() => h = true),
      onExit: (_) => setState(() => h = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => p = true),
        onTapUp: (_) { setState(() => p = false); widget.onTap(); },
        onTapCancel: () => setState(() => p = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          transform: Matrix4.translationValues(0, h && !p ? -2 : 0, 0),
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 18 : 22, vertical: widget.compact ? 11 : 13),
          decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(999), border: Border.all(color: border, width: 1.5),
            boxShadow: widget.primary && h ? [BoxShadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 4))] : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: widget.compact ? 13.5 : 14.5)),
            if (widget.icon != null) ...[const SizedBox(width: 6), Icon(widget.icon, size: 16, color: fg)],
          ]),
        ),
      ),
    );
  }
}
