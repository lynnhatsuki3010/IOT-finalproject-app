import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // URL backend của bạn - thay đổi theo IP máy của bạn
  static const String baseUrl = 'https://unreliant-alysa-distractingly.ngrok-free.dev'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8080'; // iOS Simulator
  // static const String baseUrl = 'http://192.168.1.xxx:8080'; // Real Device
  
  // ========== TEST CONNECTION ==========
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/test'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Connection test failed: $e');
      return false;
    }
  }

  // ========== AUTH APIs ==========
  
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint('❌ Register error: $e');
      throw Exception('Failed to register: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      throw Exception('Failed to login: $e');
    }
  }

  // ========== PASSWORD RESET APIs ==========
  
  Future<void> sendPasswordResetOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      debugPrint('❌ Send OTP error: $e');
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Invalid OTP');
      }
    } catch (e) {
      debugPrint('❌ Verify OTP error: $e');
      throw Exception('Failed to verify OTP: $e');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to reset password');
      }
    } catch (e) {
      debugPrint('❌ Reset password error: $e');
      throw Exception('Failed to reset password: $e');
    }
  }

  // ========== HOME APIs ==========
  
  Future<void> saveHomeSetup({
    required int userId,
    required String homeName,
    required String country,
    required List<Map<String, String>> rooms,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/home/setup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'homeName': homeName,
          'country': country,
          'rooms': rooms,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to save home setup');
      }
      
      debugPrint('✅ Home setup saved successfully');
    } catch (e) {
      debugPrint('❌ Save home setup error: $e');
      throw Exception('Failed to save home setup: $e');
    }
  }

  Future<Map<String, dynamic>> getHomeData(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/home/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to get home data');
      }
    } catch (e) {
      debugPrint('❌ Get home data error: $e');
      throw Exception('Failed to get home data: $e');
    }
  }

  // ========== DEVICE APIs ==========
  
  Future<Map<String, dynamic>> addDevice({
    required int userId,
    required String name,
    required String type,
    required String connectionType,
    required String room,
    String? topic,
    String? imagePath,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/home/devices'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'name': name,
          'type': type,
          'connectionType': connectionType,
          'room': room,
          'topic': topic ?? '/device/$name',
          'imagePath': imagePath,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Device added successfully');
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to add device');
      }
    } catch (e) {
      debugPrint('❌ Add device error: $e');
      throw Exception('Failed to add device: $e');
    }
  }

  Future<Map<String, dynamic>> toggleDevice(int deviceId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/home/devices/$deviceId/toggle'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to toggle device');
      }
    } catch (e) {
      debugPrint('❌ Toggle device error: $e');
      throw Exception('Failed to toggle device: $e');
    }
  }

  Future<void> deleteDevice(int deviceId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/home/devices/$deviceId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete device');
      }
    } catch (e) {
      debugPrint('❌ Delete device error: $e');
      throw Exception('Failed to delete device: $e');
    }
  }
}