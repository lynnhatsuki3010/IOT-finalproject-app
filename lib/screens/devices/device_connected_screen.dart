import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';
import 'device_control_screen.dart';
import 'plugin_control_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../models/device.dart';

class DeviceConnectedScreen extends StatelessWidget {
  final String deviceName;
  final String deviceType;
  final String deviceImage;

  // ✅ CẤU HÌNH WEBSOCKET URL
  static const String WEBSOCKET_URL = 'wss://unreliant-alysa-distractingly.ngrok-free.dev';
  
  // ✅ CỐ ĐỊNH TOPIC CHO SMART PLUG
  static const String PLUGIN_CONTROL_TOPIC = '/plugin/control';
  static const String PLUGIN_STATUS_TOPIC = '/plugin/status';

  const DeviceConnectedScreen({
    super.key,
    required this.deviceName,
    required this.deviceType,
    required this.deviceImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A20),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success checkmark
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5B7CFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 40),
                    
                    const Text(
                      'Connected!',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'You have connected to $deviceName.',
                        style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 60),
                    
                    // Device image
                    Container(
                      width: 250,
                      height: 250,
                      decoration: const BoxDecoration(color: Color(0xFF2A2930), shape: BoxShape.circle),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Image.asset(
                            deviceImage,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              _getDeviceIcon(deviceType),
                              size: 120,
                              color: const Color(0xFF5B7CFF).withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2930),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Text('Go to Homepage', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final homeProvider = Provider.of<HomeProvider>(context, listen: false);
                        
                        final userId = authProvider.user?.userId;
                        if (userId != null) {
                          // ✅ TẠO DEVICE VỚI TOPIC CỐ ĐỊNH CHO SMART PLUG
                          final device = Device(
                            id: '',
                            name: deviceName,
                            type: deviceType,
                            connectionType: 'Wi-Fi',
                            room: 'Living Room',
                            isOn: false,
                          );

                          // ✅ LƯU THIẾT BỊ VÀO DATABASE
                          final success = await homeProvider.addDevice(device, userId);
                          
                          if (success && context.mounted) {
                            // ✅ KIỂM TRA LOẠI THIẾT BỊ VÀ ĐIỀU HƯỚNG ĐÚNG
                            if (_isSmartPlug(deviceType)) {
                              // Chuyển sang PluginControlScreen với WebSocket
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PluginControlScreen(
                                    deviceName: deviceName,
                                    baseUrl: WEBSOCKET_URL,
                                  ),
                                ),
                              );
                            } else {
                              // Các thiết bị khác dùng DeviceControlScreen thông thường
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DeviceControlScreen(
                                    deviceName: deviceName,
                                    deviceType: deviceType,
                                  ),
                                ),
                              );
                            }
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to save device'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7CFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Text('Control Device', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

  // ✅ HÀM KIỂM TRA LOẠI SMART PLUG
  bool _isSmartPlug(String deviceType) {
    final type = deviceType.toLowerCase();
    return type == 'smart_plug' || 
           type == 'plug' || 
           type == 'smart plug' ||
           type == 'smartplug';
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'lamp':
      case 'light':
        return Icons.lightbulb;
      case 'speaker':
        return Icons.speaker;
      case 'camera':
      case 'cctv':
      case 'webcam':
        return Icons.videocam;
      case 'router':
        return Icons.router;
      case 'smart_plug':
      case 'plug':
      case 'smart plug':
      case 'smartplug':
        return Icons.power;
      default:
        return Icons.devices;
    }
  }
}