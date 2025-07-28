import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vruksha/core/theme/app_theme.dart';

class CategoryGridSkeleton extends StatelessWidget {
  const CategoryGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: 6, // Show 6 skeleton items
      itemBuilder: (context, index) {
        return _buildCategoryCardSkeleton();
      },
    );
  }

  Widget _buildCategoryCardSkeleton() {
    // Generate a random pastel color for variety
    final List<Color> pastelColors = [
      const Color(0xFFE8F5E8), // Light Green
      const Color(0xFFF7F0FC), // Light Purple
      const Color(0xFFFFF0E8), // Light Orange
      const Color(0xFFE8F0FF), // Light Blue
    ];

    final colorIndex = (DateTime.now().millisecondsSinceEpoch % pastelColors.length);
    final backgroundColor = pastelColors[colorIndex];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image placeholder
            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            // Title placeholder
            Container(
              height: 16,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            // Browse button placeholder
            Container(
              height: 28,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}