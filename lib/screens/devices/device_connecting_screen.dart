import 'package:flutter/material.dart';
import 'dart:async';
import 'device_connected_screen.dart';

class DeviceConnectingScreen extends StatefulWidget {
  final String deviceName;
  final String deviceType;
  final String deviceImage; // Thêm dòng này

  const DeviceConnectingScreen({
    super.key,
    required this.deviceName,
    required this.deviceType,
    required this.deviceImage, // Thêm dòng này
  });

  @override
  State<DeviceConnectingScreen> createState() => _DeviceConnectingScreenState();
}

class _DeviceConnectingScreenState extends State<DeviceConnectingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress = (_controller.value * 100).toInt();
      });
    });

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DeviceConnectedScreen(
              deviceName: widget.deviceName,
              deviceType: widget.deviceType,
              deviceImage: widget.deviceImage, // Thêm dòng này
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

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
          'Device Detected',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Connect to device',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            // WiFi & Bluetooth info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2930),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5B7CFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.wifi, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5B7CFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bluetooth, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Turn on your Wifi & Bluetooth to connect',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Device name chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF5B7CFF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.deviceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            
            // Device with circular progress
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 4,
                    color: const Color(0xFF5B7CFF),
                    backgroundColor: const Color(0xFF2A2930),
                  ),
                ),
                Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A2930),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval( // Sử dụng ClipOval để ảnh nằm gọn trong vòng tròn
                    child: Padding(
                      padding: const EdgeInsets.all(30.0), // Padding để ảnh không sát mép
                      child: Image.asset(
                        widget.deviceImage,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          _getDeviceIcon(widget.deviceType),
                          size: 100,
                          color: const Color(0xFF5B7CFF).withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Connecting...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            
            Text(
              '$_progress%',
              style: const TextStyle(
                color: Color(0xFF5B7CFF),
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            
            const Text(
              "Can't connect with your devices?",
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Learn more',
                style: TextStyle(
                  color: Color(0xFF5B7CFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
}