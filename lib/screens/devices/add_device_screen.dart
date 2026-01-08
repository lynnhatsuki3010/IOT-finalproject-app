import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/home_provider.dart';
import '../../models/device.dart';
import 'scan_device_screen.dart';
import 'device_detected_screen.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _radarController;
  String _selectedCategory = 'Popular';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  final List<String> _categories = ['Popular', 'Lightning', 'Camera', 'Electrical'];

  final List<Map<String, dynamic>> _manualDevices = [
    {
      'name': 'Smart V1 CCTV',
      'type': 'cctv',
      'image': 'assets/devices/smartv1cctv.png',
      'connectionType': 'Wi-Fi',
    },
    {
      'name': 'Smart Webcam',
      'type': 'webcam',
      'image': 'assets/devices/smartwebcam.png',
      'connectionType': 'Wi-Fi',
    },
    {
      'name': 'Smart V2 CCTV',
      'type': 'cctv',
      'image': 'assets/devices/smartv2cctv.png',
      'connectionType': 'Wi-Fi',
    },
    {
      'name': 'Smart Lamp',
      'type': 'lamp',
      'image': 'assets/devices/smartlamp.png',
      'connectionType': 'Wi-Fi',
    },
    {
      'name': 'Smart Speaker',
      'type': 'speaker',
      'image': 'assets/devices/smartspeaker.png',
      'connectionType': 'Bluetooth',
    },
    {
      'name': 'Smart Router',
      'type': 'router',
      'image': 'assets/devices/smartplugin.png',
      'connectionType': 'Wi-Fi',
    },
  ];

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
          'Add Device',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanDeviceScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2930),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Nearby Devices',
                    _tabController.index == 0,
                    () => setState(() => _tabController.animateTo(0)),
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    'Add Manual',
                    _tabController.index == 1,
                    () => setState(() => _tabController.animateTo(1)),
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNearbyDevicesTab(),
                _buildAddManualTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B7CFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyDevicesTab() {
    return Column(
      children: [
        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                const Text(
                  'Looking for nearby devices...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),

                // WiFi & Bluetooth info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2930),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5B7CFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.wifi, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5B7CFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bluetooth, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Flexible(
                        child: Text(
                          'Turn on your Wifi & Bluetooth',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Radar Animation - Fixed size
                SizedBox(
                  width: 280,
                  height: 280,
                  child: AnimatedBuilder(
                    animation: _radarController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(280, 280),
                        painter: RadarPainter(_radarController.value),
                        child: child,
                      );
                    },
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2A2930),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/avatar.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 45,
                                color: Color(0xFF9CA3AF),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),

        // Fixed bottom section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1A20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Connect Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DeviceDetectedScreen(
                                deviceName: 'Stereo Speaker',
                                deviceType: 'speaker',
                              ),
                            ),
                          );
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B7CFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Connect to All Devices',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Help links
                const Text(
                  "Can't find your devices?",
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    'Learn more',
                    style: TextStyle(
                      color: Color(0xFF5B7CFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddManualTab() {
    return Column(
      children: [
        // Category chips
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedCategory == _categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildCategoryChip(_categories[index], isSelected),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Device Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            itemCount: _manualDevices.length,
            itemBuilder: (context, index) {
              return _buildDeviceCard(_manualDevices[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B7CFF) : const Color(0xFF2A2930),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeviceDetectedScreen(
              deviceName: device['name'],
              deviceType: device['type'],
              deviceImage: device['image'],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2930),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                device['image'],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    _getDeviceIcon(device['type']),
                    size: 70,
                    color: const Color(0xFF5B7CFF),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              device['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType) {
      case 'lamp':
        return Icons.lightbulb;
      case 'camera':
      case 'cctv':
      case 'webcam':
        return Icons.videocam;
      case 'speaker':
        return Icons.speaker;
      case 'router':
        return Icons.router;
      default:
        return Icons.devices;
    }
  }
}

// Radar Animation Painter
class RadarPainter extends CustomPainter {
  final double progress;

  RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw 3 radar circles
    for (int i = 1; i <= 3; i++) {
      final radius = maxRadius * (i / 3);
      final paint = Paint()
        ..color = const Color(0xFF5B7CFF).withOpacity(0.1 + (i * 0.1))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }

    // Draw scanning arc
    final sweepAngle = math.pi * 2 * progress;
    final arcPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF5B7CFF).withOpacity(0.5),
          const Color(0xFF5B7CFF).withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: maxRadius),
        -math.pi / 2,
        sweepAngle,
        false,
      )
      ..close();

    canvas.drawPath(path, arcPaint);
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) => oldDelegate.progress != progress;
}