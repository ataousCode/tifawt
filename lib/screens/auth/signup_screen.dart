// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      Helpers.showErrorSnackBar(
        context,
        'Please agree to the Terms of Service and Privacy Policy',
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signUpWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    if (success && mounted) {
      Helpers.showSuccessSnackBar(context, AppConstants.signupSuccessMessage);
      Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
    } else if (mounted && authProvider.error != null) {
      Helpers.showErrorSnackBar(context, authProvider.error!);
    }
  }

  Future<void> _signupWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
    } else if (mounted && authProvider.error != null) {
      Helpers.showErrorSnackBar(context, authProvider.error!);
    }
  }

  Future<void> _signupWithApple() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithApple();

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
    } else if (mounted && authProvider.error != null) {
      Helpers.showErrorSnackBar(context, authProvider.error!);
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    //final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ThemeConstants.primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(color: ThemeConstants.primaryColor),
            ),

            // Signup form
            SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeConstants.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  // App logo
                  Icon(Icons.menu_book, size: 60, color: Colors.white)
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack)
                      .fade(duration: 600.ms),

                  const SizedBox(height: ThemeConstants.smallPadding),

                  // App name and tagline
                  Text(
                        'Join ${AppConstants.appName}',
                        style: ThemeConstants.headlineStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .slideY(
                        duration: 500.ms,
                        begin: 0.5,
                        curve: Curves.easeOutQuad,
                      )
                      .fade(duration: 500.ms),

                  const SizedBox(height: 10),

                  // Signup card
                  Card(
                        elevation: ThemeConstants.mediumElevation,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ThemeConstants.largeRadius,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            ThemeConstants.largePadding,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Account',
                                  style: ThemeConstants.titleStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: ThemeConstants.largePadding,
                                ),

                                // Name field
                                TextFormField(
                                  controller: _nameController,
                                  keyboardType: TextInputType.name,
                                  decoration: const InputDecoration(
                                    hintText: 'Full Name',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: Validators.validateName,
                                ),

                                const SizedBox(
                                  height: ThemeConstants.mediumPadding,
                                ),

                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    hintText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  validator: Validators.validateEmail,
                                ),

                                const SizedBox(
                                  height: ThemeConstants.mediumPadding,
                                ),

                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: Validators.validatePassword,
                                ),

                                const SizedBox(
                                  height: ThemeConstants.mediumPadding,
                                ),

                                // Confirm password field
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    hintText: 'Confirm Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator:
                                      (value) =>
                                          Validators.validateConfirmPassword(
                                            value,
                                            _passwordController.text,
                                          ),
                                ),

                                const SizedBox(
                                  height: ThemeConstants.mediumPadding,
                                ),

                                // Terms and conditions
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _agreeToTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _agreeToTerms = value!;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        'I agree to the Terms of Service and Privacy Policy',
                                        style: ThemeConstants.captionStyle,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: ThemeConstants.mediumPadding,
                                ),

                                // Signup button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        authProvider.loading ? null : _signup,
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
                                            : const Text('Sign Up'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .slideY(
                        duration: 600.ms,
                        begin: 0.3,
                        curve: Curves.easeOutQuad,
                      )
                      .fade(duration: 600.ms),

                  // const SizedBox(height: ThemeConstants.largePadding),

                  // // Social signup
                  // Text(
                  //   'Or sign up with',
                  //   style: ThemeConstants.bodyStyle.copyWith(
                  //     color: Colors.white,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  const SizedBox(height: ThemeConstants.mediumPadding),

                  // Social signup buttons
                  // Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         // Google button
                  //         ElevatedButton.icon(
                  //           onPressed:
                  //               authProvider.loading ? null : _signupWithGoogle,
                  //           icon: Image.asset(
                  //             'assets/icons/google.png',
                  //             height: 14,
                  //           ),
                  //           label: const Text('Google'),
                  //           style: ElevatedButton.styleFrom(
                  //             backgroundColor: Colors.white,
                  //             foregroundColor: Colors.black,
                  //           ),
                  //         ),

                  //         const SizedBox(width: ThemeConstants.mediumPadding),

                  //         // Apple button
                  //         ElevatedButton.icon(
                  //           onPressed:
                  //               authProvider.loading ? null : _signupWithApple,
                  //           icon: Icon(
                  //             Icons.apple,
                  //             color: isDarkMode ? Colors.white : Colors.black,
                  //           ),
                  //           label: const Text('Apple'),
                  //           style: ElevatedButton.styleFrom(
                  //             backgroundColor:
                  //                 isDarkMode ? Colors.black : Colors.white,
                  //             foregroundColor:
                  //                 isDarkMode ? Colors.white : Colors.black,
                  //           ),
                  //         ),
                  //       ],
                  //     )
                  //.animate()
                  // .slideY(
                  //   duration: 700.ms,
                  //   begin: 0.3,
                  //   curve: Curves.easeOutQuad,
                  // )
                  // .fade(duration: 700.ms),
                  const SizedBox(height: ThemeConstants.smallElevation),

                  // Login
                  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: ThemeConstants.bodyStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToLogin,
                            child: Text(
                              'Sign In',
                              style: ThemeConstants.bodyStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .slideY(
                        duration: 800.ms,
                        begin: 0.3,
                        curve: Curves.easeOutQuad,
                      )
                      .fade(duration: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
