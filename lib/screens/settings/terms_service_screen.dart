import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/theme_constants.dart';

class TermsServiceScreen extends StatelessWidget {
  const TermsServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Terms of Service',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ThemeConstants.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: ThemeConstants.smallPadding),
              
              Text(
                'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: ThemeConstants.largePadding),
              
              const Text(
                'Please read these Terms of Service carefully before using the Proverbs App. These terms govern your use of our application.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const SizedBox(height: ThemeConstants.mediumPadding),
              
              _buildSection(
                title: '1. Acceptance of Terms',
                content: 'By accessing or using the Proverbs App, you agree to be bound by these Terms. If you disagree with any part of the terms, you may not access the application.',
              ),
              
              _buildSection(
                title: '2. Use License',
                content: 'Permission is granted to temporarily download one copy of the app for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n'
                    '• Modify or copy the materials\n'
                    '• Use the materials for any commercial purpose\n'
                    '• Attempt to decompile or reverse engineer any software contained in the app\n'
                    '• Remove any copyright or other proprietary notations from the materials\n'
                    '• Transfer the materials to another person or "mirror" the materials on any other server',
              ),
              
              _buildSection(
                title: '3. User Accounts',
                content: 'When you create an account with us, you must provide accurate and complete information. You are responsible for maintaining the security of your account and password. The app cannot and will not be liable for any loss or damage from your failure to comply with this security obligation.',
              ),
              
              _buildSection(
                title: '4. Content',
                content: 'Our app allows you to post, link, store, share and otherwise make available certain information, text, or material. You are responsible for the content that you post to the application, including its legality, reliability, and appropriateness.',
              ),
              
              _buildSection(
                title: '5. Privacy Policy',
                content: 'Your use of the Proverbs App is also governed by our Privacy Policy, which can be found in the app settings.',
              ),
              
              _buildSection(
                title: '6. Changes to Terms',
                content: 'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. It is your responsibility to check our Terms periodically for changes. Your continued use of the app following the posting of any changes to these Terms constitutes acceptance of those changes.',
              ),
              
              _buildSection(
                title: '7. Disclaimer',
                content: 'The app is provided on an "AS IS" and "AS AVAILABLE" basis. The company disclaims all warranties of any kind, whether express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, and non-infringement.',
              ),
              
              _buildSection(
                title: '8. Limitation of Liability',
                content: 'In no event shall the company, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the application.',
              ),
              
              _buildSection(
                title: '9. Contact Us',
                content: 'If you have any questions about these Terms, please contact us through the app\'s feedback feature or at support@proverbsapp.com.',
              ),
              
              const SizedBox(height: ThemeConstants.extraLargePadding),
              
              const Center(
                child: Text(
                  '© 2023 Proverbs App. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: ThemeConstants.smallPadding),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        const SizedBox(height: ThemeConstants.smallPadding),
        const Divider(),
      ],
    );
  }
}