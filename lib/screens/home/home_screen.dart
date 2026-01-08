import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/device.dart';
import '../devices/add_device_screen.dart';
import '../devices/scan_device_screen.dart';
import '../devices/device_control_screen.dart';
import '../devices/plugin_control_screen.dart'; // ✅ THÊM IMPORT
import '../chat/chat_screen.dart';
import '../notifications/notification_screen.dart';
import '../devices/category_devices_screen.dart';
import '../devices/voice_command_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  bool _showFabMenu = false;
  bool _showHomeMenu = false;

  // ✅ BASE URL WEBSOCKET (đổi theo ngrok của bạn)
  // Dùng wss:// cho ngrok domain hoặc ws:// cho TCP port
  static const String WEBSOCKET_BASE_URL = 'wss://unreliant-alysa-distractingly.ngrok-free.dev';
  
  // ✅ HOẶC dùng TCP port (uncomment dòng dưới nếu dùng ngrok tcp)
  // static const String WEBSOCKET_BASE_URL = 'ws://0.tcp.ap.ngrok.io:17408';

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    
    final userId = authProvider.user?.userId;
    if (userId != null) {
      await homeProvider.loadHomeData(userId.toString());
    }
  }

  // ✅ HÀM ĐIỀU HƯỚNG ĐÚNG THEO LOẠI THIẾT BỊ
  void _navigateToDeviceControl(Device device) {
    if (_isSmartPlug(device.type)) {
      // Điều hướng đến PluginControlScreen với WebSocket
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PluginControlScreen(
            deviceName: device.name,
            baseUrl: WEBSOCKET_BASE_URL, // ✅ SỬ DỤNG WEBSOCKET_BASE_URL
            deviceId: device.id,
          ),
        ),
      );
    } else {
      // Các thiết bị khác dùng DeviceControlScreen thông thường
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
  }

  // ✅ HÀM KIỂM TRA LOẠI SMART PLUG
  bool _isSmartPlug(String deviceType) {
    final type = deviceType.toLowerCase();
    return type == 'smart_plug' || 
           type == 'plug' || 
           type == 'smart plug' ||
           type == 'smartplug';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final devices = homeProvider.filteredDevices;
        final rooms = homeProvider.getRoomList();
        final devicesByCategory = homeProvider.devicesByCategory;
        
        return Scaffold(
          backgroundColor: const Color(0xFF1B1A20),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          // Home Name với Dropdown
                          GestureDetector(
                            onTap: () {
                              setState(() => _showHomeMenu = !_showHomeMenu);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  homeProvider.homeData?.homeName ?? 'My Home',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                Icon(
                                  _showHomeMenu 
                                    ? Icons.keyboard_arrow_up 
                                    : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ChatScreen()),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2930),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF5B7CFF), width: 2),
                              ),
                              child: const Icon(Icons.face, color: Color(0xFF5B7CFF), size: 22),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NotificationScreen()),
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2A2930),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF5252),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Weather Card
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF5B7CFF), Color(0xFF4C6FE8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '20°C',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 42,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            'New York City, USA',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Today Cloudy',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing: 12,
                                            children: [
                                              _buildWeatherInfo(Icons.water_drop_outlined, 'AQI 92'),
                                              _buildWeatherInfo(Icons.water_drop, '78.2%'),
                                              _buildWeatherInfo(Icons.air, '2.0 m/s'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.wb_cloudy, color: Colors.white, size: 90),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Category Cards
                            if (devicesByCategory.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(
                                  children: [
                                    Expanded(child: _buildCategoryCard(
                                      Icons.lightbulb_outline,
                                      'Lightning',
                                      '${devicesByCategory['Lightning'] ?? 0} lights',
                                      const Color(0xFFFFB800),
                                    )),
                                    const SizedBox(width: 10),
                                    Expanded(child: _buildCategoryCard(
                                      Icons.videocam_outlined,
                                      'Cameras',
                                      '${devicesByCategory['Cameras'] ?? 0} cameras',
                                      const Color(0xFFE91E63),
                                    )),
                                    const SizedBox(width: 10),
                                    Expanded(child: _buildCategoryCard(
                                      Icons.power_outlined,
                                      'Electrical',
                                      '${devicesByCategory['Electrical'] ?? 0} devices',
                                      const Color(0xFFFF5722),
                                    )),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 28),
                            
                            // All Devices Header
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                children: [
                                  const Text(
                                    'All Devices',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {},
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Room Tabs
                            if (rooms.length > 1)
                              SizedBox(
                                height: 46,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: rooms.length,
                                  itemBuilder: (context, index) {
                                    final room = rooms[index];
                                    final isSelected = homeProvider.selectedRoom == room;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: ChoiceChip(
                                        label: Text(room),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          homeProvider.setSelectedRoom(room);
                                        },
                                        backgroundColor: const Color(0xFF2A2930),
                                        selectedColor: const Color(0xFF5B7CFF),
                                        labelStyle: TextStyle(
                                          color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            if (rooms.length > 1) const SizedBox(height: 20),
                            
                            // Devices Grid or Empty State
                            if (devices.isEmpty)
                              _buildEmptyState()
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 14,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemCount: devices.length,
                                  itemBuilder: (context, index) {
                                    return _buildDeviceCard(devices[index], homeProvider);
                                  },
                                ),
                              ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Home Dropdown Menu với Blur Effect
                if (_showHomeMenu)
                  GestureDetector(
                    onTap: () => setState(() => _showHomeMenu = false),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 20,
                              top: 70,
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: 300,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2930),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildHomeMenuItem(
                                        'My Home',
                                        true,
                                        () {
                                          setState(() => _showHomeMenu = false);
                                        },
                                      ),
                                      _buildDivider(),
                                      _buildHomeMenuItem(
                                        'My Apartment',
                                        false,
                                        () {
                                          setState(() => _showHomeMenu = false);
                                        },
                                      ),
                                      _buildDivider(),
                                      _buildHomeMenuItem(
                                        'My Office',
                                        false,
                                        () {
                                          setState(() => _showHomeMenu = false);
                                        },
                                      ),
                                      _buildDivider(),
                                      _buildHomeMenuItem(
                                        'My Parents\' House',
                                        false,
                                        () {
                                          setState(() => _showHomeMenu = false);
                                        },
                                      ),
                                      _buildDivider(),
                                      _buildHomeMenuItem(
                                        'My Garden',
                                        false,
                                        () {
                                          setState(() => _showHomeMenu = false);
                                        },
                                      ),
                                      _buildDivider(),
                                      _buildHomeMenuItem(
                                        'Home Management',
                                        false,
                                        () {
                                          setState(() => _showHomeMenu = false);
                                        },
                                        icon: Icons.settings_outlined,
                                      ),
                                      _buildDivider(),
                                      _buildHomeMenuItem(
                                        'Log Out',
                                        false,
                                        () async {
                                          setState(() => _showHomeMenu = false);
                                          final authProvider = Provider.of<AuthProvider>(
                                            context,
                                            listen: false,
                                          );
                                          await authProvider.logout();
                                          if (context.mounted) {
                                            Navigator.of(context).pushNamedAndRemoveUntil(
                                              '/',
                                              (route) => false,
                                            );
                                          }
                                        },
                                        icon: Icons.logout,
                                        isLogout: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                                
                // FAB Menu Overlay with Blur
                if (_showFabMenu)
                  GestureDetector(
                    onTap: () => setState(() => _showFabMenu = false),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 20,
                              bottom: 80,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildFabMenuItem(Icons.devices, 'Add Device', () {
                                    setState(() => _showFabMenu = false);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                  _buildFabMenuItem(Icons.qr_code_scanner, 'Scan', () {
                                    setState(() => _showFabMenu = false);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const ScanDeviceScreen()),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // FAB Buttons
                Positioned(
                  right: 20,
                  bottom: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'mic',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VoiceCommandScreen()),
                          );
                        },
                        backgroundColor: const Color(0xFF2A2930),
                        child: const Icon(Icons.mic, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      FloatingActionButton(
                        heroTag: 'add',
                        onPressed: () {
                          setState(() => _showFabMenu = !_showFabMenu);
                        },
                        backgroundColor: const Color(0xFF5B7CFF),
                        child: Icon(
                          _showFabMenu ? Icons.close : Icons.add,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigation(),
        );
      },
    );
  }

  Widget _buildHomeMenuItem(
    String title,
    bool isSelected,
    VoidCallback onTap, {
    IconData? icon,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isLogout ? const Color(0xFFFF5252) : const Color(0xFF5B7CFF),
                size: 20,
              ),
              const SizedBox(width: 12),
            ] else if (isSelected) ...[
              const Icon(
                Icons.check,
                color: Color(0xFF5B7CFF),
                size: 20,
              ),
              const SizedBox(width: 12),
            ] else ...[
              const SizedBox(width: 32),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isLogout ? const Color(0xFFFF5252) : Colors.white,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: const Color(0xFF3D4556),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 60.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
              const Icon(
                Icons.devices_other,
                size: 50,
                color: Color(0xFF5B7CFF),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'No Devices',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "You haven't added a device yet.",
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 15,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 150,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text(
                'Add Device',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B7CFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(IconData icon, String name, String count, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryDevicesScreen(
              category: name,
              icon: icon,
              color: color,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2930),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              count,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Device device, HomeProvider provider) {
    return GestureDetector(
      onTap: () => _navigateToDeviceControl(device), // ✅ SỬ DỤNG HÀM ĐIỀU HƯỚNG MỚI
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
                    height: 90,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      _getDeviceIcon(device.type),
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                Switch(
                  value: device.isOn,
                  onChanged: (value) {
                    // ✅ Truyền WebSocket URL nếu là smart plug
                    provider.toggleDevice(
                      device.id,
                      websocketUrl: _isSmartPlug(device.type) ? WEBSOCKET_BASE_URL : null,
                    );
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
                fontFamily: 'Inter',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'lamp':
      case 'light':
        return Icons.lightbulb_outline;
      case 'speaker':
        return Icons.speaker_outlined;
      case 'camera':
      case 'cctv':
      case 'webcam':
        return Icons.videocam_outlined;
      case 'router':
        return Icons.router_outlined;
      case 'smart_plug':
      case 'plug':
      case 'smart plug':
      case 'smartplug':
        return Icons.power; // ✅ ICON CHO SMART PLUG
      default:
        return Icons.devices;
    }
  }

  Widget _buildFabMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2930),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.check_circle_outline, 'Smart', 1),
              _buildNavItem(Icons.bar_chart, 'Reports', 2),
              _buildNavItem(Icons.person_outline, 'Account', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF5B7CFF) : const Color(0xFF9CA3AF),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF5B7CFF) : const Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:ui';
// import '../../providers/home_provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../models/device.dart';
// import '../devices/add_device_screen.dart';
// import '../devices/scan_device_screen.dart';
// import '../devices/device_control_screen.dart';
// import '../devices/plugin_control_screen.dart'; // ✅ THÊM IMPORT
// import '../chat/chat_screen.dart';
// import '../notifications/notification_screen.dart';
// import '../devices/category_devices_screen.dart';
// import '../devices/voice_command_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedTabIndex = 0;
//   bool _showFabMenu = false;
//   bool _showHomeMenu = false;

//   // ✅ CẤU HÌNH WEBSOCKET URL - THAY ĐỔI THEO NGROK CỦA BẠN
//   static const String WEBSOCKET_URL = 'wss://unreliant-alysa-distractingly.ngrok-free.dev';

//   @override
//   void initState() {
//     super.initState();
//     _loadHomeData();
//   }

//   Future<void> _loadHomeData() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    
//     final userId = authProvider.user?.userId;
//     if (userId != null) {
//       await homeProvider.loadHomeData(userId.toString());
//     }
//   }

//   // ✅ HÀM ĐIỀU HƯỚNG ĐÚNG THEO LOẠI THIẾT BỊ
//   void _navigateToDeviceControl(Device device) {
//     if (_isSmartPlug(device.type)) {
//       // Điều hướng đến PluginControlScreen với WebSocket
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => PluginControlScreen(
//             deviceName: device.name,
//             baseUrl: WEBSOCKET_URL,
//             deviceId: device.id,
//           ),
//         ),
//       );
//     } else {
//       // Các thiết bị khác dùng DeviceControlScreen thông thường
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => DeviceControlScreen(
//             deviceName: device.name,
//             deviceType: device.type,
//             room: device.room,
//           ),
//         ),
//       );
//     }
//   }

//   // ✅ HÀM KIỂM TRA LOẠI SMART PLUG
//   bool _isSmartPlug(String deviceType) {
//     final type = deviceType.toLowerCase();
//     return type == 'smart_plug' || 
//            type == 'plug' || 
//            type == 'smart plug' ||
//            type == 'smartplug';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HomeProvider>(
//       builder: (context, homeProvider, child) {
//         final devices = homeProvider.filteredDevices;
//         final rooms = homeProvider.getRoomList();
//         final devicesByCategory = homeProvider.devicesByCategory;
        
//         return Scaffold(
//           backgroundColor: const Color(0xFF1B1A20),
//           body: SafeArea(
//             child: Stack(
//               children: [
//                 Column(
//                   children: [
//                     // Header
//                     Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Row(
//                         children: [
//                           // Home Name với Dropdown
//                           GestureDetector(
//                             onTap: () {
//                               setState(() => _showHomeMenu = !_showHomeMenu);
//                             },
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   homeProvider.homeData?.homeName ?? 'My Home',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 26,
//                                     fontWeight: FontWeight.w700,
//                                     fontFamily: 'Inter',
//                                   ),
//                                 ),
//                                 Icon(
//                                   _showHomeMenu 
//                                     ? Icons.keyboard_arrow_up 
//                                     : Icons.keyboard_arrow_down,
//                                   color: Colors.white,
//                                   size: 26,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const Spacer(),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (_) => const ChatScreen()),
//                               );
//                             },
//                             child: Container(
//                               width: 44,
//                               height: 44,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF2A2930),
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: const Color(0xFF5B7CFF), width: 2),
//                               ),
//                               child: const Icon(Icons.face, color: Color(0xFF5B7CFF), size: 22),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (_) => const NotificationScreen()),
//                               );
//                             },
//                             child: Stack(
//                               children: [
//                                 Container(
//                                   width: 44,
//                                   height: 44,
//                                   decoration: const BoxDecoration(
//                                     color: Color(0xFF2A2930),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
//                                 ),
//                                 Positioned(
//                                   right: 8,
//                                   top: 8,
//                                   child: Container(
//                                     width: 8,
//                                     height: 8,
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFFFF5252),
//                                       shape: BoxShape.circle,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Weather Card
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                               child: Container(
//                                 padding: const EdgeInsets.all(20),
//                                 decoration: BoxDecoration(
//                                   gradient: const LinearGradient(
//                                     colors: [Color(0xFF5B7CFF), Color(0xFF4C6FE8)],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           const Text(
//                                             '20°C',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 42,
//                                               fontWeight: FontWeight.w700,
//                                               fontFamily: 'Inter',
//                                             ),
//                                           ),
//                                           const SizedBox(height: 6),
//                                           const Text(
//                                             'New York City, USA',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 15,
//                                               fontWeight: FontWeight.w500,
//                                               fontFamily: 'Inter',
//                                             ),
//                                           ),
//                                           const SizedBox(height: 4),
//                                           const Text(
//                                             'Today Cloudy',
//                                             style: TextStyle(
//                                               color: Colors.white70,
//                                               fontSize: 13,
//                                               fontFamily: 'Inter',
//                                             ),
//                                           ),
//                                           const SizedBox(height: 10),
//                                           Wrap(
//                                             spacing: 12,
//                                             children: [
//                                               _buildWeatherInfo(Icons.water_drop_outlined, 'AQI 92'),
//                                               _buildWeatherInfo(Icons.water_drop, '78.2%'),
//                                               _buildWeatherInfo(Icons.air, '2.0 m/s'),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     const Icon(Icons.wb_cloudy, color: Colors.white, size: 90),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
                            
//                             // Category Cards
//                             if (devicesByCategory.isNotEmpty)
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                                 child: Row(
//                                   children: [
//                                     Expanded(child: _buildCategoryCard(
//                                       Icons.lightbulb_outline,
//                                       'Lightning',
//                                       '${devicesByCategory['Lightning'] ?? 0} lights',
//                                       const Color(0xFFFFB800),
//                                     )),
//                                     const SizedBox(width: 10),
//                                     Expanded(child: _buildCategoryCard(
//                                       Icons.videocam_outlined,
//                                       'Cameras',
//                                       '${devicesByCategory['Cameras'] ?? 0} cameras',
//                                       const Color(0xFFE91E63),
//                                     )),
//                                     const SizedBox(width: 10),
//                                     Expanded(child: _buildCategoryCard(
//                                       Icons.power_outlined,
//                                       'Electrical',
//                                       '${devicesByCategory['Electrical'] ?? 0} devices',
//                                       const Color(0xFFFF5722),
//                                     )),
//                                   ],
//                                 ),
//                               ),
//                             const SizedBox(height: 28),
                            
//                             // All Devices Header
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                               child: Row(
//                                 children: [
//                                   const Text(
//                                     'All Devices',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 22,
//                                       fontWeight: FontWeight.w700,
//                                       fontFamily: 'Inter',
//                                     ),
//                                   ),
//                                   const Spacer(),
//                                   IconButton(
//                                     onPressed: () {},
//                                     padding: EdgeInsets.zero,
//                                     constraints: const BoxConstraints(),
//                                     icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 12),
                            
//                             // Room Tabs
//                             if (rooms.length > 1)
//                               SizedBox(
//                                 height: 46,
//                                 child: ListView.builder(
//                                   scrollDirection: Axis.horizontal,
//                                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                                   itemCount: rooms.length,
//                                   itemBuilder: (context, index) {
//                                     final room = rooms[index];
//                                     final isSelected = homeProvider.selectedRoom == room;
//                                     return Padding(
//                                       padding: const EdgeInsets.only(right: 10),
//                                       child: ChoiceChip(
//                                         label: Text(room),
//                                         selected: isSelected,
//                                         onSelected: (selected) {
//                                           homeProvider.setSelectedRoom(room);
//                                         },
//                                         backgroundColor: const Color(0xFF2A2930),
//                                         selectedColor: const Color(0xFF5B7CFF),
//                                         labelStyle: TextStyle(
//                                           color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
//                                           fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                                           fontFamily: 'Inter',
//                                           fontSize: 14,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(24),
//                                         ),
//                                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             if (rooms.length > 1) const SizedBox(height: 20),
                            
//                             // Devices Grid or Empty State
//                             if (devices.isEmpty)
//                               _buildEmptyState()
//                             else
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                                 child: GridView.builder(
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                                     crossAxisCount: 2,
//                                     mainAxisSpacing: 14,
//                                     crossAxisSpacing: 14,
//                                     childAspectRatio: 0.85,
//                                   ),
//                                   itemCount: devices.length,
//                                   itemBuilder: (context, index) {
//                                     return _buildDeviceCard(devices[index], homeProvider);
//                                   },
//                                 ),
//                               ),
//                             const SizedBox(height: 100),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 // Home Dropdown Menu với Blur Effect
//                 if (_showHomeMenu)
//                   GestureDetector(
//                     onTap: () => setState(() => _showHomeMenu = false),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                       child: Container(
//                         color: Colors.black.withOpacity(0.3),
//                         child: Stack(
//                           children: [
//                             Positioned(
//                               left: 20,
//                               top: 70,
//                               child: Material(
//                                 color: Colors.transparent,
//                                 child: Container(
//                                   width: 300,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF2A2930),
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.3),
//                                         blurRadius: 20,
//                                         offset: const Offset(0, 10),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       _buildHomeMenuItem(
//                                         'My Home',
//                                         true,
//                                         () {
//                                           setState(() => _showHomeMenu = false);
//                                         },
//                                       ),
//                                       _buildDivider(),
//                                       _buildHomeMenuItem(
//                                         'My Apartment',
//                                         false,
//                                         () {
//                                           setState(() => _showHomeMenu = false);
//                                         },
//                                       ),
//                                       _buildDivider(),
//                                       _buildHomeMenuItem(
//                                         'My Office',
//                                         false,
//                                         () {
//                                           setState(() => _showHomeMenu = false);
//                                         },
//                                       ),
//                                       _buildDivider(),
//                                       _buildHomeMenuItem(
//                                         'My Parents\' House',
//                                         false,
//                                         () {
//                                           setState(() => _showHomeMenu = false);
//                                         },
//                                       ),
//                                       _buildDivider(),
//                                       _buildHomeMenuItem(
//                                         'My Garden',
//                                         false,
//                                         () {
//                                           setState(() => _showHomeMenu = false);
//                                         },
//                                       ),
//                                       _buildDivider(),
//                                       _buildHomeMenuItem(
//                                         'Home Management',
//                                         false,
//                                         () {
//                                           setState(() => _showHomeMenu = false);
//                                         },
//                                         icon: Icons.settings_outlined,
//                                       ),
//                                       _buildDivider(),
//                                       _buildHomeMenuItem(
//                                         'Log Out',
//                                         false,
//                                         () async {
//                                           setState(() => _showHomeMenu = false);
//                                           final authProvider = Provider.of<AuthProvider>(
//                                             context,
//                                             listen: false,
//                                           );
//                                           await authProvider.logout();
//                                           if (context.mounted) {
//                                             Navigator.of(context).pushNamedAndRemoveUntil(
//                                               '/',
//                                               (route) => false,
//                                             );
//                                           }
//                                         },
//                                         icon: Icons.logout,
//                                         isLogout: true,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
                                
//                 // FAB Menu Overlay with Blur
//                 if (_showFabMenu)
//                   GestureDetector(
//                     onTap: () => setState(() => _showFabMenu = false),
//                     child: BackdropFilter(
//                       filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                       child: Container(
//                         color: Colors.black.withOpacity(0.3),
//                         child: Stack(
//                           children: [
//                             Positioned(
//                               right: 20,
//                               bottom: 80,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   _buildFabMenuItem(Icons.devices, 'Add Device', () {
//                                     setState(() => _showFabMenu = false);
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
//                                     );
//                                   }),
//                                   const SizedBox(height: 10),
//                                   _buildFabMenuItem(Icons.qr_code_scanner, 'Scan', () {
//                                     setState(() => _showFabMenu = false);
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(builder: (_) => const ScanDeviceScreen()),
//                                     );
//                                   }),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
                
//                 // FAB Buttons
//                 Positioned(
//                   right: 20,
//                   bottom: 10,
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       FloatingActionButton(
//                         heroTag: 'mic',
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (_) => const VoiceCommandScreen()),
//                           );
//                         },
//                         backgroundColor: const Color(0xFF2A2930),
//                         child: const Icon(Icons.mic, color: Colors.white, size: 22),
//                       ),
//                       const SizedBox(width: 12),
//                       FloatingActionButton(
//                         heroTag: 'add',
//                         onPressed: () {
//                           setState(() => _showFabMenu = !_showFabMenu);
//                         },
//                         backgroundColor: const Color(0xFF5B7CFF),
//                         child: Icon(
//                           _showFabMenu ? Icons.close : Icons.add,
//                           color: Colors.white,
//                           size: 26,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           bottomNavigationBar: _buildBottomNavigation(),
//         );
//       },
//     );
//   }

//   Widget _buildHomeMenuItem(
//     String title,
//     bool isSelected,
//     VoidCallback onTap, {
//     IconData? icon,
//     bool isLogout = false,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         child: Row(
//           children: [
//             if (icon != null) ...[
//               Icon(
//                 icon,
//                 color: isLogout ? const Color(0xFFFF5252) : const Color(0xFF5B7CFF),
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//             ] else if (isSelected) ...[
//               const Icon(
//                 Icons.check,
//                 color: Color(0xFF5B7CFF),
//                 size: 20,
//               ),
//               const SizedBox(width: 12),
//             ] else ...[
//               const SizedBox(width: 32),
//             ],
//             Expanded(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   color: isLogout ? const Color(0xFFFF5252) : Colors.white,
//                   fontSize: 16,
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//                   fontFamily: 'Inter',
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Container(
//       height: 1,
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       color: const Color(0xFF3D4556),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 60.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               Icon(
//                 Icons.assignment_outlined,
//                 size: 100,
//                 color: Colors.white.withOpacity(0.1),
//               ),
//               const Icon(
//                 Icons.devices_other,
//                 size: 50,
//                 color: Color(0xFF5B7CFF),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Devices',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.w700,
//               fontFamily: 'Inter',
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             "You haven't added a device yet.",
//             style: TextStyle(
//               color: Color(0xFF9CA3AF),
//               fontSize: 15,
//               fontFamily: 'Inter',
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 32),
//           SizedBox(
//             width: 150,
//             height: 48,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
//                 );
//               },
//               icon: const Icon(Icons.add, color: Colors.white, size: 20),
//               label: const Text(
//                 'Add Device',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF5B7CFF),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 elevation: 0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWeatherInfo(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, color: Colors.white70, size: 14),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 11,
//             fontFamily: 'Inter',
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryCard(IconData icon, String name, String count, Color color) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => CategoryDevicesScreen(
//               category: name,
//               icon: icon,
//               color: color,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: const Color(0xFF2A2930),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: color, size: 28),
//             const SizedBox(height: 10),
//             Text(
//               name,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'Inter',
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               count,
//               style: const TextStyle(
//                 color: Color(0xFF9CA3AF),
//                 fontSize: 12,
//                 fontFamily: 'Inter',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDeviceCard(Device device, HomeProvider provider) {
//     return GestureDetector(
//       onTap: () => _navigateToDeviceControl(device), // ✅ SỬ DỤNG HÀM ĐIỀU HƯỚNG MỚI
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: const Color(0xFF2A2930),
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Image.asset(
//                     device.getImagePath(),
//                     height: 90,
//                     fit: BoxFit.contain,
//                     errorBuilder: (_, __, ___) => Icon(
//                       _getDeviceIcon(device.type),
//                       color: Colors.white,
//                       size: 48,
//                     ),
//                   ),
//                 ),
//                 Switch(
//                   value: device.isOn,
//                   onChanged: (value) {
//                     provider.toggleDevice(device.id);
//                   },
//                   activeColor: const Color(0xFF5B7CFF),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Text(
//               device.name,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'Inter',
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(
//                   device.connectionType == 'Wi-Fi' ? Icons.wifi : Icons.bluetooth,
//                   color: const Color(0xFF9CA3AF),
//                   size: 12,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   device.connectionType,
//                   style: const TextStyle(
//                     color: Color(0xFF9CA3AF),
//                     fontSize: 12,
//                     fontFamily: 'Inter',
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   IconData _getDeviceIcon(String deviceType) {
//     switch (deviceType.toLowerCase()) {
//       case 'lamp':
//       case 'light':
//         return Icons.lightbulb_outline;
//       case 'speaker':
//         return Icons.speaker_outlined;
//       case 'camera':
//       case 'cctv':
//       case 'webcam':
//         return Icons.videocam_outlined;
//       case 'router':
//         return Icons.router_outlined;
//       case 'smart_plug':
//       case 'plug':
//       case 'smart plug':
//       case 'smartplug':
//         return Icons.power; // ✅ ICON CHO SMART PLUG
//       default:
//         return Icons.devices;
//     }
//   }

//   Widget _buildFabMenuItem(IconData icon, String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFF2A2930),
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: Colors.white, size: 20),
//             const SizedBox(width: 10),
//             Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'Inter',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomNavigation() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF1B1A20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(Icons.home, 'Home', 0),
//               _buildNavItem(Icons.check_circle_outline, 'Smart', 1),
//               _buildNavItem(Icons.bar_chart, 'Reports', 2),
//               _buildNavItem(Icons.person_outline, 'Account', 3),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, String label, int index) {
//     final isSelected = _selectedTabIndex == index;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedTabIndex = index),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             color: isSelected ? const Color(0xFF5B7CFF) : const Color(0xFF9CA3AF),
//             size: 24,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? const Color(0xFF5B7CFF) : const Color(0xFF9CA3AF),
//               fontSize: 12,
//               fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//               fontFamily: 'Inter',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:ui';
// import '../../providers/home_provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../models/device.dart';
// import '../devices/add_device_screen.dart';
// import '../devices/scan_device_screen.dart';
// import '../devices/device_control_screen.dart';
// import '../devices/plugin_control_screen.dart';
// import '../chat/chat_screen.dart';
// import '../notifications/notification_screen.dart';
// import '../devices/category_devices_screen.dart';
// import '../devices/voice_command_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedTabIndex = 0;
//   bool _showFabMenu = false;
//   bool _showHomeMenu = false;

//   // ✅ CẤU HÌNH WEBSOCKET URL - THAY ĐỔI THEO NGROK CỦA BẠN
//   static const String WEBSOCKET_URL = 'wss://unreliant-alysa-distractingly.ngrok-free.dev';

//   @override
//   void initState() {
//     super.initState();
//     _loadHomeData();
//   }

//   Future<void> _loadHomeData() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    
//     final userId = authProvider.user?.userId;
//     if (userId != null) {
//       await homeProvider.loadHomeData(userId.toString());
//     }
//   }

//   // ✅ HÀM ĐIỀU HƯỚNG ĐÚNG THEO LOẠI THIẾT BỊ
//   void _navigateToDeviceControl(Device device) {
//     if (_isSmartPlug(device.type)) {
//       // Điều hướng đến PluginControlScreen với WebSocket
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => PluginControlScreen(
//             deviceName: device.name,
//             baseUrl: WEBSOCKET_URL,
//             deviceId: device.id,
//           ),
//         ),
//       );
//     } else {
//       // Các thiết bị khác dùng DeviceControlScreen thông thường
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => DeviceControlScreen(
//             deviceName: device.name,
//             deviceType: device.type,
//             room: device.room,
//           ),
//         ),
//       );
//     }
//   }

//   // ✅ HÀM KIỂM TRA LOẠI SMART PLUG
//   bool _isSmartPlug(String deviceType) {
//     final type = deviceType.toLowerCase();
//     return type == 'smart_plug' || 
//            type == 'plug' || 
//            type == 'smart plug' ||
//            type == 'smartplug';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HomeProvider>(
//       builder: (context, homeProvider, child) {
//         final devices = homeProvider.filteredDevices;
//         final rooms = homeProvider.getRoomList();
//         final devicesByCategory = homeProvider.devicesByCategory;
        
//         return Scaffold(
//           backgroundColor: const Color(0xFF1B1A20),
//           body: SafeArea(
//             child: Stack(
//               children: [
//                 Column(
//                   children: [
//                     // Header
//                     Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Row(
//                         children: [
//                           // Home Name với Dropdown
//                           GestureDetector(
//                             onTap: () {
//                               setState(() => _showHomeMenu = !_showHomeMenu);
//                             },
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   homeProvider.homeData?.homeName ?? 'My Home',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 26,
//                                     fontWeight: FontWeight.w700,
//                                     fontFamily: 'Inter',
//                                   ),
//                                 ),
//                                 Icon(
//                                   _showHomeMenu 
//                                     ? Icons.keyboard_arrow_up 
//                                     : Icons.keyboard_arrow_down,
//                                   color: Colors.white,
//                                   size: 26,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const Spacer(),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (_) => const ChatScreen()),
//                               );
//                             },
//                             child: Container(
//                               width: 44,
//                               height: 44,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF2A2930),
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: const Color(0xFF5B7CFF), width: 2),
//                               ),
//                               child: const Icon(Icons.face, color: Color(0xFF5B7CFF), size: 22),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (_) => const NotificationScreen()),
//                               );
//                             },
//                             child: Stack(
//                               children: [
//                                 Container(
//                                   width: 44,
//                                   height: 44,
//                                   decoration: const BoxDecoration(
//                                     color: Color(0xFF2A2930),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
//                                 ),
//                                 Positioned(
//                                   right: 8,
//                                   top: 8,
//                                   child: Container(
//                                     width: 8,
//                                     height: 8,
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFFFF5252),
//                                       shape: BoxShape.circle,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Weather Card
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                               child: Container(
//                                 padding: const EdgeInsets.all(20),
//                                 decoration: BoxDecoration(
//                                   gradient: const LinearGradient(
//                                     colors: [Color(0xFF5B7CFF), Color(0xFF4C6FE8)],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           const Text(
//                                             '20°C',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 42,
//                                               fontWeight: FontWeight.w700,
//                                               fontFamily: 'Inter',
//                                             ),
//                                           ),
//                                           const SizedBox(height: 6),
//                                           const Text(
//                                             'New York City, USA',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 15,
//                                               fontWeight: FontWeight.w500,
//                                               fontFamily: 'Inter',
//                                             ),
//                                           ),
//                                           const SizedBox(height: 4),
//                                           const Text(
//                                             'Today Cloudy',
//                                             style: TextStyle(
//                                               color: Colors.white70,
//                                               fontSize: 13,
//                                               fontFamily: 'Inter',
//                                             ),
//                                           ),
//                                           const SizedBox(height: 10),
//                                           Wrap(
//                                             spacing: 12,
//                                             children: [
//                                               _buildWeatherInfo(Icons.water_drop_outlined, 'AQI 92'),
//                                               _buildWeatherInfo(Icons.water_drop, '78.2%'),
//                                               _buildWeatherInfo(Icons.air, '2.0 m/s'),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     const Icon(Icons.wb_cloudy, color: Colors.white, size: 80),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 28),
                            
//                             // Categories Section
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text(
//                                     'Categories',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w700,
//                                       fontFamily: 'Inter',
//                                     ),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {},
//                                     child: const Text(
//                                       'See all',
//                                       style: TextStyle(
//                                         color: Color(0xFF5B7CFF),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         fontFamily: 'Inter',
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 16),
                            
//                             // Category Cards
//                             SingleChildScrollView(
//                               scrollDirection: Axis.horizontal,
//                               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                               child: Row(
//                                 children: [
//                                   _buildCategoryCard(
//                                     'Lightning',
//                                     '${devicesByCategory['Lightning'] ?? 0}',
//                                     Icons.lightbulb_outline,
//                                     const Color(0xFFFFC107),
//                                   ),
//                                   const SizedBox(width: 14),
//                                   _buildCategoryCard(
//                                     'Cameras',
//                                     '${devicesByCategory['Cameras'] ?? 0}',
//                                     Icons.videocam_outlined,
//                                     const Color(0xFF00BCD4),
//                                   ),
//                                   const SizedBox(width: 14),
//                                   _buildCategoryCard(
//                                     'Electrical',
//                                     '${devicesByCategory['Electrical'] ?? 0}',
//                                     Icons.power,
//                                     const Color(0xFF5B7CFF),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 28),
                            
//                             // Rooms Section
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text(
//                                     'Rooms',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w700,
//                                       fontFamily: 'Inter',
//                                     ),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {},
//                                     child: const Text(
//                                       'See all',
//                                       style: TextStyle(
//                                         color: Color(0xFF5B7CFF),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         fontFamily: 'Inter',
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 16),
                            
//                             // Room Cards
//                             SingleChildScrollView(
//                               scrollDirection: Axis.horizontal,
//                               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                               child: Row(
//                                 children: rooms.map((room) => Padding(
//                                   padding: const EdgeInsets.only(right: 14),
//                                   child: _buildRoomCard(
//                                     room,
//                                     homeProvider.getDeviceCountByRoom(room).toString(),
//                                   ),
//                                 )).toList(),
//                               ),
//                             ),
//                             const SizedBox(height: 28),
                            
//                             // Smart Devices Section
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text(
//                                     'Smart Devices',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w700,
//                                       fontFamily: 'Inter',
//                                     ),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {},
//                                     child: const Text(
//                                       'See all',
//                                       style: TextStyle(
//                                         color: Color(0xFF5B7CFF),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         fontFamily: 'Inter',
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 16),
                            
//                             // Devices Grid
//                             devices.isEmpty 
//                               ? Padding(
//                                   padding: const EdgeInsets.all(40),
//                                   child: Center(
//                                     child: Column(
//                                       children: [
//                                         Icon(
//                                           Icons.devices_other,
//                                           size: 64,
//                                           color: Colors.white.withOpacity(0.3),
//                                         ),
//                                         const SizedBox(height: 16),
//                                         const Text(
//                                           'No devices yet',
//                                           style: TextStyle(
//                                             color: Color(0xFF9CA3AF),
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                               : Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                                   child: GridView.builder(
//                                     shrinkWrap: true,
//                                     physics: const NeverScrollableScrollPhysics(),
//                                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                                       crossAxisCount: 2,
//                                       mainAxisSpacing: 14,
//                                       crossAxisSpacing: 14,
//                                       childAspectRatio: 0.85,
//                                     ),
//                                     itemCount: devices.length > 6 ? 6 : devices.length,
//                                     itemBuilder: (context, index) {
//                                       return _buildDeviceCard(devices[index], homeProvider);
//                                     },
//                                   ),
//                                 ),
//                             const SizedBox(height: 100),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 // Home Dropdown Menu
//                 if (_showHomeMenu)
//                   Positioned(
//                     top: 80,
//                     left: 20,
//                     right: 20,
//                     child: GestureDetector(
//                       onTap: () => setState(() => _showHomeMenu = false),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF2A2930),
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.3),
//                               blurRadius: 20,
//                               offset: const Offset(0, 10),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             _buildHomeMenuItem(
//                               homeProvider.homeData?.homeName ?? 'My Home',
//                               isSelected: true,
//                             ),
//                             const Divider(color: Color(0xFF3A3940), height: 1),
//                             _buildHomeMenuItem('Add New Home', isSelected: false),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
                
//                 // FAB Menu
//                 if (_showFabMenu)
//                   Positioned.fill(
//                     child: GestureDetector(
//                       onTap: () => setState(() => _showFabMenu = false),
//                       child: BackdropFilter(
//                         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                         child: Container(
//                           color: Colors.black.withOpacity(0.3),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(bottom: 100, right: 20),
//                                 child: Align(
//                                   alignment: Alignment.centerRight,
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       _buildFabMenuItem(
//                                         Icons.qr_code_scanner,
//                                         'Scan QR Code',
//                                         () {
//                                           setState(() => _showFabMenu = false);
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(builder: (_) => const ScanDeviceScreen()),
//                                           );
//                                         },
//                                       ),
//                                       const SizedBox(height: 12),
//                                       _buildFabMenuItem(
//                                         Icons.add_circle_outline,
//                                         'Add Device',
//                                         () {
//                                           setState(() => _showFabMenu = false);
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
//                                           );
//                                         },
//                                       ),
//                                       const SizedBox(height: 12),
//                                       _buildFabMenuItem(
//                                         Icons.mic,
//                                         'Voice Control',
//                                         () {
//                                           setState(() => _showFabMenu = false);
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(builder: (_) => const VoiceCommandScreen()),
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () => setState(() => _showFabMenu = !_showFabMenu),
//             backgroundColor: const Color(0xFF5B7CFF),
//             child: Icon(
//               _showFabMenu ? Icons.close : Icons.add,
//               color: Colors.white,
//               size: 28,
//             ),
//           ),
//           floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//           bottomNavigationBar: _buildBottomNavigation(),
//         );
//       },
//     );
//   }

//   Widget _buildWeatherInfo(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, color: Colors.white70, size: 16),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 12,
//             fontFamily: 'Inter',
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryCard(String title, String count, IconData icon, Color color) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => CategoryDevicesScreen(
//               category: title,
//               icon: icon,
//               color: color,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         width: 140,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFF2A2930),
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: color, size: 24),
//             ),
//             const SizedBox(height: 14),
//             Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'Inter',
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               count,
//               style: const TextStyle(
//                 color: Color(0xFF9CA3AF),
//                 fontSize: 12,
//                 fontFamily: 'Inter',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRoomCard(String title, String count) {
//     return Container(
//       width: 120,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2A2930),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: const Color(0xFF5B7CFF).withOpacity(0.15),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(Icons.room, color: Color(0xFF5B7CFF), size: 20),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               fontFamily: 'Inter',
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             count,
//             style: const TextStyle(
//               color: Color(0xFF9CA3AF),
//               fontSize: 12,
//               fontFamily: 'Inter',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDeviceCard(Device device, HomeProvider provider) {
//     return GestureDetector(
//       onTap: () => _navigateToDeviceControl(device),
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: const Color(0xFF2A2930),
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Image.asset(
//                     device.getImagePath(),
//                     height: 90,
//                     fit: BoxFit.contain,
//                     errorBuilder: (_, __, ___) => Icon(
//                       _getDeviceIcon(device.type),
//                       color: Colors.white,
//                       size: 48,
//                     ),
//                   ),
//                 ),
//                 Switch(
//                   value: device.isOn,
//                   onChanged: (value) {
//                     provider.toggleDevice(device.id);
//                   },
//                   activeColor: const Color(0xFF5B7CFF),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Text(
//               device.name,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'Inter',
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(
//                   device.connectionType == 'Wi-Fi' ? Icons.wifi : Icons.bluetooth,
//                   color: const Color(0xFF9CA3AF),
//                   size: 12,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   device.connectionType,
//                   style: const TextStyle(
//                     color: Color(0xFF9CA3AF),
//                     fontSize: 12,
//                     fontFamily: 'Inter',
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   IconData _getDeviceIcon(String deviceType) {
//     switch (deviceType.toLowerCase()) {
//       case 'lamp':
//       case 'light':
//         return Icons.lightbulb_outline;
//       case 'speaker':
//         return Icons.speaker_outlined;
//       case 'camera':
//       case 'cctv':
//       case 'webcam':
//         return Icons.videocam_outlined;
//       case 'router':
//         return Icons.router_outlined;
//       case 'smart_plug':
//       case 'plug':
//       case 'smart plug':
//       case 'smartplug':
//         return Icons.power;
//       default:
//         return Icons.devices;
//     }
//   }

//   Widget _buildFabMenuItem(IconData icon, String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFF2A2930),
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: Colors.white, size: 20),
//             const SizedBox(width: 10),
//             Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 fontFamily: 'Inter',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHomeMenuItem(String title, {required bool isSelected}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       child: Row(
//         children: [
//           Icon(
//             isSelected ? Icons.check_circle : Icons.add_circle_outline,
//             color: isSelected ? const Color(0xFF5B7CFF) : const Color(0xFF9CA3AF),
//             size: 24,
//           ),
//           const SizedBox(width: 12),
//           Text(
//             title,
//             style: TextStyle(
//               color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
//               fontSize: 16,
//               fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//               fontFamily: 'Inter',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNavigation() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF1B1A20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(Icons.home, 'Home', 0),
//               _buildNavItem(Icons.check_circle_outline, 'Smart', 1),
//               _buildNavItem(Icons.bar_chart, 'Reports', 2),
//               _buildNavItem(Icons.person_outline, 'Account', 3),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, String label, int index) {
//     final isSelected = _selectedTabIndex == index;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedTabIndex = index),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             color: isSelected ? const Color(0xFF5B7CFF) : const Color(0xFF9CA3AF),
//             size: 24,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? const Color(0xFF5B7CFF) : const Color(0xFF9CA3AF),
//               fontSize: 12,
//               fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//               fontFamily: 'Inter',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }