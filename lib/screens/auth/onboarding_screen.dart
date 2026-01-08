import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/social_auth_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A20),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 32,
            vertical: size.height * 0.04,
          ),
          child: Column(
            children: [
              // Top Content - Scrollable if needed
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.02),
                      
                      // App Logo
                      Container(
                        width: 90,
                        height: 90,
                        child: Image.asset(
                          'assets/logo/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3E5EF1).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.wifi,
                                size: 40,
                                color: Color(0xFF3E5EF1),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      
                      // Title
                      const Text(
                        "Let's Get Started!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      const Text(
                        "Let's dive in into your account",
                        style: TextStyle(
                          color: Color(0xFFA0AEC0),
                          fontSize: 15,
                          fontFamily: 'Inter',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.03),
                      
                      // Social Login Buttons
                      _SocialButton(
                        icon: FontAwesomeIcons.google,
                        label: 'Continue with Google',
                        iconColor: Colors.white,
                        onPressed: () => _handleGoogleSignIn(context),
                      ),
                      const SizedBox(height: 12),
                      
                      _SocialButton(
                        icon: FontAwesomeIcons.apple,
                        label: 'Continue with Apple',
                        iconColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Apple Sign In - Coming Soon')),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      _SocialButton(
                        icon: FontAwesomeIcons.facebook,
                        label: 'Continue with Facebook',
                        iconColor: const Color(0xFF1877F2),
                        onPressed: () => _handleFacebookSignIn(context),
                      ),
                      const SizedBox(height: 12),
                      
                      _SocialButton(
                        icon: FontAwesomeIcons.twitter,
                        label: 'Continue with Twitter',
                        iconColor: const Color(0xFF1DA1F2),
                        onPressed: () => _handleTwitterSignIn(context),
                      ),
                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              ),
              
              // Bottom Buttons - Fixed at bottom
              Column(
                children: [
                  // Sign up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E5EF1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Sign in Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2930),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Terms
                  const Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF718096),
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        ' · ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF718096),
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        'Terms of Service',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF718096),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleGoogleSignIn(BuildContext context) async {
    final socialAuthProvider = Provider.of<SocialAuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3E5EF1)),
      ),
    );
    
    final success = await socialAuthProvider.signInWithGoogle();
    
    if (context.mounted) {
      Navigator.pop(context);
      
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign In failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleFacebookSignIn(BuildContext context) async {
    final socialAuthProvider = Provider.of<SocialAuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3E5EF1)),
      ),
    );
    
    final success = await socialAuthProvider.signInWithFacebook();
    
    if (context.mounted) {
      Navigator.pop(context);
      
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facebook Sign In failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleTwitterSignIn(BuildContext context) async {
    final socialAuthProvider = Provider.of<SocialAuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3E5EF1)),
      ),
    );
    
    
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A2930),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
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
                child: FaIcon(icon, size: 20, color: iconColor),
              ),
            ),
            // Text centered
            Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}