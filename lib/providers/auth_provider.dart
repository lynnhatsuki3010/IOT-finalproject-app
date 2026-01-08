import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';

class User {
  final String email;
  final String name;
  final String? homeName;
  final int? userId;
  final String? token;

  User({
    required this.email,
    required this.name,
    this.homeName,
    this.userId,
    this.token,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'homeName': homeName,
    'userId': userId,
    'token': token,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    email: json['email'],
    name: json['name'],
    homeName: json['homeName'],
    userId: json['userId'],
    token: json['token'],
  );
}

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  // Temporary storage for password reset flow
  String? _resetEmail;
  String? _resetOtp;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('smartify_user');
      
      if (userJson != null) {
        _user = User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      // Call backend API
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      
      // Create user from response
      _user = User(
        email: response['email'],
        name: response['name'],
        userId: response['userId'],
        token: response['token'],
        homeName: 'My Home',
      );
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('smartify_user', jsonEncode(_user!.toJson()));
      await prefs.setString('auth_token', response['token']);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      // Call backend API
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
      );
      
      // Create user from response
      _user = User(
        email: response['email'],
        name: response['name'],
        userId: response['userId'],
        token: response['token'],
        homeName: 'My Home',
      );
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('smartify_user', jsonEncode(_user!.toJson()));
      await prefs.setString('auth_token', response['token']);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('smartify_user');
    await prefs.remove('auth_token');
    notifyListeners();
  }

  // Send OTP for password reset
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _apiService.sendPasswordResetOtp(email);
      _resetEmail = email; // Store for later use
      return true;
    } catch (e) {
      debugPrint('Send OTP error: $e');
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      await _apiService.verifyOtp(email: email, otp: otp);
      _resetEmail = email;
      _resetOtp = otp; // Store for password reset
      return true;
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      return false;
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    try {
      await _apiService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      
      // Clear temporary data
      _resetEmail = null;
      _resetOtp = null;
      
      return true;
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
    }
  }

  // Getters for stored reset data
  String? get resetEmail => _resetEmail;
  String? get resetOtp => _resetOtp;

  // Test backend connection
  Future<bool> testBackendConnection() async {
    return await _apiService.testConnection();
  }
}



// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class User {
//   final String email;
//   final String name;
//   final String homeName;

//   User({
//     required this.email,
//     required this.name,
//     required this.homeName,
//   });

//   Map<String, dynamic> toJson() => {
//     'email': email,
//     'name': name,
//     'homeName': homeName,
//   };

//   factory User.fromJson(Map<String, dynamic> json) => User(
//     email: json['email'],
//     name: json['name'],
//     homeName: json['homeName'],
//   );
// }

// class AuthProvider extends ChangeNotifier {
//   User? _user;
//   bool _isLoading = true;

//   User? get user => _user;
//   bool get isLoading => _isLoading;
//   bool get isAuthenticated => _user != null;

//   AuthProvider() {
//     _loadUser();
//   }

//   Future<void> _loadUser() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userJson = prefs.getString('smartify_user');
      
//       if (userJson != null) {
//         _user = User.fromJson(jsonDecode(userJson));
//       }
//     } catch (e) {
//       debugPrint('Error loading user: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> login(String email, String password) async {
//     try {
//       // Mock authentication - In production, call your API
//       await Future.delayed(const Duration(seconds: 1));
      
//       _user = User(
//         email: email,
//         name: email.split('@')[0],
//         homeName: 'My Home',
//       );
      
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('smartify_user', jsonEncode(_user!.toJson()));
      
//       notifyListeners();
//       return true;
//     } catch (e) {
//       debugPrint('Login error: $e');
//       return false;
//     }
//   }

//   Future<bool> register(String email, String password) async {
//     try {
//       // Mock registration - In production, call your API
//       await Future.delayed(const Duration(seconds: 1));
      
//       _user = User(
//         email: email,
//         name: email.split('@')[0],
//         homeName: 'My Home',
//       );
      
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('smartify_user', jsonEncode(_user!.toJson()));
      
//       notifyListeners();
//       return true;
//     } catch (e) {
//       debugPrint('Register error: $e');
//       return false;
//     }
//   }

//   Future<void> logout() async {
//     _user = null;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('smartify_user');
//     notifyListeners();
//   }

//   Future<bool> sendPasswordReset(String email) async {
//     try {
//       // Mock password reset - In production, call your API
//       await Future.delayed(const Duration(seconds: 1));
//       return true;
//     } catch (e) {
//       debugPrint('Password reset error: $e');
//       return false;
//     }
//   }
// }