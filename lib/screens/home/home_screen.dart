import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/proverb.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/proverb_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/category_item.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/proverb_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBottomNavIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Load initial data
  Future<void> _loadData() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final proverbProvider = Provider.of<ProverbProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // First, load all proverbs regardless of category (pass null to load all)
    await proverbProvider.loadProverbsByCategory(null);

    // Then, if there's a selected category, filter to that category
    if (categoryProvider.selectedCategory != null) {
      await proverbProvider.loadProverbsByCategory(
        categoryProvider.selectedCategory!.id,
      );
    }

    if (authProvider.isAuthenticated) {
      proverbProvider.loadFavoriteProverbs(authProvider.user!.uid);
      proverbProvider.loadBookmarkedProverbs(authProvider.user!.uid);
    }
  }
  // Future<void> _loadData() async {
  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //   final categoryProvider = Provider.of<CategoryProvider>(
  //     context,
  //     listen: false,
  //   );
  //   final proverbProvider = Provider.of<ProverbProvider>(
  //     context,
  //     listen: false,
  //   );

  //   if (categoryProvider.selectedCategory != null) {
  //     proverbProvider.loadProverbsByCategory(
  //       categoryProvider.selectedCategory!.id,
  //     );
  //   }

  //   if (authProvider.isAuthenticated) {
  //     proverbProvider.loadFavoriteProverbs(authProvider.user!.uid);
  //     proverbProvider.loadBookmarkedProverbs(authProvider.user!.uid);
  //   }
  // }

  // Handle bottom navigation bar tap
  void _onBottomNavTap(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (index == AppConstants.profileNavIndex &&
        !authProvider.isAuthenticated) {
      Helpers.showSnackBar(
        context,
        'Please login to access profile',
        isError: true,
      );

      Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
      return;
    }

    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case AppConstants.homeNavIndex:
        // We're already on the home screen
        break;
      case AppConstants.favoritesNavIndex:
        Navigator.of(context).pushNamed(AppConstants.favoritesRoute);
        break;
      case AppConstants.bookmarksNavIndex:
        Navigator.of(context).pushNamed(AppConstants.bookmarksRoute);
        break;
      case AppConstants.profileNavIndex:
        if (authProvider.isAdmin) {
          Navigator.of(context).pushNamed(AppConstants.adminDashboardRoute);
        } else {
          Navigator.of(context).pushNamed(AppConstants.profileRoute);
        }
        break;
    }
  }

  // Handle category selection
  void _onCategorySelected(Category category) {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final proverbProvider = Provider.of<ProverbProvider>(
      context,
      listen: false,
    );

    categoryProvider.selectCategory(category.id);
    proverbProvider.loadProverbsByCategory(category.id);
  }

  // Navigate to proverb details
  void _navigateToProverbDetails(Proverb proverb) {
    Navigator.of(context).pushNamed(
      AppConstants.proverbDetailsRoute,
      arguments: {'proverbId': proverb.id},
    );
  }

  // Mark proverb as read
  Future<void> _markProverbAsRead(Proverb proverb) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final proverbProvider = Provider.of<ProverbProvider>(
      context,
      listen: false,
    );

    if (authProvider.isAuthenticated) {
      await proverbProvider.markProverbAsRead(
        authProvider.user!.uid,
        proverb.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final proverbProvider = Provider.of<ProverbProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppConstants.appName,
        showBackButton: false,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () {
          //     Helpers.showSnackBar(context, 'Search coming soon!');
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force reload all proverbs
              final proverbProvider = Provider.of<ProverbProvider>(
                context,
                listen: false,
              );
              final categoryProvider = Provider.of<CategoryProvider>(
                context,
                listen: false,
              );

              // First load all proverbs
              proverbProvider.loadProverbsByCategory(null);

              // Then load for current category if one is selected
              if (categoryProvider.selectedCategory != null) {
                proverbProvider.loadProverbsByCategory(
                  categoryProvider.selectedCategory!.id,
                );
              }

              Helpers.showSnackBar(context, 'Proverbs refreshed');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed(AppConstants.settingsRoute);
            },
          ),
          //! Reset later if needed
        ],
      ),
      body: Column(
        children: [
          // Categories horizontal list
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(
              vertical: ThemeConstants.smallPadding,
            ),
            child:
                categoryProvider.loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryProvider.categories.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.mediumPadding,
                      ),
                      itemBuilder: (context, index) {
                        final category = categoryProvider.categories[index];
                        final isSelected =
                            categoryProvider.selectedCategory?.id ==
                            category.id;

                        return CategoryItem(
                          category: category,
                          isSelected: isSelected,
                          onTap: () => _onCategorySelected(category),
                        );
                      },
                    ),
          ),

          // Proverbs PageView
          Expanded(
            child:
                proverbProvider.loading
                    ? const LoadingIndicator(message: 'Loading proverbs...')
                    : proverbProvider.proverbs.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.menu_book,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: ThemeConstants.mediumPadding),
                          Text(
                            'No proverbs found',
                            style: ThemeConstants.titleStyle.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: ThemeConstants.smallPadding),
                          ElevatedButton(
                            onPressed: () {
                              final categoryProvider =
                                  Provider.of<CategoryProvider>(
                                    context,
                                    listen: false,
                                  );

                              if (categoryProvider.categories.isNotEmpty) {
                                categoryProvider.selectCategory(
                                  categoryProvider.categories.first.id,
                                );
                                proverbProvider.loadProverbsByCategory(
                                  categoryProvider.categories.first.id,
                                );
                              }
                            },
                            child: const Text('Try another category'),
                          ),
                        ],
                      ),
                    )
                    : PageView.builder(
                      controller: _pageController,
                      itemCount: proverbProvider.proverbs.length,
                      onPageChanged: (index) {
                        proverbProvider.goToProverbByIndex(index);

                        // Mark proverb as read when page changes
                        _markProverbAsRead(proverbProvider.proverbs[index]);
                      },
                      itemBuilder: (context, index) {
                        final proverb = proverbProvider.proverbs[index];

                        return ProverbCard(
                          proverb: proverb,
                          onTap: () => _navigateToProverbDetails(proverb),
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
