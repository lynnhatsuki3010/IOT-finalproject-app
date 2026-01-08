import 'package:flutter/material.dart';
import '../../services/wifi_provisioning_service.dart';
import 'device_detected_screen.dart';

class WiFiConfigScreen extends StatefulWidget {
  final String deviceName;
  final String pop; // ✅ THÊM BIẾN NÀY
  final String username;
  final WiFiProvisioningService provisioningService;

  const WiFiConfigScreen({
    super.key,
    required this.deviceName,
    required this.pop, // ✅ THÊM VÀO CONSTRUCTOR
    required this.username, // ✅ THÊM VÀO CONSTRUCTOR
    required this.provisioningService,
  });

  @override
  State<WiFiConfigScreen> createState() => _WiFiConfigScreenState();
}

class _WiFiConfigScreenState extends State<WiFiConfigScreen> {
  List<String> _availableNetworks = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _selectedSSID;
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _scanNetworks();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  /// Quét các mạng WiFi khả dụng từ ESP32
  Future<void> _scanNetworks() async {
    setState(() => _isScanning = true);
    
    // SỬA LỖI: Tạm thời vô hiệu hóa tính năng scan từ ESP32 vì ta đang dùng Custom JSON Service
    // Việc scan WiFi yêu cầu Protocol phức tạp hơn.
    // Code này sẽ giả lập việc scan xong và trả về rỗng -> Buộc người dùng nhập tay.
    
    await Future.delayed(const Duration(seconds: 1)); // Giả lập loading nhẹ
    
    setState(() {
      _availableNetworks = []; // Trả về danh sách rỗng để hiện ô nhập tay
      _isScanning = false;
    });
    
    debugPrint('⚠️ Scan skipped: Manual input required for JSON RAW mode');
  }

  /// Gửi thông tin WiFi tới ESP32
  Future<void> _provisionWiFi() async {
    // Nếu nhập tay (khi list rỗng), _selectedSSID có thể chưa được gán từ Radio,
    // ta cần đảm bảo lấy giá trị từ TextField nếu có (đã handle ở logic onChanged phía dưới)
    
    if (_selectedSSID == null || _selectedSSID!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter WiFi Network Name (SSID)')),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter WiFi password')),
      );
      return;
    }

    setState(() => _isConnecting = true);

    try {
      debugPrint('🚀 Starting Provisioning...');
      
      // ✅ SỬA: Gọi startProvisioning thay vì sendWiFiCredentials
      bool success = await widget.provisioningService.startProvisioning(
        deviceName: widget.deviceName,
        proofOfPossession: widget.pop, // Dùng POP lấy từ QR
        username: widget.username, // ✅ TRUYỀN USERNAME XUỐNG SERVICE
        ssid: _selectedSSID!,
        password: _passwordController.text,
      );

      setState(() => _isConnecting = false);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cấu hình thành công!'), backgroundColor: Colors.green),
        );

        // ❌ BỎ: await widget.provisioningService.disconnect(); (Thư viện tự ngắt)

        // Chuyển màn hình
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DeviceDetectedScreen(
              deviceName: 'Smart Plug',
              deviceType: 'smart_plug',
              deviceImage: 'assets/devices/smartplugin.png',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Cấu hình thất bại (Sai mật khẩu hoặc POP)'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint('❌ Provision error: $e');
      setState(() => _isConnecting = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure WiFi'),
        centerTitle: true,
      ),
      body: _isScanning
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing WiFi configuration...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.router, size: 40, color: Color(0xFF5B7CFF)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Connected Device',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.deviceName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Connected',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // WiFi Networks List or Manual Input
                  const Text(
                    'Select WiFi Network',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_availableNetworks.isNotEmpty) ...[
                    // Show list of available networks
                    Card(
                      child: Column(
                        children: _availableNetworks.map((ssid) {
                          return RadioListTile<String>(
                            value: ssid,
                            groupValue: _selectedSSID,
                            onChanged: (value) {
                              setState(() => _selectedSSID = value);
                            },
                            title: Text(ssid),
                            secondary: const Icon(Icons.wifi),
                          );
                        }).toList(),
                      ),
                    ),
                  ] else ...[
                    // Manual SSID input
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Please enter WiFi Name manually:',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'WiFi Network Name (SSID)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.wifi),
                              ),
                              onChanged: (value) {
                                setState(() => _selectedSSID = value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Password input
                  const Text(
                    'WiFi Password',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Connect button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isConnecting ? null : _provisionWiFi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7CFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isConnecting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Sending Credentials...'),
                              ],
                            )
                          : const Text(
                              'Connect to WiFi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Make sure you enter the correct 2.4GHz WiFi credentials. 5GHz is usually not supported by ESP32.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
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
}