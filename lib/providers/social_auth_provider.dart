import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
//import 'package:twitter_login/twitter_login.dart';

class SocialUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String provider; // 'google', 'facebook', 'twitter'

  SocialUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.provider,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'provider': provider,
  };

  factory SocialUser.fromJson(Map<String, dynamic> json) => SocialUser(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    photoUrl: json['photoUrl'],
    provider: json['provider'],
  );
}

class SocialAuthProvider extends ChangeNotifier {
  SocialUser? _socialUser;
  bool _isLoading = false;

  // Initialize social auth instances
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  SocialUser? get socialUser => _socialUser;
  bool get isLoading => _isLoading;
  bool get isSocialLoggedIn => _socialUser != null;

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create social user from Google account
      _socialUser = SocialUser(
        id: googleUser.id,
        name: googleUser.displayName ?? 'Google User',
        email: googleUser.email,
        photoUrl: googleUser.photoUrl,
        provider: 'google',
      );
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('social_user', jsonEncode(_socialUser!.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Google Sign In error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Facebook Sign In
  Future<bool> signInWithFacebook() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      // Check the login status
      if (result.status != LoginStatus.success) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get user data
      final userData = await FacebookAuth.instance.getUserData(
        fields: "name,email,picture.width(200)",
      );

      _socialUser = SocialUser(
        id: userData['id'] ?? '',
        name: userData['name'] ?? 'Facebook User',
        email: userData['email'] ?? '',
        photoUrl: userData['picture']?['data']?['url'],
        provider: 'facebook',
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('social_user', jsonEncode(_socialUser!.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Facebook Sign In error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  // Load saved social user
  Future<void> loadSocialUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('social_user');
      
      if (userJson != null) {
        _socialUser = SocialUser.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      debugPrint('Error loading social user: $e');
    }
    notifyListeners();
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Sign out from all providers
      if (_socialUser?.provider == 'google') {
        await _googleSignIn.signOut();
      } else if (_socialUser?.provider == 'facebook') {
        await FacebookAuth.instance.logOut();
      }
      // Twitter doesn't need explicit sign out
      
      _socialUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('social_user');
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
}