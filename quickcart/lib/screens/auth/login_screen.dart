import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/gradient_background.dart';
import '../home/home_shell.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

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
                          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome Back!', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
                            Text('Sign in to continue shopping...', style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
                            SizedBox(height: 18.h),
                            _AuthField(hint: 'Enter your email...', icon: Icons.email_outlined),
                            SizedBox(height: 12.h),
                            _AuthField(hint: 'Enter your password...', icon: Icons.lock_outline, obscure: true),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text('Forgot password?', style: TextStyle(color: AppColors.accent, fontSize: 11.sp, fontWeight: FontWeight.w800)),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: AppColors.accent, padding: EdgeInsets.symmetric(vertical: 14.h)),
                                onPressed: () => Navigator.pushReplacementNamed(context, HomeShell.routeName),
                                child: const Text('Sign In'),
                              ),
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () {},
                                child: Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
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
  const _AuthField({required this.hint, required this.icon, this.obscure = false});

  final String hint;
  final IconData icon;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white60, fontSize: 12.sp),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.r), borderSide: BorderSide.none),
      ),
    );
  }
}
