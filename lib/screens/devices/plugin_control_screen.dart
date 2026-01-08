import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../services/websocket_service.dart';

class PluginControlScreen extends StatefulWidget {
  final String deviceName;
  final String baseUrl; // WebSocket URL: ws://host:port or wss://host:port
  final String? deviceId; // Optional: để lưu vào database

  const PluginControlScreen({
    super.key,
    required this.deviceName,
    required this.baseUrl,
    this.deviceId,
  });

  @override
  State<PluginControlScreen> createState() => _PluginControlScreenState();
}

class _PluginControlScreenState extends State<PluginControlScreen> {
  bool _isOn = false;
  double _current = 0.0;
  double _power = 0.0;
  double _voltage = 220.0;
  DateTime? _lastUpdate;

  // WebSocket Service
  final WebSocketService _wsService = WebSocketService();
  bool _isConnected = false;
  StreamSubscription? _dataSubscription;

  // ✅ Định nghĩa các Topic Telemetry
  static const String TOPIC_CONTROL = '/plugin/control';
  static const String TOPIC_STATUS = '/plugin/status';

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _wsService.dispose();
    super.dispose();
  }

  Future<void> _connectWebSocket() async {
    try {
      debugPrint('🔌 Connecting to WebSocket: ${widget.baseUrl}');
      
      final success = await _wsService.connect(widget.baseUrl);
      
      if (success && mounted) {
        setState(() => _isConnected = true);
        
        // Lắng nghe dữ liệu từ WebSocket
        _dataSubscription = _wsService.dataStream?.listen(
          _handleWebSocketData,
          onError: (error) {
            debugPrint('❌ WebSocket stream error: $error');
            if (mounted) {
              setState(() => _isConnected = false);
            }
          },
          onDone: () {
            debugPrint('⚠️ WebSocket stream closed');
            if (mounted) {
              setState(() => _isConnected = false);
            }
          },
        );
        
        debugPrint('✅ WebSocket connected and listening');
      } else {
        debugPrint('❌ WebSocket connection failed');
        if (mounted) {
          setState(() => _isConnected = false);
        }
      }
      
    } catch (e) {
      debugPrint('❌ WebSocket connection error: $e');
      if (mounted) {
        setState(() => _isConnected = false);
      }
    }
  }

  void _handleWebSocketData(Map<String, dynamic> data) {
    try {
      debugPrint('📥 Received data: $data');
      
      // Xử lý dữ liệu theo format từ ESP32
      // Format 1: {"current": 1.234, "power": 271.48, "relay": 1}
      // Format 2: {"current": "1.234", "power": "271.48", "relay": "1"}
      
      if (mounted) {
        setState(() {
          // Parse current
          if (data.containsKey('current')) {
            _current = double.tryParse(data['current'].toString()) ?? 0.0;
          }
          
          // Parse power
          if (data.containsKey('power')) {
            _power = double.tryParse(data['power'].toString()) ?? 0.0;
          }
          
          // Parse voltage (nếu có)
          if (data.containsKey('voltage')) {
            _voltage = double.tryParse(data['voltage'].toString()) ?? 220.0;
          }
          
          // Parse relay state
          if (data.containsKey('relay')) {
            final relayValue = int.tryParse(data['relay'].toString()) ?? 0;
            _isOn = (relayValue == 1);
          }
          
          _lastUpdate = DateTime.now();
        });
        
        debugPrint('✅ Updated: ${_current.toStringAsFixed(3)}A | ${_power.toStringAsFixed(1)}W | ${_isOn ? "ON" : "OFF"}');
      }
      
    } catch (e) {
      debugPrint('❌ Data parse error: $e');
    }
  }

  Future<void> _togglePower(bool value) async {
    if (!_isConnected) {
      _showSnackBar('❌ Not connected to device');
      return;
    }

    try {
      // Optimistic update
      setState(() => _isOn = value);
      
      debugPrint('🎯 Toggling device: ${value ? "ON" : "OFF"}');
      
      // Gửi lệnh qua WebSocket
      await _wsService.toggleDevice(value);
      
      debugPrint('✅ Toggle command sent');
      
    } catch (e) {
      debugPrint('❌ Toggle error: $e');
      
      // Rollback nếu lỗi
      if (mounted) {
        setState(() => _isOn = !value);
      }
      
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStale = _lastUpdate == null || 
                    DateTime.now().difference(_lastUpdate!) > const Duration(seconds: 10);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1A20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Smart Plug Control',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          // Connection Status Indicator
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isConnected && !isStale 
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: _isConnected && !isStale ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isConnected && !isStale ? 'LIVE' : 'SYNC',
                      style: TextStyle(
                        color: _isConnected && !isStale ? Colors.green : Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _connectWebSocket,
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
                  // Device header
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2930),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.power,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.deviceName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _lastUpdate != null 
                                  ? 'Updated ${_formatLastUpdate(_lastUpdate!)}'
                                  : 'Waiting for data...',
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isOn,
                        onChanged: _isConnected ? _togglePower : null,
                        activeColor: const Color(0xFF5B7CFF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Power Wheel Visualization
                  _buildPowerWheel(),
                  
                  const SizedBox(height: 40),
                  
                  // Metrics Row (Current & Voltage)
                  _buildMetricsRow(),
                  
                  const SizedBox(height: 24),
                  
                  // Energy Stats Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showEnergyStatsDialog(context),
                      icon: const Icon(Icons.bar_chart, color: Color(0xFF5B7CFF)),
                      label: const Text(
                        'View Energy Statistics',
                        style: TextStyle(
                          color: Color(0xFF5B7CFF),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF5B7CFF), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerWheel() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated power wheel
          CustomPaint(
            size: const Size(300, 300),
            painter: PowerWheelPainter(_isOn, _power),
          ),
          
          // Center display (Power in Watts)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_power.toStringAsFixed(1)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: _isOn 
                          ? const Color(0xFF5B7CFF).withOpacity(0.5)
                          : Colors.transparent,
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const Text(
                'WATTS',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _isOn 
                      ? const Color(0xFF5B7CFF).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isOn ? 'ACTIVE' : 'STANDBY',
                  style: TextStyle(
                    color: _isOn ? const Color(0xFF5B7CFF) : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'CURRENT',
            '${_current.toStringAsFixed(3)} A',
            Icons.flash_on,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'VOLTAGE',
            '${_voltage.toStringAsFixed(1)} V',
            Icons.electrical_services,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2930),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdate(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inSeconds < 5) return "just now";
    if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    return "${diff.inHours}h ago";
  }

  void _showEnergyStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2930),
        title: const Text(
          'Energy Statistics',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Today', '${(_power * 0.024).toStringAsFixed(2)} kWh'),
            const SizedBox(height: 8),
            _buildStatRow('This Week', '${(_power * 0.168).toStringAsFixed(2)} kWh'),
            const SizedBox(height: 8),
            _buildStatRow('This Month', '${(_power * 0.72).toStringAsFixed(2)} kWh'),
            const SizedBox(height: 16),
            const Text(
              'Feature coming soon!',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF5B7CFF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9CA3AF)),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Power Wheel Painter (animated ring based on power usage)
class PowerWheelPainter extends CustomPainter {
  final bool isOn;
  final double power;

  PowerWheelPainter(this.isOn, this.power);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // Background ring
    final bgPaint = Paint()
      ..color = const Color(0xFF2A2930)
      ..strokeWidth = 30
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, bgPaint);
    
    if (isOn) {
      // Animated power ring (based on power level)
      final powerLevel = (power / 2200).clamp(0.0, 1.0); // Max 2200W
      
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        colors: [
          const Color(0xFF5B7CFF).withOpacity(0.3),
          const Color(0xFF5B7CFF),
          const Color(0xFF00D4FF),
          const Color(0xFF5B7CFF).withOpacity(0.3),
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = 30
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      // Draw arc based on power level
      final sweepAngle = 2 * math.pi * powerLevel;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        paint,
      );
      
      // Glow effect
      final glowPaint = Paint()
        ..color = const Color(0xFF5B7CFF).withOpacity(0.1)
        ..strokeWidth = 40
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(center, radius, glowPaint);
    }
    
    // Inner decoration circles
    final innerPaint1 = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawCircle(center, radius - 50, innerPaint1);
    canvas.drawCircle(center, radius - 70, innerPaint1);
  }

  @override
  bool shouldRepaint(PowerWheelPainter oldDelegate) =>
      oldDelegate.isOn != isOn || oldDelegate.power != power;
}