import 'package:shared_preferences/shared_preferences.dart';
import 'package:vruksha/screens/cart_screen.dart';
import 'package:vruksha/screens/login_screen.dart';
import 'package:vruksha/screens/my_orders_screen.dart';
import 'package:vruksha/screens/my_profile.dart';
import 'package:vruksha/screens/product_detail_scree.dart';
import 'package:flutter/material.dart';
import 'package:vruksha/screens/explore_screen.dart';
import 'package:vruksha/utils/customNavBar.dart';
import 'package:dio/dio.dart';
import '../utils/responsive_layout.dart';
import '../utils/responsive_scaffold.dart';
import 'package:vruksha/models/product.dart';
import 'package:vruksha/models/category.dart' as category_model;
import 'package:vruksha/screens/widgets/section_title.dart';
import 'package:vruksha/screens/widgets/product_card.dart';
import 'package:vruksha/screens/widgets/grocery_box.dart';
import 'package:vruksha/core/theme/app_theme.dart';
import 'package:vruksha/screens/widgets/product_card_skeleton.dart';
import 'package:vruksha/screens/widgets/category_skeleton.dart';
import 'package:vruksha/screens/widgets/banner_skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dio = Dio();
  List<Product> products = [];
  List<category_model.Category> categories = [];
  bool isLoading = true;
  bool isCategoriesLoading = true;
  int _currentIndex = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
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

  Future<void> fetchProducts() async {
    try {
      final response = await dio.get('http://54.227.34.249:3000/api/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          products = data.map((json) => Product.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load products'),
              backgroundColor: AppTheme.orange,
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.orange,
          ),
        );
      });
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await dio.get(
        'http://54.227.34.249:3000/api/categories',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          categories =
              data
                  .map((json) => category_model.Category.fromJson(json))
                  .toList();
          isCategoriesLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() => isCategoriesLoading = false);
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      isCategoriesLoading = true;
    });
    await Future.wait([fetchProducts(), fetchCategories()]);
  }

  // At the top of the file, add this import

  // Then in your build method, replace the Scaffold with ResponsiveScaffold
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      title: 'Home',
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 40),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          await fetchProducts();
          await fetchCategories();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveLayout.isMobile(context) ? 16 : 24,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(theme),
              const SizedBox(height: 24),
              SectionTitle(
                title: 'Categories',
                onSeeAllPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExploreScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildCategoriesList(theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  // Update your _buildCategoriesList method to be responsive
  Widget _buildCategoriesList(ThemeData theme) {
    if (isCategoriesLoading) {
      return SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) => const CategorySkeleton(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = ResponsiveLayout.isDesktop(context);
        final isTablet = ResponsiveLayout.isTablet(context);

        if (isDesktop || isTablet) {
          // Grid layout for larger screens
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 6 : 4,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return GroceryBox(
                title: categories[index].name,
                imgUrl: categories[index].icon,
                id: categories[index].id,
              );
            },
          );
        } else {
          // Horizontal list for mobile
          return SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GroceryBox(
                  title: categories[index].name,
                  imgUrl: categories[index].icon,
                  id: categories[index].id,
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildBanner(ThemeData theme) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.asset(
              'assets/banner.png',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fresh Groceries',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get up to 30% off on your first order',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5, // Show 5 skeleton items
          itemBuilder: (context, index) {
            return const ProductCardSkeleton();
          },
        ),
      );
    } else if (products.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 48,
              color: AppTheme.textGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No products available',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              id: product.id,
              title: product.name,
              qty: product.variations[0].weight,
              imgUrl: product.images[0],
              price: product.variations[0].price,
            );
          },
        ),
      );
    }
  }
}
