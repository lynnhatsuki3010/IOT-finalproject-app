import 'package:flutter/material.dart';
import 'onboarding_screen.dart'; // Đảm bảo bạn vẫn giữ file này

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF3E5EF1),
      // Sử dụng top: true, bottom: false để màu đen tràn xuống tận đáy màn hình
      body: SafeArea(
        bottom: false, 
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // ================================================
            // LỚP 1: PHONE MOCKUP (Nằm dưới)
            // ================================================
            Positioned(
              top: size.height * 0.05,
              left: 0,
              right: 0,
              // Chừa khoảng trống bên dưới để phần đen đè lên (khoảng 35% màn hình)
              bottom: size.height * 0.25, 
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildImagePage('assets/mockup/walkthrough1.png', size),
                  _buildImagePage('assets/mockup/walkthrough2.png', size),
                  _buildImagePage('assets/mockup/walkthrough3.png', size),
                ],
              ),
            ),

            // ================================================
            // LỚP 2: BOTTOM SHEET (Nằm đè lên trên)
            // ================================================
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              // Chiều cao phần đen chiếm khoảng 45% màn hình
              height: size.height * 0.45, 
              child: Stack(
                children: [
                  // 2.1 Background màu đen với đường cong
                  ClipPath(
                    clipper: _ArcClipper(),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B1A20),
                      ),
                    ),
                  ),

                  // 2.2 Nội dung Text & Button
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      24, 
                      size.height * 0.08, // Padding top lớn để né đường cong
                      24, 
                      size.height * 0.04  // Padding bottom để cách đáy màn hình
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn đều các phần tử
                      children: [
                        // --- Title & Description Group ---
                        Column(
                          children: [
                            Text(
                              _getTitles()[_currentPage],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: size.height * 0.015),
                            Text(
                              _getDescriptions()[_currentPage],
                              style: const TextStyle(
                                color: Color(0xFFA0AEC0),
                                fontSize: 15,
                                fontFamily: 'Inter',
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                        // --- Indicators ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? const Color(0xFF3E5EF1)
                                    : Colors.grey[700],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        // --- Buttons ---
                        // Đường kẻ mờ
                        Column(
                          children: [
                            Container(
                              height: 1,
                              margin: const EdgeInsets.only(bottom: 20),
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
                            Row(
                              children: [
                                if (_currentPage < 2) ...[
                                  Expanded(
                                    child: TextButton(
                                      onPressed: _goToOnboarding,
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        backgroundColor: const Color(0xFF2A2930),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(28),
                                        ),
                                      ),
                                      child: const Text(
                                        'Skip',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  flex: _currentPage < 2 ? 2 : 1,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_currentPage < 2) {
                                        _pageController.nextPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      } else {
                                        _goToOnboarding();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3E5EF1),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      _currentPage < 2 ? 'Continue' : "Let's Get Started",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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

  void _goToOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  List<String> _getTitles() {
    return [
      'Empower Your Home,\nSimplify Your Life',
      'Effortless Control,\nAutomate, & Secure',
      'Efficiency that Saves,\nComfort that Lasts.',
    ];
  }

  List<String> _getDescriptions() {
    return [
      'Transform your living space into a smarter, more connected home with Smartify. All at your fingertips.',
      'Smartify empowers you to control your devices, & automate your routines. Embrace a world where your home adapts to your needs',
      'Take control of your home\'s energy usage, set preferences, and enjoy a space that adapts to your needs while saving power.',
    ];
  }

  // Widget hiển thị ảnh mockup (Đã chỉnh sửa)
  Widget _buildImagePage(String imagePath, Size size) {
    return Container(
      alignment: Alignment.bottomCenter,
      // Loại bỏ padding bottom để ảnh sát mép dưới khung chứa
      child: Container(
        width: size.width * 0.9, // Tăng nhẹ độ rộng để ảnh nhìn to rõ hơn
        decoration: BoxDecoration(
          // Bạn có thể giữ hoặc bỏ shadow tùy vào ảnh gốc đã có shadow chưa
          
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Image.asset(
            imagePath,
            // 👇 CỰC KỲ QUAN TRỌNG: Dùng contain để hiện toàn bộ file ảnh gốc
            fit: BoxFit.contain, 
          ),
        ),
      ),
    );
  }
}

// Custom Clipper (Đã chỉnh sửa độ cong)
class _ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Start from top-left
    path.moveTo(0, 0);
    
    // Create deep arc curve
    path.quadraticBezierTo(
      size.width / 2, // control point x (center)
      60,             // control point y (Tăng lên 60 để cong sâu hơn, tạo cảm giác ôm lấy đt)
      size.width,     // end point x (right)
      0,              // end point y (top)
    );
    
    // Draw to bottom-right
    path.lineTo(size.width, size.height);
    
    // Draw to bottom-left
    path.lineTo(0, size.height);
    
    // Close path
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}