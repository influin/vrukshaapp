import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vruksha/utils/user_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final dio = Dio();
  static const String baseUrl = 'http://54.227.34.249:3000/api/auth';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/login',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Store user data and token
        await UserStorage.saveUser(data['user'], data['token']);
        return data;
      } else {
        throw Exception(
          response.data?['message'] ?? 'Something went wrong. Try again.',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Something went wrong. Try again.',
      );
    }
  }

  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String phone,
    bool isBusiness,
  ) async {
    try {
      // Create the request data
      final requestData = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'isBusiness': isBusiness ? 1 : 0, // Convert boolean to integer
      };

      // Print the request data to terminal
      print('Request data for signup:');
      print(jsonEncode(requestData));

      final response = await dio.post(
        '$baseUrl/register', // Fixed URL - removed the duplicate 'auth'
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: requestData,
      );

      // Print the response data
      print('Response data:');
      print(jsonEncode(response.data));

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
          response.data?['message'] ?? 'Something went wrong. Try again.',
        );
      }
    } on DioException catch (e) {
      // Print detailed error information
      print('DioException during signup:');
      print('Status code: ${e.response?.statusCode}');
      print('Error data: ${jsonEncode(e.response?.data ?? {})}');
      print('Error type: ${e.type}');
      print('Error message: ${e.message}');
      
      if (e.response?.statusCode == 400) {
        // Handle validation errors
        throw Exception(e.response?.data?['message'] ?? 'Invalid input data');
      } else if (e.response?.statusCode == 409) {
        // Handle conflict (e.g., email already exists)
        throw Exception(e.response?.data?['message'] ?? 'Email already in use');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else {
        throw Exception(
          e.response?.data?['message'] ?? 'Something went wrong. Try again.',
        );
      }
    } catch (e) {
      print('Unexpected error during signup: $e');
      throw Exception('An unexpected error occurred. Please try again later.');
    }
  }
}
