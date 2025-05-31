import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../providers/auth_provider.dart';
import '../theme/theme_constants.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
        //_checkAuthAndNavigate();
      }
    });

    // Add a fallback timer in case Lottie doesn't load correctly
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted && !_hasNavigated) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // void _checkAuthAndNavigate() async {
  //   if (_hasNavigated) return;

  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);

  //   // wait for the auth state to be determined
  //   while(authProvider.status == AuthStatus.uninitialized) {
  //     await Future.delayed(const Duration(milliseconds: 1000));
  //     if (!mounted) return;
  //   }

  //   _navigateToNextScreen();
  // }

  void _navigateToNextScreen() {
    if (_hasNavigated) return;

    setState(() {
      _hasNavigated = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.status == AuthStatus.authenticated) {
      Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
    } else {
      // Either unauthenticated or still initializing - navigate to login
      Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Auto-navigate when auth stats is determined
        if (!_hasNavigated && authProvider.status != AuthStatus.uninitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToNextScreen();
          });
        }

        return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/splash.json',
              width: 200,
              height: 200,
              controller: _animationController,
              onLoaded: (composition) {
                _animationController.duration = composition.duration;
                _animationController.forward();
              },
            ),

            const SizedBox(height: ThemeConstants.largePadding),

            // App name
            Text(
              AppConstants.appName,
              style: ThemeConstants.headlineStyle.copyWith(
                color: ThemeConstants.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),

            const SizedBox(height: ThemeConstants.mediumPadding),

            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
      },
    );
  }
}
