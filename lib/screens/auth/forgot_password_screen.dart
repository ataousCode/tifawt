import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.resetPassword(
      _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _isEmailSent = true;
      });

      Helpers.showSuccessSnackBar(
        context,
        AppConstants.resetPasswordSuccessMessage,
      );
    } else if (mounted && authProvider.error != null) {
      Helpers.showErrorSnackBar(context, authProvider.error!);
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      // appBar: AppBar(title: const Text('Reset Password'), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.largePadding),
          child: Column(
            children: [
              // Success view
              if (_isEmailSent) ...[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 100,
                          )
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.easeOutBack)
                          .fade(duration: 600.ms),

                      const SizedBox(height: ThemeConstants.largePadding),

                      Text(
                            'Email Sent!',
                            style: ThemeConstants.titleStyle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          .animate()
                          .slideY(
                            duration: 500.ms,
                            begin: 0.5,
                            curve: Curves.easeOutQuad,
                          )
                          .fade(duration: 500.ms),

                      const SizedBox(height: ThemeConstants.mediumPadding),

                      Text(
                            'Please check your email for instructions to reset your password.',
                            style: ThemeConstants.bodyStyle,
                            textAlign: TextAlign.center,
                          )
                          .animate()
                          .slideY(
                            duration: 600.ms,
                            begin: 0.5,
                            curve: Curves.easeOutQuad,
                          )
                          .fade(duration: 600.ms),

                      const SizedBox(height: ThemeConstants.extraLargePadding),

                      ElevatedButton(
                            onPressed: _navigateToLogin,
                            child: const Text('Back to Login'),
                          )
                          .animate()
                          .slideY(
                            duration: 700.ms,
                            begin: 0.5,
                            curve: Curves.easeOutQuad,
                          )
                          .fade(duration: 700.ms),
                    ],
                  ),
                ),
              ] else ...[
                // Reset password form
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                            Icons.lock_reset,
                            size: 80,
                            color: ThemeConstants.primaryColor,
                          )
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.easeOutBack)
                          .fade(duration: 600.ms),

                      const SizedBox(height: ThemeConstants.largePadding),

                      Text(
                            'Forgot Password?',
                            style: ThemeConstants.titleStyle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          .animate()
                          .slideY(
                            duration: 500.ms,
                            begin: 0.5,
                            curve: Curves.easeOutQuad,
                          )
                          .fade(duration: 500.ms),

                      const SizedBox(height: ThemeConstants.smallPadding),

                      Text(
                            'Enter your email address and we\'ll send you instructions to reset your password.',
                            style: ThemeConstants.bodyStyle,
                            textAlign: TextAlign.center,
                          )
                          .animate()
                          .slideY(
                            duration: 600.ms,
                            begin: 0.5,
                            curve: Curves.easeOutQuad,
                          )
                          .fade(duration: 600.ms),

                      const SizedBox(height: ThemeConstants.extraLargePadding),

                      Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: Validators.validateEmail,
                            ),
                          )
                          .animate()
                          .slideY(
                            duration: 700.ms,
                            begin: 0.5,
                            curve: Curves.easeOutQuad,
                          )
                          .fade(duration: 700.ms),

                      const SizedBox(height: ThemeConstants.largePadding),

                      SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  authProvider.loading ? null : _resetPassword,
                              child:
                                  authProvider.loading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Text('Send Reset Instructions'),
                            ),
                          )
                          .animate()
                          .slideY(
                            duration: 800.ms,
                            begin: 0.5,
                            curve: Curves.easeOutQuad,
                          )
                          .fade(duration: 800.ms),

                      const SizedBox(height: ThemeConstants.mediumPadding),

                      TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Back to Login'),
                          )
                          .animate()
                          .slideY(
                            duration: 900.ms,
                            begin: 0.5,
                            curve: Curves.easeOutQuad,
                          )
                          .fade(duration: 900.ms),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
