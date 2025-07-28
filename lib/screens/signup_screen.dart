import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vruksha/core/theme/app_theme.dart';
import 'package:vruksha/providers/auth_provider.dart';
import 'package:vruksha/screens/home_screen.dart';
import 'package:vruksha/screens/login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool isBusiness = false;
  bool _obscurePassword = true; // For password visibility toggle
  bool _isValidEmail = false; // Track email validity
  String _passwordStrength = ''; // Track password strength
  double _strengthScore = 0.0; // Password strength score
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Email validation regex
  final RegExp _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    // Add listeners to validate input in real-time
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    // Remove listeners when widget is disposed
    emailController.removeListener(_validateEmail);
    passwordController.removeListener(_validatePassword);
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Validate email format
  void _validateEmail() {
    setState(() {
      _isValidEmail = _emailRegex.hasMatch(emailController.text.trim());
    });
  }

  // Validate password and calculate strength
  void _validatePassword() {
    final password = passwordController.text;
    double score = 0.0;
    String strength = '';

    // Check minimum length
    if (password.length >= 8) score += 0.25;

    // Check for uppercase letter
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.25;

    // Check for lowercase letter
    if (password.contains(RegExp(r'[a-z]'))) score += 0.25;

    // Check for number
    if (password.contains(RegExp(r'[0-9]'))) score += 0.125;

    // Check for special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 0.125;

    // Determine strength label
    if (score < 0.25) {
      strength = 'Weak';
    } else if (score < 0.5) {
      strength = 'Medium';
    } else if (score < 0.75) {
      strength = 'Strong';
    } else {
      strength = 'Very Strong';
    }

    setState(() {
      _strengthScore = score;
      _passwordStrength = strength;
    });
  }

  // Get color for password strength indicator
  Color _getStrengthColor() {
    if (_strengthScore < 0.25) return Colors.red;
    if (_strengthScore < 0.5) return Colors.orange;
    if (_strengthScore < 0.75) return Colors.yellow;
    return AppTheme.primaryGreen;
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    
    final success = await ref.read(authProvider.notifier).signup(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
      phoneController.text.trim(),
      isBusiness,
    );

    if (success && mounted) {
      // Check if there's a pending cart item
      final prefs = await SharedPreferences.getInstance();
      final hasPendingCartItem = prefs.containsKey('pending_cart_product_id');

      // Navigate to login screen with a message about the pending cart item
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );

      // Show a message if there's a pending cart item
      if (hasPendingCartItem) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to add the item to your cart'),
            backgroundColor: AppTheme.primaryGreen,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please login.'),
            backgroundColor: AppTheme.primaryGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.02),
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    SizedBox(height: size.height * 0.03),
                    Text(
                      'Create Account',
                      style: textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to start shopping with Vruksha Farms',
                      style: textTheme.bodyLarge?.copyWith(color: AppTheme.textGrey),
                    ),
                    SizedBox(height: size.height * 0.04),
                    
                    // Name Field
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryGreen),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Field
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                        suffixIcon: emailController.text.isEmpty
                            ? null
                            : Icon(
                                _isValidEmail ? Icons.check_circle : Icons.cancel,
                                color: _isValidEmail ? AppTheme.primaryGreen : Colors.red,
                              ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!_emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone Field
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryGreen),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.textGrey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (_strengthScore < 0.5) {
                          return 'Password is too weak';
                        }
                        return null;
                      },
                    ),
                    
                    // Password Strength Indicator
                    if (passwordController.text.isNotEmpty) ...[  
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _strengthScore,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
                              minHeight: 5,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _passwordStrength,
                            style: TextStyle(
                              color: _getStrengthColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Password must be at least 8 characters with uppercase, lowercase, number, and special character',
                        style: textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 16),
                    
                    // Business Account Switch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.business, color: AppTheme.primaryGreen),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Sign up as Business Account',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Switch(
                            value: isBusiness,
                            onChanged: (value) => setState(() => isBusiness = value),
                            activeColor: AppTheme.primaryGreen,
                          ),
                        ],
                      ),
                    ),
                    
                    // Error Message
                    if (authState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.error!.replaceAll('Exception: ', ''),
                                  style: textTheme.bodyMedium?.copyWith(color: Colors.red),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                onPressed: () => ref.read(authProvider.notifier).clearError(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    SizedBox(height: size.height * 0.04),
                    
                    // Signup Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _signup,
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create Account'),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.03),
                    
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(
                            'Sign In',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
