import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/proverb.dart';
import '../../models/category.dart'; // Add this import
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/proverb_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';

class ManageProverbsScreen extends StatefulWidget {
  const ManageProverbsScreen({Key? key}) : super(key: key);

  @override
  State<ManageProverbsScreen> createState() => _ManageProverbsScreenState();
}

class _ManageProverbsScreenState extends State<ManageProverbsScreen> {
  bool _isLoading = true;
  List<Proverb> _proverbs = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load categories
      await Provider.of<CategoryProvider>(
        context,
        listen: false,
      ); //.loadCategories(activeOnly: false);

      // Load proverbs
      await _loadProverbs();
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
          context,
          'Failed to load data: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProverbs() async {
    final proverbProvider = Provider.of<ProverbProvider>(
      context,
      listen: false,
    );
    await proverbProvider.loadProverbsByCategory(_selectedCategoryId);

    if (mounted) {
      setState(() {
        _proverbs = List.from(proverbProvider.proverbs);
        _filterProverbs();
      });
    }
  }

  void _filterProverbs() {
    final proverbProvider = Provider.of<ProverbProvider>(
      context,
      listen: false,
    );
    List<Proverb> filteredProverbs = List.from(proverbProvider.proverbs);

    // Filter by category if selected
    if (_selectedCategoryId != null) {
      filteredProverbs =
          filteredProverbs
              .where((proverb) => proverb.categoryId == _selectedCategoryId)
              .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredProverbs =
          filteredProverbs
              .where(
                (proverb) =>
                    proverb.text.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    proverb.author.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    setState(() {
      _proverbs = filteredProverbs;
    });
  }

  void _navigateToAddProverb() {
    Navigator.of(context).pushNamed(AppConstants.addProverbRoute).then((_) {
      _loadProverbs();
    });
  }

  void _navigateToEditProverb(String proverbId) {
    Navigator.of(context)
        .pushNamed(
          AppConstants.editProverbRoute,
          arguments: {'proverbId': proverbId},
        )
        .then((_) {
          _loadProverbs();
        });
  }

  Future<void> _deleteProverb(Proverb proverb) async {
    // Fix: Create a custom dialog and get its result
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Proverb?'),
            content: const Text(
              'Are you sure you want to delete this proverb? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    // Null check for shouldDelete
    if (shouldDelete == true) {
      final proverbProvider = Provider.of<ProverbProvider>(
        context,
        listen: false,
      );

      try {
        final success = await proverbProvider.deleteProverb(proverb.id);

        if (success && mounted) {
          Helpers.showSuccessSnackBar(context, 'Proverb deleted successfully');
          _loadProverbs();
        }
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(
            context,
            'Failed to delete proverb: ${e.toString()}',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    if (!authProvider.isAuthenticated || !authProvider.isAdmin) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Manage Proverbs'),
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
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Manage Proverbs'),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProverb,
        backgroundColor: ThemeConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
      body:
          _isLoading
              ? const LoadingIndicator(message: 'Loading proverbs...')
              : Column(
                children: [
                  // Search and filter
                  Container(
                    padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                    child: Column(
                      children: [
                        // Search bar
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search proverbs',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                _searchQuery.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                        _filterProverbs();
                                      },
                                    )
                                    : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ThemeConstants.mediumRadius,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                            _filterProverbs();
                          },
                        ),

                        const SizedBox(height: ThemeConstants.mediumPadding),

                        // Category filter
                        DropdownButtonFormField<String?>(
                          value: _selectedCategoryId,
                          decoration: InputDecoration(
                            hintText: 'Filter by category',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ThemeConstants.mediumRadius,
                              ),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Categories'),
                            ),
                            ...categoryProvider.categories.map((category) {
                              return DropdownMenuItem<String?>(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                            _filterProverbs();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Proverbs list
                  Expanded(
                    child:
                        _proverbs.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.menu_book,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(
                                    height: ThemeConstants.mediumPadding,
                                  ),
                                  const Text(
                                    'No proverbs found',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: ThemeConstants.smallPadding,
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _navigateToAddProverb,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add New Proverb'),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(
                                ThemeConstants.mediumPadding,
                              ),
                              itemCount: _proverbs.length,
                              itemBuilder: (context, index) {
                                final proverb = _proverbs[index];

                                // Fix: Handle the case when category might not be found
                                Category category;
                                try {
                                  category = categoryProvider.categories
                                      .firstWhere(
                                        (c) => c.id == proverb.categoryId,
                                      );
                                } catch (e) {
                                  // Fallback to a default category if not found
                                  category = Category(
                                    id: 'unknown',
                                    name: 'Unknown Category',
                                  );
                                }

                                return Card(
                                  margin: const EdgeInsets.only(
                                    bottom: ThemeConstants.mediumPadding,
                                  ),
                                  elevation: ThemeConstants.smallElevation,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      ThemeConstants.mediumRadius,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Proverb image
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(
                                            ThemeConstants.mediumRadius,
                                          ),
                                          topRight: Radius.circular(
                                            ThemeConstants.mediumRadius,
                                          ),
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: proverb.backgroundImageUrl,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) => Container(
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                          errorWidget:
                                              (context, url, error) =>
                                                  Container(
                                                    height: 150,
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child: Icon(Icons.error),
                                                    ),
                                                  ),
                                        ),
                                      ),

                                      // Proverb details
                                      Padding(
                                        padding: const EdgeInsets.all(
                                          ThemeConstants.mediumPadding,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    Helpers.truncateText(
                                                      proverb.text,
                                                      100,
                                                    ),
                                                    style: ThemeConstants
                                                        .subtitleStyle
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
                                                if (!proverb.isActive)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'Inactive',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),

                                            const SizedBox(
                                              height:
                                                  ThemeConstants.smallPadding,
                                            ),

                                            Text(
                                              '- ${proverb.author}',
                                              style: ThemeConstants.captionStyle
                                                  .copyWith(
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                            ),

                                            const SizedBox(
                                              height:
                                                  ThemeConstants.smallPadding,
                                            ),

                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.category,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  category.name,
                                                  style: ThemeConstants
                                                      .captionStyle
                                                      .copyWith(
                                                        color: Colors.grey,
                                                      ),
                                                ),
                                                const Spacer(),
                                                const Icon(
                                                  Icons.remove_red_eye,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  proverb.viewCount.toString(),
                                                  style: ThemeConstants
                                                      .captionStyle
                                                      .copyWith(
                                                        color: Colors.grey,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Actions
                                      ButtonBar(
                                        children: [
                                          TextButton.icon(
                                            onPressed:
                                                () => _navigateToEditProverb(
                                                  proverb.id,
                                                ),
                                            icon: const Icon(Icons.edit),
                                            label: const Text('Edit'),
                                          ),
                                          TextButton.icon(
                                            onPressed:
                                                () => _deleteProverb(proverb),
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            label: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
