import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_management/configs/routes/routes_name.dart';

// ─────────────────────────────────────────────────────────────
//  COLOURS (App Themed - Orange & Dark)
// ─────────────────────────────────────────────────────────────
const _bg         = Color(0xFF0D0E1A); // Aapki app ka exact background
const _navy       = Color(0xFF16182B);
const _orangeMain = Color(0xFFFF7B00); // Primary Dashboard Orange
const _orangeLight= Color(0xFFFF9F43); // Lighter/Amber Orange
const _orangeDeep = Color(0xFFFF5200); // Deep Reddish Orange
const _white      = Color(0xffEFF3FF);
const _muted      = Color(0xff4A506B);

// ─────────────────────────────────────────────────────────────
//  ENTRY — drop this into your Navigator / route
// ─────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  /// Called when splash finishes — navigate to your home screen here
  final VoidCallback? onComplete;
  const SplashScreen({super.key, this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── controllers ──────────────────────────────────────────
  late final AnimationController _grid;      // slow grid scroll
  late final AnimationController _particles; // particle drift
  late final AnimationController _logo;      // logo build-up
  late final AnimationController _ring;      // outer progress ring
  late final AnimationController _pulse;     // logo pulse glow
  late final AnimationController _text;      // typewriter + tagline
  late final AnimationController _exit;      // whole-screen exit

  // ── derived animations ────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoRotate;
  late final Animation<double> _ringProgress;
  late final Animation<double> _taglineFade;
  late final Animation<double> _exitScale;
  late final Animation<double> _exitFade;

  // typewriter state
  final String _appName    = 'NEXUDO';
  final String _tagline    = 'Command your day. Conquer your goals.';
  // int _visibleChars        = 0;
  // bool _taglineVisible     = false;

  late final ValueNotifier<bool> _taglineVisible = ValueNotifier(false);
  final ValueNotifier<int> _visibleChars = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // ── ambient ──
    _grid = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat();

    _particles = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();

    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);

    // ── logo ──
    _logo = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _logoFade = CurvedAnimation(
        parent: _logo,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut));

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
          parent: _logo,
          curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)),
    );

    _logoRotate = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(
          parent: _logo,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    // ── ring ──
    _ring = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    _ringProgress = CurvedAnimation(
        parent: _ring, curve: Curves.easeInOut);

    // ── text ──
    _text = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    _taglineFade = CurvedAnimation(
        parent: _text,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut));

    // ── exit ──
    _exit = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _exitScale = Tween<double>(begin: 1.0, end: 18.0).animate(
      CurvedAnimation(parent: _exit, curve: Curves.easeInExpo),
    );

    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _exit,
          curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runSequence(); // ✅ Ab yeh tab chalega jab dark screen hat chuki hogi
    });
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Logo enters
    _logo.forward();
    await Future.delayed(const Duration(milliseconds: 700));

    // Ring starts filling
    _ring.forward();

    // Typewriter starts
    await Future.delayed(const Duration(milliseconds: 200));
    _text.forward();
    _typeWriter();

    // Wait for ring to complete
    await Future.delayed(const Duration(milliseconds: 2000));

    // Show tagline
    _taglineVisible.value = true;
    await Future.delayed(const Duration(milliseconds: 900));

    // Exit zoom-burst
    _exit.forward();
    await Future.delayed(const Duration(milliseconds: 650));

    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(RoutesName.welcome); // or your route
    }
  }

  Future<void> _typeWriter() async {
    for (int i = 1; i <= _appName.length; i++) {
      await Future.delayed(const Duration(milliseconds: 85));
      if (mounted) {
        _visibleChars.value = i;
      }
    }
  }

  @override
  void dispose() {
    _grid.dispose();
    _particles.dispose();
    _logo.dispose();
    _ring.dispose();
    _pulse.dispose();
    _text.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _grid, _particles, _logo, _ring,
          _pulse, _text, _exit,
        ]),
        builder: (_, __) {
          return Stack(
            children: [
              // ── 1. Grid background ──────────────────────
              CustomPaint(
                size: size,
                painter: _GridPainter(_grid.value),
              ),

              // ── 2. Particle field ───────────────────────
              CustomPaint(
                size: size,
                painter: _ParticlePainter(_particles.value),
              ),

              // ── 3. Ambient corner glows ─────────────────
              _cornerGlow(size),

              // ── 4. All central content ──────────────────
              Transform.scale(
                scale: _exitScale.value,
                child: Opacity(
                  opacity: _exitFade.value,
                  child: _buildCenter(size),
                ),
              ),

              // ── 5. Exit white flash ─────────────────────
              if (_exit.value > 0.4)
                Opacity(
                  opacity:
                  ((_exit.value - 0.4) / 0.6).clamp(0, 1) * 0.85,
                  child: Container(color: _orangeMain.withOpacity(0.15)),
                ),

              // ── 6. Scan line overlay ────────────────────
              CustomPaint(
                size: size,
                painter: _ScanLinePainter(_grid.value),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Central content ──────────────────────────────────────
  Widget _buildCenter(Size size) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Logo mark ──
          Transform.rotate(
            angle: _logoRotate.value,
            child: Transform.scale(
              scale: _logoScale.value,
              child: Opacity(
                opacity: _logoFade.value,
                child: _buildLogoMark(),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // ── App name typewriter ──
          Opacity(
            opacity: _logoFade.value,
            child: _buildAppName(),
          ),

          const SizedBox(height: 14),

          // ── Tagline ──
          AnimatedOpacity(
            opacity: _taglineVisible.value ? _taglineFade.value : 0,
            duration: const Duration(milliseconds: 600),
            child: _buildTagline(),
          ),

          const SizedBox(height: 52),

          // ── Progress ring + percentage ──
          Opacity(
            opacity: _logoFade.value,
            child: _buildProgressRing(),
          ),

          const SizedBox(height: 24),

          // ── Loading label ──
          Opacity(
            opacity: _logoFade.value * _ring.value,
            child: _buildLoadingLabel(),
          ),
        ],
      ),
    );
  }

  // ── Logo mark (geometric task-check icon) ────────────────
  Widget _buildLogoMark() {
    final pulse = _pulse.value;
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 110 + 20 * pulse,
            height: 110 + 20 * pulse,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _orangeMain.withOpacity(0.25 + 0.15 * pulse),
                  blurRadius: 40 + 20 * pulse,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: _orangeDeep.withOpacity(0.2 + 0.1 * pulse),
                  blurRadius: 60,
                  spreadRadius: -4,
                ),
              ],
            ),
          ),

          // Hexagon shell
          CustomPaint(
            size: const Size(100, 100),
            painter: _HexPainter(pulse, _ring.value),
          ),

          // Inner icon
          CustomPaint(
            size: const Size(52, 52),
            painter: _TaskIconPainter(_ring.value),
          ),
        ],
      ),
    );
  }

  // ── Typewriter app name ──────────────────────────────────
  Widget _buildAppName() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_appName.length, (i) {
        final visible = i < _visibleChars.value;
        return AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 60),
          child: AnimatedSlide(
            offset: visible ? Offset.zero : const Offset(0, 0.4),
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutBack,
            child: Text(
              _appName[i],
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: 12,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [_white, _orangeMain],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(
                      const Rect.fromLTWH(0, 0, 300, 60)),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Tagline ──────────────────────────────────────────────
  Widget _buildTagline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        _tagline,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: _muted.withOpacity(0.9),
          letterSpacing: 0.6,
          height: 1.6,
        ),
      ),
    );
  }

  // ── Progress arc ─────────────────────────────────────────
  Widget _buildProgressRing() {
    final pct = (_ringProgress.value * 100).toInt();
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(72, 72),
            painter: _RingPainter(_ringProgress.value, _pulse.value),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            child: Text(
              '$pct%',
              key: ValueKey(pct),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _orangeMain,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading label ────────────────────────────────────────
  Widget _buildLoadingLabel() {
    final steps = [
      'Initialising workspace...',
      'Loading your tasks...',
      'Syncing priorities...',
      'Ready to launch!',
    ];
    final idx = (_ring.value * (steps.length - 1)).round();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Text(
        steps[idx],
        key: ValueKey(idx),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _muted.withOpacity(0.7),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ── Corner glows ─────────────────────────────────────────
  Widget _cornerGlow(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _orangeDeep.withOpacity(0.18),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          right: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _orangeMain.withOpacity(0.12),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: size.height * 0.25,
          left: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _orangeLight.withOpacity(0.08),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CUSTOM PAINTERS
// ─────────────────────────────────────────────────────────────

/// Perspective grid that scrolls toward viewer
class _GridPainter extends CustomPainter {
  final double t; // 0..1 repeating
  _GridPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _muted.withOpacity(0.18)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    final horizonY = size.height * 0.52;
    final vp = Offset(size.width / 2, horizonY);

    // Vertical perspective lines (fan from vanishing point)
    const linesH = 18;
    for (int i = 0; i <= linesH; i++) {
      final frac = i / linesH;
      final startX = size.width * frac;
      paint.color =
          _muted.withOpacity(0.06 + 0.12 * (1 - (frac - 0.5).abs() * 2).clamp(0, 1));
      canvas.drawLine(Offset(startX, size.height), vp, paint);
    }

    // Horizontal scrolling lines (depth illusion)
    const linesV = 20;
    for (int i = 0; i <= linesV; i++) {
      // map i to a depth value that scrolls
      final rawDepth = ((i / linesV) + t) % 1.0;
      // perspective: closer rows near bottom
      final depth = rawDepth * rawDepth; // quadratic → denser near bottom
      final y = horizonY + (size.height - horizonY) * depth;
      if (y < horizonY) continue;

      // width of line at this depth
      final widthFrac = 0.05 + 0.95 * depth;
      final x0 = vp.dx - (vp.dx * widthFrac);
      final x1 = vp.dx + (size.width - vp.dx) * widthFrac;

      paint.color = _muted.withOpacity(0.04 + 0.14 * depth);
      canvas.drawLine(Offset(x0, y), Offset(x1, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter o) => o.t != t;
}

/// Floating particles / data-node field
class _ParticlePainter extends CustomPainter {
  final double t;
  _ParticlePainter(this.t);

  static final _rng = math.Random(42);
  static final _particles = List.generate(38, (i) {
    return _ParticleData(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      r: 1.0 + _rng.nextDouble() * 2.2,
      speed: 0.04 + _rng.nextDouble() * 0.06,
      phase: _rng.nextDouble(),
      color: i % 5 == 0
          ? _orangeLight
          : i % 4 == 0
          ? _orangeDeep
          : _orangeMain,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final progress = ((t * p.speed * 5 + p.phase) % 1.0);
      final py = (p.y - progress * 0.4) % 1.0;

      final paint = Paint()
        ..color = p.color.withOpacity(
            0.15 + 0.45 * math.sin(progress * math.pi))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(p.x * size.width, py * size.height),
        p.r * (0.6 + 0.4 * math.sin(progress * math.pi)),
        paint,
      );
    }

    // Draw subtle connecting lines between nearby particles
    final linePaint = Paint()
      ..strokeWidth = 0.4
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < _particles.length; i++) {
      final a = _particles[i];
      final ay = ((a.y - ((t * a.speed * 5 + a.phase) % 1.0) * 0.4) % 1.0) * size.height;
      final ax = a.x * size.width;

      for (int j = i + 1; j < _particles.length; j++) {
        final b = _particles[j];
        final by = ((b.y - ((t * b.speed * 5 + b.phase) % 1.0) * 0.4) % 1.0) * size.height;
        final bx = b.x * size.width;

        final dist = math.sqrt(
            math.pow(ax - bx, 2) + math.pow(ay - by, 2));
        if (dist < 90) {
          linePaint.color =
              _orangeMain.withOpacity(0.06 * (1 - dist / 90));
          canvas.drawLine(Offset(ax, ay), Offset(bx, by), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter o) => o.t != t;
}

class _ParticleData {
  final double x, y, r, speed, phase;
  final Color color;
  const _ParticleData({
    required this.x, required this.y, required this.r,
    required this.speed, required this.phase, required this.color,
  });
}

/// Hexagon logo shell with animated segments
class _HexPainter extends CustomPainter {
  final double pulse;
  final double ring;
  _HexPainter(this.pulse, this.ring);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Build hexagon path
    Path hexPath() {
      final path = Path();
      for (int i = 0; i < 6; i++) {
        final angle = (i * 60 - 30) * math.pi / 180;
        final x = cx + r * math.cos(angle);
        final y = cy + r * math.sin(angle);
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path.close();
      return path;
    }

    // Filled dark hex
    canvas.drawPath(
      hexPath(),
      Paint()
        ..color = _navy
        ..style = PaintingStyle.fill,
    );

    // Gradient stroke
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = SweepGradient(
        colors: [_orangeMain, _orangeDeep, _orangeLight, _orangeMain],
        startAngle: ring * math.pi * 2,
        endAngle: ring * math.pi * 2 + math.pi * 2,
      ).createShader(Rect.fromCircle(
          center: Offset(cx, cy), radius: r));

    canvas.drawPath(hexPath(), borderPaint);

    // Corner dots
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      final dotVis = (ring * 6 - i).clamp(0, 1);
      canvas.drawCircle(
        Offset(x, y),
        3.5 * dotVis + 1.5 * pulse * dotVis,
        Paint()
          ..color = _orangeMain.withOpacity(dotVis.toDouble())
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_HexPainter o) =>
      o.pulse != pulse || o.ring != ring;
}

/// Animated checkmark + task lines inside the logo
class _TaskIconPainter extends CustomPainter {
  final double progress; // 0..1
  _TaskIconPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final linePaint = Paint()
      ..color = _orangeMain
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dimPaint = Paint()
      ..color = _muted.withOpacity(0.6)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Three task lines (left side)
    final lines = [
      [0.12, 0.35, 0.55, 0.35],
      [0.12, 0.52, 0.55, 0.52],
      [0.12, 0.69, 0.42, 0.69],
    ];
    for (int i = 0; i < lines.length; i++) {
      final l = lines[i];
      final lineProgress =
      ((progress - i * 0.2) / 0.3).clamp(0.0, 1.0);
      if (lineProgress <= 0) continue;
      canvas.drawLine(
        Offset(l[0] * size.width, l[1] * size.height),
        Offset(
            (l[0] + (l[2] - l[0]) * lineProgress) * size.width,
            l[3] * size.height),
        i == 0 ? linePaint : dimPaint,
      );
    }

    // Animated checkmark (first item)
    final checkProgress =
    ((progress - 0.4) / 0.4).clamp(0.0, 1.0);
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = _orangeLight
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      // Small checkbox square
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 22, cy - 14, 10, 10),
          const Radius.circular(2),
        ),
        Paint()
          ..color = _orangeLight.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );

      // Tick
      if (checkProgress > 0.3) {
        final tickP = ((checkProgress - 0.3) / 0.7).clamp(0, 1);
        final path = Path()
          ..moveTo(cx - 21, cy - 9)
          ..lineTo(cx - 18.5, cy - 7)
          ..lineTo(cx - 14, cy - 13);
        final metrics = path.computeMetrics().first;
        canvas.drawPath(
          metrics.extractPath(0, metrics.length * tickP),
          checkPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TaskIconPainter o) => o.progress != progress;
}

/// Arc progress ring
class _RingPainter extends CustomPainter {
  final double progress;
  final double pulse;
  _RingPainter(this.progress, this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 4;

    // Track
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = _muted.withOpacity(0.2)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke,
    );

    if (progress <= 0) return;

    // Filled arc
    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: const [_orangeDeep, _orangeMain, _orangeLight],
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + math.pi * 2,
      ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      arcPaint,
    );

    // Leading dot glow
    final endAngle = -math.pi / 2 + math.pi * 2 * progress;
    final dotX = cx + r * math.cos(endAngle);
    final dotY = cy + r * math.sin(endAngle);

    canvas.drawCircle(
      Offset(dotX, dotY),
      4.5 + 1.5 * pulse,
      Paint()
        ..color = _orangeMain
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(dotX, dotY),
      8 + 4 * pulse,
      Paint()
        ..color = _orangeMain.withOpacity(0.25 + 0.15 * pulse)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_RingPainter o) =>
      o.progress != progress || o.pulse != pulse;
}

/// Moving horizontal scan line
class _ScanLinePainter extends CustomPainter {
  final double t;
  _ScanLinePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final y = (t * size.height * 1.3) % (size.height + 40) - 20;
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        _orangeMain.withOpacity(0.04),
        _orangeMain.withOpacity(0.07),
        _orangeMain.withOpacity(0.04),
        Colors.transparent,
      ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, y, size.width, 40),
      Paint()
        ..shader = gradient.createShader(
            Rect.fromLTWH(0, y, size.width, 40)),
    );
  }

  @override
  bool shouldRepaint(_ScanLinePainter o) => o.t != t;
}