import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../bloc/auth_bloc/auth_event.dart';
import '../../../bloc/auth_bloc/auth_state.dart';
import '../../../configs/color/color.dart';
import '../../../configs/routes/routes_name.dart';
import '../../../utils/extensions/flush_bar_extension.dart';
import '../../NavigationBar/Navigation.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            context.flushBarErrorMessage(message: state.message);
          }

          if (state is AuthSuccess) {
            context.flushBarSuccessMessage(message: state.message);
            Navigator.pushNamedAndRemoveUntil(
              context,
              RoutesName.navBar,
                  (route) => false,
              arguments: state.message, // ✅ ONLY PASS MESSAGE
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
                  ? [const Color(0xFF0F172A), const Color(0xFF1E293B), const Color(0xFF020617)]
                  : [Colors.white, Colors.blue.shade50, Colors.white],
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
                    const SizedBox(height: 60),
                    _buildHeader(isDark),
                    const SizedBox(height: 50),
                    _interactiveTextField(
                      controller: _emailController,
                      hint: "Email Address",
                      icon: Icons.email_outlined,
                      isDark: isDark,
                      validator: (val) => val!.isEmpty ? "Email is required" : null,
                    ),
                    const SizedBox(height: 20),
                    _interactiveTextField(
                      controller: _passwordController,
                      hint: "Password",
                      icon: Icons.lock_outline,
                      isDark: isDark,
                      isPassword: true,
                      validator: (val) => val!.length < 6 ? "Password too short" : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, RoutesName.forgotPassword);
                        },
                        child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Login Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading =
                          state is AuthLoading && state.action == AuthAction.login;

                      return _buildLoginButton(isLoading, isDark);
                    },
                  ),

                    const SizedBox(height: 30),
                    _buildDivider(isDark),
                    const SizedBox(height: 25),

                    // Interactive Google Login Button (Full Width)
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading =
                          state is AuthLoading && state.action == AuthAction.google;

                      return _buildGoogleButton(isLoading, isDark);
                    },
                  ),

                    const SizedBox(height: 12),
                    _buildSignupPrompt(isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- New Interactive Google Button ---
  Widget _buildGoogleButton(bool isLoading, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade300,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                )
                    : Image.asset("assets/icons/google.png", height: 24),
                const SizedBox(width: 15),
                Text(
                  isLoading ? "Connecting..." : "Continue with Google",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Reusable Components ---

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: [
              if (isDark) BoxShadow(color: AppColors.primaryBlue.withOpacity(0.1), blurRadius: 20)
            ],
          ),
          child: Icon(Icons.lock_person_rounded, size: 60, color: AppColors.primaryBlue),
        ),
        const SizedBox(height: 25),
        Text("Welcome Back",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const Text("Login to your existing account", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _interactiveTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _isObscure : false,
        validator: validator,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          suffixIcon: isPassword
              ? IconButton(
              icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _isObscure = !_isObscure))
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading, bool isDark) {
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: MaterialButton(
        onPressed: isLoading
            ? null
            : () {
          if (_formKey.currentState!.validate()) {

            context.read<AuthBloc>().add(
              LoginRequested(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              ),
            );

          }
        },
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          "LOG IN",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.grey.shade300)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text("Or", style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider(color: isDark ? Colors.white10 : Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildSignupPrompt(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, RoutesName.signup),
          child: const Text("Sign Up", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        ),
      ],
    );
  }
}