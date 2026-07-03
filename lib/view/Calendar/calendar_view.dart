import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../bloc/Schedule_blocl/schedule_bloc.dart';

// ─────────────────────────────────────────────
// PREMIUM COLOR THEME CONSTANTS
// ─────────────────────────────────────────────
const _bg           = Color(0xff0D0E1A);
const _card         = Color(0xff1A1C33); // Thora dark/deep blue for depth
const _accent1      = Color(0xff7C6FFF);
const _accent2      = Color(0xffFF6FD8);
const _accent3      = Color(0xff6FFFCB);
const _textPrimary  = Color(0xffF0F2FF);
const _textMuted    = Color(0xff7A7D9C);

const _bgLight      = Color(0xffF8FAFC);
const _cardLight    = Color(0xffFFFFFF);
const _textPrimaryL = Color(0xff1A1A2E);
const _textMutedL   = Color(0xff8D94A5);

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with TickerProviderStateMixin {
  late final AnimationController _orb, _reveal;
  late final Animation<double> _revealCurve;

  @override
  void initState() {
    super.initState();
    context.read<ScheduleBloc>().add(ScheduleLoadStarted());

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
            child: BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, state) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    _FadeSlide(animation: _revealCurve, delay: 0.0, child: _TopBar(isDark: isDark)),
                    const SizedBox(height: 24),

                    // 🔥 PREMIUM FLOATING CALENDAR
                    _FadeSlide(
                      animation: _revealCurve, delay: 0.1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.only(bottom: 15, top: 5),
                        decoration: BoxDecoration(
                          color: isDark ? _card.withOpacity(0.8) : _cardLight,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.8)),
                          boxShadow: [
                            if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 25, offset: const Offset(0, 10))
                          ],
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.now().subtract(const Duration(days: 30)),
                          lastDay: DateTime.now().add(const Duration(days: 90)),
                          focusedDay: state.selectedDate,
                          calendarFormat: CalendarFormat.week,
                          selectedDayPredicate: (day) => isSameDay(state.selectedDate, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            context.read<ScheduleBloc>().add(ScheduleDateSelected(selectedDay));
                          },
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(color: isDark ? _textMuted : _textMutedL, fontWeight: FontWeight.w600, fontSize: 13),
                            weekendStyle: TextStyle(color: _accent2.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            selectedDecoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [_accent2, _accent1], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(color: _accent1.withOpacity(0.2), shape: BoxShape.circle),
                            defaultTextStyle: TextStyle(color: isDark ? _textPrimary : _textPrimaryL, fontWeight: FontWeight.w700),
                            weekendTextStyle: TextStyle(color: _accent2.withOpacity(0.8), fontWeight: FontWeight.w700),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(color: isDark ? _textPrimary : _textPrimaryL, fontWeight: FontWeight.w800, fontSize: 18),
                            leftChevronIcon: Icon(Icons.chevron_left_rounded, color: isDark ? _textPrimary : _textPrimaryL, size: 28),
                            rightChevronIcon: Icon(Icons.chevron_right_rounded, color: isDark ? _textPrimary : _textPrimaryL, size: 28),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Tasks Timeline Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Daily Timeline", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? _textPrimary : _textPrimaryL)),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // 🔥 GLASSMORPHISM TASKS TIMELINE
                    Expanded(
                      child: state.status == ScheduleStatus.loading
                          ? const Center(child: CircularProgressIndicator(color: _accent1))
                          : state.tasks.isEmpty
                          ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy_rounded, size: 60, color: (isDark ? _textMuted : _textMutedL).withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text("No tasks scheduled on this date.", style: TextStyle(color: isDark ? _textMuted : _textMutedL, fontSize: 16, fontWeight: FontWeight.w500)),
                            ],
                          )
                      )
                          : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 120),
                        itemCount: state.tasks.length,
                        itemBuilder: (context, index) {
                          return _FadeSlide(
                            animation: _revealCurve,
                            delay: 0.3 + (index * 0.1),
                            child: _PremiumTimelineCard(
                              task: state.tasks[index],
                              isHighlighted: index == 0,
                              isDark: isDark,
                              isLast: index == state.tasks.length - 1,
                            ),
                          );
                        },
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
}

// ─────────────────────────────────────────────
// PREMIUM TIMELINE CARD WIDGET
// ─────────────────────────────────────────────
class _PremiumTimelineCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool isHighlighted;
  final bool isDark;
  final bool isLast;

  const _PremiumTimelineCard({required this.task, required this.isHighlighted, required this.isDark, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final startTime = task['start_time'] ?? '10:00 AM';
    final status = task['status'] ?? 'To Do';

    // Split AM/PM for editorial look
    final timeParts = startTime.split(' ');
    final mainTime = timeParts[0];
    final amPm = timeParts.length > 1 ? timeParts[1] : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Sleek Time Section
            SizedBox(
              width: 55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 22),
                  Text(mainTime, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? _textPrimary : _textPrimaryL)),
                  Text(amPm, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isDark ? _textMuted : _textMutedL)),
                ],
              ),
            ),
            const SizedBox(width: 15),

            // 2. Timeline Graphic (Glowing Dot + Gradient Line)
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  const SizedBox(height: 26),
                  Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: isDark ? _bg : _bgLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: isHighlighted ? _accent2 : (isDark ? _textMuted.withOpacity(0.3) : _textMutedL.withOpacity(0.3)), width: 4),
                      boxShadow: [if (isHighlighted) BoxShadow(color: _accent2.withOpacity(0.6), blurRadius: 10)],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [isHighlighted ? _accent2.withOpacity(0.8) : (isDark ? Colors.white12 : Colors.black12), isDark ? Colors.white12 : Colors.black12],
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            )
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 15),

            // 3. Glassmorphism Task Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isHighlighted ? _accent1 : (isDark ? Colors.white.withOpacity(0.03) : Colors.white),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(isHighlighted ? 0.3 : (isDark ? 0.05 : 0.8))),
                        boxShadow: [if (!isDark && !isHighlighted) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(
                                      task['title'] ?? 'Task',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isHighlighted ? Colors.white : (isDark ? _textPrimary : _textPrimaryL))
                                  )
                              ),
                              _statusPill(status, isHighlighted),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.folder_outlined, size: 14, color: isHighlighted ? Colors.white70 : (isDark ? _textMuted : _textMutedL)),
                              const SizedBox(width: 6),
                              Text(task['category'] ?? 'General', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isHighlighted ? Colors.white70 : (isDark ? _textMuted : _textMutedL))),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String status, bool isHigh) {
    Color getPillColor() {
      if (status == 'Completed') return _accent3;
      if (status == 'Overdue' || status == 'Task Due') return Colors.redAccent;
      return _accent2; // Default To Do
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHigh ? Colors.white.withOpacity(0.2) : getPillColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
          status,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isHigh ? Colors.white : getPillColor())
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RE-USED UTILS (TopBar, FadeSlide, AnimatedBackground)
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isDark;
  const _TopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassButton(icon: Icons.arrow_back_ios_new_rounded, isDark: isDark, onTap: () => Navigator.maybePop(context)),
          Text('Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: isDark ? _textPrimary : _textPrimaryL)),
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
              padding: const EdgeInsets.only(left: 4.0), // Center align iOS arrow
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