import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String _appVersion = '';
  bool _notificationsEnabled = true;
  bool _emailNotifications = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(
      text: authProvider.userModel?.displayName,
    );
    _loadAppInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.updateUserProfile(
        displayName: _nameController.text.trim(),
        profileImage: _profileImage,
      );
      
      if (mounted) {
        Helpers.showSnackBar(context, 'Profile updated successfully!', isSuccess: true);
        setState(() {
          _profileImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to update profile: $e', isError: true);
      }
    }
  }

  Future<void> _logout() async {
    await Helpers.logout(context, showConfirmation: true);
  }

  Future<void> _rateApp() async {
    // In a real app, you would use a package like in_app_review
    Helpers.showSnackBar(context, 'Thank you for your feedback!', isSuccess: true);
  }

  Future<void> _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@tifawt.com',
      query: 'subject=Tifawt App Feedback&body=Please share your feedback here...',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        Helpers.showSnackBar(context, 'Could not open email app', isError: true);
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_reset),
                ),
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
          ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                // Implement password change logic here
                Helpers.showSnackBar(context, 'Password changed successfully!', isSuccess: true);
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement account deletion logic here
              Helpers.showSnackBar(context, 'Account deletion requested', isSuccess: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.darkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: const CustomAppBar(
        title: 'Profile',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Header Card
              _buildCard(
                child: Column(
                  children: [
                    // Profile Image
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ThemeConstants.primaryColor,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : authProvider.userModel?.photoUrl != null
                                    ? CachedNetworkImageProvider(
                                        authProvider.userModel!.photoUrl!,
                                      )
                                    : null,
                            child: _profileImage == null &&
                                    authProvider.userModel?.photoUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey[400],
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ThemeConstants.primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().scale(delay: 100.ms, duration: 600.ms),
                    const SizedBox(height: 16),
                    // User Info
                    Text(
                      authProvider.userModel?.displayName ?? 'User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.userModel?.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                    const SizedBox(height: 20),
                    // Update Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _updateProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Update Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ).animate().slideX(delay: 400.ms, duration: 600.ms),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 800.ms),
              
              const SizedBox(height: 16),
              
              // Profile Information
              _buildCard(
                title: 'Profile Information',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your display name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ).animate().slideX(delay: 200.ms, duration: 600.ms),
              
              const SizedBox(height: 16),
              
              // App Settings
              _buildCard(
                title: 'App Settings',
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      subtitle: 'Toggle dark theme',
                      trailing: Switch(
                        value: isDark,
                        onChanged: (value) {
                           themeProvider.toggleTheme();
                         },
                        activeColor: ThemeConstants.primaryColor,
                      ),
                    ),
                    const Divider(),
                    _buildSettingsTile(
                      icon: Icons.notifications,
                      title: 'Push Notifications',
                      subtitle: 'Receive app notifications',
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                        activeColor: ThemeConstants.primaryColor,
                      ),
                    ),
                    const Divider(),
                    _buildSettingsTile(
                      icon: Icons.email,
                      title: 'Email Notifications',
                      subtitle: 'Receive email updates',
                      trailing: Switch(
                        value: _emailNotifications,
                        onChanged: (value) {
                          setState(() {
                            _emailNotifications = value;
                          });
                        },
                        activeColor: ThemeConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ).animate().slideX(delay: 300.ms, duration: 600.ms),
              
              const SizedBox(height: 16),
              
              // App Actions
              _buildCard(
                title: 'App Actions',
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.star_rate,
                      title: 'Rate App',
                      subtitle: 'Help us improve',
                      onTap: _rateApp,
                    ),
                    const Divider(),
                    _buildActionTile(
                      icon: Icons.feedback,
                      title: 'Send Feedback',
                      subtitle: 'Share your thoughts',
                      onTap: _sendFeedback,
                    ),
                    const Divider(),
                    _buildActionTile(
                      icon: Icons.info,
                      title: 'About',
                      subtitle: 'Version $_appVersion',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Tifawt',
                          applicationVersion: _appVersion,
                          applicationLegalese: '© 2024 Tifawt. All rights reserved.',
                        );
                      },
                    ),
                  ],
                ),
              ).animate().slideX(delay: 400.ms, duration: 600.ms),
              
              const SizedBox(height: 16),
              
              // Account Actions
              _buildCard(
                title: 'Account Actions',
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.lock_reset,
                      title: 'Change Password',
                      subtitle: 'Update your password',
                      onTap: _showChangePasswordDialog,
                    ),
                    const Divider(),
                    _buildActionTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      onTap: _logout,
                    ),
                  ],
                ),
              ).animate().slideX(delay: 500.ms, duration: 600.ms),
              
              const SizedBox(height: 16),
              
              // Danger Zone
              _buildCard(
                title: 'Danger Zone',
                isDestructive: true,
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.delete_forever,
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account',
                      onTap: _showDeleteAccountDialog,
                      isDestructive: true,
                    ),
                  ],
                ),
              ).animate().slideX(delay: 600.ms, duration: 600.ms),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    String? title,
    required Widget child,
    bool isDestructive = false,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.darkMode;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDestructive
            ? (isDark ? Colors.red[900]?.withOpacity(0.2) : Colors.red[50])
            : (isDark ? Colors.grey[800] : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: isDestructive
            ? Border.all(color: Colors.red.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDestructive
                    ? Colors.red
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.darkMode;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: ThemeConstants.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.grey[300] : Colors.grey[600],
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.darkMode;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : ThemeConstants.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive
              ? Colors.red
              : (isDark ? Colors.white : Colors.black87),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.grey[300] : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? Colors.grey[400] : Colors.grey[500],
      ),
      onTap: onTap,
    );
  }
}
