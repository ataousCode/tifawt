import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/proverb_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final proverbProvider = Provider.of<ProverbProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    if (!authProvider.isAuthenticated || !authProvider.isAdmin) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Admin Dashboard'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: ThemeConstants.mediumPadding),
              const Text(
                'Admin access required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: ThemeConstants.smallPadding),
              const Text(
                'You need to be an admin to access this page',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeConstants.mediumPadding),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppConstants.homeRoute);
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Admin Dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin greeting
            const Text(
              'Welcome Admin',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: ThemeConstants.smallPadding),
            const Text(
              'Manage your proverbs and categories',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: ThemeConstants.extraLargePadding),

            // Quick actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.add_circle,
                    title: 'Add Proverb',
                    color: ThemeConstants.primaryColor,
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AppConstants.addProverbRoute);
                    },
                  ),
                ),
                const SizedBox(width: ThemeConstants.mediumPadding),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.category,
                    title: 'Manage Categories',
                    color: ThemeConstants.secondaryColor,
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AppConstants.manageCategoriesRoute);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: ThemeConstants.extraLargePadding),

            // Stats
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.menu_book,
                    title: 'Total Proverbs',
                    value: proverbProvider.proverbs.length.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: ThemeConstants.mediumPadding),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.category,
                    title: 'Categories',
                    value: categoryProvider.categories.length.toString(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: ThemeConstants.extraLargePadding),

            // Management options
            const Text(
              'Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),
            _buildManagementCard(
              icon: Icons.menu_book,
              title: 'Manage Proverbs',
              description: 'Add, edit, or delete proverbs',
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(AppConstants.manageProverbsRoute);
              },
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),
            _buildManagementCard(
              icon: Icons.category,
              title: 'Manage Categories',
              description: 'Create, edit, or remove categories',
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(AppConstants.manageCategoriesRoute);
              },
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),
            _buildManagementCard(
              icon: Icons.people,
              title: 'Manage Users',
              description: 'View and manage user accounts',
              onTap: () {
                Navigator.of(context).pushNamed(AppConstants.manageUsersRoute);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: ThemeConstants.smallElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: ThemeConstants.mediumPadding),
              Text(
                title,
                style: ThemeConstants.subtitleStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: ThemeConstants.smallElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: ThemeConstants.smallPadding),
                Text(title, style: ThemeConstants.captionStyle),
              ],
            ),
            const SizedBox(height: ThemeConstants.mediumPadding),
            Text(
              value,
              style: ThemeConstants.headlineStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: ThemeConstants.smallElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryLightColor,
                  borderRadius: BorderRadius.circular(
                    ThemeConstants.mediumRadius,
                  ),
                ),
                child: Icon(icon, color: ThemeConstants.primaryColor, size: 30),
              ),
              const SizedBox(width: ThemeConstants.mediumPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ThemeConstants.subtitleStyle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: ThemeConstants.captionStyle.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
