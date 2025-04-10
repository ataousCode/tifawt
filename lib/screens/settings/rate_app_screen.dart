import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({Key? key}) : super(key: key);

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  int _rating = 0;
  bool _hasRated = false;
  bool _isLoading = true;
  bool _isSubmitting = false;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkUserRating();
  }

  Future<void> _checkUserRating() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      // Not logged in, can't check for rating
      setState(() {
        _hasRated = false;
        _isLoading = false;
      });
      return;
    }

    try {
      // Check Firestore for this specific user's rating
      final userId = authProvider.user!.uid;
      final ratingDoc =
          await _firestore.collection('ratings').doc(userId).get();

      setState(() {
        _hasRated = ratingDoc.exists;
        if (ratingDoc.exists) {
          _rating = ratingDoc.data()?['rating'] ?? 0;
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking user rating: $e');
      setState(() {
        _hasRated = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveRating() async {
    if (_rating == 0) {
      Helpers.showSnackBar(context, 'Please select a rating first');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      Helpers.showSnackBar(context, 'Please log in to rate the app');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = authProvider.user!.uid;

      // Save to Firestore with this user's ID
      await _firestore.collection('ratings').doc(userId).set({
        'userId': userId,
        'userEmail': authProvider.user!.email,
        'rating': _rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() => _hasRated = true);

      if (_rating >= 4 && mounted) {
        _showStoreRatingDialog();
      } else if (mounted) {
        _showFeedbackDialog();
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
          context,
          'Failed to save rating: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showStoreRatingDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2C2C3B),
            title: const Text(
              'Thank You!',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'We\'re glad you\'re enjoying the app! Would you like to rate us on the app store?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                ),
                child: const Text('Rate Now'),
              ),
            ],
          ),
    );

    if (result == true) {
      _openAppStore();
    }
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2C2C3B),
            title: const Text(
              'Thank You for Your Feedback',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'We\'re sorry that you didn\'t have a better experience. Your feedback helps us improve.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppConstants.feedbackRoute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                ),
                child: const Text('Send Feedback'),
              ),
            ],
          ),
    );
  }

  void _openAppStore() {
    // Replace with your actual app store links
    final String storeUrl =
        Theme.of(context).platform == TargetPlatform.iOS
            ? 'https://apps.apple.com/app/idYOUR_APP_ID' // iOS App Store
            : 'https://play.google.com/store/apps/details?id=com.example.proverbs_app'; // Google Play Store

    launchUrl(Uri.parse(storeUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212330),
      appBar: const CustomAppBar(title: 'Rate App'),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: ThemeConstants.primaryColor,
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(ThemeConstants.largePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rate_rounded,
                      size: 80,
                      color: Colors.amber,
                    ),

                    const SizedBox(height: ThemeConstants.mediumPadding),

                    Text(
                      _hasRated
                          ? 'Thank You for Rating Us!'
                          : 'How Would You Rate Our App?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: ThemeConstants.smallPadding),

                    Text(
                      _hasRated
                          ? 'We appreciate your feedback!'
                          : 'Your feedback helps us improve the app experience',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: ThemeConstants.extraLargePadding),

                    // Star rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40,
                          ),
                          onPressed:
                              _hasRated
                                  ? null
                                  : () {
                                    setState(() {
                                      _rating = index + 1;
                                    });
                                  },
                        );
                      }),
                    ),

                    const SizedBox(height: ThemeConstants.extraLargePadding),

                    // Submit button or rating info
                    if (!_hasRated)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isSubmitting || _rating == 0
                                  ? null
                                  : _saveRating,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            disabledBackgroundColor: ThemeConstants.primaryColor
                                .withOpacity(0.5),
                          ),
                          child:
                              _isSubmitting
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Submit Rating',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          Text(
                            'You rated our app $_rating out of 5 stars',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: ThemeConstants.mediumPadding),

                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                AppConstants.feedbackRoute,
                              );
                            },
                            icon: const Icon(
                              Icons.feedback,
                              color: ThemeConstants.primaryColor,
                            ),
                            label: const Text(
                              'Send Additional Feedback',
                              style: TextStyle(
                                color: ThemeConstants.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }
}
