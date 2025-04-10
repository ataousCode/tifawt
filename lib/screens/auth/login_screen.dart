// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
    } else if (mounted && authProvider.error != null) {
      Helpers.showErrorSnackBar(context, authProvider.error!);
    }
  }

  Future<void> _loginWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
    } else if (mounted && authProvider.error != null) {
      Helpers.showErrorSnackBar(context, authProvider.error!);
    }
  }

  Future<void> _loginWithApple() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithApple();

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
    } else if (mounted && authProvider.error != null) {
      Helpers.showErrorSnackBar(context, authProvider.error!);
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).pushNamed(AppConstants.signupRoute);
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).pushNamed(AppConstants.forgotPasswordRoute);
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

            // Login form
            SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeConstants.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // App logo
                  Icon(Icons.menu_book, size: 80, color: Colors.white)
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack)
                      .fade(duration: 600.ms),

                  const SizedBox(height: ThemeConstants.mediumPadding),

                  // App name
                  Text(
                        AppConstants.appName,
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

                  const SizedBox(height: 20),

                  // Login card
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
                                  'Welcome Back',
                                  style: ThemeConstants.titleStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: ThemeConstants.smallPadding,
                                ),

                                Text(
                                  'Sign in to continue',
                                  style: ThemeConstants.bodyStyle.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(
                                  height: ThemeConstants.smallElevation,
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
                                  height: ThemeConstants.smallPadding,
                                ),

                                // Remember me & Forgot password
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value!;
                                            });
                                          },
                                        ),
                                        const Text('Remember'),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: _navigateToForgotPassword,
                                      child: const Text('Forgot'),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: ThemeConstants.mediumPadding,
                                ),

                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        authProvider.loading ? null : _login,
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
                                            : const Text('Sign In'),
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

                  const SizedBox(height: ThemeConstants.smallElevation),

                  // Social login
                  // Text(
                  //   'Or sign in with',
                  //   style: ThemeConstants.bodyStyle.copyWith(
                  //     color: Colors.white,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),

                  // const SizedBox(height: ThemeConstants.mediumPadding),

                  // // Social login buttons
                  // Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         // Google button
                  //         ElevatedButton.icon(
                  //           onPressed:
                  //               authProvider.loading ? null : _loginWithGoogle,
                  //           icon: Image.asset(
                  //             'assets/icons/google.png',
                  //             height: 24,
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
                  //               authProvider.loading ? null : _loginWithApple,
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
                  //     .animate()
                  //     .slideY(
                  //       duration: 700.ms,
                  //       begin: 0.3,
                  //       curve: Curves.easeOutQuad,
                  //     )
                  //     .fade(duration: 700.ms),
                  //const SizedBox(height: ThemeConstants.extraLargePadding),

                  // Sign up
                  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: ThemeConstants.bodyStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToSignUp,
                            child: Text(
                              'Sign Up',
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
