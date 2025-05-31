// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/theme_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Privacy Policy'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeConstants.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: ThemeConstants.smallPadding),

              Text(
                'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: ThemeConstants.largePadding),

              const Text(
                'This Privacy Policy describes how your personal information is collected, used, and shared when you use our Proverbs App.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),

              const SizedBox(height: ThemeConstants.mediumPadding),

              _buildSection(
                title: '1. Information We Collect',
                content:
                    'When you use our app, we collect several types of information:\n\n'
                    '• Account Information: When you create an account, we collect your email address, name, and profile picture.\n\n'
                    '• Usage Data: We collect information about how you interact with our app, including your favorites, bookmarks, and reading history.\n\n'
                    '• Device Information: We collect information about the device you use to access our app, including device type, operating system, and unique device identifiers.\n\n'
                    '• Location Information: With your permission, we may collect and process information about your location for providing location-based features.',
              ),

              _buildSection(
                title: '2. How We Use Your Information',
                content:
                    'We use the information we collect to:\n\n'
                    '• Provide, maintain, and improve our app\n'
                    '• Personalize your experience\n'
                    '• Communicate with you, including sending updates and notifications\n'
                    '• Monitor and analyze usage and trends\n'
                    '• Detect, prevent, and address technical issues and security breaches',
              ),

              _buildSection(
                title: '3. Sharing Your Information',
                content:
                    'We do not share your personal information with third parties except:\n\n'
                    '• With service providers who perform services on our behalf\n'
                    '• To comply with legal obligations\n'
                    '• To protect and defend our rights and property\n'
                    '• With your consent or at your direction',
              ),

              _buildSection(
                title: '4. Data Storage and Security',
                content:
                    'We use commercially reasonable security measures to protect your personal information. However, no method of transmission over the Internet or electronic storage is 100% secure, and we cannot guarantee absolute security.',
              ),

              _buildSection(
                title: '5. Your Rights',
                content:
                    'Depending on your location, you may have the right to:\n\n'
                    '• Access the personal information we hold about you\n'
                    '• Request that we correct or update your personal information\n'
                    '• Request that we delete your personal information\n'
                    '• Object to or restrict our processing of your personal information\n'
                    '• Data portability',
              ),

              _buildSection(
                title: '6. Children\'s Privacy',
                content:
                    'Our app is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe we have collected information from your child, please contact us.',
              ),

              _buildSection(
                title: '7. Changes to This Privacy Policy',
                content:
                    'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
              ),

              _buildSection(
                title: '8. Contact Us',
                content:
                    'If you have questions or concerns about this Privacy Policy, please contact us through the app\'s feedback feature or at privacy@proverbsapp.com.',
              ),

              const SizedBox(height: ThemeConstants.extraLargePadding),

              const Center(
                child: Text(
                  '© 2023 Proverbs App. All rights reserved.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: ThemeConstants.mediumPadding),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: ThemeConstants.smallPadding),
        Text(content, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: ThemeConstants.smallPadding),
        const Divider(),
      ],
    );
  }
}
