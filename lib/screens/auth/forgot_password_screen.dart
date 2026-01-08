import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:async';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // MOCK: Giả lập delay gửi OTP
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      // MOCK: Luôn chuyển sang màn hình nhập OTP
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EnterOTPScreen(email: _emailController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A20),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
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
                    'Forgot Your Password? ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    '🔑',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              const Text(
                "We've got you covered. Enter your registered email to reset your password. We will send an OTP code to your email for the next steps.",
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              const Text(
                'Your Registered Email',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'andrew.ainsley@yourdomain.com',
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
              ),
              const SizedBox(height: 40),
              
              // Separator line
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
                  onPressed: _isLoading ? null : _handleSendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B7CFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFF5B7CFF).withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Send OTP Code',
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
      ),
    );
  }
}

// Screen 2: Enter OTP - MOCK MODE
class EnterOTPScreen extends StatefulWidget {
  final String email;

  const EnterOTPScreen({super.key, required this.email});

  @override
  State<EnterOTPScreen> createState() => _EnterOTPScreenState();
}

class _EnterOTPScreenState extends State<EnterOTPScreen> {
  final List<String> _otpDigits = ['', '', '', '']; // ✅ 4-digit OTP
  int _resendSeconds = 60;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _addDigit(String digit) {
    for (int i = 0; i < _otpDigits.length; i++) {
      if (_otpDigits[i].isEmpty) {
        setState(() => _otpDigits[i] = digit);

        // Khi nhập đủ 4 số thì verify
        if (_otpDigits.every((d) => d.isNotEmpty)) {
          _verifyOTP();
        }
        break;
      }
    }
  }

  void _removeDigit() {
    for (int i = _otpDigits.length - 1; i >= 0; i--) {
      if (_otpDigits[i].isNotEmpty) {
        setState(() => _otpDigits[i] = '');
        break;
      }
    }
  }

  Future<void> _verifyOTP() async {
    setState(() => _isVerifying = true);

    final otp = _otpDigits.join('');

    // MOCK verify
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isVerifying = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNewPasswordScreen(
          email: widget.email,
          otp: otp,
        ),
      ),
    );
  }

  Future<void> _resendCode() async {
    if (_resendSeconds != 0) return;

    // MOCK resend
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _resendSeconds = 60;
      _otpDigits.fillRange(0, 4, '');
    });

    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A20),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                children: const [
                  Text(
                    'Enter OTP Code ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('🔐', style: TextStyle(fontSize: 24)),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                'Please check your email inbox for a message from Smartify. Enter the one-time verification code below.',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 48,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2930),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _otpDigits[index].isNotEmpty
                            ? const Color(0xFF5B7CFF)
                            : const Color(0xFF3D4556),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _otpDigits[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              if (_isVerifying)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5B7CFF),
                  ),
                ),

              if (!_isVerifying) ...[
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 15,
                      ),
                      children: [
                        const TextSpan(text: 'You can resend the code in '),
                        TextSpan(
                          text: '$_resendSeconds',
                          style: const TextStyle(
                            color: Color(0xFF5B7CFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' seconds'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: TextButton(
                    onPressed: _resendSeconds == 0 ? _resendCode : null,
                    child: Text(
                      'Resend code',
                      style: TextStyle(
                        color: _resendSeconds == 0
                            ? const Color(0xFF5B7CFF)
                            : const Color(0xFF6B7280),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              _NumberPad(
                onNumberPressed: _addDigit,
                onDeletePressed: _removeDigit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// Screen 3: Create New Password - MOCK MODE (không thực sự đổi password)
class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  
  const CreateNewPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSavePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);

    // ✅ CHỈ ĐIỀU HƯỚNG – KHÔNG SNACKBAR
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PasswordSuccessScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A20),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
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
                    'Secure Your Account ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const Text('🔒', style: TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 12),
              
              const Text(
                'Almost there! Create a new password for your Smartify account to keep it secure. Remember to choose a strong and unique password.',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              const Text(
                'New Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '••••••••••••',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280), size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF6B7280),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscureNew = !_obscureNew);
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
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Confirm New Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '••••••••••••',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280), size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF6B7280),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
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
              ),
              const SizedBox(height: 40),
              
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
                  onPressed: _isLoading ? null : _handleSavePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B7CFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFF5B7CFF).withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save New Password',
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
      ),
    );
  }
}

