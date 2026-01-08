import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_esp_ble_prov/flutter_esp_ble_prov.dart';

class WiFiProvisioningService {
  // UUID Service để quét
  static const String PROV_SERVICE_UUID = "021a9004-0382-4aea-bff4-6b3f1c5adfb4";
  
  // Instance của thư viện
  final FlutterEspBleProv _espBleProv = FlutterEspBleProv();

  StreamSubscription? _scanSubscription;

  /// Bước 1: Quét tìm thiết bị
  Future<BluetoothDevice?> scanForDevice({Duration timeout = const Duration(seconds: 10)}) async {
    debugPrint('🔍 Bắt đầu quét thiết bị với Service UUID: $PROV_SERVICE_UUID');
    
    // Đảm bảo dừng scan cũ
    await FlutterBluePlus.stopScan();
    
    Completer<BluetoothDevice?> completer = Completer();
    
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.advertisementData.serviceUuids.contains(Guid(PROV_SERVICE_UUID))) {
          debugPrint('✅ Tìm thấy thiết bị: ${result.device.remoteId} - ${result.device.platformName}');
          
          if (!completer.isCompleted) {
            completer.complete(result.device);
            FlutterBluePlus.stopScan();
          }
          break;
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: timeout,
        withServices: [Guid(PROV_SERVICE_UUID)],
      );
    } catch (e) {
      debugPrint('❌ Lỗi scan: $e');
      if (!completer.isCompleted) completer.complete(null);
    }
    
    // Timeout handler
    Future.delayed(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(null);
        FlutterBluePlus.stopScan();
      }
    });
    
    return completer.future;
  }

  /// Bước 2: Thực hiện Provisioning bằng thư viện
  Future<bool> startProvisioning({
    required String deviceName,
    required String proofOfPossession,
    required String username, // ✅ THÊM THAM SỐ USERNAME
    required String ssid,
    required String password,
  }) async {
    try {
      debugPrint('🚀 Bắt đầu Provisioning qua thư viện...');
      
      // 1. Dừng scan của FlutterBluePlus để tránh xung đột
      await FlutterBluePlus.stopScan();

      // 2. Scan nội bộ của thư viện (TRUYỀN PREFIX)
      debugPrint('   Scanning BLE devices with prefix: $deviceName');
      await _espBleProv.scanBleDevices(deviceName); 

      // 3. Gọi provisionWifi với POSITIONAL arguments
      // Thứ tự: deviceName, pop, ssid, password
      debugPrint('   Provisioning: $deviceName with SSID: $ssid');
      await _espBleProv.provisionWifi(
        deviceName,           // Positional argument 1
        proofOfPossession,    // Positional argument 2
        ssid,                 // Positional argument 3
        password,             // Positional argument 4
      );

      debugPrint('✅ Provisioning thành công!');
      return true;

    } catch (e) {
      debugPrint('❌ Provisioning thất bại: $e');
      return false;
    }
  }

  /// Dọn dẹp khi dispose
  Future<void> disconnect() async {
    try {
      await FlutterBluePlus.stopScan(); 
      debugPrint("🛑 Đã dừng scan background");
    } catch (e) {
      // Bỏ qua lỗi
    }
  }
}