import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../bloc/auth_bloc/auth_event.dart';
import '../../../bloc/auth_bloc/auth_state.dart';
import '../../../configs/color/color.dart';
import '../../../configs/routes/routes_name.dart';
import '../../../utils/extensions/flush_bar_extension.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            context.flushBarErrorMessage(message: state.message);
          }

          if (state is AuthSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RoutesName.navBar,
                  (route) => false,
              arguments: state.message, // ✅ SAME SYSTEM
            );
          }
        },
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
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
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildAnimatedHeader(isDark),
                    const SizedBox(height: 40),

                    // INPUT FIELDS
                    _buildTextField(
                      _userController,
                      "Full Name",
                      Icons.person_outline,
                      isDark,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      _emailController,
                      "Email Address",
                      Icons.email_outlined,
                      isDark,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      _passController,
                      "Password",
                      Icons.lock_outline,
                      isDark,
                      isPass: true,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      _confirmPassController,
                      "Confirm Password",
                      Icons.lock_reset,
                      isDark,
                      isPass: true,
                      isConfirm: true,
                    ),

                    const SizedBox(height: 35),

                    // SIGN UP BUTTON
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading =
                            state is AuthLoading &&
                                state.action == AuthAction.signup;

                        return _buildEnhancedButton(isLoading);
                      },
                    ),

                    const SizedBox(height: 30),

                    _buildSocialDivider(isDark),
                    const SizedBox(height: 25),

                    // GOOGLE BUTTON
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading =
                            state is AuthLoading &&
                                state.action == AuthAction.google;

                        return _buildGoogleButton(isLoading, isDark);
                      },
                    ),

                    const SizedBox(height: 12),
                    _buildFooter(isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI COMPONENTS ----------------

  Widget _buildAnimatedHeader(bool isDark) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.2),
            ),
            boxShadow: [
              if (isDark)
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  blurRadius: 20,
                ),
            ],
          ),
          child: Icon(
            Icons.person_add_rounded,
            size: 40,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Create Account",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const Text(
          "Join our community today",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon,
      bool isDark, {
        bool isPass = false,
        bool isConfirm = false,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPass ? _isObscure : false,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 22,
          ),
          suffixIcon: isPass
              ? IconButton(
            icon: Icon(
              _isObscure
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _isObscure = !_isObscure),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) {
            return "This field is required";
          }
          if (isConfirm && val != _passController.text) {
            return "Passwords do not match";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEnhancedButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            const Color(0xFF6366F1),
          ],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: isLoading
            ? null
            : () {
          if (_formKey.currentState!.validate()) {
            context.read<AuthBloc>().add(
              SignUpRequested(
                _userController.text.trim(),
                _emailController.text.trim(),
                _passController.text.trim(),
              ),
            );
          }
        },
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(bool isLoading, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : Colors.grey.shade300,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: isLoading
            ? null
            : () {
          context.read<AuthBloc>().add(GoogleLoginRequested());
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.blue,
                ),
              )
                  : Image.asset("assets/icons/google.png", height: 24),
              const SizedBox(width: 15),
              Text(
                isLoading
                    ? "Connecting..."
                    : "Continue with Google",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                  isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark
                ? Colors.white10
                : Colors.grey.shade300,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            "Or register with",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark
                ? Colors.white10
                : Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pushNamed(context, RoutesName.login),
          child: const Text(
            "Login",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ),
      ],
    );
  }
}