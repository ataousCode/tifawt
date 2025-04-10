import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// Import with an alias to fix ambiguous import
import '../../providers/auth_provider.dart' as app_auth;
import '../../theme/theme_constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _categoryOptions = [
    'Bug Report',
    'Feature Request',
    'Content Issue',
    'General Feedback',
    'Other',
  ];
  String _selectedCategory = 'General Feedback';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userEmail = FirebaseAuth.instance.currentUser?.email;

      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': userId,
        'userEmail': userEmail,
        'category': _selectedCategory,
        'message': _feedbackController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'isResolved': false,
        'deviceInfo': {'platform': Theme.of(context).platform.toString()},
      });

      if (mounted) {
        _feedbackController.clear();

        Helpers.showSuccessDialog(
          context: context,
          title: 'Thank You!',
          message:
              'Your feedback has been submitted successfully. We appreciate your input!',
          onDismiss: () {
            Navigator.of(context).pop();
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(
          context,
          'Failed to submit feedback: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the aliased AuthProvider
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Send Feedback'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConstants.largePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.feedback,
                size: 70,
                color: ThemeConstants.primaryColor,
              ),

              const SizedBox(height: ThemeConstants.mediumPadding),

              const Text(
                'We value your feedback!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ThemeConstants.smallPadding),

              const Text(
                'Your insights help us improve the app experience for everyone.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ThemeConstants.extraLargePadding),

              // Feedback category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Feedback Category',
                  border: OutlineInputBorder(),
                ),
                items:
                    _categoryOptions.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: ThemeConstants.mediumPadding),

              // Feedback message
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Your Feedback',
                  hintText:
                      'Please share your thoughts, suggestions, or report issues...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your feedback';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more detailed feedback';
                  }
                  return null;
                },
              ),

              const SizedBox(height: ThemeConstants.mediumPadding),

              // User information notice
              Container(
                padding: const EdgeInsets.all(ThemeConstants.mediumPadding),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ThemeConstants.mediumRadius,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.grey),
                    const SizedBox(width: ThemeConstants.smallPadding),
                    Expanded(
                      child: Text(
                        isAuthenticated
                            ? 'Your feedback will be submitted with your account information.'
                            : 'Your feedback will be submitted anonymously.',
                        style: ThemeConstants.captionStyle,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: ThemeConstants.extraLargePadding),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
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
                        : const Text('Submit Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
