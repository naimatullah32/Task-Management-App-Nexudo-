import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/Home_Bloc/home_bloc.dart';
import '../../services/notification_service/notification_service.dart';


// ─────────────────────────────────────────────
// PREMIUM COLOR THEME
// ─────────────────────────────────────────────
const _bg           = Color(0xff0D0E1A);
const _card         = Color(0xff161727);
const _accent1      = Color(0xff7C6FFF);
const _accent2      = Color(0xff47C8FF); // Image matching blue gradient
const _accent3      = Color(0xff6FFFCB);
const _textPrimary  = Color(0xffF0F2FF);
const _textMuted    = Color(0xff7A7D9C);

const _bgLight      = Color(0xffF8FAFC); // Slightly softer white
const _cardLight    = Color(0xffFFFFFF);
const _textPrimaryL = Color(0xff1A1A2E);
const _textMutedL   = Color(0xff6B7280);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _orb, _reveal;
  late final Animation<double> _revealCurve;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoadStarted());

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayStr = DateFormat('MMM dd, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: isDark ? _bg : _bgLight,
      body: Stack(
        children: [
          _AnimatedBackground(controller: _orb, isDark: isDark),
          SafeArea(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state.status == HomeStatus.loading && state.todayTasks.isEmpty) {
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

                          // 1. TOP BAR (Menu & Avatar)
                          _FadeSlide(
                            animation: _revealCurve, delay: 0.0,
                            child: _buildTopBar(isDark, state.avatarUrl),
                          ),
                          // const SizedBox(height: 32),

                          // 2. GREETING HEADER
                          _FadeSlide(
                            animation: _revealCurve, delay: 0.1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Hello, ${state.userName}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? _textPrimary : _textPrimaryL)),
                                  const SizedBox(height: 4),
                                  Text(todayStr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? _textMuted : _textMutedL)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 3. SEARCH BAR
                          _FadeSlide(
                            animation: _revealCurve, delay: 0.2,
                            child: _buildSearchBar(isDark, context),
                          ),
                          const SizedBox(height: 36),

                          // 4. CATEGORIES SECTION
                          _FadeSlide(
                            animation: _revealCurve, delay: 0.3,
                            child: _buildSectionHeader("Categories", "View All", isDark),
                          ),
                          const SizedBox(height: 16),
                          _FadeSlide(
                            animation: _revealCurve, delay: 0.35,
                            child: SizedBox(
                              height: 140,
                              child: state.categories.isEmpty
                                  ? Center(child: Text("No categories yet", style: TextStyle(color: isDark ? _textMuted : _textMutedL)))
                                  : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: state.categories.length,
                                itemBuilder: (context, index) {
                                  final cat = state.categories[index];
                                  // Alternate gradients for categories
                                  final colors = index % 2 == 0 ? [_accent2, _accent1] : [_accent1, const Color(0xffFF8A47)];
                                  return _CategoryCard(
                                    title: cat['name'],
                                    taskCount: cat['taskCount'],
                                    progress: cat['progress'],
                                    gradientColors: colors,
                                    isDark: isDark,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // 5. MY TASKS SECTION
                          _FadeSlide(
                            animation: _revealCurve, delay: 0.4,
                            child: _buildSectionHeader("My Task", "${state.todayTasks.length}", isDark, isCount: true),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              await NotificationService().showTestNotification();
                            },
                            child: const Text('Test Notification'),
                          )
                        ],

                      ),
                    ),

                    // TASKS LIST (Vertical)
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 120), // Bottom padding for FAB
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final task = state.todayTasks[index];
                            return _FadeSlide(
                              animation: _revealCurve,
                              delay: 0.45 + (index * 0.05),
                              child: _HomeTaskCard(task: task, isDark: isDark),
                            );
                          },
                          childCount: state.todayTasks.length,
                        ),
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
  // WIDGET BUILDERS
  // ─────────────────────────────────────────────

  Widget _buildTopBar(bool isDark, String? avatarUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Drawer Icon (Matching Image)
          GestureDetector(
            onTap: () {}, // Open drawer logic
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 24, height: 2.5, decoration: BoxDecoration(color: isDark ? _textPrimary : _textPrimaryL, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 6),
                Container(width: 16, height: 2.5, decoration: BoxDecoration(color: isDark ? _textPrimary : _textPrimaryL, borderRadius: BorderRadius.circular(2))),
              ],
            ),
          ),
          // User Avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? _card : _cardLight,
              border: Border.all(color: Colors.white.withOpacity(isDark ? 0.1 : 0.5), width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: ClipOval(
              child: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? Image.network(avatarUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person, color: isDark ? _textMuted : _textMutedL))
                  : Icon(Icons.person, color: isDark ? _textMuted : _textMutedL),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? _card.withOpacity(0.8) : _cardLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.8)),
          boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => context.read<HomeBloc>().add(HomeSearchQueried(val)),
          style: TextStyle(color: isDark ? _textPrimary : _textPrimaryL, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "Find your task",
            hintStyle: TextStyle(color: (isDark ? _textMuted : _textMutedL).withOpacity(0.6), fontSize: 15),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            suffixIcon: Icon(Icons.search_rounded, color: isDark ? _textMuted : _textMutedL),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String trailing, bool isDark, {bool isCount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? _textPrimary : _textPrimaryL)),
              if (isCount) ...[
                const SizedBox(width: 8),
                Text(trailing, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? _textMuted : _textMutedL)),
              ]
            ],
          ),
          if (!isCount)
            Text(trailing, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textMuted)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY CARD (Gradient with Progress Bar)
