// ignore_for_file: deprecated_member_use, use_super_parameters

import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/theme_constants.dart';
import '../../utils/constants.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I create an account?',
      answer:
          'You can create an account by tapping on "Sign Up" from the login screen. You\'ll need to provide a valid email address and create a password. You can also sign up using your Google or Apple account for faster access.',
    ),
    FAQItem(
      question: 'How do I save a proverb to favorites?',
      answer:
          'To save a proverb to your favorites, simply tap on the heart icon when viewing the proverb. You can access all your favorite proverbs by tapping on the "Favorites" tab in the bottom navigation bar.',
    ),
    FAQItem(
      question: 'What\'s the difference between favorites and bookmarks?',
      answer:
          'Favorites are proverbs you love and want to access frequently. Bookmarks are proverbs you want to read later or refer back to. Think of favorites as your collection of best proverbs, while bookmarks are more like a reading list.',
    ),
    FAQItem(
      question: 'How do I change my app theme?',
      answer:
          'You can switch between light and dark themes by going to Settings and toggling the "Dark Mode" option under the Appearance section.',
    ),
    FAQItem(
      question: 'Can I use the app offline?',
      answer:
          'Currently, the app requires an internet connection to fetch proverbs and sync your favorites and bookmarks. We\'re working on adding offline capabilities in a future update.',
    ),
    FAQItem(
      question: 'How do I reset my password?',
      answer:
          'If you forgot your password, you can reset it by tapping on "Forgot Password" on the login screen. You\'ll receive an email with instructions to create a new password.',
    ),
    FAQItem(
      question: 'How do I delete my account?',
      answer:
          'To delete your account, go to your Profile, then tap on "Delete Account". You\'ll need to confirm your password to complete this action. Note that account deletion is permanent and will remove all your data.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Help Center'),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(ThemeConstants.largePadding),
            color: ThemeConstants.primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                const Icon(
                  Icons.help_outline,
                  size: 60,
                  color: ThemeConstants.primaryColor,
                ),

                const SizedBox(height: ThemeConstants.mediumPadding),

                const Text(
                  'How can we help you?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: ThemeConstants.smallPadding),

                const Text(
                  'Browse through our frequently asked questions or contact support',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: ThemeConstants.mediumPadding),

                // Quick help options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickHelpButton(
                      icon: Icons.feedback,
                      label: 'Send Feedback',
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppConstants.feedbackRoute);
                      },
                    ),
                    _buildQuickHelpButton(
                      icon: Icons.contact_support,
                      label: 'Contact Support',
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppConstants.feedbackRoute);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // FAQ header
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
            child: Row(
              children: [
                const Icon(
                  Icons.question_answer,
                  color: ThemeConstants.primaryColor,
                ),
                const SizedBox(width: ThemeConstants.smallPadding),
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var item in _faqItems) {
                        item.isExpanded = true;
                      }
                    });
                  },
                  child: const Text('Expand All'),
                ),
              ],
            ),
          ),

          // FAQ list
          Expanded(
            child: ListView.builder(
              itemCount: _faqItems.length,
              itemBuilder: (context, index) {
                return _buildFAQItem(_faqItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelpButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.largePadding,
          vertical: ThemeConstants.mediumPadding,
        ),
        child: Column(
          children: [
            Icon(icon, color: ThemeConstants.primaryColor, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.mediumPadding,
        vertical: ThemeConstants.smallPadding,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
      ),
      child: ExpansionTile(
        initiallyExpanded: item.isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            item.isExpanded = expanded;
          });
        },
        title: Text(
          item.question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
            child: Text(
              item.answer,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}
