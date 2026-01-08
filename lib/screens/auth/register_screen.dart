import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_auth_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import 'signup_steps_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to Terms & Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF5B7CFF)),
      ),
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      // Lấy name từ email (hoặc thêm TextField cho name)
      String name = _emailController.text.split('@')[0];
      
      final success = await authProvider.register(
        name,
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SignUpStepScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Future<void> _handleRegister() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   if (!_agreedToTerms) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please agree to Terms & Conditions'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => const Center(
  //       child: CircularProgressIndicator(color: Color(0xFF5B7CFF)),
  //     ),
  //   );

  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //   final success = await authProvider.register(
  //     _emailController.text.trim(),
  //     _passwordController.text,
  //   );

  //   if (mounted) {
  //     Navigator.pop(context);
      
  //     if (success) {
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (_) => const SignUpStepScreen()),
  //       );
  //     }
  //   }
  // }

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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(height: 40),
                      
                      Row(
                        children: [
                          const Text(
                            'Join Smartify Today ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          Text('👤', style: TextStyle(fontSize: 32)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      const Text(
                        'Join Smartify, Your Gateway to Smart Living.',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      const Text(
                        'Email',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6B7280), size: 20),
                          filled: true,
                          fillColor: const Color(0xFF2A2930),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
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
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() => _agreedToTerms = value ?? false);
                              },
                              activeColor: const Color(0xFF5B7CFF),
                              checkColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF5B7CFF), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(text: 'I agree to Smartify '),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: TextStyle(
                                      color: Color(0xFF5B7CFF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Already have an account?  ',
                              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  color: Color(0xFF5B7CFF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
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
                      const SizedBox(height: 12),
                      
                      _SocialLoginButton(
                        icon: FontAwesomeIcons.twitter,
                        label: 'Continue with Twitter',
                        onPressed: () => _handleSocialLogin('twitter'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
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
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7CFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: FaIcon(icon, size: 20, color: Colors.white),
              ),
            ),
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