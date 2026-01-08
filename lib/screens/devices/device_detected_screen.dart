import 'package:flutter/material.dart';
import 'device_connecting_screen.dart';

class DeviceDetectedScreen extends StatelessWidget {
  final String deviceName;
  final String deviceType;
  final String? deviceImage; // Đường dẫn ảnh (nếu có)

  const DeviceDetectedScreen({
    super.key,
    required this.deviceName,
    required this.deviceType,
    this.deviceImage,
  });

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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
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
                        _buildStatusIcon(Icons.wifi),
                        const SizedBox(width: 8),
                        _buildStatusIcon(Icons.bluetooth),
                        const SizedBox(width: 12),
                        const Flexible(
                          child: Text(
                            'Turn on your Wifi & Bluetooth to connect',
                            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                          ),
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
                          deviceName,
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
                  
                  // Device image (Hiển thị ảnh Router hoặc icon mặc định)
                  _buildDeviceImage(deviceType),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          
          // Bottom section
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Connect button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeviceConnectingScreen(
                            deviceName: deviceName,
                            deviceType: deviceType,
                            // Truyền ảnh sang màn hình connecting để đồng bộ
                            deviceImage: deviceImage ?? '', 
                          ),
                        ),
                      );
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
                      'Connect',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF5B7CFF),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildDeviceImage(String deviceType) {
    return Container(
      width: 250,
      height: 250,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2930),
        shape: BoxShape.circle,
      ),
      // Sử dụng ClipOval để ảnh nằm gọn trong hình tròn
      child: ClipOval(
        child: (deviceImage != null && deviceImage!.isNotEmpty)
            ? Padding(
                // Thêm padding nhỏ để ảnh không bị cắt quá sát nếu là hình vuông
                padding: const EdgeInsets.all(20.0), 
                child: Image.asset(
                  deviceImage!,
                  fit: BoxFit.contain,
                  // Nếu đường dẫn ảnh sai, tự động hiện icon
                  errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(deviceType),
                ),
              )
            : _buildFallbackIcon(deviceType),
      ),
    );
  }

  Widget _buildFallbackIcon(String deviceType) {
    IconData icon;
    // Chuẩn hóa chuỗi về chữ thường để so sánh
    switch (deviceType.toLowerCase()) {
      case 'smart_router': // Thêm case này cho yêu cầu của bạn
      case 'router':
        icon = Icons.router;
        break;
      case 'lamp':
        icon = Icons.lightbulb;
        break;
      case 'speaker':
        icon = Icons.speaker;
        break;
      case 'camera':
      case 'cctv':
      case 'webcam':
        icon = Icons.videocam;
        break;
      default:
        icon = Icons.devices_other;
    }
    return Center(
      child: Icon(
        icon,
        size: 100,
        color: const Color(0xFF5B7CFF).withOpacity(0.5),
      ),
    );
  }
}