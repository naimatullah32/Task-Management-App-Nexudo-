import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/addTask/add_task_bloc.dart';
import '../../utils/extensions/flush_bar_extension.dart';


// ─────────────────────────────────────────────
// COLOURS (Exact match with Profile)
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

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> with TickerProviderStateMixin {
  late final AnimationController _orb;
  late final AnimationController _reveal;
  late final Animation<double> _revealCurve;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Design', 'icon': Icons.brush_rounded, 'color': _accent2},
    {'name': 'Code', 'icon': Icons.code_rounded, 'color': _accent3},
    {'name': 'Personal', 'icon': Icons.person_rounded, 'color': _accent1},
    {'name': 'Work', 'icon': Icons.work_rounded, 'color': Colors.orangeAccent},
  ];

  @override
  void initState() {
    super.initState();
    _orb = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _reveal = AnimationController(vsync: this, duration: const Duration(milliseconds: 5800));
    _revealCurve = CurvedAnimation(parent: _reveal, curve: Curves.easeOutExpo);

    _titleFocus.addListener(() => setState(() {}));
    _descFocus.addListener(() => setState(() {}));

    // Start entrance animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _reveal.forward();
    });
  }

  @override
  void dispose() {
    _orb.dispose();
    _reveal.dispose();
    _titleController.dispose();
    _descController.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  void _submitTask(BuildContext context) {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    context.read<AddTaskBloc>().add(
      AddTaskSubmitted(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final state = context.read<AddTaskBloc>().state;
    final picked = await showDatePicker(
      context: context,
      initialDate: state.dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark ? ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: _accent1, surface: _card),
          ) : ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: _accent1, surface: _cardLight),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      context.read<AddTaskBloc>().add(AddTaskDateSelected(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AddTaskBloc, AddTaskState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == AddTaskStatus.success) {

          _titleController.clear();
          _descController.clear();
          context.read<AddTaskBloc>().add(AddTaskReset());

          // 1. Success Message show karein
          context.flushBarSuccessMessage(message: 'Task added successfully!');

          // 2. Thora delay de kar safely back jayein taake context destroy na ho
          // aur user message parh le
          Future.delayed(const Duration(seconds: 2), () {
            if (Navigator.canPop(context)) {
              // Agar stack mein piche screen hai toh safely pop karo
              Navigator.pop(context, true);
            } else {
              // Agar piche koi screen nahi bachi toh home par bhej do (RoutesName use karein)
              // Navigator.pushReplacementNamed(context, RoutesName.navBar);
            }
          });

        } else if (state.status == AddTaskStatus.failure) {
          // 3. Error Message show karein
          context.flushBarErrorMessage(
            message: state.errorMessage ?? 'Failed to add task. Please try again!',
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? _bg : _bgLight,
        body: Stack(
          children: [
            _AnimatedBackground(controller: _orb, isDark: isDark),
            SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _FadeSlide(animation: _revealCurve, delay: 0.0, child: _TopBar(isDark: isDark)),
                        const SizedBox(height: 32),

                        // Title Input
                        _FadeSlide(
                          animation: _revealCurve, delay: 0.1,
                          child: _buildInputField(
                            controller: _titleController,
                            focusNode: _titleFocus,
                            hint: "Task Title...",
                            icon: Icons.title_rounded,
                            accent: _accent1,
                            isDark: isDark,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Description Input
                        _FadeSlide(
                          animation: _revealCurve, delay: 0.2,
                          child: _buildInputField(
                            controller: _descController,
                            focusNode: _descFocus,
                            hint: "Task Description...",
                            icon: Icons.notes_rounded,
                            accent: _accent2,
                            isDark: isDark,
                            maxLines: 3,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Category Section
                        _FadeSlide(
                          animation: _revealCurve, delay: 0.3,
                          child: _sectionLabel("CATEGORY", isDark),
                        ),
                        _FadeSlide(
                          animation: _revealCurve, delay: 0.35,
                          child: SizedBox(
                            height: 50,
                            child: ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _categories.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final cat = _categories[index];
                                return BlocBuilder<AddTaskBloc, AddTaskState>(
                                  buildWhen: (p, c) => p.category != c.category,
                                  builder: (context, state) {
                                    final isSelected = state.category == cat['name'];
                                    return _CategoryPill(
                                      name: cat['name'],
                                      icon: cat['icon'],
                                      color: cat['color'],
                                      isSelected: isSelected,
                                      isDark: isDark,
                                      onTap: () => context.read<AddTaskBloc>().add(AddTaskCategorySelected(cat['name'])),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Priority Section
                        _FadeSlide(
                          animation: _revealCurve, delay: 0.4,
                          child: _sectionLabel("PRIORITY", isDark),
                        ),
                        _FadeSlide(
                          animation: _revealCurve, delay: 0.45,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: BlocBuilder<AddTaskBloc, AddTaskState>(
                              buildWhen: (p, c) => p.priority != c.priority,
                              builder: (context, state) {
                                return Row(
                                  children: [
                                    Expanded(child: _PriorityPill(name: 'Low', color: _accent3, isSelected: state.priority == 'Low', isDark: isDark, onTap: () => context.read<AddTaskBloc>().add(AddTaskPrioritySelected('Low')))),
                                    const SizedBox(width: 10),
                                    Expanded(child: _PriorityPill(name: 'Medium', color: _accent1, isSelected: state.priority == 'Medium', isDark: isDark, onTap: () => context.read<AddTaskBloc>().add(AddTaskPrioritySelected('Medium')))),
                                    const SizedBox(width: 10),
                                    Expanded(child: _PriorityPill(name: 'High', color: const Color(0xffFF475A), isSelected: state.priority == 'High', isDark: isDark, onTap: () => context.read<AddTaskBloc>().add(AddTaskPrioritySelected('High')))),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Due Date
                        _FadeSlide(
                          animation: _revealCurve, delay: 0.5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: BlocBuilder<AddTaskBloc, AddTaskState>(
                              buildWhen: (p, c) => p.dueDate != c.dueDate,
                              builder: (context, state) {
                                final hasDate = state.dueDate != null;
                                return GestureDetector(
                                  onTap: () => _pickDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: isDark ? _card : _cardLight,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.6)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today_rounded, color: hasDate ? _accent3 : (isDark ? _textMuted : _textMutedL), size: 22),
                                        const SizedBox(width: 16),
                                        Text(
                                          hasDate ? DateFormat('MMM dd, yyyy').format(state.dueDate!) : 'Select Due Date',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: hasDate ? (isDark ? _textPrimary : _textPrimaryL) : (isDark ? _textMuted : _textMutedL),
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(Icons.chevron_right_rounded, color: isDark ? _textMuted : _textMutedL),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),


                        // add_task_screen.dart mein "Due Date" wale block ke FORAN BAAD ye naya code paste karein (Submit button se pehle):

                        const SizedBox(height: 24),
                        _FadeSlide(
                          animation: _revealCurve, delay: 0.55,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                // START TIME
                                Expanded(
                                  child: BlocBuilder<AddTaskBloc, AddTaskState>(
                                    buildWhen: (p, c) => p.startTime != c.startTime,
                                    builder: (context, state) {
                                      return GestureDetector(
                                        onTap: () async {
                                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                          if (time != null && context.mounted) {
                                            final formattedTime = time.format(context);
                                            context.read<AddTaskBloc>().add(AddTaskStartTimeSelected(formattedTime));
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(color: isDark ? _card : _cardLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.6))),
                                          child: Row(
                                            children: [
                                              Icon(Icons.schedule_rounded, color: state.startTime != null ? _accent1 : (isDark ? _textMuted : _textMutedL), size: 20),
                                              const SizedBox(width: 10),
                                              Text(state.startTime ?? 'Start Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: state.startTime != null ? (isDark ? _textPrimary : _textPrimaryL) : (isDark ? _textMuted : _textMutedL))),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // END TIME
                                Expanded(
                                  child: BlocBuilder<AddTaskBloc, AddTaskState>(
                                    buildWhen: (p, c) => p.endTime != c.endTime,
                                    builder: (context, state) {
                                      return GestureDetector(
                                        onTap: () async {
                                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                          if (time != null && context.mounted) {
                                            final formattedTime = time.format(context);
                                            context.read<AddTaskBloc>().add(AddTaskEndTimeSelected(formattedTime));
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(color: isDark ? _card : _cardLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.6))),
                                          child: Row(
                                            children: [
                                              Icon(Icons.history_toggle_off_rounded, color: state.endTime != null ? _accent2 : (isDark ? _textMuted : _textMutedL), size: 20),
                                              const SizedBox(width: 10),
                                              Text(state.endTime ?? 'End Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: state.endTime != null ? (isDark ? _textPrimary : _textPrimaryL) : (isDark ? _textMuted : _textMutedL))),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Submit Button
                        _FadeSlide(
                          animation: _revealCurve, delay: 0.6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: BlocBuilder<AddTaskBloc, AddTaskState>(
                              builder: (context, state) {
                                return _PressableButton(
                                  onTap: state.status == AddTaskStatus.loading ? () {} : () => _submitTask(context),
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [_accent1, _accent2]),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(color: _accent1.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))
                                      ],
                                    ),
                                    child: Center(
                                      child: state.status == AddTaskStatus.loading
                                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                          : const Text('CREATE TASK', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? _textMuted : _textMutedL, letterSpacing: 2),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required Color accent,
    required bool isDark,
    required int maxLines,
  }) {
    final isFocused = focusNode.hasFocus;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isFocused ? accent.withOpacity(0.05) : (isDark ? _card : _cardLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isFocused ? accent.withOpacity(0.5) : Colors.white.withOpacity(isDark ? 0.05 : 0.6), width: isFocused ? 1.5 : 1),
          boxShadow: isFocused ? [BoxShadow(color: accent.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 14 : 0),
              child: Icon(icon, color: isFocused ? accent : (isDark ? _textMuted : _textMutedL), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: maxLines,
                style: TextStyle(color: isDark ? _textPrimary : _textPrimaryL, fontSize: 16, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: (isDark ? _textMuted : _textMutedL).withOpacity(0.6), fontSize: 15, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                cursorColor: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INTERACTIVE PILLS (Category & Priority)
// ─────────────────────────────────────────────
class _CategoryPill extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryPill({required this.name, required this.icon, required this.color, required this.isSelected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : (isDark ? _card : _cardLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.white.withOpacity(isDark ? 0.05 : 0.6)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? color : (isDark ? _textMuted : _textMutedL)),
            const SizedBox(width: 8),
            Text(name, style: TextStyle(color: isSelected ? (isDark ? _textPrimary : _textPrimaryL) : (isDark ? _textMuted : _textMutedL), fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  final String name;
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _PriorityPill({required this.name, required this.color, required this.isSelected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? color : (isDark ? _card : _cardLight),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? color : Colors.white.withOpacity(isDark ? 0.05 : 0.6)),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
        ),
        child: Center(
          child: Text(name, style: TextStyle(color: isSelected ? Colors.white : (isDark ? _textMuted : _textMutedL), fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RE-USED HELPERS FROM PROFILE (TopBar, Background, FadeSlide, Button)
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
          _GlassButton(
            icon: Icons.arrow_back_ios_new_rounded,
            isDark: isDark,
            onTap: () => Navigator.maybePop(context),
          ),
          Text('NEW TASK', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 3, color: isDark ? _textPrimary : _textPrimaryL)),
          const SizedBox(width: 44), // To balance the back button
        ],
      ),
    );
  }
}

class _GlassButton extends StatefulWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.isDark, required this.onTap});

  @override
  State<_GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<_GlassButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
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
      onTapUp: (_) { _c.reverse(); widget.onTap(); },
      onTapCancel: () => _c.reverse(),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.scale(scale: 1 - .08 * _c.value, child: child),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(widget.isDark ? .07 : .45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(widget.isDark ? .12 : .6), width: 1),
              ),
              child: Icon(widget.icon, color: widget.isDark ? _textPrimary : _textPrimaryL, size: 18),
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
    final shifted = CurvedAnimation(parent: animation, curve: Interval(delay, (delay + .4).clamp(0.0, 1.0), curve: Curves.easeOutQuart));
    return AnimatedBuilder(
      animation: shifted,
      builder: (_, child) => Opacity(opacity: shifted.value, child: Transform.translate(offset: Offset(0, 24 * (1 - shifted.value)), child: child)),
      child: child,
    );
  }
}

class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressableButton({required this.child, required this.onTap});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) { _c.reverse(); widget.onTap(); },
      onTapCancel: () => _c.reverse(),
      child: AnimatedBuilder(animation: _c, builder: (_, child) => Transform.scale(scale: 1 - .05 * _c.value, child: child), child: widget.child),
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
      canvas.drawCircle(Offset(cx, cy), r, Paint()..shader = RadialGradient(colors: [c.withOpacity(isDark ? a : a * 0.55), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    }
    orb(size.width * (.20 + .15 * math.sin(t * math.pi * 2)), size.height * (.15 + .08 * math.cos(t * math.pi * 2)), 190, _accent1, .25);
    orb(size.width * (.78 + .10 * math.cos(t * math.pi * 2 + 1)), size.height * (.28 + .10 * math.sin(t * math.pi * 2 + 1)), 150, _accent2, .20);
    orb(size.width * (.50 + .08 * math.sin(t * math.pi * 2 + 2)), size.height * (.72 + .05 * math.cos(t * math.pi * 2 + 2)), 130, _accent3, .15);
  }
  @override bool shouldRepaint(_OrbPainter o) => o.t != t;
}