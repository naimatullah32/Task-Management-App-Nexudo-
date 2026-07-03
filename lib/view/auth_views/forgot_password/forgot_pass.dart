import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/configs/routes/routes_name.dart';

import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../bloc/auth_bloc/auth_event.dart';
import '../../../bloc/auth_bloc/auth_state.dart';
import '../../../configs/color/color.dart';
import '../../../utils/extensions/flush_bar_extension.dart';
import 'OTP_view.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      extendBodyBehindAppBar: true,

      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {

          // ❌ ERROR HANDLING
          if (state is AuthFailure) {
            context.flushBarErrorMessage(message: state.message);
          }

          // ✅ SUCCESS → GO TO OTP SCREEN
          if (state is AuthSuccess) {
            Navigator.pushNamed(
              context,
              RoutesName.otpView,
              arguments: {
                "email": _emailController.text.trim(),
                "message": state.message,
              },
            );
          }
        },

        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                const Color(0xFF0F172A),
                const Color(0xFF1E293B),
                const Color(0xFF020617),
              ]
                  : [
                Colors.white,
                Colors.blue.shade50,
                Colors.white,
              ],
            ),
          ),

          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),

              child: Form(
                key: _formKey,

                child: Column(
                  children: [

                    const SizedBox(height: 40),

                    _buildHeader(isDark),

                    const SizedBox(height: 60),

                    _buildTextField(
                      controller: _emailController,
                      hint: "Enter Registered Email",
                      icon: Icons.email_outlined,
                      isDark: isDark,
                      validator: (val) =>
                      val!.isEmpty ? "Email is required" : null,
                    ),

                    const SizedBox(height: 40),

                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {

                        // ❗ FIXED ACTION NAME
                        final isLoading =
                            state is AuthLoading &&
                                state.action == AuthAction.forgot;

                        return _buildButton(
                          isLoading: isLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {

                              // ✅ SEND OTP EVENT
                              context.read<AuthBloc>().add(
                                ForgotPasswordRequested(
                                  _emailController.text.trim(),
                                ),
                              );
                            }
                          },
                          text: "SEND OTP",
                        );
                      },
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI (UNCHANGED) ----------------

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            size: 70,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 25),
        Text(
          "Forgot Password?",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Enter your email to receive OTP code",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildButton({
    required bool isLoading,
    required VoidCallback onPressed,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            const Color(0xFF6366F1),
          ],
        ),
      ),
      child: MaterialButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}