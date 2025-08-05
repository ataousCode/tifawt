import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/proverb_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();

    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // Load initial data
  Future<void> _loadData() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    // Load all categories including inactive ones
    categoryProvider.loadCategories(activeOnly: false);
  }

  Future<void> _logout() async {
    await Helpers.logout(context, showConfirmation: true);
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final proverbProvider = Provider.of<ProverbProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.darkMode;

    if (!authProvider.isAuthenticated || !authProvider.isAdmin) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'Admin Access Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You need administrator privileges to access this dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
                },
                icon: const Icon(Icons.home),
                label: const Text('Go to Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Admin Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Section
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Proverbs',
                          proverbProvider.proverbs.length.toString(),
                          Icons.format_quote,
                          ThemeConstants.primaryColor,
                        ).animate().slideX(delay: 200.ms, duration: 600.ms),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Categories',
                          categoryProvider.categories.length.toString(),
                          Icons.category,
                          Colors.orange,
                        ).animate().slideX(delay: 400.ms, duration: 600.ms),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Management Actions
                  const Text(
                    'Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard(
                        'Add Proverb',
                        Icons.add_circle_outline,
                        ThemeConstants.primaryColor,
                        () {
                          Navigator.of(context).pushNamed(
                            AppConstants.addProverbRoute,
                          );
                        },
                      ).animate().scale(delay: 200.ms, duration: 600.ms),
                      _buildActionCard(
                        'Manage Proverbs',
                        Icons.format_quote_outlined,
                        Colors.blue,
                        () {
                          Navigator.of(context).pushNamed(
                            AppConstants.manageProverbsRoute,
                          );
                        },
                      ).animate().scale(delay: 400.ms, duration: 600.ms),
                      _buildActionCard(
                        'Manage Categories',
                        Icons.category_outlined,
                        Colors.orange,
                        () {
                          Navigator.of(context).pushNamed(
                            AppConstants.manageCategoriesRoute,
                          );
                        },
                      ).animate().scale(delay: 600.ms, duration: 600.ms),
                      _buildActionCard(
                        'Manage Users',
                        Icons.people_outline,
                        Colors.green,
                        () {
                          Navigator.of(context).pushNamed(
                            AppConstants.manageUsersRoute,
                          );
                        },
                      ).animate().scale(delay: 800.ms, duration: 600.ms),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
        ),
      ),
    );
  }
}
