import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/gradient_background.dart';
import '../home/home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final missingName = _isSignUp && name.isEmpty;
    if (email.isEmpty || password.isEmpty || missingName) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSignUp
                ? 'Please enter your name, email, and password.'
                : 'Please enter your email and password.',
          ),
        ),
      );
      return;
    }
    final provider = context.read<AppStateProvider>();
    if (_isSignUp) {
      await provider.register(name: name, email: email, password: password);
    } else {
      await provider.login(email: email, password: password);
    }
    if (!mounted) return;
    if (provider.lastError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.lastError!)));
      return;
    }
    Navigator.pushReplacementNamed(context, HomeShell.routeName);
  }

  void _resetPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter your email first.')));
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Reset'),
        content: Text('A password reset link has been sent to $email.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(compact: true),
                  SizedBox(height: 28.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isSignUp ? 'Create Account!' : 'Welcome Back!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _isSignUp
                                  ? 'Sign up to start shopping...'
                                  : 'Sign in to continue shopping...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(height: 18.h),
                            if (_isSignUp) ...[
                              _AuthField(
                                controller: _nameController,
                                hint: 'Enter your name...',
                                icon: Icons.person_outline,
                              ),
                              SizedBox(height: 12.h),
                            ],
                            _AuthField(
                              controller: _emailController,
                              hint: 'Enter your email...',
                              icon: Icons.email_outlined,
                            ),
                            SizedBox(height: 12.h),
                            _AuthField(
                              controller: _passwordController,
                              hint: 'Enter your password...',
                              icon: Icons.lock_outline,
                              obscure: true,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _resetPassword,
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            Consumer<AppStateProvider>(
                              builder: (context, provider, _) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.accent,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14.h,
                                      ),
                                    ),
                                    onPressed: provider.isBusy ? null : _submit,
                                    child: provider.isBusy
                                        ? SizedBox.square(
                                            dimension: 18.w,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                          )
                                        : Text(
                                            _isSignUp ? 'Sign Up' : 'Sign In',
                                          ),
                                  ),
                                );
                              },
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () =>
                                    setState(() => _isSignUp = !_isSignUp),
                                child: Text(
                                  _isSignUp
                                      ? 'Already have an account? Sign In'
                                      : "Don't have an account? Sign Up",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white60, fontSize: 12.sp),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
