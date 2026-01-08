import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class Device {
  final String id;
  final String name;
  final String ip;
  double power;
  bool isOn;
  WebSocketChannel? channel;

  Device({
    required this.id,
    required this.name,
    required this.ip,
    this.power = 0,
    this.isOn = false,
    this.channel,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ip': ip,
    'power': power,
    'isOn': isOn,
  };

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: json['id'],
    name: json['name'],
    ip: json['ip'],
    power: json['power']?.toDouble() ?? 0,
    isOn: json['isOn'] ?? false,
  );
}

class DeviceProvider extends ChangeNotifier {
  final List<Device> _devices = [];
  Device? _selectedDevice;
  bool _isConnecting = false;

  List<Device> get devices => _devices;
  Device? get selectedDevice => _selectedDevice;
  bool get isConnecting => _isConnecting;

  // Add a new device
  void addDevice(Device device) {
    _devices.add(device);
    notifyListeners();
  }

  // Remove a device
  void removeDevice(String deviceId) {
    final device = _devices.firstWhere((d) => d.id == deviceId);
    device.channel?.sink.close();
    _devices.removeWhere((d) => d.id == deviceId);
    notifyListeners();
  }

  // Select a device
  void selectDevice(Device device) {
    _selectedDevice = device;
    notifyListeners();
  }

  // Connect to device via WebSocket
  Future<bool> connectToDevice(String ip) async {
    _isConnecting = true;
    notifyListeners();

    try {
      // Create WebSocket connection
      final wsUrl = Uri.parse('ws://$ip/ws');
      final channel = WebSocketChannel.connect(wsUrl);

      // Wait for connection
      await Future.delayed(const Duration(seconds: 2));

      // Create device
      final device = Device(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Smart Plug',
        ip: ip,
        channel: channel,
      );

      // Listen to WebSocket messages
      channel.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            device.power = (data['power'] ?? 0).toDouble();
            device.isOn = data['relay'] == 1;
            notifyListeners();
          } catch (e) {
            debugPrint('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
        },
      );

      addDevice(device);
      _selectedDevice = device;
      _isConnecting = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Connection error: $e');
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  // Send control command to device
  void controlDevice(Device device, bool state) {
    try {
      final command = jsonEncode({'relay': state ? 1 : 0});
      device.channel?.sink.add(command);
      device.isOn = state;
      notifyListeners();
    } catch (e) {
      debugPrint('Control error: $e');
    }
  }

  // Toggle device state
  void toggleDevice(Device device) {
    controlDevice(device, !device.isOn);
  }

  @override
  void dispose() {
    // Close all WebSocket connections
    for (var device in _devices) {
      device.channel?.sink.close();
    }
    super.dispose();
  }
}