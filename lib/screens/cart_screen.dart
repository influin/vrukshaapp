import 'package:vruksha/screens/explore_screen.dart';
import 'package:vruksha/screens/home_screen.dart';
import 'package:vruksha/screens/my_orders_screen.dart';
import 'package:vruksha/screens/my_profile.dart';
import 'package:vruksha/utils/checkout.dart';
import 'package:flutter/material.dart';
import 'package:vruksha/utils/customNavBar.dart';
import 'package:vruksha/services/api_service.dart';
import 'package:vruksha/core/theme/app_theme.dart';
import 'package:vruksha/screens/login_screen.dart';
import 'package:vruksha/screens/widgets/cart_skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _currentIndex = 2;
  bool isLoading = true;
  Map<String, dynamic>? cartData;
  String? error;
  final ApiService _apiService = ApiService();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fetchCartData();
  }

  Future<void> fetchCartData() async {
    setState(() {
      isLoading = true;
      error = null; // Reset error state before fetching
    });

    try {
      final cartData = await _apiService.getCartData();
      setState(() {
        this.cartData = cartData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        if (e.toString().contains('Authentication required')) {
          error = 'Please login to view your cart';
        } else {
          error = 'Error loading cart: ${e.toString()}';
        }
        isLoading = false;
      });
    }
  }

  void _onTabTapped(int index) async {
    if (index == _currentIndex) return;

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

  double get totalPrice {
    if (cartData == null) return 0.0;
    return (cartData!['total'] as num).toDouble();
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity < 1) return; // Prevent quantity from going below 1

    try {
      final updatedCart = await _apiService.updateCartItemQuantity(
        itemId,
        newQuantity,
      );
      setState(() {
        cartData = updatedCart;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating quantity: ${e.toString()}'),
          backgroundColor: AppTheme.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final updatedCart = await _apiService.removeCartItem(itemId);
      setState(() {
        cartData = updatedCart;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product removed from cart'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing item: ${e.toString()}'),
          backgroundColor: AppTheme.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _refreshCart() async {
    await fetchCartData();
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Cart', style: theme.textTheme.headlineLarge),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: AppTheme.primaryGreen,
          onRefresh: _refreshCart,
          child:
              isLoading
                  ? const CartSkeleton()
                  : error != null
                  ? _buildErrorView(error!, theme)
                  : _buildCartContent(theme),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildErrorView(String errorMessage, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: AppTheme.textGrey,
            ),
            const SizedBox(height: 24),
            Text(
              errorMessage,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (errorMessage.contains('login'))
              ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Login',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: fetchCartData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(ThemeData theme) {
    return cartData == null || cartData!['items'].isEmpty
        ? _buildEmptyCart(theme)
        : _buildCartItems(theme);
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('assets/My Cart.png', height: 200, fit: BoxFit.contain),
            // const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Looks like you haven\'t added anything to your cart yet.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ExploreScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Start Shopping',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartData!['items'].length,
            itemBuilder: (context, index) {
              final item = cartData!['items'][index];
              final product = item['product'];
              final variation = item['variation'];
              return _buildCartItem(item, product, variation, theme);
            },
          ),
        ),
        _buildCheckoutSection(theme),
      ],
    );
  }

  Widget _buildCartItem(
    Map<String, dynamic> item,
    Map<String, dynamic> product,
    Map<String, dynamic> variation,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product image with cached network image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: product['images'][0],
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      height: 70,
                      width: 70,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 70,
                      width: 70,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: theme.textTheme.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(variation['weight'], style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _qtyButton(
                        () => updateQuantity(item['_id'], item['quantity'] - 1),
                        Icons.remove,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['quantity'].toString(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _qtyButton(
                        () => updateQuantity(item['_id'], item['quantity'] + 1),
                        Icons.add,
                        color: AppTheme.primaryGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => removeItem(item['_id']),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppTheme.textGrey,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '₹${((variation['price'] as num).toDouble() * (item['quantity'] as num).toDouble()).toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: theme.textTheme.bodyLarge),
              Text(
                '₹${totalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery', style: theme.textTheme.bodyLarge),
              Text(
                'FREE',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${totalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Replace this line in the ElevatedButton onPressed callback:
              // From: ? () => showCheckoutSheet(context, totalPrice)
              // To: ? () => navigateToCheckout(context, totalPrice)
              onPressed:
                  cartData != null && cartData!['items'].isNotEmpty
                      ? () => navigateToCheckout(context, totalPrice)
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: AppTheme.textLight,
              ),
              child: Text(
                'Proceed to Checkout',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(
    VoidCallback onPressed,
    IconData icon, {
    Color color = AppTheme.textDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        splashRadius: 24,
      ),
    );
  }
}
