import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: ThemeConstants.titleStyle.copyWith(
          color:
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : ThemeConstants.textDarkColor,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
              : null,
      automaticallyImplyLeading: showBackButton,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
