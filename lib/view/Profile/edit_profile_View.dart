// lib/screens/profile/edit_profile_view.dart
//
// ✅ THEME UPDATE — light/dark system-based mode added
//    isDark = MediaQuery.of(context).platformBrightness == Brightness.dark
//    Zero logic changes — only color tokens passed down to every widget.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/auth_bloc/auth_bloc.dart';
import '../../bloc/auth_bloc/auth_state.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../configs/routes/routes_name.dart';
import '../../utils/extensions/flush_bar_extension.dart';

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
// THEME HELPER  — single source of truth
// All widgets call these instead of inlining
// ternary expressions, keeping code DRY.
// ─────────────────────────────────────────────
extension _T on bool {
  // ignore: unused_element
  Color get bg          => this ? _bg          : _bgLight;
  Color get card        => this ? _card        : _cardLight;
  Color get textPrimary => this ? _textPrimary : _textPrimaryL;
  Color get textMuted   => this ? _textMuted   : _textMutedL;

  // Surface for read-only / disabled fields
  Color get surfaceDim  => this
      ? _card.withOpacity(.5)
      : Colors.white.withOpacity(.75);

  // Glass button fill
  Color get glassFill   => Colors.white.withOpacity(this ? .07 : .50);
  Color get glassBorder => Colors.white.withOpacity(this ? .12 : .65);

  // Card border in normal state
  Color get cardBorder  => Colors.white.withOpacity(this ? .06 : .0);

  // Orb alpha multiplier
  double get orbAlpha   => this ? 1.0 : 0.45;
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  final Map<String, String?> data;

  final void Function(
      String name,
      String title,
      String? phone,
      String? location,
      ) onSave;

  const EditProfileScreen({
    super.key,
    required this.data,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {

  // ── Animation controllers (unchanged) ───────────────────
  late final AnimationController _orb;
  late final AnimationController _entrance;
  late final AnimationController _reveal;
  late final AnimationController _saveBtn;
  late final Animation<double>   _entranceFade;
  late final Animation<double>   _entranceSlide;
  late final Animation<double>   _revealCurve;

  // ── Form (unchanged) ────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ctrlName;
  late final TextEditingController _ctrlTitle;
  late final TextEditingController _ctrlPhone;
  late final TextEditingController _ctrlLocation;
  late final String _emailDisplay;

  late final FocusNode _fnName;
  late final FocusNode _fnTitle;
  late final FocusNode _fnPhone;
  late final FocusNode _fnLocation;

  @override
  void initState() {
    super.initState();

    // Pre-fill (unchanged)
    _ctrlName     = TextEditingController(text: widget.data['name']     ?? '');
    _ctrlTitle    = TextEditingController(text: widget.data['title']    ?? '');
    _ctrlPhone    = TextEditingController(text: widget.data['phone']    ?? '');
    _ctrlLocation = TextEditingController(text: widget.data['location'] ?? '');
    _emailDisplay = widget.data['email'] ?? '';

    _fnName     = FocusNode();
    _fnTitle    = FocusNode();
    _fnPhone    = FocusNode();
    _fnLocation = FocusNode();

    _orb = AnimationController(
        vsync: this, duration: const Duration(microseconds: 400))
      ..repeat();

    // ── Entrance: screen slides up + fades in (500 ms) ──────
    _entrance = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _entranceFade = CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut));
    _entranceSlide = CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic));

    // ── Reveal: staggered content appears AFTER entrance ────
    // Each _FadeSlide waits for its own delay interval inside
    // _revealCurve, so items cascade in one-by-one.
    _reveal = AnimationController(
        vsync: this, duration: const Duration(seconds: 7));
    _revealCurve =
        CurvedAnimation(parent: _reveal, curve: Curves.easeOutExpo);

    _saveBtn = AnimationController(
        vsync: this, duration: const Duration(seconds: 2));

