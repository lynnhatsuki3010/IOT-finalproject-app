import 'package:flutter/material.dart';
import 'dart:math' as math;

class VoiceCommandScreen extends StatefulWidget {
  const VoiceCommandScreen({super.key});

  @override
  State<VoiceCommandScreen> createState() => _VoiceCommandScreenState();
}

class _VoiceCommandScreenState extends State<VoiceCommandScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _orbController;
  late AnimationController _pulseController;
  
  final String _mainText = '"Turn on all the lights in the entire room"';

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _orbController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ),

          Column(
            children: [
              const Spacer(flex: 3),

              const Text(
                'We are listening...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'What do you want to do?',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  _mainText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28, 
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              SizedBox(
                height: 180, 
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: SiriWavePainter(_waveController.value),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
              
              const Spacer(flex: 3),

              // IMPROVED ORB - Giống Siri hơn
              AnimatedBuilder(
                animation: Listenable.merge([_orbController, _pulseController]),
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow layers (nhiều lớp để tạo độ sâu)
                      ...List.generate(3, (index) {
                        return Container(
                          width: 160 + (index * 30),
                          height: 160 + (index * 30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF00B4DB).withOpacity(0.3 - index * 0.1),
                                const Color(0xFF8E44AD).withOpacity(0.2 - index * 0.08),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.3, 1.0],
                            ),
                          ),
                        );
                      }),

                      // Main orb với animated waves
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00B4DB).withOpacity(0.6),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: const Color(0xFF8E44AD).withOpacity(0.4),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: SiriOrbPainter(
                            _orbController.value,
                            _pulseController.value,
                          ),
                        ),
                      ),

                      // Rim light (viền sáng)
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                            ],
                            stops: const [0.7, 1.0],
                          ),
                        ),
                      ),

                      // Center highlight
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.3, -0.4),
                            colors: [
                              Colors.white.withOpacity(0.4),
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.2, 0.6],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }
}

// Painter vẽ sóng âm (giữ nguyên code cũ của bạn)
class SiriWavePainter extends CustomPainter {
  final double animationValue;

  SiriWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final centerX = size.width / 2;

    final waves = [
      _WaveLayer(color: const Color(0xFFA8E6CF), amplitude: 0.3, speed: 1.0, offset: 0),
      _WaveLayer(color: const Color(0xFFDCEDC1), amplitude: 0.5, speed: 1.4, offset: 2),
      _WaveLayer(color: const Color(0xFFFFD3B6), amplitude: 0.4, speed: 1.2, offset: 4),
      _WaveLayer(color: const Color(0xFFFFAAA5), amplitude: 0.6, speed: 0.8, offset: 1),
      _WaveLayer(color: const Color(0xFFFF8B94), amplitude: 0.8, speed: 1.1, offset: 3),
      _WaveLayer(color: const Color(0xFF00B4DB), amplitude: 1.0, speed: 1.0, offset: 0),
      _WaveLayer(color: const Color(0xFF8E44AD), amplitude: 0.9, speed: 1.3, offset: 2.5),
    ];

    for (var wave in waves) {
      _drawSingleWave(canvas, size, centerY, centerX, wave);
    }
  }

  void _drawSingleWave(Canvas canvas, Size size, double centerY, double centerX, _WaveLayer wave) {
    final paint = Paint()
      ..color = wave.color.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();
    path.moveTo(0, centerY);

    for (double x = 0; x <= size.width; x += 2) {
      double distFromCenter = (x - centerX).abs();
      double attenuation = math.max(0, 1.0 - (distFromCenter / (size.width * 0.5)));
      attenuation = attenuation * attenuation; 

      double sineValue = math.sin((x / size.width * 10) + (animationValue * 2 * math.pi * wave.speed) + wave.offset);
      double yOffset = sineValue * 40 * wave.amplitude * attenuation;

      path.lineTo(x, centerY + yOffset);
    }

    for (double x = size.width; x >= 0; x -= 2) {
      double distFromCenter = (x - centerX).abs();
      double attenuation = math.max(0, 1.0 - (distFromCenter / (size.width * 0.5)));
      attenuation = attenuation * attenuation;

      double sineValue = math.sin((x / size.width * 10) + (animationValue * 2 * math.pi * wave.speed) + wave.offset);
      double yOffset = -sineValue * 40 * wave.amplitude * attenuation;
      path.lineTo(x, centerY + yOffset);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SiriWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _WaveLayer {
  final Color color;
  final double amplitude;
  final double speed;
  final double offset;

  _WaveLayer({
    required this.color,
    required this.amplitude,
    required this.speed,
    required this.offset,
  });
}

// NEW: Painter vẽ orb với wave patterns bên trong
class SiriOrbPainter extends CustomPainter {
  final double rotation;
  final double pulse;

  SiriOrbPainter(this.rotation, this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Clip hình tròn
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    // Base gradient background
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1a1a2e),
          const Color(0xFF0f0f1e),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Vẽ các wave patterns (giống sọc trong ảnh)
    _drawWavePatterns(canvas, size, center, radius);

    // Gradient overlay
    final gradientPaint = Paint()
      ..shader = SweepGradient(
        transform: GradientRotation(rotation * 2 * math.pi),
        colors: [
          const Color(0xFF00B4DB).withOpacity(0.6),
          const Color(0xFF0083B0).withOpacity(0.4),
          const Color(0xFF8E44AD).withOpacity(0.6),
          const Color(0xFFB565D8).withOpacity(0.5),
          const Color(0xFF00B4DB).withOpacity(0.6),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(center, radius, gradientPaint);
  }

  void _drawWavePatterns(Canvas canvas, Size size, Offset center, double radius) {
    // Vẽ nhiều curves/waves chéo như trong ảnh
    for (int i = 0; i < 30; i++) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      final path = Path();
      final angle = (i / 30) * 2 * math.pi + rotation * 2 * math.pi;
      final waveOffset = math.sin(rotation * 4 * math.pi + i * 0.5) * 15;

      // Tạo đường cong từ góc này sang góc kia
      final startAngle = angle - 0.8;
      final endAngle = angle + 0.8;

      path.moveTo(
        center.dx + math.cos(startAngle) * radius * 0.3,
        center.dy + math.sin(startAngle) * radius * 0.3,
      );

      // Bezier curve để tạo đường uốn lượn
      path.quadraticBezierTo(
        center.dx + waveOffset,
        center.dy + waveOffset,
        center.dx + math.cos(endAngle) * radius * 0.9,
        center.dy + math.sin(endAngle) * radius * 0.9,
      );

      canvas.drawPath(path, paint);
    }

    // Thêm một số curves lớn hơn, nổi bật hơn
    for (int i = 0; i < 5; i++) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final path = Path();
      final angle = (i / 5) * 2 * math.pi + rotation * 1.5 * math.pi;
      final waveOffset = math.sin(rotation * 3 * math.pi + i) * 25;

      final startAngle = angle - 1.2;
      final endAngle = angle + 1.2;

      path.moveTo(
        center.dx + math.cos(startAngle) * radius * 0.2,
        center.dy + math.sin(startAngle) * radius * 0.2,
      );

      path.cubicTo(
        center.dx + waveOffset * 0.5,
        center.dy - waveOffset * 0.8,
        center.dx - waveOffset * 0.7,
        center.dy + waveOffset * 0.6,
        center.dx + math.cos(endAngle) * radius * 0.95,
        center.dy + math.sin(endAngle) * radius * 0.95,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SiriOrbPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
  }
}