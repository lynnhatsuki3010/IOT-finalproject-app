class Device {
  final String id;
  final String name;
  final String type; // 'lamp', 'speaker', 'camera', etc.
  final String connectionType; // 'Wi-Fi' or 'Bluetooth'
  final String room;
  final String? imagePath;
  bool isOn;
  
  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.connectionType,
    required this.room,
    this.imagePath,
    this.isOn = false,
  });
  
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      connectionType: json['connectionType'] ?? 'Wi-Fi',
      room: json['room'] ?? '',
      imagePath: json['imagePath'],
      isOn: json['isOn'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'connectionType': connectionType,
      'room': room,
      'imagePath': imagePath,
      'isOn': isOn,
    };
  }
  
  String getImagePath() {
    if (imagePath != null) return imagePath!;
    
    // Map device names to image assets
    switch (name.toLowerCase()) {
      case 'smart v1 cctv':
        return 'assets/devices/smartv1cctv.png';
      case 'smart v2 cctv':
        return 'assets/devices/smartv2cctv.png';
      case 'smart webcam':
        return 'assets/devices/smartwebcam.png';
      case 'smart lamp':
        return 'assets/devices/smartlamp.png';
      case 'smart speaker':
      case 'stereo speaker':
        return 'assets/devices/smartspeaker.png';
      case 'smart router':
      case 'router':
        return 'assets/devices/smartplugin.png';
      default:
        return 'assets/devices/smartplugin.png';
    }
  }
}

class Room {
  final String id;
  final String name;
  final String icon;
  
  Room({
    required this.id,
    required this.name,
    required this.icon,
  });
  
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? 'room',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}

class HomeData {
  final String userId;
  final String homeName;
  final String country;
  final List<Room> rooms;
  final List<Device> devices;
  
  HomeData({
    required this.userId,
    required this.homeName,
    required this.country,
    required this.rooms,
    required this.devices,
  });
  
  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      userId: json['userId'] ?? '',
      homeName: json['homeName'] ?? 'My Home',
      country: json['country'] ?? '',
      rooms: (json['rooms'] as List?)
          ?.map((r) => Room.fromJson(r))
          .toList() ?? [],
      devices: (json['devices'] as List?)
          ?.map((d) => Device.fromJson(d))
          .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'homeName': homeName,
      'country': country,
      'rooms': rooms.map((r) => r.toJson()).toList(),
      'devices': devices.map((d) => d.toJson()).toList(),
    };
  }
}