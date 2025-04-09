import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/theme_constants.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool showRetryButton;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.onRetry,
    this.showRetryButton = true,
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
              'assets/animations/error.json',
              width: 120,
              height: 120,
            ),

            const SizedBox(height: ThemeConstants.mediumPadding),

            Text(
              title,
              style: ThemeConstants.titleStyle.copyWith(
                color: Colors.red,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Dismiss'),
                ),

                if (showRetryButton && onRetry != null) ...[
                  const SizedBox(width: ThemeConstants.mediumPadding),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRetry!();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
