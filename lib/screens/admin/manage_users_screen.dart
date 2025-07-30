import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  List<UserModel> _users = [];
  String _searchQuery = '';
  bool _isAdmin = false;
  final TextEditingController _searchController = TextEditingController();

  // Pagination
  static const int _pageSize = 10;
  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUsers();

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        if (!_isLoadingMore && _hasMoreData) {
          _loadMoreUsers();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _users = [];
      _lastDocument = null;
      _hasMoreData = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _isAdmin = authProvider.isAdmin;

      if (!_isAdmin) {
        // Non-admins shouldn't access this page, but just in case
        setState(() {
          _isLoading = false;
          _hasMoreData = false;
        });
        return;
      }

      await _fetchUsers();
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
          context,
          'Failed to load users: ${e.toString()}',
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

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await _fetchUsers();
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
          context,
          'Failed to load more users: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _fetchUsers() async {
    Query query = _firestore.collection('users');
    // Removed orderBy to avoid compound query indexing issues
    // Will sort in memory after fetching

    // Apply search filter if provided
    if (_searchQuery.isNotEmpty) {
      // Search by email (case insensitive startsWith not supported in Firestore)
      // So we use >= and < for prefix search
      String searchEnd =
          _searchQuery.substring(0, _searchQuery.length - 1) +
          String.fromCharCode(
            _searchQuery.codeUnitAt(_searchQuery.length - 1) + 1,
          );

      query = query
          .where('email', isGreaterThanOrEqualTo: _searchQuery)
          .where('email', isLessThan: searchEnd);
    }

    // Apply pagination
    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    // Limit results
    query = query.limit(_pageSize);

    // Execute query
    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      setState(() {
        _hasMoreData = false;
      });
      return;
    }

    // Update last document for pagination
    _lastDocument = snapshot.docs.last;

    // Parse users
    List<UserModel> newUsers =
        snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Ensure id is set
          return UserModel.fromJson(data);
        }).toList();

    // Sort in memory by createdAt (descending)
    newUsers.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    // Update state
    setState(() {
      _users.addAll(newUsers);
      _hasMoreData = newUsers.length == _pageSize;
    });
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _searchQuery = query.trim();
      _lastDocument = null;
    });

    await _loadUsers();
  }

  Future<void> _toggleAdminStatus(UserModel user) async {
    try {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                user.isAdmin ? 'Remove Admin Status?' : 'Make Admin?',
              ),
              content: Text(
                user.isAdmin
                    ? 'Are you sure you want to remove admin privileges from ${user.displayName ?? user.email}?'
                    : 'Are you sure you want to grant admin privileges to ${user.displayName ?? user.email}?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        user.isAdmin ? Colors.red : ThemeConstants.primaryColor,
                  ),
                  child: Text(user.isAdmin ? 'Remove' : 'Grant'),
                ),
              ],
            ),
      );

      if (confirm != true) return;

      // Update user in Firestore
      await _firestore.collection('users').doc(user.id).update({
        'isAdmin': !user.isAdmin,
      });

      if (mounted) {
        Helpers.showSuccessSnackBar(
          context,
          'Admin status ${user.isAdmin ? 'removed from' : 'granted to'} ${user.displayName ?? user.email}',
        );

        // Refresh users
        await _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
          context,
          'Failed to update admin status: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated || !authProvider.isAdmin) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Manage Users'),
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
      appBar: const CustomAppBar(title: 'Manage Users'),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchUsers('');
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ThemeConstants.mediumRadius,
                  ),
                ),
              ),
              onSubmitted: _searchUsers,
              textInputAction: TextInputAction.search,
            ),
          ),

          // User count and stats
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConstants.mediumPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Users: ${_users.length}${_hasMoreData ? '+' : ''}',
                  style: ThemeConstants.subtitleStyle,
                ),
                Text(
                  'Admins: ${_users.where((user) => user.isAdmin).length}',
                  style: ThemeConstants.subtitleStyle.copyWith(
                    color: ThemeConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: ThemeConstants.smallPadding),

          // User list
          Expanded(
            child:
                _isLoading && _users.isEmpty
                    ? const LoadingIndicator(message: 'Loading users...')
                    : _users.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: ThemeConstants.mediumPadding),
                          const Text(
                            'No users found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: ThemeConstants.smallPadding),
                          if (_searchQuery.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                _searchUsers('');
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear Search'),
                            ),
                        ],
                      ),
                    )
                    : Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(
                            ThemeConstants.mediumPadding,
                          ),
                          itemCount: _users.length + (_hasMoreData ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show loading indicator at the bottom
                            if (index == _users.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    ThemeConstants.mediumPadding,
                                  ),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final user = _users[index];
                            return _buildUserCard(user);
                          },
                        ),

                        // Show loading indicator when refreshing with search
                        if (_isLoading && _users.isNotEmpty)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              color: ThemeConstants.primaryColor,
                            ),
                          ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    final isCurrentUser = currentUser?.uid == user.id;

    return Card(
      margin: const EdgeInsets.only(bottom: ThemeConstants.mediumPadding),
      elevation: ThemeConstants.smallElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(ThemeConstants.mediumPadding),
        leading: CircleAvatar(
          backgroundColor: ThemeConstants.primaryLightColor,
          backgroundImage:
              user.photoUrl != null
                  ? CachedNetworkImageProvider(user.photoUrl!) as ImageProvider
                  : null,
          radius: 25,
          child:
              user.photoUrl == null
                  ? Text(
                    user.displayName?.substring(0, 1).toUpperCase() ??
                        user.email.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                  : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.displayName ?? 'No Display Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            if (isCurrentUser)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Joined: ${Helpers.formatDate(user.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.favorite, size: 14, color: Colors.red),
                Text(
                  'Favorites: ${user.favoriteProverbs.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Icon(
                  Icons.bookmark,
                  size: 14,
                  color: ThemeConstants.primaryColor,
                ),
                Text(
                  'Bookmarks: ${user.bookmarkedProverbs.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Icon(Icons.visibility, size: 14, color: Colors.grey),
                Text(
                  'Read: ${user.readProverbs.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing:
            isCurrentUser
                ? null
                : IconButton(
                  icon: Icon(
                    user.isAdmin
                        ? Icons.admin_panel_settings_rounded
                        : Icons.admin_panel_settings,
                    color:
                        user.isAdmin ? Colors.red : ThemeConstants.primaryColor,
                  ),
                  onPressed: () => _toggleAdminStatus(user),
                  tooltip: user.isAdmin ? 'Remove Admin Status' : 'Make Admin',
                ),
      ),
    );
  }
}
