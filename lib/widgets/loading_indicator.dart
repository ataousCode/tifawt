import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/theme_constants.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool useAnimation;
  
  const LoadingIndicator({
    super.key,
    this.message,
    this.useAnimation = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (useAnimation) ...[
            Lottie.asset(
              'assets/animations/loading.json',
              width: 150,
              height: 150,
            ),
          ] else ...[
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primaryColor),
            ),
          ],
          
          if (message != null) ...[
            const SizedBox(height: ThemeConstants.mediumPadding),
            Text(
              message!,
              style: ThemeConstants.bodyStyle.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? ThemeConstants.textLightColor
                    : ThemeConstants.textDarkColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}