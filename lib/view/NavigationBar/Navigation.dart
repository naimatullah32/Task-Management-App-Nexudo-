import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUI modes ke liye laazmi hai
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_management/view/AddTask/AddTaskView.dart';
import 'package:task_management/view/Calendar/calendar_view.dart';
import 'package:task_management/view/Profile/profileView.dart';
import '../../configs/color/color.dart';
import '../../utils/extensions/flush_bar_extension.dart';
import '../Home/home_screen.dart';
import '../Stats/Stats.dart';

class DashboardScreen extends StatefulWidget {
  final String? message;
  const DashboardScreen({super.key, this.message});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    if (widget.message != null) {
      Future.microtask(() {
        context.flushBarSuccessMessage(message: widget.message!);
      });
    }

    // 🔥 RULE 1: Navigation bar ko immersive sticky banana taake wo automatic dissapear ho jaye
    _setImmersiveMode();
  }

  void _setImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top], // Sirf top bar (status bar) dikhaye, bottom hide rakhe
    );
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ScheduleScreen(),
    const AddTaskScreen(),
    const StatsView(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Har bar screen build hone par immersive mode re-enforce karein
    _setImmersiveMode();

    return Scaffold(
      extendBody: true,
      // 🔥 Overflow fix karne ke liye body ko SingleChildScrollView ya safe bounds mein rakha jata hai
      body: _screens[_selectedIndex],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 65, width: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, const Color(0xFF6366F1)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.4),
              blurRadius: 15, offset: const Offset(0, 8),
            )
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => setState(() => _selectedIndex = 2),
          child: const Icon(Iconsax.add, size: 32, color: Colors.white),
        ),
      ),

      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    // 🔥 OVERFLOW FIX: Media Query ka use kar ke check karna ke keyboard ya system bar active toh nahi
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    if (bottomPadding > 0) {
      return const SizedBox.shrink(); // Keyboard khulne par bottom bar hide ho jaye taake overflow na ho
    }

    return Container(
      // Fixed height ke andar flexible wrap lagaya hai
      height: 75,
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: isDark ? null : Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomAppBar(
          padding: EdgeInsets.zero,
          color: Colors.transparent,
          elevation: 0,
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          // 🔥 Row ko SafeArea ya Flexible structures mein constraints diye hain
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildNavItem(IconlyLight.home, "Home", 0)),
              Expanded(child: _buildNavItem(Iconsax.calendar, "Calendar", 1)),
              const SizedBox(width: 50), // FAB space balanced
              Expanded(child: _buildNavItem(Icons.analytics_outlined, "Stats", 3)),
              Expanded(child: _buildNavItem(Iconsax.user, "Profile", 4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Elements ko strictly vertical center rakhne ke liye
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade500,
            size: 24, // Size ko 26 se 24 kiya taake compact dimensions mein fit ho
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4, width: isSelected ? 4 : 0,
            decoration: BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
          )
        ],
      ),
    );
  }
}