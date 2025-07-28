import 'package:vruksha/screens/cart_screen.dart';
import 'package:vruksha/screens/category_screen.dart';
import 'package:vruksha/screens/my_orders_screen.dart';
import 'package:vruksha/screens/my_profile.dart';
import 'package:flutter/material.dart';
import 'package:vruksha/utils/customNavBar.dart';
import 'package:vruksha/screens/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:vruksha/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vruksha/screens/login_screen.dart';
// Add this import at the top of the file
import 'package:vruksha/screens/widgets/category_grid_skeleton.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<dynamic> categories = [];
  String? error;
  int _currentIndex = 1;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _fetchCategories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) async {
    if (index == _currentIndex) return;

    // For Cart, Orders, and Profile screens, check authentication
    if (index == 2 || index == 3 || index == 4) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        // Not authenticated, navigate to login
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }
    }

    // User is authenticated or screen doesn't require authentication
    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const ExploreScreen();
        break;
      case 2:
        screen = const CartScreen();
        break;
      case 3:
        screen = const MyOrdersScreen();
        break;
      case 4:
        screen = const MyProfileScreen();
        break;
      default:
        return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _fetchCategories() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      var dio = Dio();
      var response = await dio.get('http://54.227.34.249:3000/api/categories');

      if (response.statusCode == 200) {
        setState(() {
          categories = response.data;
          isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          error = 'Failed to load categories';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    await _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Find Products', style: theme.textTheme.headlineLarge),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: AppTheme.primaryGreen,
          onRefresh: _refreshData,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar with improved styling
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Store',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textLight,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.primaryGreen,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppTheme.borderGrey,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppTheme.borderGrey,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Categories section title
                const SizedBox(height: 16),
                // Categories grid with improved styling
                Expanded(
                  child: isLoading
                      ? const CategoryGridSkeleton() // Use our new skeleton widget
                      : error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppTheme.orange,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                error!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textGrey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _refreshData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : categories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 48,
                                color: AppTheme.textLight,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No categories available',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textGrey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                          : FadeTransition(
                            opacity: _fadeAnimation,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.85,
                                  ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return _buildCategoryCard(category, theme);
                              },
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildCategoryCard(dynamic category, ThemeData theme) {
    // Generate a pastel color based on the category name
    final List<Color> pastelColors = [
      const Color(0xFFE8F5E8), // Light Green
      const Color(0xFFF7F0FC), // Light Purple
      const Color(0xFFFFF0E8), // Light Orange
      const Color(0xFFE8F0FF), // Light Blue
      const Color(0xFFFFF0F0), // Light Red
      const Color(0xFFF0F8FF), // Light Cyan
    ];

    final colorIndex = category['name'].toString().length % pastelColors.length;
    final backgroundColor = pastelColors[colorIndex];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CategoryProductListScreen(
                  categoryTitle: category['name'],
                  categoryId: category['_id'],
                ),
          ),
        );
      },
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image with error handling
            Container(
              height: 100,
              width: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.network(
                category['icon'],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported_outlined,
                    size: 40,
                    color: AppTheme.textLight,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Category name with improved styling
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category['name'],
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Browse button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Browse',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: AppTheme.primaryGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
