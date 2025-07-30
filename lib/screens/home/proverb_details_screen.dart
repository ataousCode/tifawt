// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tifawt/models/category.dart';

import '../../models/proverb.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/proverb_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';

class ProverbDetailsScreen extends StatefulWidget {
  final String? proverbId;

  const ProverbDetailsScreen({super.key, this.proverbId});

  @override
  State<ProverbDetailsScreen> createState() => _ProverbDetailsScreenState();
}

class _ProverbDetailsScreenState extends State<ProverbDetailsScreen> {
  Proverb? _proverb;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProverb();
    });
  }

  Future<void> _loadProverb() async {
    if (widget.proverbId == null) {
      setState(() {
        _loading = false;
        _errorMessage = 'Proverb not found';
      });
      return;
    }

    final proverbProvider = Provider.of<ProverbProvider>(
      context,
      listen: false,
    );

    try {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      final proverb = await proverbProvider.getProverbById(widget.proverbId!);

      if (proverb == null) {
        setState(() {
          _loading = false;
          _errorMessage = 'Proverb not found';
        });
        return;
      }

      setState(() {
        _proverb = proverb;
        _loading = false;
      });

      // Mark proverb as read
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        await proverbProvider.markProverbAsRead(
          authProvider.user!.uid,
          proverb.id,
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to load proverb: ${e.toString()}';
      });
    }
  }

  Widget _buildActions() {
    final authProvider = Provider.of<AuthProvider>(context);
    final proverbProvider = Provider.of<ProverbProvider>(context);

    if (_proverb == null || !authProvider.isAuthenticated) {
      return const SizedBox.shrink();
    }

    final isFavorite = proverbProvider.isProverbFavorite(_proverb!.id);
    final isBookmarked = proverbProvider.isProverbBookmarked(_proverb!.id);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.largePadding,
        vertical: ThemeConstants.mediumPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Favorite button
          Column(
            children: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                  size: 30,
                ),
                onPressed: () async {
                  final success = await proverbProvider.toggleFavoriteProverb(
                    authProvider.user!.uid,
                    _proverb!.id,
                  );

                  if (success && mounted) {
                    String message =
                        isFavorite
                            ? 'Removed from favorites'
                            : 'Added to favorites';

                    Helpers.showSnackBar(context, message);
                  }
                },
              ),
              Text('Favorite', style: ThemeConstants.captionStyle),
            ],
          ),

          // Bookmark button
          Column(
            children: [
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? ThemeConstants.primaryColor : null,
                  size: 30,
                ),
                onPressed: () async {
                  final success = await proverbProvider.toggleBookmarkProverb(
                    authProvider.user!.uid,
                    _proverb!.id,
                  );

                  if (success && mounted) {
                    String message =
                        isBookmarked
                            ? 'Removed from bookmarks'
                            : 'Added to bookmarks';

                    Helpers.showSnackBar(context, message);
                  }
                },
              ),
              Text('Bookmark', style: ThemeConstants.captionStyle),
            ],
          ),

          // Share button
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.share, size: 30),
                onPressed: () {
                  // Implement share functionality
                  Helpers.showSnackBar(
                    context,
                    'Share functionality coming soon!',
                  );
                },
              ),
              Text('Share', style: ThemeConstants.captionStyle),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: '',
        // backgroundColor: Colors.transparent,
        // elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Helpers.showCustomDialog(
                context: context,
                content: Container(
                  padding: const EdgeInsets.all(ThemeConstants.largePadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'About this Proverb',
                        style: ThemeConstants.titleStyle,
                      ),
                      const SizedBox(height: ThemeConstants.mediumPadding),
                      if (_proverb != null) ...[
                        _buildInfoRow('Author', _proverb!.author),
                        const Divider(),
                        _buildInfoRow(
                          'Category',
                          categoryProvider.categories
                              .firstWhere(
                                (c) => c.id == _proverb!.categoryId,
                                orElse: () => Category(id: '', name: 'Unknown'),
                              )
                              .name,
                        ),
                        const Divider(),
                        _buildInfoRow('Views', '${_proverb!.viewCount}'),
                      ],
                      const SizedBox(height: ThemeConstants.largePadding),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body:
          _loading
              ? const LoadingIndicator(message: 'Loading proverb...')
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: ThemeConstants.mediumPadding),
                    Text('Error', style: ThemeConstants.titleStyle),
                    const SizedBox(height: ThemeConstants.smallPadding),
                    Text(
                      _errorMessage!,
                      style: ThemeConstants.bodyStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ThemeConstants.largePadding),
                    ElevatedButton(
                      onPressed: _loadProverb,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _proverb == null
              ? const Center(child: Text('Proverb not found'))
              : Column(
                children: [
                  // Proverb image and content
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image
                        CachedNetworkImage(
                          imageUrl: _proverb!.backgroundImageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) =>
                                  Container(color: Colors.grey[300]),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                        ),

                        // Gradient overlay
                        Container(
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

                        // Proverb content
                        Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(
                              ThemeConstants.largePadding,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Proverb text
                                Text(
                                      _proverb!.text,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
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
                                    )
                                    .animate()
                                    .fadeIn(duration: 800.ms)
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      duration: 800.ms,
                                      curve: Curves.easeOutQuad,
                                    ),

                                const SizedBox(
                                  height: ThemeConstants.largePadding,
                                ),

                                // Author
                                Text(
                                      '- ${_proverb!.author}',
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
                                    )
                                    .animate()
                                    .fadeIn(delay: 300.ms, duration: 800.ms)
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      delay: 300.ms,
                                      duration: 800.ms,
                                      curve: Curves.easeOutQuad,
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  _buildActions(),
                ],
              ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: ThemeConstants.smallPadding,
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: ThemeConstants.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(child: Text(value, style: ThemeConstants.bodyStyle)),
        ],
      ),
    );
  }
}
