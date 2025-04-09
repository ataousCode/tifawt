// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../models/proverb.dart';
import '../../providers/auth_provider.dart';
import '../../providers/proverb_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();

    // Load favorites when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  // Load favorite proverbs
  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final proverbProvider = Provider.of<ProverbProvider>(
      context,
      listen: false,
    );

    if (authProvider.isAuthenticated) {
      await proverbProvider.loadFavoriteProverbs(authProvider.user!.uid);
    }
  }

  // Navigate to proverb details
  void _navigateToProverbDetails(Proverb proverb) {
    Navigator.of(context).pushNamed(
      AppConstants.proverbDetailsRoute,
      arguments: {'proverbId': proverb.id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final proverbProvider = Provider.of<ProverbProvider>(context);

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Favorites'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
              const SizedBox(height: ThemeConstants.mediumPadding),
              const Text(
                'You need to be logged in to view favorites',
                textAlign: TextAlign.center,
              ),
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
      appBar: const CustomAppBar(title: 'Favorites'),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child:
            proverbProvider.loading
                ? const LoadingIndicator(message: 'Loading favorites...')
                : proverbProvider.favoriteProverbs.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: ThemeConstants.mediumPadding),
                      const Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: ThemeConstants.smallPadding),
                      const Text(
                        'Add proverbs to your favorites\nby tapping the heart icon',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: ThemeConstants.mediumPadding),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed(AppConstants.homeRoute);
                        },
                        child: const Text('Explore Proverbs'),
                      ),
                    ],
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Favorite Proverbs',
                        style: ThemeConstants.titleStyle,
                      ),
                      Text(
                        '${proverbProvider.favoriteProverbs.length} proverbs',
                        style: ThemeConstants.captionStyle,
                      ),
                      const SizedBox(height: ThemeConstants.mediumPadding),
                      Expanded(
                        child: MasonryGridView.count(
                          crossAxisCount: 1,
                          mainAxisSpacing: ThemeConstants.mediumPadding,
                          crossAxisSpacing: ThemeConstants.mediumPadding,
                          itemCount: proverbProvider.favoriteProverbs.length,
                          itemBuilder: (context, index) {
                            final proverb =
                                proverbProvider.favoriteProverbs[index];

                            return FavoriteProverbCard(
                              proverb: proverb,
                              onTap: () => _navigateToProverbDetails(proverb),
                              onRemove: () async {
                                final success = await proverbProvider
                                    .toggleFavoriteProverb(
                                      authProvider.user!.uid,
                                      proverb.id,
                                    );

                                if (success && mounted) {
                                  Helpers.showSnackBar(
                                    context,
                                    'Removed from favorites',
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

// Customized card for favorites screen
class FavoriteProverbCard extends StatelessWidget {
  final Proverb proverb;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteProverbCard({
    super.key,
    required this.proverb,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: ThemeConstants.smallElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Proverb content
            Padding(
              padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proverb.text,
                    style: ThemeConstants.subtitleStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.smallPadding),
                  Text(
                    '- ${proverb.author}',
                    style: ThemeConstants.captionStyle.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: onRemove,
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: onTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
