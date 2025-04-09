// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/category.dart';
import '../theme/theme_constants.dart';

class CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.smallPadding,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? ThemeConstants.primaryColor
                  : Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : ThemeConstants.surfaceDarkColor,
          borderRadius: BorderRadius.circular(ThemeConstants.mediumRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.mediumPadding,
          vertical: ThemeConstants.smallPadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category.iconUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(ThemeConstants.smallRadius),
                child: CachedNetworkImage(
                  imageUrl: category.iconUrl!,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => const SizedBox(
                        width: 24,
                        height: 24,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) =>
                          const Icon(Icons.category, size: 24),
                ),
              ),
              const SizedBox(width: ThemeConstants.smallPadding),
            ],
            Text(
              category.name,
              style: ThemeConstants.subtitleStyle.copyWith(
                color:
                    isSelected
                        ? Colors.white
                        : Theme.of(context).brightness == Brightness.light
                        ? ThemeConstants.textLightColor
                        : ThemeConstants.textDarkColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