    // ✅ KEY FIX: entrance first → then reveal starts
    // Previously both ran at the same time so items were
    // already visible before the slide-up finished.
    _entrance.forward().then((_) {
      if (mounted) _reveal.forward();
    });
  }

  @override
  void dispose() {
    _orb.dispose();
    _entrance.dispose();
    _reveal.dispose();
    _saveBtn.dispose();
    _ctrlName.dispose();
    _ctrlTitle.dispose();
    _ctrlPhone.dispose();
    _ctrlLocation.dispose();
    _fnName.dispose();
    _fnTitle.dispose();
    _fnPhone.dispose();
    _fnLocation.dispose();
    super.dispose();
  }

  // ── Avatar pick (unchanged) ──────────────────────────────
  Future<void> _pickAvatar() async {
    HapticFeedback.lightImpact();
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null && mounted) {
      context.read<ProfileBloc>()
          .add(ProfileAvatarUpdateRequested(picked.path));
    }
  }

  // ── Save (unchanged) ─────────────────────────────────────
  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    HapticFeedback.mediumImpact();

    final phone    = _ctrlPhone.text.trim().isEmpty
        ? null : _ctrlPhone.text.trim();
    final location = _ctrlLocation.text.trim().isEmpty
        ? null : _ctrlLocation.text.trim();

    context.read<ProfileBloc>().add(ProfileSaveRequested(
      name:     _ctrlName.text.trim(),
      title:    _ctrlTitle.text.trim(),
      phone:    phone,
      location: location,
    ));

    widget.onSave(
      _ctrlName.text.trim(),
      _ctrlTitle.text.trim(),
      phone,
      location,
    );
  }

  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // ✅ System-based light/dark — single line, propagated to all children
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) =>
      prev.status == ProfileStatus.saving &&
          curr.status == ProfileStatus.loaded,
      listener: (_, __) {
        if (mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        // ✅ Theme-aware background
        backgroundColor: isDark.bg,
        resizeToAvoidBottomInset: true,
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
              // ── Orb background ────────────────────────────
              AnimatedBuilder(
                animation: _orb,
                builder: (_, __) => CustomPaint(
                  painter: _OrbPainter(_orb.value, isDark),
                  size: MediaQuery.of(context).size,
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Top bar
                    _FadeSlide(
                      anim: _revealCurve,
                      delay: 0.0,
                      child: _buildTopBar(isDark),
                    ),

                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding:
                          const EdgeInsets.fromLTRB(20, 0, 20, 60),
                          children: [
                            const SizedBox(height: 28),

                            // ── Avatar ──────────────────────────────
                            _FadeSlide(
                              anim: _revealCurve,
                              delay: 0.05,
                              child: _buildAvatarPicker(isDark),
                            ),
                            const SizedBox(height: 32),

                            // ── PERSONAL ────────────────────────────
                            _sectionLabel('PERSONAL', isDark),

                            _FadeSlide(
                              anim: _revealCurve,
                              delay: 0.12,
                              child: _AnimatedField(
                                ctrl:      _ctrlName,
                                focusNode: _fnName,
                                label:     'Full Name',
                                icon:      Icons.person_rounded,
                                iconColor: _accent1,
                                isDark:    isDark,
                                validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Name is required'
                                    : null,
                              ),
                            ),

                            _FadeSlide(
                              anim: _revealCurve,
                              delay: 0.18,
                              child: _AnimatedField(
                                ctrl:      _ctrlTitle,
                                focusNode: _fnTitle,
                                label:     'Title / Role',
                                icon:      Icons.work_rounded,
                                iconColor: _accent2,
                                isDark:    isDark,
                                hint:      'e.g. UI/UX Designer',
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ── CONTACT ─────────────────────────────
                            _sectionLabel('CONTACT', isDark),

                            _FadeSlide(
                              anim: _revealCurve,
                              delay: 0.24,
                              child: _ReadOnlyField(
                                label:     'Email',
                                value:     _emailDisplay,
                                icon:      Icons.email_rounded,
                                iconColor: const Color(0xffFF475A),
                                isDark:    isDark,
                                subHint:
                                'Managed by your login provider',
                              ),
                            ),

                            _FadeSlide(
                              anim: _revealCurve,
                              delay: 0.30,
                              child: _AnimatedField(
                                ctrl:         _ctrlPhone,
                                focusNode:    _fnPhone,
                                label:        'Phone (optional)',
                                icon:         Icons.phone_rounded,
                                iconColor:    const Color(0xff47FF8A),
                                isDark:       isDark,
                                keyboardType: TextInputType.phone,
                                hint:
                                'Leave empty to hide from profile',
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ── LOCATION & TIME ──────────────────────
                            _sectionLabel('LOCATION & TIME', isDark),

                            _FadeSlide(
                              anim: _revealCurve,
                              delay: 0.36,
                              child: _AnimatedField(
                                ctrl:      _ctrlLocation,
                                focusNode: _fnLocation,
                                label:     'Location (optional)',
                                icon:      Icons.location_on_rounded,
                                iconColor: const Color(0xffFF8A47),
                                isDark:    isDark,
                                hint:      'City, Country',
                              ),
                            ),

                            _FadeSlide(
                              anim: _revealCurve,
                              delay: 0.42,
                              child: BlocBuilder<ProfileBloc, ProfileState>(
                                buildWhen: (p, c) =>
                                p.localTime != c.localTime,
                                builder: (_, st) => _ReadOnlyField(
                                  label:    'Local Time',
                                  value:    st.localTime.isEmpty
                                      ? ProfileState.currentLocalTime()
                                      : st.localTime,
                                  icon:      Icons.access_time_rounded,
                                  iconColor: const Color(0xff47C8FF),
                                  isDark:    isDark,
                                  subHint:
                                  'Auto-detected from your device',
                                ),
                              ),
                            ),

                            const SizedBox(height: 36),

                            _FadeSlide(
                              anim: _revealCurve,
                              delay: 0.50,
                              child: _buildSaveButton(isDark),
                            ),
                          ],
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
    );
  }

  // ── Top bar ──────────────────────────────────────────────
  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassIconBtn(
            icon:   Icons.arrow_back_ios_new_rounded,
            isDark: isDark,
            onTap:  () => Navigator.of(context).pop(),
          ),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
                colors: [_accent1, _accent2])
                .createShader(b),
            child: const Text(
              'EDIT PROFILE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  // ── Avatar picker ─────────────────────────────────────────
  Widget _buildAvatarPicker(bool isDark) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (p, c) =>
      p.avatarUrl != c.avatarUrl || p.isSaving != c.isSaving,
      builder: (_, state) => Center(
        child: GestureDetector(
          onTap: _pickAvatar,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                // ✅ Rotating gradient ring — same in both modes
                AnimatedBuilder(
                  animation: _orb,
                  builder: (_, __) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: const [
                          _accent1, _accent2, _accent3, _accent1
                        ],
                        transform:
                        GradientRotation(_orb.value * 2 * math.pi),
                      ),
                    ),
                  ),
                ),

                // ✅ Avatar fill — theme-aware background
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: Container(
                        // ✅ Light mode: white-ish fill instead of dark
                        color: isDark.bg,
                        child: state.isSaving
                            ? const Center(
                            child: CircularProgressIndicator(
                                color: _accent1, strokeWidth: 2.5))
                            : (state.avatarUrl != null &&
                            state.avatarUrl!.isNotEmpty
                            ? Image.network(
                          state.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _defaultAvatar(isDark),
                          loadingBuilder:
                              (_, child, progress) =>
                          progress == null
                              ? child
                              : _defaultAvatar(isDark),
                        )
                            : _defaultAvatar(isDark)),
                      ),
                    ),
                  ),
                ),

                // Camera badge — same in both modes (gradient)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [_accent1, _accent2]),
                      border: Border.all(
                          color: isDark.bg, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                            color: _accent1.withOpacity(.5),
                            blurRadius: 10)
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Default avatar icon — theme-aware gradient + icon color
  Widget _defaultAvatar(bool isDark) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xff1E2040), Color(0xff12132B)]
            : const [Color(0xffDDE6F5), Color(0xffCDD8EE)],
      ),
    ),
    child: Icon(Icons.person,
        size: 50, color: isDark.textMuted),
  );

  // ✅ Section label — theme-aware muted color
  Widget _sectionLabel(String text, bool isDark) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12, top: 4),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isDark.textMuted,
        letterSpacing: 2.5,
      ),
    ),
  );

  // ── Save button ──────────────────────────────────────────
  // ✅ Gradient button looks great in both modes — no change needed.
  //    Shadow slightly reduced in light mode for subtlety.
  Widget _buildSaveButton(bool isDark) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (p, c) => p.isSaving != c.isSaving,
      builder: (_, state) => GestureDetector(
        onTapDown:   (_) => _saveBtn.forward(),
        onTapUp:     (_) {
          _saveBtn.reverse();
          if (!state.isSaving) _save();
        },
        onTapCancel: ()  => _saveBtn.reverse(),
        child: AnimatedBuilder(
          animation: _saveBtn,
          builder: (_, child) => Transform.scale(
              scale: 1 - .03 * _saveBtn.value, child: child),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_accent1, _accent2],
                begin: Alignment.centerLeft,
                end:   Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _accent1.withOpacity(isDark ? .4 : .25),
                  blurRadius: isDark ? 24 : 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Center(
              child: state.isSaving
                  ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
                  : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: .5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ANIMATED FIELD  ✅ full light/dark support
// ─────────────────────────────────────────────
class _AnimatedField extends StatefulWidget {
  final TextEditingController      ctrl;
  final FocusNode                  focusNode;
  final String                     label;
  final IconData                   icon;
  final Color                      iconColor;
  final bool                       isDark;
  final String?                    hint;
  final TextInputType?             keyboardType;
  final String? Function(String?)? validator;

  const _AnimatedField({
    required this.ctrl,
    required this.focusNode,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_AnimatedField> createState() => _AnimatedFieldState();
}

class _AnimatedFieldState extends State<_AnimatedField> {
  final ValueNotifier<bool> _focused = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocus);
  }

  void _onFocus() => _focused.value = widget.focusNode.hasFocus;

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    _focused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ValueListenableBuilder<bool>(
        valueListenable: _focused,
        builder: (_, focused, __) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            // ✅ Light: white card with soft shadow instead of dark card
            color: focused
                ? widget.iconColor.withOpacity(.07)
                : (isDark ? _card : Colors.white),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: focused
                  ? widget.iconColor.withOpacity(.5)
              // ✅ Light: subtle grey border when not focused
                  : (isDark
                  ? Colors.white.withOpacity(.06)
                  : const Color(0xffDDE3F0)),
              width: focused ? 1.5 : 1.0,
            ),
            boxShadow: focused
                ? [
              BoxShadow(
                color: widget.iconColor.withOpacity(isDark ? .15 : .12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ]
            // ✅ Light mode: always show soft elevation shadow
                : isDark
                ? []
                : [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: widget.iconColor
                        .withOpacity(focused ? .20 : .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    color: focused
                        ? widget.iconColor
                        : widget.iconColor.withOpacity(.7),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),

                // TextFormField
                Expanded(
                  child: TextFormField(
                    controller:   widget.ctrl,
                    focusNode:    widget.focusNode,
                    keyboardType: widget.keyboardType,
                    validator:    widget.validator,
                    // ✅ Theme-aware text + cursor color
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark.textPrimary,
                    ),
                    cursorColor: widget.iconColor,
                    decoration: InputDecoration(
                      labelText: widget.label,
                      hintText:  widget.hint,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        color: focused
                            ? widget.iconColor
                            : isDark.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: isDark.textMuted.withOpacity(.5),
                      ),
                      border:         InputBorder.none,
                      isDense:        true,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),

                // Edit pencil indicator
                if (focused)
                  Icon(
                    Icons.edit_rounded,
                    color: widget.iconColor.withOpacity(.4),
                    size: 15,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// READ-ONLY FIELD  ✅ full light/dark support
// ─────────────────────────────────────────────
class _ReadOnlyField extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    iconColor;
  final bool     isDark;
  final String?  subHint;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    this.subHint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          // ✅ Light: frosted-white surface with border
          color: isDark.surfaceDim,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(.04)
                : const Color(0xffDDE3F0),
            width: 1,
          ),
          // ✅ Light: subtle shadow
          boxShadow: isDark
              ? []
              : [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
              Icon(icon, color: iconColor.withOpacity(.6), size: 18),
            ),
            const SizedBox(width: 12),

            // Label + value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark.textMuted.withOpacity(.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isNotEmpty ? value : (subHint ?? ''),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      // ✅ Light: filled value slightly darker, hint lighter
                      color: value.isNotEmpty
                          ? isDark.textPrimary.withOpacity(.65)
                          : isDark.textMuted.withOpacity(.45),
                    ),
                  ),
                ],
              ),
            ),

            // Lock icon
            Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: isDark.textMuted.withOpacity(.35),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ORB PAINTER  ✅ alpha reduced in light mode
// (unchanged logic — only isDark.orbAlpha used)
// ─────────────────────────────────────────────
class _OrbPainter extends CustomPainter {
  final double t;
  final bool   isDark;
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
                // ✅ Light mode: orbs are 45% as visible
                c.withOpacity(a * isDark.orbAlpha),
                Colors.transparent,
              ],
            ).createShader(
                Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    }

    orb(size.width * (.15 + .12 * math.sin(t * math.pi * 2)),
        size.height * (.12 + .06 * math.cos(t * math.pi * 2)),
        160, _accent1, .20);
    orb(size.width * (.82 + .08 * math.cos(t * math.pi * 2 + 1)),
        size.height * (.35 + .10 * math.sin(t * math.pi * 2 + 1)),
        130, _accent2, .18);
    orb(size.width * (.45 + .07 * math.sin(t * math.pi * 2 + 2)),
        size.height * (.80 + .04 * math.cos(t * math.pi * 2 + 2)),
        120, _accent3, .13);
  }

  @override
  bool shouldRepaint(_OrbPainter o) => o.t != t;
}

