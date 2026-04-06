import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/constants/constants.dart';
import '../providers/auth_provider.dart';

/// Forgot Password Screen
/// Allows users to reset their password via email
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success =
        await authProvider.resetPassword(_emailController.text.trim());

    if (mounted) {
      if (success) {
        setState(() => _emailSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  Text(
                    _emailSent ? 'Email Sent!' : 'Forgot Password?',
                    style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Description
                  Text(
                    _emailSent
                        ? 'Check your email for a link to reset your password.'
                        : 'Enter your email address and we\'ll send you a link to reset your password.',
                    style: AppTextStyles.body1
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  if (!_emailSent) ...[
                    // Email Field
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Send Reset Email Button
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => CustomButton(
                        text: 'Send Reset Email',
                        onPressed: _handleResetPassword,
                        isLoading: auth.isLoading,
                      ),
                    ),
                  ] else ...[
                    // Back to Login Button
                    CustomButton(
                      text: 'Back to Login',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      isLoading: false,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  // Back to Login Link
                  if (!_emailSent)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Back to Login'),
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
