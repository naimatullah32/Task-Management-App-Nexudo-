import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/configs/routes/routes_name.dart';

import 'package:task_management/view/auth_views/forgot_password/reset_pass.dart';
import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../bloc/auth_bloc/auth_event.dart';
import '../../../bloc/auth_bloc/auth_state.dart';
import '../../../configs/color/color.dart';
import '../../../utils/extensions/flush_bar_extension.dart';

class VerifyOTPScreen extends StatefulWidget {

  // ⭐ FIX #1: EMAIL REQUIRED
  final String email;
  final String? message;

  const VerifyOTPScreen({
    super.key,
    required this.email,
    this.message,
  });

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {

  final List<TextEditingController> _otpControllers =
  List.generate(6, (index) => TextEditingController());

  final List<FocusNode> _focusNodes =
  List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.message != null) {
      Future.microtask(() {
        context.flushBarSuccessMessage(message: widget.message!);
      });
    }
  }

  String get _otpCode =>
      _otpControllers.map((e) => e.text).join();

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

          // ❌ ERROR
          if (state is AuthFailure) {
            context.flushBarErrorMessage(message: state.message);
          }

          // ✅ SUCCESS → GO TO RESET PASSWORD
          if (state is AuthSuccess) {
            Navigator.pushNamed(
              context,
              RoutesName.resetPassword,
              arguments: {
                "email": widget.email,
                "otp": _otpCode,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
              
                child: Column(
                  children: [
              
                    const SizedBox(height: 40),
              
                    Icon(
                      Icons.mark_email_read_rounded,
                      size: 70,
                      color: AppColors.primaryBlue,
                    ),
              
                    const SizedBox(height: 25),
              
                    const Text(
                      "Verification",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              
                    const Text(
                      "Enter the 6-digit code sent to your email",
                      style: TextStyle(color: Colors.grey),
                    ),
              
                    const SizedBox(height: 60),
              
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                            (index) => _buildOTPBox(context, index, isDark),
                      ),
                    ),
              
                    const SizedBox(height: 50),
              
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
              
                        final isLoading =
                            state is AuthLoading &&
                                state.action == AuthAction.otpVerify;
              
                        return _buildButton(
                          isLoading: isLoading,
              
                          onPressed: () {
              
                            // ❗ VALIDATION
                            if (_otpCode.length != 6) {
                              context.flushBarErrorMessage(
                                message: "Enter complete 6-digit OTP",
                              );
                              return;
                            }
              
                            // ⭐ FIX #2: SEND EMAIL + OTP
                            context.read<AuthBloc>().add(
                              VerifyOtpRequested(
                                widget.email,
                                _otpCode,
                              ),
                            );
                          },
              
                          text: "VERIFY",
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

  Widget _buildOTPBox(BuildContext context, int index, bool isDark) {
    return Container(
      height: 55,
      width: 46,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.5),
        ),
      ),
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
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