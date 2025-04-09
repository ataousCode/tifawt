// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../models/proverb.dart';
import '../providers/auth_provider.dart';
import '../providers/proverb_provider.dart';
import '../theme/theme_constants.dart';
import '../utils/helpers.dart';

class ProverbCard extends StatelessWidget {
  final Proverb proverb;
  final VoidCallback? onTap;
  final bool showActions;

  const ProverbCard({
    super.key,
    required this.proverb,
    this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final proverbProvider = Provider.of<ProverbProvider>(context);

    final isFavorite = proverbProvider.isProverbFavorite(proverb.id);
    final isBookmarked = proverbProvider.isProverbBookmarked(proverb.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.mediumPadding,
          vertical: ThemeConstants.smallPadding,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConstants.largeRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ThemeConstants.largeRadius),
          child: Stack(
            children: [
              // Background image
              CachedNetworkImage(
                imageUrl: proverb.backgroundImageUrl,
                height: 350,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      height: 350,
                      width: double.infinity,
                      color: Colors.grey[300],
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 350,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
              ),

              // Gradient overlay
              Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),

              // Content
              Container(
                height: 350,
                width: double.infinity,
                padding: const EdgeInsets.all(ThemeConstants.largePadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Proverb text
                    Text(
                      proverb.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: ThemeConstants.mediumPadding),

                    // Author
                    Text(
                      '- ${proverb.author}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Actions
              if (showActions && authProvider.isAuthenticated)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.mediumPadding,
                      vertical: ThemeConstants.smallPadding,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Favorite button
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                          ),
                          onPressed: () async {
                            final success = await proverbProvider
                                .toggleFavoriteProverb(
                                  authProvider.user!.uid,
                                  proverb.id,
                                );

                            if (success) {
                              String message =
                                  isFavorite
                                      ? 'Removed from favorites'
                                      : 'Added to favorites';

                              Helpers.showSnackBar(context, message);
                            }
                          },
                        ),

                        // Bookmark button
                        IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color:
                                isBookmarked
                                    ? ThemeConstants.primaryColor
                                    : Colors.white,
                          ),
                          onPressed: () async {
                            final success = await proverbProvider
                                .toggleBookmarkProverb(
                                  authProvider.user!.uid,
                                  proverb.id,
                                );

                            if (success) {
                              String message =
                                  isBookmarked
                                      ? 'Removed from bookmarks'
                                      : 'Added to bookmarks';

                              Helpers.showSnackBar(context, message);
                            }
                          },
                        ),

                        // Share button
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                            Helpers.showSnackBar(
                              context,
                              'Share functionality coming soon!',
                            );
                          },
                        ),
                      ],
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
