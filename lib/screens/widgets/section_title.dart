import 'package:flutter/material.dart';
import 'package:vruksha/screens/explore_screen.dart';
import 'package:vruksha/core/theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;

  const SectionTitle({
    super.key, 
    required this.title, 
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium,
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryGreen,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onSeeAllPressed ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExploreScreen()),
            );
          },
          child: Text(
            'See all',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