// ─────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final String title;
  final int taskCount;
  final double progress;
  final List<Color> gradientColors;
  final bool isDark;

  const _CategoryCard({required this.title, required this.taskCount, required this.progress, required this.gradientColors, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDark ? _card : _cardLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: gradientColors.first.withOpacity(isDark ? 0.2 : 0.15), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          // Top Gradient Area
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text("$taskCount Projects", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Progress Area
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${(progress * 100).toInt()}%", style: TextStyle(color: isDark ? _textPrimary : _textPrimaryL, fontWeight: FontWeight.w800, fontSize: 13)),
                        const SizedBox(height: 6),
                        LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: [
                                  // Background track (hamesha full width)
                                  Container(
                                      height: 5,
                                      width: constraints.maxWidth,
                                      decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(5))
                                  ),
                                  // Active Progress bar
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeOutCubic,
                                    height: 5,
                                    // 🔥 Fix: constraints.maxWidth ko progress (0.0 to 1.0) se multiply kiya hai
                                    width: constraints.maxWidth * progress,
                                    decoration: BoxDecoration(color: gradientColors.first, borderRadius: BorderRadius.circular(5)),
                                  ),
                                ],
                              );
                            }
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Dummy Avatar Stack
                  SizedBox(
                    width: 50, height: 26,
                    child: Stack(
                      children: [
                        Positioned(right: 0, child: _circleAvatar(Colors.orangeAccent)),
                        Positioned(right: 12, child: _circleAvatar(Colors.blueAccent)),
                        Positioned(right: 24, child: _circleAvatar(Colors.pinkAccent)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleAvatar(Color color) {
    return Container(
      width: 26, height: 26,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      child: const Icon(Icons.person, size: 14, color: Colors.white),
    );
  }
}

// ─────────────────────────────────────────────
// HOME TASK CARD (White/Dark Premium Card)
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
// HOME TASK CARD (Clean & Clickable)
// ─────────────────────────────────────────────
class _HomeTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool isDark;

  const _HomeTaskCard({required this.task, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final status = task['status'] ?? 'To Do';
    final startTime = task['start_time'] ?? '10:00 AM';
    final endTime = task['end_time'] ?? '11:00 AM';

    final bool isCompleted = status == 'Completed';

    // 🔥 AUTOMATIC 'TASK DUE' DETECTION
    bool isTaskDue = false;
    if (!isCompleted && task['due_date'] != null) {
      final dueDate = DateTime.parse(task['due_date']);
      if (DateTime.now().isAfter(dueDate)) {
        isTaskDue = true;
      }
    }

    Color pillColor = isCompleted ? _accent3 : (isTaskDue ? Colors.redAccent : _accent1);
    String displayStatus = isCompleted ? 'Completed' : (isTaskDue ? 'Task Due' : 'To Do');

    return GestureDetector(
      onTap: () {
        // 🔥 SLIDE UP ANIMATION SCREEN OPEN KAREGA
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // Custom height ke liye
          backgroundColor: Colors.transparent, // Background transparent rakha hai rounded corners ke liye
          builder: (context) => TaskDetailsSheet(task: task, isDark: isDark, isTaskDue: isTaskDue),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? _card.withOpacity(isCompleted ? 0.45 : 1.0) : _cardLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isCompleted ? _accent3.withOpacity(0.2) : Colors.white.withOpacity(isDark ? 0.05 : 0.8)),
          boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task['title'] ?? 'Untitled Task',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isCompleted ? (isDark ? _textMuted : _textMutedL) : (isDark ? _textPrimary : _textPrimaryL),
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(task['category'] ?? 'General', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? _textMuted : _textMutedL)),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04), height: 1),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: isTaskDue ? Colors.redAccent : _accent1),
                    const SizedBox(width: 6),
                    Text("$startTime - $endTime", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? _textMuted : _textMutedL)),
                  ],
                ),
                // STATUS PILL
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: pillColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: pillColor.withOpacity(0.3), width: 1),
                  ),
                  child: Text(displayStatus, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: pillColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RE-USED UTILS (FadeSlide, Background)
// ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────
// PREMIUM SLIDE-UP TASK DETAILS SHEET
// ─────────────────────────────────────────────
class TaskDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool isDark;
  final bool isTaskDue;

  const TaskDetailsSheet({super.key, required this.task, required this.isDark, required this.isTaskDue});

  @override
  Widget build(BuildContext context) {
    final taskId = task['id'] ?? '';
    final title = task['title'] ?? 'Untitled Task';
    final description = task['description'] ?? 'No description provided.';
    final category = task['category'] ?? 'General';
    final startTime = task['start_time'] ?? '10:00 AM';
    final endTime = task['end_time'] ?? '11:00 AM';

    String formattedDate = "Not Set";
    if (task['due_date'] != null) {
      formattedDate = DateFormat('EEEE, MMM dd, yyyy').format(DateTime.parse(task['due_date']));
    }

    // State ko live read karne ke liye hum yahan state check kar sakte hain,
    // but initially data database se lenge
    return BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // Find current task state dynamically from the list
          final currentTask = state.todayTasks.firstWhere((t) => t['id'] == taskId, orElse: () => task);
          final bool isCompleted = currentTask['status'] == 'Completed';

          return Container(
            decoration: BoxDecoration(
              color: isDark ? _bg : _bgLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, -10))],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            // Height itni rakhi hai ke screen ka 70% hissa cover kare
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Drag Handle
                Center(
                  child: Container(
                    width: 50, height: 5,
                    decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 30),

                // 2. Category & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: _accent1.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Text(category, style: const TextStyle(color: _accent1, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    if (isTaskDue && !isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Text("Task Due", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Title
                Text(
                  title,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: isDark ? _textPrimary : _textPrimaryL),
                ),
                const SizedBox(height: 24),

                // 4. Timing & Date Details (Premium List)
                _buildDetailRow(Icons.calendar_month_rounded, "Date", formattedDate, isDark),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.schedule_rounded, "Time", "$startTime - $endTime", isDark),

                const SizedBox(height: 24),
                Divider(color: isDark ? Colors.white12 : Colors.black12),
                const SizedBox(height: 16),

                // 5. Description
                Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? _textPrimary : _textPrimaryL)),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      description,
                      style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? _textMuted : _textMutedL),
                    ),
                  ),
                ),

                // 6. GIANT INTERACTIVE COMPLETE BUTTON
                SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      // Update the status using Bloc
                      context.read<HomeBloc>().add(HomeTaskStatusToggleRequested(
                        taskId: taskId,
                        currentStatus: currentTask['status'],
                      ));
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 60,
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        color: isCompleted ? _accent3 : (isDark ? _card : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isCompleted ? Colors.transparent : _accent1, width: 2),
                        boxShadow: isCompleted ? [BoxShadow(color: _accent3.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))] : [],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                color: isCompleted ? _bg : _accent1, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              isCompleted ? "Completed" : "Mark as Complete",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isCompleted ? _bg : _accent1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: isDark ? _card : _cardLight, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: _accent1, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? _textMuted : _textMutedL)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? _textPrimary : _textPrimaryL)),
          ],
        )
      ],
    );
  }
}