// Screen 4: Success
class PasswordSuccessScreen extends StatelessWidget {
  const PasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A20),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5B7CFF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 86,
                            height: 86,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 44,
                              color: Color(0xFF5B7CFF),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        "You're All Set!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Your password has been successfully changed. (Mock mode)',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 15,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              Column(
                children: [
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
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
                        'Go to Homepage',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Number Pad Widget
class _NumberPad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onDeletePressed;

  const _NumberPad({
    required this.onNumberPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildNumberRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildNumberRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildNumberRow(['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('*'),
            _buildNumberButton('0'),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) => _buildNumberButton(n)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => onNumberPressed(number),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 80,
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: onDeletePressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import 'dart:async';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _emailController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleSendOTP() async {
//     if (_emailController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter your email')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final success = await authProvider.sendPasswordReset(_emailController.text.trim());

//     setState(() => _isLoading = false);

//     if (success && mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => EnterOTPScreen(email: _emailController.text.trim()),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1B1A20),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Back Button
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 padding: EdgeInsets.zero,
//                 alignment: Alignment.centerLeft,
//               ),
//               const SizedBox(height: 40),
              
//               // Title with emoji
//               Row(
//                 children: [
//                   const Text(
//                     'Forgot Your Password? ',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       height: 1.2,
//                     ),
//                   ),
//                   Text(
//                     '🔑',
//                     style: TextStyle(fontSize: 24),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
              
//               const Text(
//                 "We've got you covered. Enter your registered email to reset your password. We will send an OTP code to your email for the next steps.",
//                 style: TextStyle(
//                   color: Color(0xFF9CA3AF),
//                   fontSize: 16,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 40),
              
//               const Text(
//                 'Your Registered Email',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   hintText: 'andrew.ainsley@yourdomain.com',
//                   hintStyle: const TextStyle(color: Color(0xFF6B7280)),
//                   prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6B7280), size: 20),
//                   filled: true,
//                   fillColor: const Color(0xFF2A2930),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//                 ),
//               ),
//               const SizedBox(height: 40),
              
//               // Separator line
//               Container(
//                 height: 1,
//                 margin: const EdgeInsets.only(bottom: 24),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.white.withOpacity(0),
//                       Colors.white.withOpacity(0.1),
//                       Colors.white.withOpacity(0),
//                     ],
//                   ),
//                 ),
//               ),
              
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _handleSendOTP,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF5B7CFF),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 18),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(28),
//                     ),
//                     elevation: 0,
//                     disabledBackgroundColor: const Color(0xFF5B7CFF).withOpacity(0.5),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         )
//                       : const Text(
//                           'Send OTP Code',
//                           style: TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Screen 1: Enter Email - GIỮ NGUYÊN

// // Screen 2: Enter OTP - CẬP NHẬT
// class EnterOTPScreen extends StatefulWidget {
//   final String email;
  
//   const EnterOTPScreen({super.key, required this.email});

//   @override
//   State<EnterOTPScreen> createState() => _EnterOTPScreenState();
// }

// class _EnterOTPScreenState extends State<EnterOTPScreen> {
//   final List<String> _otpDigits = ['', '', '', '', '', '']; // 6 digits for OTP
//   int _resendSeconds = 60;
//   Timer? _timer;
//   bool _isVerifying = false;

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendSeconds > 0) {
//         setState(() => _resendSeconds--);
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   void _addDigit(String digit) {
//     for (int i = 0; i < _otpDigits.length; i++) {
//       if (_otpDigits[i].isEmpty) {
//         setState(() => _otpDigits[i] = digit);
        
//         // Check if all digits entered
//         if (_otpDigits.every((d) => d.isNotEmpty)) {
//           _verifyOTP();
//         }
//         break;
//       }
//     }
//   }

//   void _removeDigit() {
//     for (int i = _otpDigits.length - 1; i >= 0; i--) {
//       if (_otpDigits[i].isNotEmpty) {
//         setState(() => _otpDigits[i] = '');
//         break;
//       }
//     }
//   }

//   Future<void> _verifyOTP() async {
//     setState(() => _isVerifying = true);
    
//     final otp = _otpDigits.join('');
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
//     final success = await authProvider.verifyOtp(widget.email, otp);
    
//     if (mounted) {
//       setState(() => _isVerifying = false);
      
//       if (success) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => CreateNewPasswordScreen(
//               email: widget.email,
//               otp: otp,
//             ),
//           ),
//         );
//       } else {
//         // Clear OTP on error
//         setState(() => _otpDigits.fillRange(0, 6, ''));
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Invalid OTP. Please try again.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _resendCode() async {
//     if (_resendSeconds == 0) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final success = await authProvider.sendPasswordReset(widget.email);
      
//       if (success) {
//         setState(() {
//           _resendSeconds = 60;
//           _otpDigits.fillRange(0, 6, '');
//         });
//         _startTimer();
        
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('OTP sent successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Failed to resend OTP'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1B1A20),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 padding: EdgeInsets.zero,
//                 alignment: Alignment.centerLeft,
//               ),

//               const SizedBox(height: 40),

//               Row(
//                 children: const [
//                   Text(
//                     'Enter OTP Code ',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   Text('🔐', style: TextStyle(fontSize: 24)),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               Text(
//                 'We sent a 6-digit code to ${widget.email}. Enter it below.',
//                 style: const TextStyle(
//                   color: Color(0xFF9CA3AF),
//                   fontSize: 16,
//                   height: 1.5,
//                 ),
//               ),

//               const SizedBox(height: 40),

//               // OTP boxes - 6 digits
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(6, (index) {
//                   return Container(
//                     width: 48,
//                     height: 56,
//                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF2A2930),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: _otpDigits[index].isNotEmpty
//                             ? const Color(0xFF5B7CFF)
//                             : const Color(0xFF3D4556),
//                         width: 2,
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         _otpDigits[index],
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//               ),

//               const SizedBox(height: 24),

//               // Loading indicator when verifying
//               if (_isVerifying)
//                 const Center(
//                   child: CircularProgressIndicator(
//                     color: Color(0xFF5B7CFF),
//                   ),
//                 ),

//               if (!_isVerifying) ...[
//                 Center(
//                   child: RichText(
//                     text: TextSpan(
//                       style: const TextStyle(
//                         color: Color(0xFF9CA3AF),
//                         fontSize: 15,
//                       ),
//                       children: [
//                         const TextSpan(text: 'You can resend the code in '),
//                         TextSpan(
//                           text: '$_resendSeconds',
//                           style: const TextStyle(
//                             color: Color(0xFF5B7CFF),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const TextSpan(text: ' seconds'),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 Center(
//                   child: TextButton(
//                     onPressed: _resendSeconds == 0 ? _resendCode : null,
//                     child: Text(
//                       'Resend code',
//                       style: TextStyle(
//                         color: _resendSeconds == 0
//                             ? const Color(0xFF5B7CFF)
//                             : const Color(0xFF6B7280),
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],

//               const Spacer(),

//               // Number Pad
//               _NumberPad(
//                 onNumberPressed: _addDigit,
//                 onDeletePressed: _removeDigit,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Screen 3: Create New Password - CẬP NHẬT
// class CreateNewPasswordScreen extends StatefulWidget {
//   final String email;
//   final String otp;
  
//   const CreateNewPasswordScreen({
//     super.key,
//     required this.email,
//     required this.otp,
//   });

//   @override
//   State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
// }

// class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _obscureNew = true;
//   bool _obscureConfirm = true;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleSavePassword() async {
//     if (_newPasswordController.text != _confirmPasswordController.text) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Passwords do not match')),
//       );
//       return;
//     }

//     if (_newPasswordController.text.length < 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Password must be at least 6 characters')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final success = await authProvider.resetPassword(
//       widget.email,
//       widget.otp,
//       _newPasswordController.text,
//     );

//     if (mounted) {
//       setState(() => _isLoading = false);
      
//       if (success) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const PasswordSuccessScreen()),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to reset password. Please try again.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1B1A20),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Back Button
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 padding: EdgeInsets.zero,
//                 alignment: Alignment.centerLeft,
//               ),
//               const SizedBox(height: 40),
              
//               // Title with emoji
//               Row(
//                 children: [
//                   const Text(
//                     'Secure Your Account ',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       height: 1.2,
//                     ),
//                   ),
//                   const Text('🔒', style: TextStyle(fontSize: 24)),
//                 ],
//               ),
//               const SizedBox(height: 12),
              
//               const Text(
//                 'Almost there! Create a new password for your Smartify account to keep it secure. Remember to choose a strong and unique password.',
//                 style: TextStyle(
//                   color: Color(0xFF9CA3AF),
//                   fontSize: 16,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 40),
              
//               // New Password Field
//               const Text(
//                 'New Password',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _newPasswordController,
//                 obscureText: _obscureNew,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   hintText: '••••••••••••',
//                   hintStyle: const TextStyle(color: Color(0xFF6B7280)),
//                   prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280), size: 20),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//                       color: const Color(0xFF6B7280),
//                       size: 20,
//                     ),
//                     onPressed: () {
//                       setState(() => _obscureNew = !_obscureNew);
//                     },
//                   ),
//                   filled: true,
//                   fillColor: const Color(0xFF2A2930),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               // Confirm Password Field
//               const Text(
//                 'Confirm New Password',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _confirmPasswordController,
//                 obscureText: _obscureConfirm,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   hintText: '••••••••••••',
//                   hintStyle: const TextStyle(color: Color(0xFF6B7280)),
//                   prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280), size: 20),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//                       color: const Color(0xFF6B7280),
//                       size: 20,
//                     ),
//                     onPressed: () {
//                       setState(() => _obscureConfirm = !_obscureConfirm);
//                     },
//                   ),
//                   filled: true,
//                   fillColor: const Color(0xFF2A2930),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//                 ),
//               ),
//               const SizedBox(height: 40),
              
//               // Separator line
//               Container(
//                 height: 1,
//                 margin: const EdgeInsets.only(bottom: 24),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.white.withOpacity(0),
//                       Colors.white.withOpacity(0.1),
//                       Colors.white.withOpacity(0),
//                     ],
//                   ),
//                 ),
//               ),
              
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _handleSavePassword,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF5B7CFF),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 18),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(28),
//                     ),
//                     elevation: 0,
//                     disabledBackgroundColor: const Color(0xFF5B7CFF).withOpacity(0.5),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         )
//                       : const Text(
//                           'Save New Password',
//                           style: TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// // Screen 4: Success
// class PasswordSuccessScreen extends StatelessWidget {
//   const PasswordSuccessScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1B1A20),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
//           child: Column(
//             children: [
//               // ===== CENTER CONTENT =====
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Success Icon (thu nhỏ + gọn)
//                       Container(
//                         width: 110,
//                         height: 110,
//                         decoration: const BoxDecoration(
//                           color: Color(0xFF5B7CFF),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Container(
//                             width: 86,
//                             height: 86,
//                             decoration: const BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.person,
//                               size: 44,
//                               color: Color(0xFF5B7CFF),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 32),

//                       const Text(
//                         "You're All Set!",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 28, // nhỏ hơn cho giống mẫu
//                           fontWeight: FontWeight.w700,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),

//                       const SizedBox(height: 12),

//                       const Text(
//                         'Your password has been successfully changed.',
//                         style: TextStyle(
//                           color: Color(0xFF9CA3AF),
//                           fontSize: 15,
//                           height: 1.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // ===== BOTTOM AREA =====
//               Column(
//                 children: [
//                   Container(
//                     height: 1,
//                     margin: const EdgeInsets.only(bottom: 20),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.white.withOpacity(0),
//                           Colors.white.withOpacity(0.12),
//                           Colors.white.withOpacity(0),
//                         ],
//                       ),
//                     ),
//                   ),

//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(context)
//                             .popUntil((route) => route.isFirst);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF5B7CFF),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 18),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(28),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: const Text(
//                         'Go to Homepage',
//                         style: TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// // Number Pad Widget
// class _NumberPad extends StatelessWidget {
//   final Function(String) onNumberPressed;
//   final VoidCallback onDeletePressed;

//   const _NumberPad({
//     required this.onNumberPressed,
//     required this.onDeletePressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildNumberRow(['1', '2', '3']),
//         const SizedBox(height: 16),
//         _buildNumberRow(['4', '5', '6']),
//         const SizedBox(height: 16),
//         _buildNumberRow(['7', '8', '9']),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildNumberButton('*'),
//             _buildNumberButton('0'),
//             _buildDeleteButton(),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildNumberRow(List<String> numbers) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: numbers.map((n) => _buildNumberButton(n)).toList(),
//     );
//   }

//   Widget _buildNumberButton(String number) {
//     return InkWell(
//       onTap: () => onNumberPressed(number),
//       borderRadius: BorderRadius.circular(50),
//       child: Container(
//         width: 80,
//         height: 60,
//         decoration: const BoxDecoration(
//           color: Colors.transparent,
//           shape: BoxShape.circle,
//         ),
//         child: Center(
//           child: Text(
//             number,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 28,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDeleteButton() {
//     return InkWell(
//       onTap: onDeletePressed,
//       borderRadius: BorderRadius.circular(50),
//       child: Container(
//         width: 80,
//         height: 80,
//         decoration: const BoxDecoration(
//           color: Colors.transparent,
//           shape: BoxShape.circle,
//         ),
//         child: const Center(
//           child: Icon(
//             Icons.backspace_outlined,
//             color: Colors.white,
//             size: 28,
//           ),
//         ),
//       ),
//     );
//   }
// }