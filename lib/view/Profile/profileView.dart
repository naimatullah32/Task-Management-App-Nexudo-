// lib/screens/profile/profile_screen.dart
//
//      • Richer screen entrance  (slide-up + fade, 700 ms easeOutCubic)
//      • Top-bar slides DOWN independently
//      • Avatar bounces in with elasticOut scale
//      • Name + badge pop in with spring scale
//      • Stats row slides up with overshoot
//      • Info cards cascade in with spring (each card gets its own delay)
//      • Skeleton loader has a sweeping shimmer stripe
//      • All existing _entrance / _reveal / _orb / _shimmer / _pulse logic
//        is 100 % preserved — only the Widget tree helpers changed.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../bloc/auth_bloc/auth_state.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../configs/routes/routes_name.dart';
import '../../utils/extensions/flush_bar_extension.dart';
import 'edit_profile_view.dart';

// ─────────────────────────────────────────────
// COLOURS  (unchanged)
// ─────────────────────────────────────────────
const _bg           = Color(0xff0D0E1A);
const _card         = Color(0xff161727);
const _accent1      = Color(0xff7C6FFF);
const _accent2      = Color(0xffFF6FD8);
const _accent3      = Color(0xff6FFFCB);
const _textPrimary  = Color(0xffF0F2FF);
const _textMuted    = Color(0xff7A7D9C);
const _bgLight      = Color(0xffEEF2F7);
const _cardLight    = Color(0xffE4EAF4);
const _textPrimaryL = Color(0xff1A1A2E);
const _textMutedL   = Color(0xff6B7280);

