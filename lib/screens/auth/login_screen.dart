import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_auth_provider.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF5B7CFF)),
      ),
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      Navigator.pop(context);
      
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    final socialAuthProvider = Provider.of<SocialAuthProvider>(context, listen: false);
    bool success = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF5B7CFF)),
      ),
    );

    switch (provider) {
      case 'google':
        success = await socialAuthProvider.signInWithGoogle();
        break;
      case 'apple':
        break;
      case 'facebook':
        success = await socialAuthProvider.signInWithFacebook();
        break;
    }

    if (mounted) {
      Navigator.pop(context);
      
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (provider != 'apple') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider Sign In failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A20),
      body: SafeArea(
        child: Column( // Sử dụng Column để phân tách nội dung và nút bấm cố định
          children: [
            // PHẦN 1: Nội dung cuộn được (Email, Password, Social Buttons)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(height: 40),
                      
                      // Title with emoji
                      Row(
                        children: [
                          const Text(
                            'Welcome Back! ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const Text('👋', style: TextStyle(fontSize: 32)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Subtitle
                      const Text(
                        'Your Smart Home, Your Rules.',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Email Field
                      _buildLabel('Email'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Email',
                        icon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your email';
                          if (!value.contains('@')) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Password Field
                      _buildLabel('Password'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFF6B7280),
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2A2930),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                  activeColor: const Color(0xFF5B7CFF),
                                  checkColor: Colors.white,
                                  side: const BorderSide(color: Color(0xFF5B7CFF), width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Remember me', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                            ],
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                            child: const Text('Forgot Password?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Social Login Buttons
                      _SocialLoginButton(
                        icon: FontAwesomeIcons.google,
                        label: 'Continue with Google',
                        onPressed: () => _handleSocialLogin('google'),
                      ),
                      const SizedBox(height: 12),
                      _SocialLoginButton(
                        icon: FontAwesomeIcons.apple,
                        label: 'Continue with Apple',
                        onPressed: () => _handleSocialLogin('apple'),
                      ),
                      const SizedBox(height: 12),
                      _SocialLoginButton(
                        icon: FontAwesomeIcons.facebook,
                        label: 'Continue with Facebook',
                        onPressed: () => _handleSocialLogin('facebook'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // PHẦN 2: Nút Sign In cố định ở dưới cùng
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Đường kẻ ngăn cách mờ
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7CFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
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

  // Hàm hỗ trợ vẽ Label cho nhanh
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  // Hàm hỗ trợ vẽ TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
        filled: true,
        fillColor: const Color(0xFF2A2930),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      validator: validator,
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
          backgroundColor: const Color(0xFF2A2930),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Icon positioned on left
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: FaIcon(icon, size: 20, color: Colors.white),
              ),
            ),
            // Text centered
            Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}