import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../models/device.dart';
import 'device_control_screen.dart';
import 'plugin_control_screen.dart'; // ✅ THÊM IMPORT

class CategoryDevicesScreen extends StatelessWidget {
  final String category;
  final IconData icon;
  final Color color;

  // ✅ CẤU HÌNH WEBSOCKET URL
  static const String WEBSOCKET_URL = 'wss://unreliant-alysa-distractingly.ngrok-free.dev';

  const CategoryDevicesScreen({
    super.key,
    required this.category,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final devices = _getDevicesByCategory(homeProvider.devices);
        
        return Scaffold(
          backgroundColor: const Color(0xFF1B1A20),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1B1A20),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '$category (${devices.length})',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          body: devices.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    return _buildDeviceCard(context, devices[index], homeProvider);
                  },
                ),
        );
      },
    );
  }

  List<Device> _getDevicesByCategory(List<Device> devices) {
    switch (category) {
      case 'Lightning':
        return devices.where((d) => 
          ['lamp', 'light'].contains(d.type.toLowerCase())
        ).toList();
      case 'Cameras':
        return devices.where((d) => 
          ['camera', 'cctv', 'webcam'].contains(d.type.toLowerCase())
        ).toList();
      case 'Electrical':
        return devices.where((d) => 
          !['lamp', 'light', 'camera', 'cctv', 'webcam'].contains(d.type.toLowerCase())
        ).toList();
      default:
        return devices;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            'No $category Devices',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add devices to see them here',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, Device device, HomeProvider provider) {
    return GestureDetector(
      onTap: () {
        // ✅ KIỂM TRA LOẠI THIẾT BỊ VÀ ĐIỀU HƯỚNG ĐÚNG
        if (_isSmartPlug(device.type)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PluginControlScreen(
                deviceName: device.name,
                baseUrl: WEBSOCKET_URL, // ✅ SỬ DỤNG WEBSOCKET
                deviceId: device.id,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeviceControlScreen(
                deviceName: device.name,
                deviceType: device.type,
                room: device.room,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2930),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Image.asset(
                    device.getImagePath(),
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      _getSpecificIcon(device.type),
                      color: color,
                      size: 48,
                    ),
                  ),
                ),
                Switch(
                  value: device.isOn,
                  onChanged: (value) {
                    provider.toggleDevice(device.id);
                  },
                  activeColor: const Color(0xFF5B7CFF),
                ),
              ],
            ),
            const Spacer(),
            Text(
              device.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              device.room,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  device.connectionType == 'Wi-Fi' ? Icons.wifi : Icons.bluetooth,
                  color: const Color(0xFF9CA3AF),
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  device.connectionType,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
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

  IconData _getSpecificIcon(String type) {
    switch (type.toLowerCase()) {
      case 'lamp':
      case 'light':
        return Icons.lightbulb_outline;
      case 'camera':
      case 'cctv':
        return Icons.videocam_outlined;
      case 'speaker':
        return Icons.speaker_outlined;
      case 'smart_plug':
      case 'plug':
      case 'smart plug':
      case 'smartplug':
        return Icons.power; // ✅ ICON CHO SMART PLUG
      default:
        return Icons.devices;
    }
  }
}