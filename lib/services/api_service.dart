import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://54.227.34.249:3000/api';

  // Get auth token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get products by category
  Future<List<dynamic>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/products/category/$categoryId',
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // Get product details
  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    try {
      final response = await _dio.get('$_baseUrl/products/$productId');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
          'Failed to load product details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching product details: $e');
    }
  }

  // Get categories
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _dio.get('$_baseUrl/categories');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Get cart data
  Future<Map<String, dynamic>> getCartData() async {
    try {
      final token = await getAuthToken();

      if (token == null) {
        throw Exception('Authentication required');
      }

      var headers = {'Authorization': 'Bearer $token'};

      var response = await _dio.request(
        '$_baseUrl/cart',
        options: Options(method: 'GET', headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cart data: $e');
    }
  }

  // Update cart item quantity
  Future<Map<String, dynamic>> updateCartItemQuantity(
    String itemId,
    int quantity,
  ) async {
    try {
      final token = await getAuthToken();

      if (token == null) {
        throw Exception('Authentication required');
      }

      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      var data = json.encode({"itemId": itemId, "quantity": quantity});

      var response = await _dio.request(
        '$_baseUrl/cart/update',
        options: Options(method: 'PUT', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update quantity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating quantity: $e');
    }
  }

  // Remove item from cart
  Future<Map<String, dynamic>> removeCartItem(String itemId) async {
    try {
      final token = await getAuthToken();

      if (token == null) {
        throw Exception('Authentication required');
      }

      var headers = {'Authorization': 'Bearer $token'};

      var response = await _dio.request(
        '$_baseUrl/cart/item/$itemId',
        options: Options(method: 'DELETE', headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to remove item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error removing item: $e');
    }
  }

  // Add item to cart
  Future<Map<String, dynamic>> addToCart(
    String productId,
    int variationIndex,
    int quantity,
  ) async {
    try {
      final token = await getAuthToken();

      if (token == null) {
        throw Exception('Authentication required');
      }

      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      var data = json.encode({
        "productId": productId,
        "variationIndex": variationIndex,
        "quantity": quantity,
      });

      var response = await _dio.request(
        '$_baseUrl/cart/add',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to add item to cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding item to cart: $e');
    }
  }

  // Get user addresses
  Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final token = await getAuthToken();

      if (token == null) {
        throw Exception('Authentication required');
      }

      var headers = {'Authorization': 'Bearer $token'};

      var response = await _dio.request(
        '$_baseUrl/auth/address',
        options: Options(method: 'GET', headers: headers),
      );

      if (response.statusCode == 200) {
        // Convert the response data to the expected format
        List<dynamic> addressList = response.data['addresses'] ?? [];
        return addressList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load addresses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching addresses: $e');
    }
  }

  // Add a new address
  Future<Map<String, dynamic>> addAddress(Map<String, String> address) async {
    try {
      final token = await getAuthToken();

      if (token == null) {
        throw Exception('Authentication required');
      }

      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      var data = json.encode(address);

      var response = await _dio.request(
        '$_baseUrl/auth/address',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to add address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding address: $e');
    }
  }

  // Delete an address
  Future<Map<String, dynamic>> deleteAddress(String addressId) async {
    try {
      final token = await getAuthToken();

      if (token == null) {
        throw Exception('Authentication required');
      }

      var headers = {'Authorization': 'Bearer $token'};

      var response = await _dio.request(
        '$_baseUrl/user/addresses/$addressId',
        options: Options(method: 'DELETE', headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to delete address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting address: $e');
    }
  }

  // Place an order
  Future<Map<String, dynamic>> placeOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final token = await getAuthToken();

      if (token == null) {
        throw Exception('Authentication required');
      }

      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      print('Sending order data: ${json.encode(orderData)}');

      var response = await _dio.request(
        '$_baseUrl/orders/create',
        options: Options(
          method: 'POST',
          headers: headers,
          validateStatus:
              (status) => status! < 500, // Accept all status codes < 500
        ),
        data: orderData,
      );

      print('Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
          response.data['message'] ??
              response.statusMessage ??
              'Failed to place order',
        );
      }
    } catch (e) {
      print('Error placing order: $e');
      throw Exception('Error placing order: $e');
    }
  }

  // Get user profile information
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await getAuthToken();

      if (token == null) {
        throw Exception('Authentication required');
      }

      var headers = {'Authorization': 'Bearer $token'};

      var response = await _dio.request(
        '$_baseUrl/auth/profile',
        options: Options(method: 'GET', headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching profile data: $e');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final token = await getAuthToken();

      if (token == null) {
        throw Exception('Authentication required');
      }

      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      var data = json.encode(profileData);

      var response = await _dio.request(
        '$_baseUrl/auth/profile',
        options: Options(method: 'PUT', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  // Update an address
  Future<Map<String, dynamic>> updateAddress(
    String addressId,
    Map<String, String> address,
  ) async {
    try {
      final token = await getAuthToken();

      if (token == null) {
        throw Exception('Authentication required');
      }

      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      var data = json.encode(address);

      var response = await _dio.request(
        '$_baseUrl/auth/address/$addressId',
        options: Options(method: 'PUT', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating address: $e');
    }
  }
}
