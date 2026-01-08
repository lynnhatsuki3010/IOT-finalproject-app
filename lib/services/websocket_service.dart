import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _dataController;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  String? _wsUrl;

  bool get isConnected => _isConnected;
  Stream<Map<String, dynamic>>? get dataStream => _dataController?.stream;

  /// Kết nối WebSocket
  Future<bool> connect(String baseUrl) async {
    try {
      _wsUrl = baseUrl;
      
      // ✅ Thêm /ws endpoint
      final wsUrl = baseUrl.endsWith('/ws') ? baseUrl : '$baseUrl/ws';
      
      debugPrint('🔌 Connecting to WebSocket: $wsUrl');

      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {
          'ngrok-skip-browser-warning': 'true',
        },
        connectTimeout: const Duration(seconds: 10), // ⭐ THÊM TIMEOUT
      );

      _dataController = StreamController<Map<String, dynamic>>.broadcast();
      
      // ✅ FIX: Set connected TRƯỚC khi listen
      _isConnected = true;
      
      // Lắng nghe dữ liệu
      _channel!.stream.listen(
        (data) {
          debugPrint('📥 Raw message: $data');
          _onDataReceived(data);
        },
        onError: (error) {
          debugPrint('❌ WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('⚠️ WebSocket connection closed');
          _handleDisconnect();
        },
        cancelOnError: false, // ⭐ Không cancel stream khi có lỗi
      );
      
      // ✅ Gửi ping mỗi 30 giây để duy trì connection
      _startPing();
      
      debugPrint('✅ WebSocket connected successfully');
      return true;
      
    } catch (e) {
      debugPrint('❌ WebSocket connection error: $e');
      _handleDisconnect();
      return false;
    }
  }

  /// ⭐ Gửi ping để giữ connection
  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add(json.encode({'type': 'ping'}));
          debugPrint('🏓 Ping sent');
        } catch (e) {
          debugPrint('❌ Ping failed: $e');
          _handleDisconnect();
        }
      }
    });
  }

  /// Xử lý dữ liệu nhận được
  void _onDataReceived(dynamic data) {
    try {
      final String dataString = data.toString();
      
      // Bỏ qua các message ping/pong
      if (dataString.contains('ping') || dataString.contains('pong')) {
        return;
      }
      
      final jsonData = json.decode(dataString);
      
      debugPrint('📥 WebSocket data: $jsonData');
      
      // Broadcast dữ liệu đến listeners
      _dataController?.add(jsonData);
      
    } catch (e) {
      debugPrint('❌ Parse error: $e - Raw data: $data');
    }
  }

  /// Gửi lệnh điều khiển
  Future<void> sendCommand(Map<String, dynamic> command) async {
    if (!_isConnected || _channel == null) {
      debugPrint('❌ WebSocket not connected');
      throw Exception('WebSocket not connected');
    }

    try {
      final jsonCommand = json.encode(command);
      debugPrint('📤 Sending command: $jsonCommand');
      _channel!.sink.add(jsonCommand);
      
      // ✅ Đợi một chút để đảm bảo message được gửi
      await Future.delayed(const Duration(milliseconds: 100));
      
      debugPrint('✅ Command sent successfully');
    } catch (e) {
      debugPrint('❌ Send command error: $e');
      throw Exception('Failed to send command: $e');
    }
  }

  

  /// Toggle thiết bị ON/OFF
  Future<void> toggleDevice(bool isOn) async {
    await sendCommand({
      'action': 'toggle',
      'value': isOn ? 1 : 0,
      'device': 'smart_plug',
    });
  }

  /// Xử lý ngắt kết nối
  void _handleDisconnect() {
    if (!_isConnected) return; // Tránh call nhiều lần
    
    _isConnected = false;
    _pingTimer?.cancel();
    
    debugPrint('⚠️ Connection lost, will reconnect in 5s...');
    
    // Tự động kết nối lại sau 5 giây
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_wsUrl != null && !_isConnected) {
        debugPrint('🔄 Attempting to reconnect...');
        connect(_wsUrl!);
      }
    });
  }

  /// Ngắt kết nối
  void disconnect() {
    try {
      _isConnected = false;
      _reconnectTimer?.cancel();
      _pingTimer?.cancel();
      _channel?.sink.close();
      _dataController?.close();
      debugPrint('🛑 WebSocket disconnected');
    } catch (e) {
      debugPrint('❌ Disconnect error: $e');
    }
  }

  /// Dispose
  void dispose() {
    disconnect();
  }
}