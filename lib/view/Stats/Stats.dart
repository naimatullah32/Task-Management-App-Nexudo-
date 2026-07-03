import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../bloc/stats_block/stats_bloc.dart';

// ─────────────────────────────────────────────
// PREMIUM COLOR THEME CONSTANTS
// ─────────────────────────────────────────────
const _bg           = Color(0xff0D0E1A);
const _card         = Color(0xff161727);
const _accent1      = Color(0xff7C6FFF);
const _accent2      = Color(0xffFF6FD8);
const _accent3      = Color(0xff6FFFCB);
const _textPrimary  = Color(0xffF0F2FF);
const _textMuted    = Color(0xff7A7D9C);
const _bgLight      = Color(0xffF8FAFC);
const _cardLight    = Color(0xffFFFFFF);
const _textPrimaryL = Color(0xff1A1A2E);
const _textMutedL   = Color(0xff6B7280);

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> with TickerProviderStateMixin {
  late final AnimationController _orb, _reveal;
  late final Animation<double> _revealCurve;

  @override
  void initState() {
    super.initState();
    context.read<StatsBloc>().add(StatsLoadStarted());

    _orb = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _reveal = AnimationController(vsync: this, duration: const Duration(milliseconds: 5800));
    _revealCurve = CurvedAnimation(parent: _reveal, curve: Curves.easeOutExpo);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _reveal.forward();
    });
  }

  @override
  void dispose() {
    _orb.dispose();
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _bg : _bgLight,
      body: Stack(
        children: [
          _AnimatedBackground(controller: _orb, isDark: isDark),
          SafeArea(
            child: BlocBuilder<StatsBloc, StatsState>(
              builder: (context, state) {
                if (state.status == StatsStatus.loading) {
                  return const Center(child: CircularProgressIndicator(color: _accent1));
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          _FadeSlide(animation: _revealCurve, delay: 0.0, child: _TopBar(isDark: isDark)),

                          // Header
                          _FadeSlide(
                            animation: _revealCurve, delay: 0.1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                              child: Text("Productivity Insights", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? _textPrimary : _textPrimaryL)),
                            ),
                          ),

                          // 🔥 HERO SECTION: Streak & Overall Completion
                          _FadeSlide(
                            animation: _revealCurve, delay: 0.2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  // Streak Card
                                  Expanded(
                                    child: _GlassCard(
                                      isDark: isDark,
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.15), shape: BoxShape.circle),
                                            child: const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 28),
                                          ),
                                          const SizedBox(height: 16),
                                          Text("${state.currentStreak} Days", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? _textPrimary : _textPrimaryL)),
                                          const SizedBox(height: 4),
                                          Text("Current Streak", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? _textMuted : _textMutedL)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Completion Rate Card (Circular Progress)
                                  Expanded(
                                    child: _GlassCard(
                                      isDark: isDark,
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 65, width: 65,
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween<double>(begin: 0, end: state.overallCompletionRate),
                                              duration: const Duration(seconds: 2),
                                              curve: Curves.easeOutCubic,
                                              builder: (context, value, _) => Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  CircularProgressIndicator(
                                                    value: value,
                                                    strokeWidth: 8,
                                                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                                    valueColor: AlwaysStoppedAnimation<Color>(_accent3),
                                                    strokeCap: StrokeCap.round,
                                                  ),
                                                  Center(
                                                    child: Text("${(value * 100).toInt()}%", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? _textPrimary : _textPrimaryL)),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text("Completion", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? _textMuted : _textMutedL)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 🔥 WEEKLY ACTIVITY CHART
                          _FadeSlide(
                            animation: _revealCurve, delay: 0.3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: _GlassCard(
                                isDark: isDark,
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Weekly Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? _textPrimary : _textPrimaryL)),
                                    const SizedBox(height: 4),
                                    Text("Tasks completed in last 7 days", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? _textMuted : _textMutedL)),
                                    const SizedBox(height: 30),
                                    SizedBox(
                                      height: 180,
                                      child: _buildBarChart(state.weeklyTasksCount, isDark),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 🔥 CATEGORY FOCUS (Pie Chart)
                          _FadeSlide(
                            animation: _revealCurve, delay: 0.4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: _GlassCard(
                                isDark: isDark,
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Category Focus", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? _textPrimary : _textPrimaryL)),
                                    const SizedBox(height: 20),
                                    if (state.categoryDistribution.isEmpty)
                                      Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("No data yet.", style: TextStyle(color: isDark ? _textMuted : _textMutedL))))
                                    else
                                      SizedBox(
                                        height: 160,
                                        child: _buildPieChart(state.categoryDistribution, isDark),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 120), // Bottom padding for FAB
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CHARTS BUILDERS (fl_chart)
  // ─────────────────────────────────────────────

  Widget _buildBarChart(List<int> weeklyData, bool isDark) {
    // Find max value to scale chart dynamically
    int maxY = weeklyData.reduce(math.max);
    if (maxY == 0) maxY = 5; // Default grid height if no tasks

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY.toDouble() + 2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Generate last 7 days names dynamically
                final day = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                final text = DateFormat('EEE').format(day).substring(0, 1); // e.g., 'M', 'T', 'W'
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(text, style: TextStyle(color: isDark ? _textMuted : _textMutedL, fontWeight: FontWeight.w700, fontSize: 12)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05), strokeWidth: 1, dashArray: [4, 4]),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (index) {
          final isMax = weeklyData[index] == maxY && maxY > 0;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weeklyData[index].toDouble(),
                gradient: isMax
                    ? const LinearGradient(colors: [_accent2, _accent1], begin: Alignment.bottomCenter, end: Alignment.topCenter)
                    : LinearGradient(colors: [isDark ? _textMuted.withOpacity(0.2) : Colors.grey.withOpacity(0.3), isDark ? _textMuted.withOpacity(0.4) : Colors.grey.withOpacity(0.5)]),
                width: 14,
                borderRadius: BorderRadius.circular(10),
                backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY.toDouble() + 2,
                    color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02)
                ),
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 1000),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }

  Widget _buildPieChart(Map<String, double> data, bool isDark) {
    final colors = [_accent1, _accent2, _accent3, Colors.orangeAccent, Colors.purpleAccent];
    int colorIndex = 0;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 30,
              sections: data.entries.map((entry) {
                final color = colors[colorIndex++ % colors.length];
                return PieChartSectionData(
                  color: color,
                  value: entry.value,
                  title: '',
                  radius: 20,
                );
              }).toList(),
            ),
            swapAnimationDuration: const Duration(milliseconds: 1200),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((entry) {
              final color = colors[(colorIndex - data.length + data.keys.toList().indexOf(entry.key)) % colors.length];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key, style: TextStyle(color: isDark ? _textPrimary : _textPrimaryL, fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}

// ─────────────────────────────────────────────
// RE-USED UTILS
// ─────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsets padding;
  const _GlassCard({required this.child, required this.isDark, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? _card.withOpacity(0.6) : _cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.8)),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: child,
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isDark;
  const _TopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassButton(icon: Icons.arrow_back_ios_new_rounded, isDark: isDark, onTap: () => Navigator.maybePop(context)),
          Text('Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: isDark ? _textPrimary : _textPrimaryL)),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? .07 : .45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(isDark ? .12 : .6), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(icon, color: isDark ? _textPrimary : _textPrimaryL, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  final Animation<double> animation;
  final double delay;
  final Widget child;
  const _FadeSlide({required this.animation, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    final shifted = CurvedAnimation(parent: animation, curve: Interval(delay.clamp(0, 1), (delay + .4).clamp(0, 1), curve: Curves.easeOutQuart));
    return AnimatedBuilder(
      animation: shifted,
      builder: (_, child) => Opacity(opacity: shifted.value, child: Transform.translate(offset: Offset(0, 24 * (1 - shifted.value)), child: child)),
      child: child,
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;
  const _AnimatedBackground({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(painter: _OrbPainter(controller.value, isDark), size: MediaQuery.of(context).size),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t; final bool isDark;
  _OrbPainter(this.t, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    void orb(double cx, double cy, double r, Color c, double a) {
      canvas.drawCircle(Offset(cx, cy), r, Paint()..shader = RadialGradient(colors: [c.withOpacity(isDark ? a : a * 0.4), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    }
    orb(size.width * (.20 + .15 * math.sin(t * math.pi * 2)), size.height * (.15 + .08 * math.cos(t * math.pi * 2)), 190, _accent1, .25);
    orb(size.width * (.78 + .10 * math.cos(t * math.pi * 2 + 1)), size.height * (.28 + .10 * math.sin(t * math.pi * 2 + 1)), 150, _accent2, .20);
  }
  @override bool shouldRepaint(_OrbPainter o) => o.t != t;
}