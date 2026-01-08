import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../services/wifi_provisioning_service.dart';
import 'wifi_config_screen.dart';

class ScanDeviceScreen extends StatefulWidget {
  const ScanDeviceScreen({super.key});

  @override
  State<ScanDeviceScreen> createState() => _ScanDeviceScreenState();
}

class _ScanDeviceScreenState extends State<ScanDeviceScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isBarcodeFound = false;
  bool _isProcessing = false;
  final WiFiProvisioningService _provService = WiFiProvisioningService();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Yêu cầu quyền truy cập Bluetooth
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request(); // Required for BLE scan on Android
  }

  @override
  void dispose() {
    controller.dispose();
    _provService.disconnect();
    super.dispose();
  }

  /// Parse QR Code JSON payload
  Map<String, dynamic>? _parseQRCode(String qrData) {
    try {
      // QR Code format từ ESP32:
      // {"ver":"v1","name":"PLUG_XXXXXX","username":"wifiprov","pop":"abcd1234","transport":"ble"}
      
      Map<String, dynamic> data = jsonDecode(qrData);
      
      debugPrint('📱 QR Code parsed:');
      debugPrint('   Device Name: ${data['name']}');
      debugPrint('   Username: ${data['username']}');
      debugPrint('   Password: ${data['pop']}');
      debugPrint('   Transport: ${data['transport']}');
      
      return data;
    } catch (e) {
      debugPrint('❌ QR Code parse error: $e');
      return null;
    }
  }

  /// Kết nối tới ESP32 qua BLE
  Future<void> _validateAndNavigate(Map<String, dynamic> qrData) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    // Lấy POP từ QR Code (QUAN TRỌNG)
    String pop = qrData['pop'] ?? '';
    String username = qrData['username'] ?? ''; // ✅ LẤY USERNAME TỪ QR 
    String deviceName = qrData['name'] ?? 'Unknown';

    try {
      // Không cần hiển thị Dialog connect lâu nữa
      // Chỉ cần kiểm tra nhanh xem có thiết bị đó xung quanh không (Optional)
      
      debugPrint('🔍 Kiểm tra thiết bị BLE...');
      var device = await _provService.scanForDevice(timeout: const Duration(seconds: 3));
      
      if (device == null) {
        // Tùy chọn: Có thể báo lỗi hoặc vẫn cho qua để thư viện tự tìm lại sau
        // Ở đây ta báo lỗi để chắc chắn thiết bị đang bật
        if (!mounted) return;
        _showErrorDialog('Device not found', 'Make sure device is powered on.');
        setState(() => _isProcessing = false);
        return;
      }

      // ❌ BỎ ĐOẠN: await _provService.connect(device); 
      // Vì thư viện sẽ tự connect ở bước sau. Nếu connect ở đây sẽ gây lỗi "Device Busy".

      debugPrint('✅ Thiết bị đã sẵn sàng. Chuyển sang cấu hình.');
      
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WiFiConfigScreen(
            deviceName: deviceName,
            pop: pop, // ✅ TRUYỀN POP SANG MÀN HÌNH SAU
            username: username, // ✅ TRUYỀN USERNAME SANG MÀN HÌNH CONFIG
            provisioningService: _provService,
          ),
        ),
      );
      
    } catch (e) {
      debugPrint('❌ Error: $e');
      if(mounted) setState(() => _isProcessing = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isBarcodeFound = false;
                _isProcessing = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // CAMERA SCANNER
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              if (_isBarcodeFound || _isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? qrCode = barcodes.first.rawValue;
                
                if (qrCode == null || qrCode.isEmpty) return;
                
                debugPrint('📱 QR Code detected: $qrCode');
                
                // Parse QR Code
                Map<String, dynamic>? qrData = _parseQRCode(qrCode);
                
                if (qrData == null) {
                  _showErrorDialog('Invalid QR Code', 'The QR code format is not valid. Please scan the correct QR code from your ESP32 device.');
                  return;
                }
                
                setState(() => _isBarcodeFound = true);
                
                // Kiểm tra transport là BLE
                if (qrData['transport'] != 'ble') {
                  _showErrorDialog('Unsupported Transport', 'This app only supports BLE transport.');
                  return;
                }
                
                // Kết nối tới thiết bị
                await _validateAndNavigate(qrData);
              }
            },
          ),

          // Overlay (làm tối vùng ngoài khung quét)
          Container(
            decoration: ShapeDecoration(
              shape: QROverlayShape(),
            ),
          ),

          // UI Layer
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      ),
                      const Expanded(
                        child: Text(
                          'Scan Device QR Code',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // QR Frame
                Center(
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: CustomPaint(painter: QRFramePainter()),
                  ),
                ),
                
                const Spacer(),
                
                // Bottom section
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        "Point the camera at the QR code",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Scan the QR code displayed on your ESP32 serial monitor",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Flash Button
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => controller.toggleTorch(),
                          icon: const Icon(Icons.flash_on, color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// QR Frame Painter (giữ nguyên)
class QRFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5B7CFF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    canvas.drawLine(const Offset(0, cornerLength), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width - cornerLength, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);
    canvas.drawLine(Offset(0, size.height - cornerLength), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width - cornerLength, size.height), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// QR Overlay Shape (giữ nguyên)
class QROverlayShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRect(rect)
      ..addRect(Rect.fromCenter(center: rect.center, width: 280, height: 280))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(getOuterPath(rect), Paint()..color = Colors.black.withOpacity(0.5));
  }

  @override
  ShapeBorder scale(double t) => this;
}