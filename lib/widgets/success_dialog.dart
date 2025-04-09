import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/theme_constants.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;

  const SuccessDialog({
    super.key,
    this.title = 'Success',
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.largeRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.largePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/loading.json',
              width: 120,
              height: 120,
            ),

            const SizedBox(height: ThemeConstants.mediumPadding),

            Text(
              title,
              style: ThemeConstants.titleStyle.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: ThemeConstants.smallPadding),

            Text(
              message,
              style: ThemeConstants.bodyStyle,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ThemeConstants.largePadding),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onDismiss != null) {
                  onDismiss!();
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
