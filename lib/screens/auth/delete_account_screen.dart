// ignore_for_file: deprecated_member_use, use_super_parameters

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeToDelete = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_emailController.text.trim() != authProvider.userModel?.email) {
      Helpers.showErrorSnackBar(
        context,
        'Email does not match your account email',
      );
      return;
    }

    if (!_agreeToDelete) {
      Helpers.showErrorSnackBar(
        context,
        'Please confirm that you understand this action is permanent',
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await authProvider.deleteAccount(
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppConstants.loginRoute, (route) => false);

        Helpers.showSuccessSnackBar(context, 'Your account has been deleted');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
          context,
          'Failed to delete account: ${e.toString()}',
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
      appBar: const CustomAppBar(title: 'Delete Account'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Warning icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 60,
                ),
              ),

              const SizedBox(height: 24),

              // Warning title
              Text(
                'Delete Your Account?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 16),

              // Warning message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C3B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'This action cannot be undone. This will permanently delete:',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Profile information
                    _buildDeleteItem(Icons.person, 'Your profile information'),

                    // Profile picture
                    _buildDeleteItem(Icons.image, 'Your profile picture'),

                    // Preferences
                    _buildDeleteItem(
                      Icons.settings,
                      'All your preferences and settings',
                    ),

                    // Activity history
                    _buildDeleteItem(Icons.history, 'Your activity history'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Confirm email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm your email',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your email address',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2C2C3B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Confirm password
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm your password',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2C2C3B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: ThemeConstants.primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Checkbox agreement
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeToDelete,
                      onChanged: (value) {
                        setState(() {
                          _agreeToDelete = value ?? false;
                        });
                      },
                      activeColor: ThemeConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'I understand that this action is permanent and cannot be undone',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Delete button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _deleteAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Delete My Account',
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

  Widget _buildDeleteItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 24),
          const SizedBox(width: 16),
          Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
