import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/device.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart'; // ✅ THÊM IMPORT

class HomeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  HomeData? _homeData;
  String _selectedRoom = 'All Rooms';
  bool _isLoading = false;
  
  // ✅ THÊM: WebSocket service cho smart plug
  final Map<String, WebSocketService> _wsConnections = {};
  
  HomeData? get homeData => _homeData;
  String get selectedRoom => _selectedRoom;
  bool get isLoading => _isLoading;
  
  List<Device> get devices => _homeData?.devices ?? [];
  List<Room> get rooms => _homeData?.rooms ?? [];
  
  List<Device> get filteredDevices {
    if (_selectedRoom == 'All Rooms' || _homeData == null) {
      return devices;
    }
    return devices.where((d) => d.room == _selectedRoom).toList();
  }
  
  int get totalDevices => devices.length;
  int get activeDevices => devices.where((d) => d.isOn).toList().length;
  
  Map<String, int> get devicesByCategory {
    final Map<String, int> categories = {
      'Lightning': 0,
      'Cameras': 0,
      'Electrical': 0,
    };
    
    for (var device in devices) {
      final category = _getCategory(device.type);
      categories[category] = (categories[category] ?? 0) + 1;
    }
    
    return categories;
  }
  
  String _getCategory(String type) {
    if (['lamp', 'light'].contains(type.toLowerCase())) return 'Lightning';
    if (['camera', 'cctv', 'webcam'].contains(type.toLowerCase())) return 'Cameras';
    return 'Electrical';
  }
  
  int getDeviceCountByRoom(String roomName) {
    if (_homeData == null) return 0;
    
    String cleanRoomName = roomName;
    if (roomName.contains('(')) {
      cleanRoomName = roomName.substring(0, roomName.indexOf('(')).trim();
    }
    
    return devices.where((d) => d.room == cleanRoomName).length;
  }
  
  // ✅ HÀM KIỂM TRA SMART PLUG
  bool _isSmartPlug(String deviceType) {
    final type = deviceType.toLowerCase();
    return type == 'smart_plug' || 
           type == 'plug' || 
           type == 'smart plug' ||
           type == 'smartplug';
  }
  
  // ========== SAVE HOME SETUP (sau signup steps) ==========
  Future<bool> saveHomeSetup({
    required int userId,
    required String homeName,
    required String country,
    required List<Map<String, String>> rooms,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.saveHomeSetup(
        userId: userId,
        homeName: homeName,
        country: country,
        rooms: rooms,
      );

      await loadHomeData(userId.toString());
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('❌ Error saving home setup: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // ========== LOAD HOME DATA TỪ BACKEND ==========
  Future<void> loadHomeData(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _apiService.getHomeData(int.parse(userId));
      
      final List<Room> roomsList = [];
      if (data['rooms'] != null) {
        for (var roomData in data['rooms']) {
          roomsList.add(Room(
            id: roomData['id'].toString(),
            name: roomData['name'],
            icon: roomData['icon'] ?? 'room',
          ));
        }
      }

      final List<Device> devicesList = [];
      if (data['devices'] != null) {
        for (var deviceData in data['devices']) {
          devicesList.add(Device(
            id: deviceData['id'].toString(),
            name: deviceData['name'],
            type: deviceData['type'] ?? 'device',
            connectionType: deviceData['connectionType'] ?? 'Wi-Fi',
            room: deviceData['room'] ?? 'Living Room',
            imagePath: deviceData['imagePath'],
            isOn: deviceData['isOn'] ?? false,
          ));
        }
      }

      _homeData = HomeData(
        userId: userId,
        homeName: data['homeName'] ?? 'My Home',
        country: data['country'] ?? '',
        rooms: roomsList,
        devices: devicesList,
      );

      _isLoading = false;
      notifyListeners();
      
      debugPrint('✅ Loaded home data: ${rooms.length} rooms, ${devices.length} devices');
      
    } catch (e) {
      debugPrint('❌ Error loading home data: $e');
      
      _homeData = HomeData(
        userId: userId,
        homeName: 'My Home',
        country: '',
        rooms: [],
        devices: [],
      );
      
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void setSelectedRoom(String room) {
    _selectedRoom = room;
    notifyListeners();
  }
  
  // ========== ADD DEVICE QUA API ==========
  Future<bool> addDevice(Device device, int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.addDevice(
        userId: userId,
        name: device.name,
        type: device.type,
        connectionType: device.connectionType,
        room: device.room,
        imagePath: device.imagePath,
      );

      await loadHomeData(userId.toString());
      
      _isLoading = false;
      notifyListeners();
      
      debugPrint('✅ Device added successfully');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error adding device: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // ========== ✅ TOGGLE DEVICE VỚI WEBSOCKET CHO SMART PLUG ==========
  Future<void> toggleDevice(String deviceId, {String? websocketUrl}) async {
    try {
      if (_homeData == null) return;
      
      final device = _homeData!.devices.firstWhere((d) => d.id == deviceId);
      final newState = !device.isOn;
      
      // Toggle locally first (optimistic update)
      device.isOn = newState;
      notifyListeners();
      
      // ✅ KIỂM TRA NẾU LÀ SMART PLUG THÌ DÙNG WEBSOCKET
      if (_isSmartPlug(device.type) && websocketUrl != null) {
        await _toggleSmartPlugViaWebSocket(deviceId, device.name, newState, websocketUrl);
      } else {
        // Thiết bị thông thường dùng HTTP API
        await _apiService.toggleDevice(int.parse(deviceId));
      }
      
      debugPrint('✅ Device toggled successfully');
      
    } catch (e) {
      debugPrint('❌ Error toggling device: $e');
      
      // Revert on error
      if (_homeData != null) {
        final device = _homeData!.devices.firstWhere((d) => d.id == deviceId);
        device.isOn = !device.isOn;
        notifyListeners();
      }
    }
  }
  
  // ✅ HÀM TOGGLE SMART PLUG QUA WEBSOCKET
  Future<void> _toggleSmartPlugViaWebSocket(
    String deviceId, 
    String deviceName, 
    bool newState, 
    String websocketUrl
  ) async {
    try {
      // Kiểm tra xem đã có connection chưa
      if (!_wsConnections.containsKey(deviceId)) {
        debugPrint('🔌 Creating new WebSocket connection for $deviceName');
        _wsConnections[deviceId] = WebSocketService();
        
        // Kết nối
        final connected = await _wsConnections[deviceId]!.connect(websocketUrl);
        
        if (!connected) {
          throw Exception('WebSocket connection failed');
        }
        
        debugPrint('✅ WebSocket connected for $deviceName');
      }
      
      // Gửi lệnh toggle
      debugPrint('📤 Sending toggle command: ${newState ? "ON" : "OFF"}');
      await _wsConnections[deviceId]!.toggleDevice(newState);
      
      debugPrint('✅ WebSocket command sent successfully');
      
    } catch (e) {
      debugPrint('❌ WebSocket toggle error: $e');
      throw e;
    }
  }
  
  // ✅ HÀM DỌN DẸP WEBSOCKET CONNECTIONS
  void disposeWebSocketConnection(String deviceId) {
    if (_wsConnections.containsKey(deviceId)) {
      _wsConnections[deviceId]!.dispose();
      _wsConnections.remove(deviceId);
      debugPrint('🧹 Cleaned up WebSocket connection for device $deviceId');
    }
  }
  
  // ========== DELETE DEVICE QUA API ==========
  Future<bool> removeDevice(String deviceId, int userId) async {
    try {
      // Cleanup WebSocket connection nếu có
      disposeWebSocketConnection(deviceId);
      
      await _apiService.deleteDevice(int.parse(deviceId));
      await loadHomeData(userId.toString());
      
      debugPrint('✅ Device removed successfully');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error removing device: $e');
      return false;
    }
  }
  
  void addRoom(Room room) {
    if (_homeData == null) return;
    _homeData!.rooms.add(room);
    notifyListeners();
  }
  
  void updateHomeInfo({String? homeName, String? country, List<Room>? rooms}) {
    if (_homeData == null) return;
    
    if (homeName != null) {
      _homeData = HomeData(
        userId: _homeData!.userId,
        homeName: homeName,
        country: _homeData!.country,
        rooms: _homeData!.rooms,
        devices: _homeData!.devices,
      );
    }
    
    if (country != null) {
      _homeData = HomeData(
        userId: _homeData!.userId,
        homeName: _homeData!.homeName,
        country: country,
        rooms: _homeData!.rooms,
        devices: _homeData!.devices,
      );
    }
    
    if (rooms != null) {
      _homeData = HomeData(
        userId: _homeData!.userId,
        homeName: _homeData!.homeName,
        country: _homeData!.country,
        rooms: rooms,
        devices: _homeData!.devices,
      );
    }
    
    notifyListeners();
  }
  
  List<String> getRoomList() {
    if (_homeData == null || _homeData!.rooms.isEmpty) {
      return ['All Rooms'];
    }
    
    final List<String> roomNames = ['All Rooms'];
    for (var room in _homeData!.rooms) {
      roomNames.add(room.name);
    }
    return roomNames;
  }
  
  // ✅ DISPOSE TẤT CẢ WEBSOCKET CONNECTIONS KHI DISPOSE PROVIDER
  @override
  void dispose() {
    for (var ws in _wsConnections.values) {
      ws.dispose();
    }
    _wsConnections.clear();
    super.dispose();
  }
}


// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../models/device.dart';
// import '../services/api_service.dart';

// class HomeProvider with ChangeNotifier {
//   final ApiService _apiService = ApiService();
  
//   HomeData? _homeData;
//   String _selectedRoom = 'All Rooms';
//   bool _isLoading = false;
  
//   HomeData? get homeData => _homeData;
//   String get selectedRoom => _selectedRoom;
//   bool get isLoading => _isLoading;
  
//   List<Device> get devices => _homeData?.devices ?? [];
//   List<Room> get rooms => _homeData?.rooms ?? [];
  
//   List<Device> get filteredDevices {
//     if (_selectedRoom == 'All Rooms' || _homeData == null) {
//       return devices;
//     }
//     return devices.where((d) => d.room == _selectedRoom).toList();
//   }
  
//   int get totalDevices => devices.length;
//   int get activeDevices => devices.where((d) => d.isOn).toList().length;
  
//   // ✅ SỬA: devicesByCategory trả về Map<String, int>
//   Map<String, int> get devicesByCategory {
//     final Map<String, int> categories = {
//       'Lightning': 0,
//       'Cameras': 0,
//       'Electrical': 0,
//     };
    
//     for (var device in devices) {
//       final category = _getCategory(device.type);
//       categories[category] = (categories[category] ?? 0) + 1;
//     }
    
//     return categories;
//   }
  
//   String _getCategory(String type) {
//     if (['lamp', 'light'].contains(type.toLowerCase())) return 'Lightning';
//     if (['camera', 'cctv', 'webcam'].contains(type.toLowerCase())) return 'Cameras';
//     return 'Electrical';
//   }
  
//   // ✅ THÊM: Method getDeviceCountByRoom
//   int getDeviceCountByRoom(String roomName) {
//     if (_homeData == null) return 0;
    
//     // Xử lý trường hợp roomName có dạng "Living Room (3)"
//     String cleanRoomName = roomName;
//     if (roomName.contains('(')) {
//       cleanRoomName = roomName.substring(0, roomName.indexOf('(')).trim();
//     }
    
//     return devices.where((d) => d.room == cleanRoomName).length;
//   }
  
//   // ========== SAVE HOME SETUP (sau signup steps) ==========
//   Future<bool> saveHomeSetup({
//     required int userId,
//     required String homeName,
//     required String country,
//     required List<Map<String, String>> rooms,
//   }) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       await _apiService.saveHomeSetup(
//         userId: userId,
//         homeName: homeName,
//         country: country,
//         rooms: rooms,
//       );

//       // Reload home data sau khi save
//       await loadHomeData(userId.toString());
      
//       _isLoading = false;
//       notifyListeners();
//       return true;
      
//     } catch (e) {
//       debugPrint('❌ Error saving home setup: $e');
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
  
//   // ========== LOAD HOME DATA TỪ BACKEND ==========
//   Future<void> loadHomeData(String userId) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final data = await _apiService.getHomeData(int.parse(userId));
      
//       // Parse rooms
//       final List<Room> roomsList = [];
//       if (data['rooms'] != null) {
//         for (var roomData in data['rooms']) {
//           roomsList.add(Room(
//             id: roomData['id'].toString(),
//             name: roomData['name'],
//             icon: roomData['icon'] ?? 'room',
//           ));
//         }
//       }

//       // Parse devices
//       final List<Device> devicesList = [];
//       if (data['devices'] != null) {
//         for (var deviceData in data['devices']) {
//           devicesList.add(Device(
//             id: deviceData['id'].toString(),
//             name: deviceData['name'],
//             type: deviceData['type'] ?? 'device',
//             connectionType: deviceData['connectionType'] ?? 'Wi-Fi',
//             room: deviceData['room'] ?? 'Living Room',
//             imagePath: deviceData['imagePath'],
//             isOn: deviceData['isOn'] ?? false,
//           ));
//         }
//       }

//       // Create HomeData object
//       _homeData = HomeData(
//         userId: userId,
//         homeName: data['homeName'] ?? 'My Home',
//         country: data['country'] ?? '',
//         rooms: roomsList,
//         devices: devicesList,
//       );

//       _isLoading = false;
//       notifyListeners();
      
//       debugPrint('✅ Loaded home data: ${rooms.length} rooms, ${devices.length} devices');
      
//     } catch (e) {
//       debugPrint('❌ Error loading home data: $e');
      
//       // Fallback: Initialize empty home for new user
//       _homeData = HomeData(
//         userId: userId,
//         homeName: 'My Home',
//         country: '',
//         rooms: [],
//         devices: [],
//       );
      
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
  
//   void setSelectedRoom(String room) {
//     _selectedRoom = room;
//     notifyListeners();
//   }
  
//   // ========== ADD DEVICE QUA API ==========
//   Future<bool> addDevice(Device device, int userId) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       await _apiService.addDevice(
//         userId: userId,
//         name: device.name,
//         type: device.type,
//         connectionType: device.connectionType,
//         room: device.room,
//         imagePath: device.imagePath,
//       );

//       // Reload home data
//       await loadHomeData(userId.toString());
      
//       _isLoading = false;
//       notifyListeners();
      
//       debugPrint('✅ Device added successfully');
//       return true;
      
//     } catch (e) {
//       debugPrint('❌ Error adding device: $e');
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
  
//   // ========== TOGGLE DEVICE QUA API ==========
//   Future<void> toggleDevice(String deviceId) async {
//     try {
//       // Toggle locally first (optimistic update)
//       if (_homeData != null) {
//         final device = _homeData!.devices.firstWhere((d) => d.id == deviceId);
//         device.isOn = !device.isOn;
//         notifyListeners();
//       }

//       // Then sync with backend
//       await _apiService.toggleDevice(int.parse(deviceId));
      
//       debugPrint('✅ Device toggled successfully');
      
//     } catch (e) {
//       debugPrint('❌ Error toggling device: $e');
      
//       // Revert on error
//       if (_homeData != null) {
//         final device = _homeData!.devices.firstWhere((d) => d.id == deviceId);
//         device.isOn = !device.isOn;
//         notifyListeners();
//       }
//     }
//   }
  
//   // ========== DELETE DEVICE QUA API ==========
//   Future<bool> removeDevice(String deviceId, int userId) async {
//     try {
//       await _apiService.deleteDevice(int.parse(deviceId));
      
//       // Reload home data
//       await loadHomeData(userId.toString());
      
//       debugPrint('✅ Device removed successfully');
//       return true;
      
//     } catch (e) {
//       debugPrint('❌ Error removing device: $e');
//       return false;
//     }
//   }
  
//   void addRoom(Room room) {
//     if (_homeData == null) return;
//     _homeData!.rooms.add(room);
//     notifyListeners();
//   }
  
//   void updateHomeInfo({String? homeName, String? country, List<Room>? rooms}) {
//     if (_homeData == null) return;
    
//     if (homeName != null) {
//       _homeData = HomeData(
//         userId: _homeData!.userId,
//         homeName: homeName,
//         country: _homeData!.country,
//         rooms: _homeData!.rooms,
//         devices: _homeData!.devices,
//       );
//     }
    
//     if (country != null) {
//       _homeData = HomeData(
//         userId: _homeData!.userId,
//         homeName: _homeData!.homeName,
//         country: country,
//         rooms: _homeData!.rooms,
//         devices: _homeData!.devices,
//       );
//     }
    
//     if (rooms != null) {
//       _homeData = HomeData(
//         userId: _homeData!.userId,
//         homeName: _homeData!.homeName,
//         country: _homeData!.country,
//         rooms: rooms,
//         devices: _homeData!.devices,
//       );
//     }
    
//     notifyListeners();
//   }
  
//   // ✅ SỬA: getRoomList không thêm count vào tên phòng
//   List<String> getRoomList() {
//     if (_homeData == null || _homeData!.rooms.isEmpty) {
//       return ['All Rooms'];
//     }
    
//     final List<String> roomNames = ['All Rooms'];
//     for (var room in _homeData!.rooms) {
//       roomNames.add(room.name);
//     }
//     return roomNames;
//   }
// }