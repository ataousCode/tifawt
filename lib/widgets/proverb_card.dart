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
        height: 400, // Increased height for better visual impact
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConstants.largeRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ThemeConstants.largeRadius),
          child: Stack(
            fit: StackFit.expand, // Make stack fill the entire container
            children: [
              // Background image - now fills the entire card
              CachedNetworkImage(
                imageUrl: proverb.backgroundImageUrl,
                fit: BoxFit.cover, // Cover the entire card area
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              // Enhanced gradient overlay for better text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Content - positioned to fill the entire card
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(ThemeConstants.largePadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Proverb text with enhanced styling
                      Text(
                        proverb.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              blurRadius: 15.0,
                              color: Colors.black,
                              offset: Offset(2.0, 2.0),
                            ),
                            Shadow(
                              blurRadius: 5.0,
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: ThemeConstants.largePadding),

                      // Author with enhanced styling
                      Text(
                        '— ${proverb.author}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
