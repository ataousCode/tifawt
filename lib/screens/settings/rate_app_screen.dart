import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkIfRated();
  }

  Future<void> _checkIfRated() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasRated = prefs.getBool('has_rated_app') ?? false;
    final int savedRating = prefs.getInt('app_rating') ?? 0;
    
    setState(() {
      _hasRated = hasRated;
      if (hasRated) {
        _rating = savedRating;
      }
    });
  }

  Future<void> _saveRating() async {
    if (_rating == 0) {
      Helpers.showSnackBar(context, 'Please select a rating first');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_rated_app', true);
      await prefs.setInt('app_rating', _rating);

      if (_rating >= 4 && mounted) {
        // For high ratings, prompt to rate on the app store
        final shouldRate = await _showStoreRatingDialog();
        if (shouldRate) {
          _openAppStore();
        }
      } else if (mounted) {
        // For lower ratings, show feedback form
        _showFeedbackDialog();
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Failed to save rating: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _hasRated = true;
        });
      }
    }
  }

  Future<bool> _showStoreRatingDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Thank You!'),
        content: const Text(
          'We\'re glad you\'re enjoying the app! Would you like to rate us on the app store?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Rate Now'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Thank You for Your Feedback'),
        content: const Text(
          'We\'re sorry that you didn\'t have a better experience. Your feedback helps us improve.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(AppConstants.feedbackRoute);
            },
            child: const Text('Send Feedback'),
          ),
        ],
      ),
    );
  }

  void _openAppStore() {
    // These URLs should be replaced with your actual app store links
    final String storeUrl = Theme.of(context).platform == TargetPlatform.iOS
        ? 'https://apps.apple.com/app/idYOUR_APP_ID'  // iOS App Store
        : 'https://play.google.com/store/apps/details?id=com.example.proverbs_app';  // Google Play Store
    
    launchUrl(Uri.parse(storeUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Rate App',
      ),
      body: SingleChildScrollView(
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
              _hasRated ? 'Thank You for Rating Us!' : 'How Would You Rate Our App?',
              style: ThemeConstants.titleStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: ThemeConstants.smallPadding),
            
            Text(
              _hasRated 
                  ? 'We appreciate your feedback!'
                  : 'Your feedback helps us improve the app experience',
              style: ThemeConstants.bodyStyle.copyWith(
                color: Colors.grey,
              ),
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
                  onPressed: _hasRated ? null : () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            
            const SizedBox(height: ThemeConstants.extraLargePadding),
            
            // Submit button
            if (!_hasRated)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveRating,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Rating'),
                ),
              ),
            
            if (_hasRated)
              Column(
                children: [
                  Text(
                    'You rated our app $_rating out of 5 stars',
                    style: ThemeConstants.subtitleStyle,
                  ),
                  
                  const SizedBox(height: ThemeConstants.mediumPadding),
                  
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(AppConstants.feedbackRoute);
                    },
                    icon: const Icon(Icons.feedback),
                    label: const Text('Send Additional Feedback'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}