// ─────────────────────────────────────────────
// GLASS ICON BUTTON  ✅ full light/dark support
// ─────────────────────────────────────────────
class _GlassIconBtn extends StatefulWidget {
  final IconData     icon;
  final bool         isDark;
  final VoidCallback onTap;
  const _GlassIconBtn(
      {required this.icon, required this.isDark, required this.onTap});

  @override
  State<_GlassIconBtn> createState() => _GlassIconBtnState();
}

class _GlassIconBtnState extends State<_GlassIconBtn>
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
    final isDark = widget.isDark;
    return GestureDetector(
      onTapDown:   (_) => _c.forward(),
      onTapUp:     (_) { _c.reverse(); widget.onTap(); },
      onTapCancel: ()  => _c.reverse(),
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
                // ✅ Light: opaque white button
                color: isDark.glassFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isDark.glassBorder, width: 1),
                // ✅ Light: add a shadow for depth
                boxShadow: isDark
                    ? []
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Icon(
                widget.icon,
                color: isDark.textPrimary,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FADE SLIDE HELPER  ✅ FIXED
// ─────────────────────────────────────────────
class _FadeSlide extends StatelessWidget {
  final Animation<double> anim;
  final double            delay;
  final Widget            child;
  const _FadeSlide(
      {required this.anim, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    final shifted = CurvedAnimation(
      parent: anim,
      curve: Interval(delay, (delay + 0.22).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: shifted,
      builder: (_, child) => Opacity(
        opacity: shifted.value,
        child: Transform.translate(
            offset: Offset(0, 28 * (1 - shifted.value)),
            child: child),
      ),
      child: child,
    );
  }
}