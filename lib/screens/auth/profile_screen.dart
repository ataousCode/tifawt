import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/auth_provider.dart';
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

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(
      text: authProvider.userModel?.displayName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.updateUserProfile(
      displayName: _nameController.text.trim(),
      profileImage: _profileImage,
    );

    if (success && mounted) {
      Helpers.showSuccessSnackBar(
        context,
        AppConstants.profileUpdateSuccessMessage,
      );
    } else if (mounted && authProvider.error != null) {
      Helpers.showErrorSnackBar(context, authProvider.error!);
    }
  }

  void _navigateToChangePassword() {
    Navigator.of(context).pushNamed(AppConstants.changePasswordRoute);
  }

  void _showDeleteAccountDialog() {
    Navigator.of(context).pushNamed(AppConstants.deleteAccountRoute);
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.signOut();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You need to be logged in to access this page'),
              const SizedBox(height: ThemeConstants.mediumPadding),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppConstants.loginRoute);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body:
          authProvider.loading
              ? const LoadingIndicator(message: 'Loading profile...')
              : SingleChildScrollView(
                padding: const EdgeInsets.all(ThemeConstants.largePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile image
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: ThemeConstants.primaryLightColor,
                          backgroundImage:
                              _profileImage != null
                                  ? FileImage(_profileImage!) as ImageProvider
                                  : authProvider.userModel?.photoUrl != null
                                  ? CachedNetworkImageProvider(
                                    authProvider.userModel!.photoUrl!,
                                  )
                                  : null,
                          child:
                              _profileImage == null &&
                                      authProvider.userModel?.photoUrl == null
                                  ? Text(
                                    authProvider.userModel?.displayName
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        'U',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                  : null,
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ThemeConstants.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: ThemeConstants.largePadding),

                    // User email
                    Text(
                      authProvider.userModel?.email ?? 'No email',
                      style: ThemeConstants.subtitleStyle.copyWith(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: ThemeConstants.extraLargePadding),

                    // Profile form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name field
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: ThemeConstants.largePadding),

                          // Update button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  authProvider.loading ? null : _updateProfile,
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
                                      : const Text('Update Profile'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: ThemeConstants.extraLargePadding),

                    // Account actions
                    Card(
                      elevation: ThemeConstants.smallElevation,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ThemeConstants.mediumRadius,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.settings,
                              color: ThemeConstants.primaryColor,
                            ),
                            title: const Text('Settings'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(AppConstants.settingsRoute);
                            },
                          ),
                          const Divider(),
                          // Change password
                          ListTile(
                            leading: const Icon(
                              Icons.lock,
                              color: ThemeConstants.primaryColor,
                            ),
                            title: const Text('Change Password'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _navigateToChangePassword,
                          ),

                          const Divider(),

                          // Delete account
                          ListTile(
                            leading: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            title: const Text(
                              'Delete Account',
                              style: TextStyle(color: Colors.red),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.red,
                            ),
                            onTap: _showDeleteAccountDialog,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: ThemeConstants.largePadding),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
