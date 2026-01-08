import 'package:flutter/material.dart';
import 'dart:math' as math;

class DeviceControlScreen extends StatefulWidget {
  final String deviceName;
  final String deviceType;
  final String room;

  const DeviceControlScreen({
    super.key,
    required this.deviceName,
    required this.deviceType,
    this.room = 'Living Room',
  });

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  String _selectedMode = 'White';
  double _brightness = 85;
  bool _isPowerOn = true;
  double _temperaturePosition = 0.25; // 0 = warm, 1 = cool

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1A20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Control Device',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Device header
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2930),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getDeviceIcon(widget.deviceType),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.deviceName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.room,
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isPowerOn,
                        onChanged: (value) => setState(() => _isPowerOn = value),
                        activeColor: const Color(0xFF5B7CFF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Mode tabs
                  Row(
                    children: [
                      Expanded(child: _buildModeTab('White')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildModeTab('Color')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildModeTab('Scene')),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Color/Temperature Wheel
                  if (_selectedMode == 'White')
                    _buildTemperatureWheel()
                  else if (_selectedMode == 'Color')
                    _buildColorWheel()
                  else
                    _buildSceneOptions(),
                  
                  const SizedBox(height: 60),
                  
                  // Brightness slider
                  _buildBrightnessSlider(),
                ],
              ),
            ),
          ),
          
          // Bottom button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showScheduleDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A2930),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Schedule Automatic ON/OFF',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(String mode) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B7CFF) : const Color(0xFF2A2930),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            mode,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureWheel() {
    return GestureDetector(
      onPanUpdate: (details) {
        final center = Offset(150, 150);
        final position = details.localPosition - center;
        final angle = math.atan2(position.dy, position.dx);
        setState(() {
          _temperaturePosition = (angle + math.pi) / (2 * math.pi);
        });
      },
      child: Container(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(300, 300),
              painter: TemperatureWheelPainter(_temperaturePosition),
            ),
            // Lamp icon in center
            Icon(
              Icons.lightbulb,
              size: 120,
              color: Colors.white.withOpacity(0.9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorWheel() {
    return Container(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(300, 300),
            painter: ColorWheelPainter(),
          ),
          Icon(
            Icons.lightbulb,
            size: 120,
            color: Colors.white.withOpacity(0.9),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneOptions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSceneChip('Reading', Icons.menu_book),
        _buildSceneChip('Relax', Icons.self_improvement),
        _buildSceneChip('Party', Icons.celebration),
        _buildSceneChip('Sleep', Icons.nightlight),
      ],
    );
  }

  Widget _buildSceneChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2930),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF5B7CFF), size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBrightnessSlider() {
    return Row(
      children: [
        const Icon(Icons.wb_sunny_outlined, color: Color(0xFF9CA3AF), size: 24),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF5B7CFF),
              inactiveTrackColor: const Color(0xFF2A2930),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF5B7CFF).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
            ),
            child: Slider(
              value: _brightness,
              min: 0,
              max: 100,
              onChanged: (value) => setState(() => _brightness = value),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${_brightness.toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType) {
      case 'lamp':
        return Icons.lightbulb;
      case 'speaker':
        return Icons.speaker;
      case 'camera':
      case 'cctv':
      case 'webcam':
        return Icons.videocam;
      case 'router':
        return Icons.router;
      default:
        return Icons.devices;
    }
  }

  void _showScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2930),
        title: const Text(
          'Schedule',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Schedule feature coming soon!',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF5B7CFF)),
            ),
          ),
        ],
      ),
    );
  }
}

// Temperature Wheel Painter (Warm to Cool)
class TemperatureWheelPainter extends CustomPainter {
  final double position;

  TemperatureWheelPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // Draw gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFFFFE5B4), // Warm
          const Color(0xFFFFFFFF), // White
          const Color(0xFFE0F4FF), // Cool
          const Color(0xFFFFE5B4), // Back to warm
        ],
        stops: const [0.0, 0.5, 0.75, 1.0],
      ).createShader(rect)
      ..strokeWidth = 40
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, paint);
    
    // Draw selector indicator
    final angle = position * 2 * math.pi - math.pi;
    final indicatorX = center.dx + radius * math.cos(angle);
    final indicatorY = center.dy + radius * math.sin(angle);
    
    final indicatorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(indicatorX, indicatorY), 15, indicatorPaint);
    
    // Inner circle
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, radius - 60, innerPaint);
  }

  @override
  bool shouldRepaint(TemperatureWheelPainter oldDelegate) =>
      oldDelegate.position != position;
}

// Color Wheel Painter
class ColorWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // Draw full color spectrum
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.red,
          Colors.yellow,
          Colors.green,
          Colors.cyan,
          Colors.blue,
          Colors.purple,
          Colors.red,
        ],
      ).createShader(rect)
      ..strokeWidth = 40
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius, paint);
    
    // Inner circle
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, radius - 60, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}