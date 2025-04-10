// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      setState(() {
        _appVersion = packageInfo.version;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _appVersion = AppConstants.appVersion;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_loading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading settings...'),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
        children: [
          // Appearance section
          _buildSectionHeader('Appearance'),
          _buildSettingItem(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            trailing: Switch(
              value: themeProvider.darkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeColor: ThemeConstants.primaryColor,
            ),
          ),

          const Divider(),

          // Notification section
          _buildSectionHeader('Notifications'),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Push Notifications',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                //Implement push notifications toggle
              },
              activeColor: ThemeConstants.primaryColor,
            ),
          ),
          _buildSettingItem(
            icon: Icons.email,
            title: 'Email Notifications',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                //Implement email notifications toggle
              },
              activeColor: ThemeConstants.primaryColor,
            ),
          ),

          const Divider(),

          // Account section
          if (authProvider.isAuthenticated) ...[
            _buildSectionHeader('Account'),
            _buildSettingItem(
              icon: Icons.person,
              title: 'Edit Profile',
              onTap: () {
                Navigator.of(context).pushNamed(AppConstants.profileRoute);
              },
            ),
            _buildSettingItem(
              icon: Icons.logout,
              title: 'Logout',
              titleColor: Colors.red,
              onTap: () async {
                await authProvider.signOut();

                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppConstants.loginRoute);
                }
              },
            ),

            const Divider(),
          ],

          // About section
          _buildSectionHeader('About'),

          _buildSettingItem(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () {
              Navigator.of(context).pushNamed(AppConstants.termsServiceRoute);
            },
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {
              Navigator.of(context).pushNamed(AppConstants.privacyPolicyRoute);
            },
          ),
          _buildSettingItem(
            icon: Icons.star,
            title: 'Rate App',
            onTap: () {
              Navigator.of(context).pushNamed(AppConstants.rateAppRoute);
            },
          ),
          _buildSettingItem(
            icon: Icons.feedback,
            title: 'Send Feedback',
            onTap: () {
              Navigator.of(context).pushNamed(AppConstants.feedbackRoute);
            },
          ),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () {
              Navigator.of(context).pushNamed(AppConstants.helpCenterRoute);
            },
          ),
          _buildSettingItem(
            icon: Icons.info,
            title: 'Version',
            trailing: Text(
              _appVersion,
              style: ThemeConstants.bodyStyle.copyWith(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: ThemeConstants.mediumPadding,
        bottom: ThemeConstants.smallPadding,
      ),
      child: Text(
        title,
        style: ThemeConstants.subtitleStyle.copyWith(
          color: ThemeConstants.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? ThemeConstants.primaryColor),
      title: Text(
        title,
        style: ThemeConstants.bodyStyle.copyWith(color: titleColor),
      ),
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
