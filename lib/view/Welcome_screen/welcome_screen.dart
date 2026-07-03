import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/configs/routes/routes_name.dart';

import '../../bloc/onBoarding_Bloc/onboarding_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPLACE WITH YOUR OWN ROUTE NAME
// import '../../configs/routes/routes_name.dart';
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color primary;
  final Color secondary;
  final IconData icon;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.primary,
    required this.secondary,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTICLE MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _Particle {
  double x, y, radius, speed, angle, opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.angle,
    required this.opacity,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGES DATA
// ─────────────────────────────────────────────────────────────────────────────
const List<OnboardingData> kOnboardingPages = [
  OnboardingData(
    title: 'Enjoy Your Time',
    subtitle: 'When you are confused about\nmanaging your task, come to us',
    imagePath: 'assets/images/amico.png',
    primary: Color(0xFF6C63FF),
    secondary: Color(0xFF9B8FFF),
    icon: Icons.emoji_emotions_rounded,
  ),
  OnboardingData(
    title: 'Stay Organized',
    subtitle: 'Plan your day and achieve your goals\nwith our intuitive task manager',
    imagePath: 'assets/images/staff-attendance-01.png',
    primary: Color(0xFF00C896),
    secondary: Color(0xFF00E5A8),
    icon: Icons.checklist_rounded,
  ),
  OnboardingData(
    title: 'Track Progress',
    subtitle: 'Monitor your daily achievements\nand keep your productivity high',
    imagePath: 'assets/images/PROCESS.png',
    primary: Color(0xFFFF7B54),
    secondary: Color(0xFFFFAA80),
    icon: Icons.trending_up_rounded,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// WELCOME SCREEN  (BLoC-powered, light/dark aware)
// ─────────────────────────────────────────────────────────────────────────────
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(totalPages: kOnboardingPages.length),
      child: const _WelcomeView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERNAL VIEW  (StatefulWidget only for AnimationControllers)
// ─────────────────────────────────────────────────────────────────────────────
class _WelcomeView extends StatefulWidget {
  const _WelcomeView();

  @override
  State<_WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<_WelcomeView>
    with TickerProviderStateMixin {
  // ── PageController ────────────────────────────────────────────────────────
  final PageController _pageCtrl = PageController();

  // ── Animation controllers ─────────────────────────────────────────────────
  late AnimationController _entryCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _rippleCtrl;
  late AnimationController _btnCtrl;
  late AnimationController _morphCtrl;
  late AnimationController _shineCtrl;

  // ── Entry animations ──────────────────────────────────────────────────────
  late Animation<Offset> _titleOffset;
  late Animation<double> _titleFade;
  late Animation<Offset> _subOffset;
  late Animation<double> _subFade;
  late Animation<double> _illusFade;
  late Animation<double> _illusScale;

  // ── Continuous animations ─────────────────────────────────────────────────
  late Animation<double> _floatAnim;
  late Animation<double> _morphAnim;
  late Animation<double> _shineAnim;

  // ── Ripple ────────────────────────────────────────────────────────────────
  late Animation<double> _rippleRadius;
  late Animation<double> _rippleOpacity;
  Offset _rippleCenter = Offset.zero;

  // ── Button ────────────────────────────────────────────────────────────────
  late Animation<double> _btnScale;

  // ── Particles ─────────────────────────────────────────────────────────────
  final List<_Particle> _particles = [];
  final math.Random _rng = math.Random(42);

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initParticles();
    _initControllers();
    _buildAnimations();
    _playEntry();
  }

  void _initParticles() {
    for (int i = 0; i < 18; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        radius: _rng.nextDouble() * 4 + 2,
        speed: _rng.nextDouble() * 0.004 + 0.001,
        angle: _rng.nextDouble() * math.pi * 2,
        opacity: _rng.nextDouble() * 0.5 + 0.15,
      ));
    }
  }

  void _initControllers() {
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _floatCtrl =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _particleCtrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
    _rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 130));
    _morphCtrl =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 3500))
      ..repeat(reverse: true);
    _shineCtrl =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
  }

  void _buildAnimations() {
    _titleOffset = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic)));
    _titleFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut)));
    _subOffset = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOutCubic)));
    _subFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.2, 0.75, curve: Curves.easeOut)));
    _illusFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _illusScale = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.75, curve: Curves.elasticOut)));

    _floatAnim = Tween<double>(begin: -10.0, end: 10.0)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _morphAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _morphCtrl, curve: Curves.easeInOut));
    _shineAnim = Tween<double>(begin: -1.5, end: 2.5)
        .animate(CurvedAnimation(parent: _shineCtrl, curve: Curves.easeInOut));

    _rippleRadius = Tween<double>(begin: 0, end: 180).animate(
        CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut));
    _rippleOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(
        CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut));

    _btnScale = Tween<double>(begin: 1.0, end: 0.93).animate(
        CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));
  }

  void _playEntry() {
    _entryCtrl.reset();
    _entryCtrl.forward();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BLoC-driven page sync
  // ─────────────────────────────────────────────────────────────────────────
  void _syncPageController(int targetPage) {
    if (_pageCtrl.hasClients &&
        (_pageCtrl.page?.round() ?? 0) != targetPage) {
      _pageCtrl.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
      );
    }
    _playEntry();
    HapticFeedback.selectionClick();
  }

  Future<void> _onButtonTap(BuildContext ctx, Offset localPos) async {
    setState(() => _rippleCenter = localPos);
    _rippleCtrl.reset();
    _rippleCtrl.forward();

    await _btnCtrl.forward();
    await _btnCtrl.reverse();

    HapticFeedback.mediumImpact();

    final bloc = ctx.read<OnboardingBloc>();
    if (bloc.state.isLastPage) {
      bloc.add(const OnboardingCompleted());
    } else {
      bloc.add(const OnboardingNextPage());
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    _particleCtrl.dispose();
    _rippleCtrl.dispose();
    _btnCtrl.dispose();
    _morphCtrl.dispose();
    _shineCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<OnboardingBloc, OnboardingState>(
      // ── Navigate when onboarding finishes ──────────────────────────────
      listener: (context, state) {
        if (state is OnboardingFinished) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesName.login,
              (route) => false,// replace with RoutesName.login
          );
        }
        if (state is OnboardingInProgress) {
          _syncPageController(state.currentPage);
        }
      },
      builder: (context, state) {
        final currentPage = state.currentPage;
        final page = kOnboardingPages[currentPage];

        // ── Theme-aware colors ──────────────────────────────────────────
        final bgColor = isDark ? const Color(0xFF0A0A14) : const Color(0xFFF6F6FF);
        final subtitleColor = isDark ? const Color(0xFF8B8FA8) : const Color(0xFF6B7280);
        final counterColor = isDark ? page.primary.withOpacity(0.9) : page.primary;
        final skipBorderColor = isDark ? page.primary.withOpacity(0.35) : page.primary.withOpacity(0.5);
        final skipBgColor = isDark ? page.primary.withOpacity(0.08) : page.primary.withOpacity(0.1);
        final particleOpacityFactor = isDark ? 0.65 : 0.35;
        final blobOpacity1 = isDark ? 0.22 : 0.14;
        final blobOpacity2 = isDark ? 0.08 : 0.05;

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              // ── Layer 1: Morphing blobs ──
              _MorphingBlobs(
                primary: page.primary,
                secondary: page.secondary,
                morphAnim: _morphAnim,
                size: size,
                opacity1: blobOpacity1,
                opacity2: blobOpacity2,
              ),

              // ── Layer 2: Particles ──
              AnimatedBuilder(
                animation: _particleCtrl,
                builder: (_, __) => CustomPaint(
                  size: size,
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _particleCtrl.value,
                    color: page.primary,
                    opacityFactor: particleOpacityFactor,
                  ),
                ),
              ),

              // ── Layer 3: Tap ripple ──
              AnimatedBuilder(
                animation: _rippleCtrl,
                builder: (_, __) => _rippleCtrl.isAnimating
                    ? CustomPaint(
                  size: size,
                  painter: _RipplePainter(
                    center: _rippleCenter,
                    radius: _rippleRadius.value,
                    opacity: _rippleOpacity.value,
                    color: page.primary,
                  ),
                )
                    : const SizedBox.shrink(),
              ),

              // ── Layer 4: Main UI ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // ── Top bar ──
                    _buildTopBar(
                      context: context,
                      state: state,
                      page: page,
                      counterColor: counterColor,
                      skipBorderColor: skipBorderColor,
                      skipBgColor: skipBgColor,
                    ),

                    // ── Pages ──
                    Expanded(
                      child: PageView.builder(
                        controller: _pageCtrl,
                        onPageChanged: (i) => context
                            .read<OnboardingBloc>()
                            .add(OnboardingPageChanged(i)),
                        itemCount: kOnboardingPages.length,
                        itemBuilder: (_, i) => _buildPageContent(
                          index: i,
                          currentIndex: currentPage,
                          size: size,
                          subtitleColor: subtitleColor,
                          isDark: isDark,
                        ),
                      ),
                    ),

                    // ── Dots ──
                    _buildDots(context: context, state: state, page: page),
                    const SizedBox(height: 24),

                    // ── Button ──
                    _buildAnimatedButton(
                      context: context,
                      state: state,
                      page: page,
                      size: size,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TOP BAR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTopBar({
    required BuildContext context,
    required OnboardingState state,
    required OnboardingData page,
    required Color counterColor,
    required Color skipBorderColor,
    required Color skipBgColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            '0${state.currentPage + 1} / 0${state.totalPages}',
            key: ValueKey(state.currentPage),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: counterColor,
              letterSpacing: 1.5,
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: state.isLastPage ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: () =>
                context.read<OnboardingBloc>().add(const OnboardingSkip()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                border: Border.all(color: skipBorderColor, width: 1),
                borderRadius: BorderRadius.circular(20),
                color: skipBgColor,
              ),
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: page.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PAGE CONTENT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPageContent({
    required int index,
    required int currentIndex,
    required Size size,
    required Color subtitleColor,
    required bool isDark,
  }) {
    final page = kOnboardingPages[index];
    final isActive = index == currentIndex;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),

        // Illustration
        AnimatedBuilder(
          animation: Listenable.merge([_floatCtrl, _entryCtrl]),
          builder: (_, child) => Transform.translate(
            offset: Offset(0, isActive ? _floatAnim.value : 0),
            child: FadeTransition(
              opacity: isActive
                  ? _illusFade
                  : const AlwaysStoppedAnimation(1),
              child: ScaleTransition(
                scale: isActive
                    ? _illusScale
                    : const AlwaysStoppedAnimation(1),
                child: child,
              ),
            ),
          ),
          child: _IllustrationWidget(page: page, size: size, isDark: isDark),
        ),

        const SizedBox(height: 52),

        // Title — gradient shader
        SlideTransition(
          position: isActive
              ? _titleOffset
              : const AlwaysStoppedAnimation(Offset.zero),
          child: FadeTransition(
            opacity:
            isActive ? _titleFade : const AlwaysStoppedAnimation(1),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [page.primary, page.secondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1.15,
                  color: Colors.white, // ShaderMask overrides this
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Subtitle
        SlideTransition(
          position: isActive
              ? _subOffset
              : const AlwaysStoppedAnimation(Offset.zero),
          child: FadeTransition(
            opacity:
            isActive ? _subFade : const AlwaysStoppedAnimation(1),
            child: Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.75,
                color: subtitleColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DOTS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDots({
    required BuildContext context,
    required OnboardingState state,
    required OnboardingData page,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(state.totalPages, (i) {
        final isActive = i == state.currentPage;
        return GestureDetector(
          onTap: () => context
              .read<OnboardingBloc>()
              .add(OnboardingJumpToPage(i)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: isActive ? 28 : 8,
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(colors: [page.primary, page.secondary])
                  : null,
              color: isActive ? null : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: page.primary.withOpacity(0.55),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ANIMATED BUTTON
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAnimatedButton({
    required BuildContext context,
    required OnboardingState state,
    required OnboardingData page,
    required Size size,
  }) {
    final isLast = state.isLastPage;

    return AnimatedBuilder(
      animation: Listenable.merge([_btnCtrl, _shineCtrl]),
      builder: (_, child) => Transform.scale(
        scale: _btnScale.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (d) =>
            setState(() => _rippleCenter = d.localPosition),
        onTap: () => _onButtonTap(context, _rippleCenter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [page.primary, page.secondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: page.primary.withOpacity(0.5),
                blurRadius: 28,
                offset: const Offset(0, 12),
                spreadRadius: -6,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Shine sweep
                AnimatedBuilder(
                  animation: _shineAnim,
                  builder: (_, __) => Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(size.width * _shineAnim.value, 0),
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(0.22),
                              Colors.white.withOpacity(0),
                            ],
                            stops: const [0, 0.5, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Label + icon
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.4),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          isLast ? '  Get Started  ' : '  Next  ',
                          key: ValueKey(isLast),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              RotationTransition(
                                turns: Tween<double>(begin: 0.5, end: 1)
                                    .animate(anim),
                                child:
                                FadeTransition(opacity: anim, child: child),
                              ),
                          child: Icon(
                            isLast
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            key: ValueKey(isLast),
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ILLUSTRATION WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _IllustrationWidget extends StatelessWidget {
  final OnboardingData page;
  final Size size;
  final bool isDark;

  const _IllustrationWidget({
    required this.page,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final r = size.width * 0.38;
    return SizedBox(
      width: r * 2.4,
      height: r * 2.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating dashed ring
          _RotatingRing(
            radius: r * 1.18,
            color: page.primary,
            strokeWidth: 1.0,
            dashed: true,
          ),

          // Middle glow ring
          Container(
            width: r * 2,
            height: r * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  page.primary.withOpacity(isDark ? 0.18 : 0.12),
                  page.secondary.withOpacity(isDark ? 0.06 : 0.04),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                  color: page.primary.withOpacity(isDark ? 0.25 : 0.3),
                  width: 1.5),
            ),
          ),

          // Inner fill
          Container(
            width: r * 1.55,
            height: r * 1.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  page.primary.withOpacity(isDark ? 0.22 : 0.14),
                  page.secondary.withOpacity(isDark ? 0.08 : 0.05),
                ],
              ),
            ),
          ),

          // Image / fallback
          SizedBox(
            width: r * 1.2,
            height: r * 1.2,
            child: Image.asset(
              page.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                page.icon,
                size: r * 0.75,
                color: page.primary,
              ),
            ),
          ),

          // Floating badges
          Positioned(
            top: r * 0.22,
            right: r * 0.22,
            child: _FloatingBadge(
                color: page.secondary, icon: Icons.star_rounded),
          ),
          Positioned(
            bottom: r * 0.25,
            left: r * 0.2,
            child: _FloatingBadge(
                color: page.primary, icon: Icons.bolt_rounded),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROTATING DASHED RING
// ─────────────────────────────────────────────────────────────────────────────
class _RotatingRing extends StatefulWidget {
  final double radius;
  final Color color;
  final double strokeWidth;
  final bool dashed;

  const _RotatingRing({
    required this.radius,
    required this.color,
    required this.strokeWidth,
    this.dashed = false,
  });

  @override
  State<_RotatingRing> createState() => _RotatingRingState();
}

class _RotatingRingState extends State<_RotatingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.rotate(
        angle: _ctrl.value * math.pi * 2,
        child: CustomPaint(
          size: Size(widget.radius * 2, widget.radius * 2),
          painter: _DashedCirclePainter(
            color: widget.color,
            strokeWidth: widget.strokeWidth,
            dashed: widget.dashed,
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool dashed;

  const _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (!dashed) {
      canvas.drawCircle(center, radius, paint);
      return;
    }

    const dashCount = 20;
    const dashAngle = math.pi * 2 / dashCount;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle,
        dashAngle * 0.55,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// FLOATING BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingBadge extends StatefulWidget {
  final Color color;
  final IconData icon;
  const _FloatingBadge({required this.color, required this.icon});

  @override
  State<_FloatingBadge> createState() => _FloatingBadgeState();
}

class _FloatingBadgeState extends State<_FloatingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: -5, end: 5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _anim.value), child: child),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: widget.color.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 12)
          ],
        ),
        child: Icon(widget.icon, color: widget.color, size: 17),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MORPHING BLOBS
// ─────────────────────────────────────────────────────────────────────────────
class _MorphingBlobs extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final Animation<double> morphAnim;
  final Size size;
  final double opacity1;
  final double opacity2;

  const _MorphingBlobs({
    required this.primary,
    required this.secondary,
    required this.morphAnim,
    required this.size,
    required this.opacity1,
    required this.opacity2,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: morphAnim,
      builder: (_, __) => Stack(
        children: [
          Positioned(
            top: -size.height * 0.12,
            right: -size.width * 0.18,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: size.width * (0.65 + morphAnim.value * 0.12),
              height: size.width * (0.65 + morphAnim.value * 0.12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withOpacity(opacity1),
                    secondary.withOpacity(opacity2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: size.width * (0.55 - morphAnim.value * 0.08),
              height: size.width * (0.55 - morphAnim.value * 0.08),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    secondary.withOpacity(opacity1 * 0.75),
                    primary.withOpacity(opacity2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTICLE PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;
  final double opacityFactor;

  const _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
    required this.opacityFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dx =
          (p.x + math.cos(p.angle + progress * math.pi * 2) * p.speed * 40) %
              1.0;
      final dy =
          (p.y + math.sin(p.angle + progress * math.pi * 2) * p.speed * 40) %
              1.0;

      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        p.radius,
        Paint()
          ..color = color.withOpacity(p.opacity * opacityFactor)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// RIPPLE PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _RipplePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double opacity;
  final Color color;

  const _RipplePainter({
    required this.center,
    required this.radius,
    required this.opacity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      center,
      radius * 0.6,
      Paint()
        ..color = color.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.radius != radius || old.opacity != opacity || old.color != color;
}