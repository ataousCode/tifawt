// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_app_bar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _passwordStrength = 'None';
  double _strengthValue = 0.0;
  Color _strengthColor = Colors.grey;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 'None';
        _strengthValue = 0.0;
        _strengthColor = Colors.grey;
      });
      return;
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (password.length >= 8) strength++;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigit) strength++;
    if (hasSpecialChar) strength++;

    setState(() {
      switch (strength) {
        case 0:
        case 1:
          _passwordStrength = 'Weak';
          _strengthValue = 0.2;
          _strengthColor = Colors.red;
          break;
        case 2:
        case 3:
          _passwordStrength = 'Medium';
          _strengthValue = 0.5;
          _strengthColor = Colors.orange;
          break;
        case 4:
        case 5:
          _passwordStrength = 'Strong';
          _strengthValue = 1.0;
          _strengthColor = Colors.green;
          break;
        default:
          _passwordStrength = 'None';
          _strengthValue = 0.0;
          _strengthColor = Colors.grey;
      }
    });
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (success && mounted) {
        Helpers.showSuccessDialog(
          context: context,
          title: 'Password Changed',
          message: 'Your password has been successfully changed.',
          onDismiss: () {
            Navigator.of(context).pop();
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
          context,
          'Failed to change password: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212330),
      appBar: const CustomAppBar(title: 'Change Password'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lock icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: ThemeConstants.primaryColor,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Update Your Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Choose a strong password that will be hard for others to guess',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Current password
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Password',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrentPassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your current password',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2C2C3B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrentPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: ThemeConstants.primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                    ),
                    validator: Validators.validatePassword,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // New password
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Password',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your new password',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2C2C3B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: ThemeConstants.primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                    ),
                    validator: Validators.validatePassword,
                    onChanged: _checkPasswordStrength,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Confirm new password
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm New Password',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Confirm your new password',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2C2C3B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: ThemeConstants.primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator:
                        (value) => Validators.validateConfirmPassword(
                          value,
                          _newPasswordController.text,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Password strength indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Password Strength: $_passwordStrength',
                    style: TextStyle(color: _strengthColor, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Progress bar
              LinearProgressIndicator(
                value: _strengthValue,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
              ),

              const SizedBox(height: 40),

              // Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Update Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
