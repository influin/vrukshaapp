import 'package:flutter/material.dart';
import 'package:vruksha/screens/category_screen.dart';
import 'package:vruksha/core/theme/app_theme.dart';

class GroceryBox extends StatelessWidget {
  final String title;
  final String imgUrl;
  final String id;

  const GroceryBox({
    super.key,
    required this.title,
    required this.imgUrl,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductListScreen(
              categoryTitle: title,
              categoryId: id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGrey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  imgUrl,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 40,
                      width: 40,
                      color: AppTheme.lightGreen,
                      child: const Icon(Icons.category, color: AppTheme.primaryGreen),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
