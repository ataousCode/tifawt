// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/proverb.dart';
import '../../providers/auth_provider.dart';
import '../../providers/proverb_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();

    // Load bookmarks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookmarks();
    });
  }

  // Load bookmarked proverbs
  Future<void> _loadBookmarks() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final proverbProvider = Provider.of<ProverbProvider>(
      context,
      listen: false,
    );

    if (authProvider.isAuthenticated) {
      await proverbProvider.loadBookmarkedProverbs(authProvider.user!.uid);
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
        appBar: const CustomAppBar(title: 'Bookmarks'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
              const SizedBox(height: ThemeConstants.mediumPadding),
              const Text(
                'You need to be logged in to view bookmarks',
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
      appBar: const CustomAppBar(title: 'Bookmarks'),
      body: RefreshIndicator(
        onRefresh: _loadBookmarks,
        child:
            proverbProvider.loading
                ? const LoadingIndicator(message: 'Loading bookmarks...')
                : proverbProvider.bookmarkedProverbs.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bookmark_border,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: ThemeConstants.mediumPadding),
                      const Text(
                        'No bookmarks yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: ThemeConstants.smallPadding),
                      const Text(
                        'Add proverbs to your bookmarks\nby tapping the bookmark icon',
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
                : ListView.builder(
                  padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                  itemCount: proverbProvider.bookmarkedProverbs.length,
                  itemBuilder: (context, index) {
                    final proverb = proverbProvider.bookmarkedProverbs[index];

                    return BookmarkProverbCard(
                      proverb: proverb,
                      onTap: () => _navigateToProverbDetails(proverb),
                      onToggleBookmark: () async {
                        final success = await proverbProvider
                            .toggleBookmarkProverb(
                              authProvider.user!.uid,
                              proverb.id,
                            );

                        if (success && mounted) {
                          Helpers.showSnackBar(
                            context,
                            'Removed from bookmarks',
                          );
                        }
                      },
                    );
                  },
                ),
      ),
    );
  }
}

// Customized card for bookmarks screen
class BookmarkProverbCard extends StatelessWidget {
  final Proverb proverb;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;

  const BookmarkProverbCard({
    super.key,
    required this.proverb,
    required this.onTap,
    required this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: ThemeConstants.mediumPadding),
      elevation: ThemeConstants.smallElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
        child: Row(
          children: [
            // Proverb image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(ThemeConstants.mediumRadius),
                bottomLeft: Radius.circular(ThemeConstants.mediumRadius),
              ),
              child: CachedNetworkImage(
                imageUrl: proverb.backgroundImageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300],
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
              ),
            ),

            // Proverb content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Helpers.truncateText(proverb.text, 100),
                      style: ThemeConstants.subtitleStyle.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
            ),

            // Bookmark button
            IconButton(
              icon: const Icon(
                Icons.bookmark,
                color: ThemeConstants.primaryColor,
              ),
              onPressed: onToggleBookmark,
            ),
          ],
        ),
      ),
    );
  }
}