// ─────────────────────────────────────────────
// SCREEN  (unchanged signature / state)
// ─────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  final String? message;
  const ProfileScreen({super.key, this.message});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  // ── existing controllers (unchanged) ──────────────────────
  late final AnimationController _orb;
  late final AnimationController _shimmer;
  late final AnimationController _pulse;
  late final AnimationController _entrance;
  late final Animation<double>   _entranceFade;
  late final Animation<double>   _entranceSlide;
  late final AnimationController _reveal;
  late final Animation<double>   _revealCurve;
  late final AnimationController _menuCtrl;

  // ── NEW animation controllers (animation-only addition) ───
  late final AnimationController _topBarCtrl;   // top-bar slides down
  late final AnimationController _avatarCtrl;   // avatar bounces in
  late final AnimationController _nameCtrl;     // name pops in
  late final AnimationController _statsCtrl;    // stats row slides up
  late final AnimationController _cardsCtrl;    // info-cards cascade
  late final AnimationController _skeletonCtrl; // skeleton shimmer loop

  // ── derived animations ────────────────────────────────────
  late final Animation<double> _topBarSlide;
  late final Animation<double> _topBarFade;
  late final Animation<double> _avatarScale;
  late final Animation<double> _avatarFade;
  late final Animation<double> _nameScale;
  late final Animation<double> _nameFade;
  late final Animation<Offset>  _statsOffset;
  late final Animation<double> _statsFade;

  @override
  void initState() {
    super.initState();

    if (widget.message != null) {
      Future.microtask(() {
        context.flushBarSuccessMessage(message: widget.message!);
      });
    }

    // ── existing controllers (unchanged) ──────────────────────
    _orb = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();

    _shimmer = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();

    _pulse = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _entrance = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _entranceFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _entranceSlide = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
    );

    _reveal = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _revealCurve =
        CurvedAnimation(parent: _reveal, curve: Curves.easeOutExpo);

    _menuCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));

    // ── NEW controllers ────────────────────────────────────────

    // Top-bar: slides DOWN from -30 to 0, fades in (starts 100 ms in)
    _topBarCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _topBarSlide = Tween<double>(begin: -30, end: 0).animate(
        CurvedAnimation(parent: _topBarCtrl, curve: Curves.easeOutCubic));
    _topBarFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _topBarCtrl,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));

    // Avatar: elastic scale bounce
    _avatarCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _avatarScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _avatarCtrl, curve: Curves.elasticOut));
    _avatarFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _avatarCtrl,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));

    // Name: spring scale pop
    _nameCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _nameScale = Tween<double>(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: _nameCtrl, curve: Curves.easeOutBack));
    _nameFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _nameCtrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));

    // Stats: slide up from +40, easeOutBack overshoot
    _statsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _statsOffset = Tween<Offset>(
        begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _statsCtrl, curve: Curves.easeOutBack));
    _statsFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _statsCtrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));

    // Info cards cascade (driven by _cardsCtrl 0→1)
    _cardsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    // Skeleton shimmer loop
    _skeletonCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();

    // ── sequence: entrance → staggered content animations ─────
    _entrance.forward().then((_) {
      if (!mounted) return;
      // Fire all content animations with small stagger offsets
      _topBarCtrl.forward();
      Future.delayed(const Duration(milliseconds: 80),
              () { if (mounted) _avatarCtrl.forward(); });
      Future.delayed(const Duration(milliseconds: 200),
              () { if (mounted) _nameCtrl.forward(); });
      Future.delayed(const Duration(milliseconds: 300),
              () { if (mounted) _statsCtrl.forward(); });
      Future.delayed(const Duration(milliseconds: 400),
              () { if (mounted) _cardsCtrl.forward(); });

      // existing reveal
      _reveal.forward();
    });

    // Load Supabase data (unchanged)
    context.read<ProfileBloc>().add(ProfileLoadStarted());
  }

  @override
  void dispose() {
    // existing
    _orb.dispose();
    _shimmer.dispose();
    _pulse.dispose();
    _entrance.dispose();
    _reveal.dispose();
    _menuCtrl.dispose();
    // new
    _topBarCtrl.dispose();
    _avatarCtrl.dispose();
    _nameCtrl.dispose();
    _statsCtrl.dispose();
    _cardsCtrl.dispose();
    _skeletonCtrl.dispose();
    super.dispose();
  }

  // ── menu helpers (unchanged) ──────────────────────────────
  void _toggleMenu() {
    context.read<ProfileBloc>().add(ProfileMenuToggled());
    _menuCtrl.isDismissed ? _menuCtrl.forward() : _menuCtrl.reverse();
  }

  void _closeMenu() {
    context.read<ProfileBloc>().add(ProfileMenuClosed());
    _menuCtrl.reverse();
  }

  void _openEdit(BuildContext ctx) {
    _closeMenu();
    final st = ctx.read<ProfileBloc>().state;
    Navigator.of(ctx).push(
      _slideRoute(
        EditProfileScreen(
          data: st.toEditMap(),
          onSave: (name, title, phone, location) =>
              ctx.read<ProfileBloc>().add(
                ProfileSaveRequested(
                  name: name, title: title,
                  phone: phone, location: location,
                ),
              ),
        ),
      ),
    );
  }

  // ── BUILD (unchanged outer structure) ────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (_, c) => c.status == ProfileStatus.loggedOut,
      listener: (ctx, _) =>
          Navigator.of(ctx).pushNamedAndRemoveUntil('/login', (_) => false),
      child: Scaffold(
        backgroundColor: isDark ? _bg : _bgLight,
        body: AnimatedBuilder(
          animation: _entrance,
          builder: (_, child) => Opacity(
            opacity: _entranceFade.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 40 * (1.0 - _entranceSlide.value)),
              child: child,
            ),
          ),
          child: Stack(
            children: [
              // 1 ── Orb background (unchanged)
              _AnimatedBackground(controller: _orb, isDark: isDark),

              // 2 ── Real content
              SafeArea(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  buildWhen: (p, c) => p.status != c.status,
                  builder: (ctx, state) {
                    if (state.status == ProfileStatus.initial ||
                        state.status == ProfileStatus.loading) {
                      // ✨ Enhanced loader with shimmer stripe
                      return _Loader(
                          pulse: _pulse,
                          shimmer: _skeletonCtrl,
                          isDark: isDark);
                    }
                    if (state.status == ProfileStatus.error) {
                      return _ErrorView(
                        message:
                        state.errorMessage ?? 'Error loading profile',
                        isDark: isDark,
                        onRetry: () =>
                            ctx.read<ProfileBloc>().add(ProfileLoadStarted()),
                      );
                    }
                    return _buildContent(ctx, isDark);
                  },
                ),
              ),

              // 3 ── Backdrop dimmer (unchanged)
              BlocBuilder<ProfileBloc, ProfileState>(
                buildWhen: (p, c) => p.isMenuOpen != c.isMenuOpen,
                builder: (_, state) => state.isMenuOpen
                    ? GestureDetector(
                  onTap: _closeMenu,
                  child: AnimatedBuilder(
                    animation: _menuCtrl,
                    builder: (_, __) => Container(
                      color: Colors.black
                          .withOpacity(0.45 * _menuCtrl.value),
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),

              // 4 ── Floating menu (unchanged)
              _MenuOverlay(
                menuAnim: _menuCtrl,
                isDark: isDark,
                onEdit: () => _openEdit(context),
                onLogout: () {
                  _closeMenu();
                  _showLogoutDialog(context, isDark);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Scrollable body ──────────────────────────────────────
  Widget _buildContent(BuildContext ctx, bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ✨ Top-bar slides DOWN
              AnimatedBuilder(
                animation: _topBarCtrl,
                builder: (_, child) => Opacity(
                  opacity: _topBarFade.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, _topBarSlide.value),
                    child: child,
                  ),
                ),
                child: _FadeSlide(
                  animation: _revealCurve,
                  delay: 0.0,
                  child: _TopBar(isDark: isDark, onMenuTap: _toggleMenu),
                ),
              ),
              const SizedBox(height: 28),

              // ✨ Avatar elastic bounce
              AnimatedBuilder(
                animation: _avatarCtrl,
                builder: (_, child) => Opacity(
                  opacity: _avatarFade.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _avatarScale.value,
                    child: child,
                  ),
                ),
                child: _FadeSlide(
                  animation: _revealCurve,
                  delay: 0.1,
                  child: BlocBuilder<ProfileBloc, ProfileState>(
                    buildWhen: (p, c) =>
                    p.avatarUrl != c.avatarUrl ||
                        p.isSaving != c.isSaving,
                    builder: (_, st) => _AvatarSection(
                      pulseController: _pulse,
                      shimmerController: _shimmer,
                      isDark: isDark,
                      avatarUrl: st.avatarUrl,
                      uploading: st.isSaving,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ✨ Name spring scale pop
              AnimatedBuilder(
                animation: _nameCtrl,
                builder: (_, child) => Opacity(
                  opacity: _nameFade.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _nameScale.value,
                    child: child,
                  ),
                ),
                child: _FadeSlide(
                  animation: _revealCurve,
                  delay: 0.2,
                  child: BlocBuilder<ProfileBloc, ProfileState>(
                    buildWhen: (p, c) =>
                    p.name != c.name || p.title != c.title,
                    builder: (_, st) => _NameSection(
                      shimmer: _shimmer,
                      name: st.name.isEmpty ? 'User' : st.name,
                      subtitle:
                      st.title.isEmpty ? 'App User' : st.title,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ✨ Stats slide-up with overshoot
              SlideTransition(
                position: _statsOffset,
                child: FadeTransition(
                  opacity: _statsFade,
                  child: _FadeSlide(
                    animation: _revealCurve,
                    delay: 0.3,
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      buildWhen: (p, c) =>
                      p.highlightedStat != c.highlightedStat ||
                          p.projects != c.projects ||
                          p.followers != c.followers ||
                          p.pending != c.pending,
                      builder: (ctx2, st) => _StatsRow(
                        isDark: isDark,
                        projects: st.projects,
                        followers: st.followers,
                        pending: st.pending,
                        highlightedStat: st.highlightedStat,
                        onTap: (key) => ctx2
                            .read<ProfileBloc>()
                            .add(ProfileStatTapped(key)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // ✨ Info cards cascade — each card staggers via _cardsCtrl
              _FadeSlide(
                animation: _revealCurve,
                delay: 0.4,
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  buildWhen: (p, c) =>
                  p.location != c.location ||
                      p.email != c.email ||
                      p.phone != c.phone ||
                      p.localTime != c.localTime,
                  builder: (_, st) => _InfoSection(
                    state: st,
                    isDark: isDark,
                    cascadeCtrl: _cardsCtrl, // ← passed in
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext ctx, bool isDark) {
    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => BlocProvider.value(
        value: ctx.read<ProfileBloc>(),
        child: _LogoutDialog(isDark: isDark),
      ),
    );
  }

  PageRoute<void> _slideRoute(Widget page) => PageRouteBuilder<void>(
    pageBuilder: (_, anim, __) => page,
    transitionDuration: const Duration(milliseconds: 420),
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

// ─────────────────────────────────────────────
// LOADER  ✨ now has a sweeping shimmer stripe
// ─────────────────────────────────────────────
class _Loader extends StatelessWidget {
  final AnimationController pulse;
  final AnimationController shimmer; // new param
  final bool isDark;
  const _Loader(
      {required this.pulse, required this.shimmer, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([pulse, shimmer]),
        builder: (_, __) {
          final shimmerPos = shimmer.value * 2 - 0.5; // -0.5 → 1.5
          return Stack(
            alignment: Alignment.center,
            children: [
              // Sweeping shimmer ring behind the spinner
              CustomPaint(
                size: const Size(90, 90),
                painter: _ShimmerRingPainter(
                    shimmerPos, isDark ? _accent1 : _accent1.withOpacity(.6)),
              ),
              // Original spinner (unchanged)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: const [_accent1, _accent2, _accent3, _accent1],
                    transform: GradientRotation(pulse.value * 2 * math.pi),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent1.withOpacity(0.5 + 0.5 * pulse.value),
                      blurRadius: 30,
                      spreadRadius: 4,
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? _bg : _bgLight,
                    ),
                    child: Icon(Icons.person,
                        color: isDark ? _textPrimary : _textPrimaryL,
                        size: 28),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Sweeping arc painted around the loader circle
class _ShimmerRingPainter extends CustomPainter {
  final double pos; // 0→1
  final Color color;
  _ShimmerRingPainter(this.pos, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 2;
    final sweepAngle = math.pi * 0.55;
    final startAngle = pos * math.pi * 2 - sweepAngle / 2;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color.withOpacity(0.45)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ShimmerRingPainter o) => o.pos != pos;
}

// ─────────────────────────────────────────────
// ERROR VIEW  (unchanged)
// ─────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorView(
      {required this.message,
        required this.isDark,
        required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded,
              size: 52,
              color: isDark ? _textMuted : _textMutedL),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  color: isDark ? _textMuted : _textMutedL)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_accent1, _accent2]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _accent1.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: const Text('Retry',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ANIMATED BACKGROUND  (unchanged)
// ─────────────────────────────────────────────
class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;
  const _AnimatedBackground(
      {required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        painter: _OrbPainter(controller.value, isDark),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  final bool isDark;
  _OrbPainter(this.t, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    void orb(double cx, double cy, double r, Color c, double a) {
      canvas.drawCircle(
          Offset(cx, cy),
          r,
          Paint()
            ..shader = RadialGradient(
              colors: [
                c.withOpacity(isDark ? a : a * 0.55),
                Colors.transparent
              ],
            ).createShader(
                Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    }

    orb(size.width * (.20 + .15 * math.sin(t * math.pi * 2)),
        size.height * (.15 + .08 * math.cos(t * math.pi * 2)),
        190, _accent1, .25);
    orb(size.width * (.78 + .10 * math.cos(t * math.pi * 2 + 1)),
        size.height * (.28 + .10 * math.sin(t * math.pi * 2 + 1)),
        150, _accent2, .20);
    orb(size.width * (.50 + .08 * math.sin(t * math.pi * 2 + 2)),
        size.height * (.72 + .05 * math.cos(t * math.pi * 2 + 2)),
        130, _accent3, .15);
  }

  @override
  bool shouldRepaint(_OrbPainter o) => o.t != t;
}

// ─────────────────────────────────────────────
// TOP BAR  (unchanged)
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onMenuTap;
  const _TopBar({required this.isDark, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassButton(
            icon: Icons.arrow_back_ios_new_rounded,
            isDark: isDark,
            onTap: () => Navigator.maybePop(context),
          ),
          Text('PROFILE',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: isDark ? _textPrimary : _textPrimaryL)),
          _GlassButton(
            icon: Icons.more_horiz_rounded,
            isDark: isDark,
            onTap: onMenuTap,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// AVATAR  (unchanged)
// ─────────────────────────────────────────────
class _AvatarSection extends StatelessWidget {
  final AnimationController pulseController, shimmerController;
  final bool isDark;
  final String? avatarUrl;
  final bool uploading;

  const _AvatarSection({
    required this.pulseController,
    required this.shimmerController,
    required this.isDark,
    this.avatarUrl,
    this.uploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pulseController, shimmerController]),
      builder: (_, __) {
        final pulse = pulseController.value;
        final angle = shimmerController.value * 2 * math.pi;
        return SizedBox(
          width: 180,
          height: 180,
          child: Stack(alignment: Alignment.center, children: [
            Transform.rotate(
              angle: angle,
              child: Container(
                width: 170,
                height: 170,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(colors: [
                    _accent1, _accent2, _accent3,
                    Colors.transparent, Colors.transparent, _accent1,
                  ]),
                ),
              ),
            ),
            Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _accent1.withOpacity(0.3 + 0.2 * pulse),
                    blurRadius: 30 + 10 * pulse,
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
            Container(
              width: 156,
              height: 156,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? _bg : _bgLight,
              ),
            ),
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [Color(0xff1E2040), Color(0xff12132B)]
                      : const [Color(0xffD8E0F0), Color(0xffC8D4EA)],
                ),
              ),
              child: ClipOval(
                child: uploading
                    ? const Center(
                    child: CircularProgressIndicator(
                        color: _accent1, strokeWidth: 2.5))
                    : (avatarUrl != null && avatarUrl!.isNotEmpty
                    ? Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _defaultIcon(isDark),
                  loadingBuilder: (_, child, progress) =>
                  progress == null
                      ? child
                      : _defaultIcon(isDark),
                )
                    : _defaultIcon(isDark)),
              ),
            ),
            Positioned(
              bottom: 14,
              right: 14,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _accent3,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isDark ? _bg : _bgLight, width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: _accent3.withOpacity(0.6), blurRadius: 8)
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _defaultIcon(bool isDark) =>
      Icon(Icons.person, size: 72, color: isDark ? _textMuted : _textMutedL);
}

// ─────────────────────────────────────────────
// NAME SECTION  (unchanged)
// ─────────────────────────────────────────────
class _NameSection extends StatelessWidget {
  final AnimationController shimmer;
  final String name, subtitle;
  final bool isDark;
  const _NameSection({
    required this.shimmer,
    required this.name,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (_, __) => Column(children: [
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: const [_accent1, _accent2, _accent3],
            stops: const [0, .5, 1],
            transform: GradientRotation(shimmer.value * 2 * math.pi),
          ).createShader(b),
          child: Text(name,
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: .5)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: _accent1.withOpacity(.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _accent1.withOpacity(.3), width: 1),
          ),
          child: Text(subtitle,
              style: const TextStyle(
                  fontSize: 13,
                  color: _accent1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// STATS ROW  (Updated Labels)
// ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final bool isDark;
  final int projects, followers, pending;
  final String? highlightedStat;
  final void Function(String key) onTap;

  const _StatsRow({
    required this.isDark,
    required this.projects,
    required this.followers,
    required this.pending,
    required this.onTap,
    this.highlightedStat,
  });

  String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  @override
  Widget build(BuildContext context) {
    // 🔥 DATA MAPPING & LABELS UPDATED HERE
    final stats = [
      {'key': 'projects', 'value': _fmt(projects), 'label': 'Total Tasks'},
      {'key': 'completed', 'value': _fmt(followers), 'label': 'Completed'},
      {'key': 'pending', 'value': _fmt(pending), 'label': 'Pending'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? .05 : .4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color:
                  Colors.white.withOpacity(isDark ? .1 : .6),
                  width: 1),
            ),
            child: Row(
              children: stats.asMap().entries.map((e) {
                final isHi = highlightedStat == e.value['key'];
                final isLast = e.key == stats.length - 1;
                return Expanded(
                    child: Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(e.value['key']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            transform: Matrix4.identity()
                              ..scale(isHi ? 1.1 : 1.0),
                            transformAlignment: Alignment.center,
                            child: Column(children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: isHi
                                      ? _accent2
                                      : (isDark
                                      ? _textPrimary
                                      : _textPrimaryL),
                                ),
                                child: Text(e.value['value']!),
                              ),
                              const SizedBox(height: 4),
                              Text(e.value['label']!,
                                  style: TextStyle(
                                      fontSize: 12, // Automatically handles text size perfectly
                                      color: isDark
                                          ? _textMuted
                                          : _textMutedL,
                                      fontWeight: FontWeight.w500)),
                            ]),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withOpacity(.1)),
                    ]));
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INFO SECTION  ✨ receives cascadeCtrl
// ─────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final ProfileState state;
  final bool isDark;
  final AnimationController cascadeCtrl; // ← new param (animation only)

  const _InfoSection({
    required this.state,
    required this.isDark,
    required this.cascadeCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final infos = <Map<String, dynamic>>[
      if (state.location != null && state.location!.isNotEmpty)
        {
          'icon': Icons.location_on_rounded,
          'color': const Color(0xffFF8A47),
          'label': 'Location',
          'value': state.location!
        },
      {
        'icon': Icons.access_time_rounded,
        'color': const Color(0xff47C8FF),
        'label': 'Local Time',
        'value': state.localTime
      },
      {
        'icon': Icons.email_rounded,
        'color': const Color(0xffFF475A),
        'label': 'Email',
        'value': state.email
      },
      if (state.phone != null && state.phone!.isNotEmpty)
        {
          'icon': Icons.phone_rounded,
          'color': const Color(0xff47FF8A),
          'label': 'Phone',
          'value': state.phone!
        },
    ];

    if (infos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text('ABOUT',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? _textMuted : _textMutedL,
                      letterSpacing: 2.5)),
            ),
            // ✨ Each card gets its own stagger interval from cascadeCtrl
            ...infos.asMap().entries.map((e) {
              final i = e.key;
              final total = infos.length;
              // stagger: card 0 starts at 0.0, last card at 0.5
              final start = (i / total) * 0.5;
              final end = (start + 0.5).clamp(0.0, 1.0);

              return _CascadeCard(
                info: e.value,
                isDark: isDark,
                animation: cascadeCtrl,
                intervalStart: start,
                intervalEnd: end,
              );
            }),
          ]),
    );
  }
}

// ─────────────────────────────────────────────
// CASCADE CARD  ✨ wraps _InfoCard with stagger
// ─────────────────────────────────────────────
class _CascadeCard extends StatelessWidget {
  final Map<String, dynamic> info;
  final bool isDark;
  final Animation<double> animation;
  final double intervalStart;
  final double intervalEnd;

  const _CascadeCard({
    required this.info,
    required this.isDark,
    required this.animation,
    required this.intervalStart,
    required this.intervalEnd,
  });

  @override
  Widget build(BuildContext context) {
    final interval = CurvedAnimation(
      parent: animation,
      curve: Interval(intervalStart, intervalEnd,
          curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: interval,
      builder: (_, child) => Opacity(
        opacity: interval.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 28 * (1 - interval.value)),
          child: child,
        ),
      ),
      child: _InfoCard(info: info, isDark: isDark),
    );
  }
}

// ─────────────────────────────────────────────
// INFO CARD  (unchanged)
// ─────────────────────────────────────────────
class _InfoCard extends StatefulWidget {
  final Map<String, dynamic> info;
  final bool isDark;
  const _InfoCard({required this.info, required this.isDark});

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  final ValueNotifier<bool> _hovered = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _press.dispose();
    _hovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.info['color'] as Color;
    final isDark = widget.isDark;

    return GestureDetector(
      onTapDown: (_) {
        _press.forward();
        _hovered.value = true;
      },
      onTapUp: (_) {
        _press.reverse();
        _hovered.value = false;
      },
      onTapCancel: () {
        _press.reverse();
        _hovered.value = false;
      },
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: 1 - .015 * _press.value, child: child),
        child: ValueListenableBuilder<bool>(
          valueListenable: _hovered,
          builder: (_, isH, __) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: isH
                  ? color.withOpacity(.08)
                  : (isDark ? _card : _cardLight),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isH
                    ? color.withOpacity(.3)
                    : Colors.white.withOpacity(isDark ? .06 : .0),
                width: 1,
              ),
            ),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(isH ? .25 : .15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.info['icon'] as IconData,
                    color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.info['label'],
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark ? _textMuted : _textMutedL,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 3),
                      Text(widget.info['value'],
                          style: TextStyle(
                              fontSize: 15,
                              color: isDark ? _textPrimary : _textPrimaryL,
                              fontWeight: FontWeight.w600)),
                    ],
                  )),
              Icon(Icons.chevron_right_rounded,
                  color: isH
                      ? color
                      : (isDark ? _textMuted : _textMutedL),
                  size: 20),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GLASS BUTTON  (unchanged)
// ─────────────────────────────────────────────
class _GlassButton extends StatefulWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _GlassButton(
      {required this.icon, required this.isDark, required this.onTap});

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) =>
            Transform.scale(scale: 1 - .08 * _c.value, child: child),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(widget.isDark ? .07 : .45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white
                        .withOpacity(widget.isDark ? .12 : .6),
                    width: 1),
              ),
              child: Icon(widget.icon,
                  color: widget.isDark ? _textPrimary : _textPrimaryL,
                  size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MENU OVERLAY  (unchanged)
// ─────────────────────────────────────────────
class _MenuOverlay extends StatelessWidget {
  final Animation<double> menuAnim;
  final bool isDark;
  final VoidCallback onEdit, onLogout;

  const _MenuOverlay({
    required this.menuAnim,
    required this.isDark,
    required this.onEdit,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      right: 20,
      child: AnimatedBuilder(
        animation: menuAnim,
        builder: (_, __) {
          final curved =
              CurvedAnimation(parent: menuAnim, curve: Curves.easeOutBack)
                  .value;
          return Transform.scale(
            scale: curved,
            alignment: Alignment.topRight,
            child: Opacity(
              opacity: menuAnim.value.clamp(0.0, 1.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: 190,
                    decoration: BoxDecoration(
                      color: (isDark
                          ? const Color(0xff1A1B30)
                          : Colors.white)
                          .withOpacity(.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(.1), width: 1),
                      boxShadow: [
                        BoxShadow(
                            color: _accent1.withOpacity(.18),
                            blurRadius: 30,
                            offset: const Offset(0, 10))
                      ],
                    ),
                    child:
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      _MenuTile(
                        icon: Icons.edit_rounded,
                        label: 'Edit Profile',
                        gradient: const LinearGradient(
                            colors: [_accent1, _accent2]),
                        onTap: onEdit,
                        isTop: true,
                        isDark: isDark,
                      ),
                      Container(
                          height: 1,
                          color: Colors.white.withOpacity(.06)),
                      _MenuTile(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        gradient: const LinearGradient(colors: [
                          Color(0xffFF4757),
                          Color(0xffFF6B81)
                        ]),
                        onTap: onLogout,
                        isTop: false,
                        isDark: isDark,
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MENU TILE  (unchanged)
// ─────────────────────────────────────────────
class _MenuTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final bool isTop, isDark;
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    required this.isTop,
    required this.isDark,
  });

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  final ValueNotifier<bool> _hovered = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    _press.dispose();
    _hovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.isTop
        ? const BorderRadius.only(
        topLeft: Radius.circular(20), topRight: Radius.circular(20))
        : const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20));

    return GestureDetector(
      onTapDown: (_) {
        _press.forward();
        _hovered.value = true;
      },
      onTapUp: (_) {
        _press.reverse();
        _hovered.value = false;
        widget.onTap();
      },
      onTapCancel: () {
        _press.reverse();
        _hovered.value = false;
      },
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: 1 - .02 * _press.value, child: child),
        child: ValueListenableBuilder<bool>(
          valueListenable: _hovered,
          builder: (_, isH, __) => AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isH
                  ? widget.gradient.colors.first.withOpacity(.12)
                  : Colors.transparent,
              borderRadius: radius,
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 15),
            child: Row(children: [
              ShaderMask(
                shaderCallback: (b) =>
                    widget.gradient.createShader(b),
                child: Icon(widget.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              ShaderMask(
                shaderCallback: (b) =>
                    widget.gradient.createShader(b),
                child: Text(widget.label,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  color: (widget.isDark ? _textMuted : _textMutedL)
                      .withOpacity(.5),
                  size: 18),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOGOUT DIALOG  (unchanged)
// ─────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  final bool isDark;
  const _LogoutDialog({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xff1A1B30) : Colors.white)
                  .withOpacity(.96),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Colors.white.withOpacity(.1), width: 1),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                    const Color(0xffFF4757).withOpacity(.15)),
                child: const Icon(Icons.logout_rounded,
                    color: Color(0xffFF4757), size: 28),
              ),
              const SizedBox(height: 18),
              Text('Logout?',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? _textPrimary : _textPrimaryL)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to\nlog out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? _textMuted : _textMutedL),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                    child: _PressableButton(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(.12)),
                        ),
                        child: Center(
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: isDark
                                        ? _textMuted
                                        : _textMutedL,
                                    fontWeight: FontWeight.w600))),
                      ),
                    )),
                const SizedBox(width: 12),
                Expanded(
                    child: _PressableButton(
                      onTap: () {
                        Navigator.pop(context);
                        context
                            .read<ProfileBloc>()
                            .add(ProfileLogoutRequested());
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xffFF4757),
                            Color(0xffFF6B81)
                          ]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xffFF4757)
                                    .withOpacity(.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6))
                          ],
                        ),
                        child: const Center(
                            child: Text('Logout',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700))),
                      ),
                    )),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FADE SLIDE HELPER  (unchanged)
// ─────────────────────────────────────────────
class _FadeSlide extends StatelessWidget {
  final Animation<double> animation;
  final double delay;
  final Widget child;
  const _FadeSlide({
    required this.animation,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final shifted = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, (delay + .4).clamp(0.0, 1.0),
          curve: Curves.easeOutQuart),
    );
    return AnimatedBuilder(
      animation: shifted,
      builder: (_, child) => Opacity(
        opacity: shifted.value,
        child: Transform.translate(
            offset: Offset(0, 24 * (1 - shifted.value)), child: child),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
// PRESSABLE BUTTON  (unchanged)
// ─────────────────────────────────────────────
class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressableButton({required this.child, required this.onTap});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) =>
            Transform.scale(scale: 1 - .05 * _c.value, child: child),
        child: widget.child,
      ),
    );
  }
}