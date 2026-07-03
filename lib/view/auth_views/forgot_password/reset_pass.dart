import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/configs/routes/routes_name.dart';

import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../bloc/auth_bloc/auth_event.dart';
import '../../../bloc/auth_bloc/auth_state.dart';
import '../../../configs/color/color.dart';
import '../../../utils/extensions/flush_bar_extension.dart';

class ResetPasswordScreen extends StatefulWidget {

  // ⭐ IMPORTANT: OTP FLOW DATA
  final String email;
  final String otp;
  final String? message;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
    this.message,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isObscureNew = true;
  bool _isObscureConfirm = true;

  @override
  void initState() {
    super.initState();

    if (widget.message != null) {
      Future.microtask(() {
        context.flushBarSuccessMessage(message: widget.message!);
      });
    }
  }

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

          // ✅ SUCCESS RESET PASSWORD
          if (state is AuthSuccess) {

            context.flushBarSuccessMessage(
              message: "Password updated successfully",
            );

            // 🔥 GO TO LOGIN SCREEN
            Navigator.pushReplacementNamed(context, RoutesName.passwordSuccess);
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

                    _passField(
                      controller: _newPassController,
                      hint: "New Password",
                      isDark: isDark,
                      isObscure: _isObscureNew,
                      onToggle: () {
                        setState(() {
                          _isObscureNew = !_isObscureNew;
                        });
                      },
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return "Password too short";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    _passField(
                      controller: _confirmPassController,
                      hint: "Confirm Password",
                      isDark: isDark,
                      isObscure: _isObscureConfirm,
                      onToggle: () {
                        setState(() {
                          _isObscureConfirm = !_isObscureConfirm;
                        });
                      },
                      validator: (val) {
                        if (val != _newPassController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),

                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {

                        // ⭐ FIXED ACTION NAME
                        final isLoading =
                            state is AuthLoading &&
                                state.action == AuthAction.resetPassword;

                        return _button(
                          isLoading: isLoading,

                          onPressed: () {

                            if (_formKey.currentState!.validate()) {

                              // 🔥 FINAL RESET EVENT
                              context.read<AuthBloc>().add(
                                ResetPasswordRequested(
                                  email: widget.email,
                                  otp: widget.otp,
                                  newPassword: _newPassController.text.trim(),
                                ),
                              );
                            }
                          },

                          text: "UPDATE PASSWORD",
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
        Icon(
          Icons.lock_open_rounded,
          size: 70,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(height: 25),
        Text(
          "Secure Account",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const Text(
          "Set a strong new password",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _passField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required bool isObscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primaryBlue),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _button({
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