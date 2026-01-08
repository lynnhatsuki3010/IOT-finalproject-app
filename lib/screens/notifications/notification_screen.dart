import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedTab = 0;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      icon: Icons.security,
      title: 'Account Security Alert 🔒',
      message: "We've noticed some unusual activity on your account. Please review your recent logins and update your password if necessary.",
      time: '09:41 AM',
      isUnread: true,
    ),
    NotificationItem(
      icon: Icons.system_update,
      title: 'System Update Available 🔄',
      message: 'A new system update is ready for installation. It includes performance improvements and bug fixes.',
      time: '08:46 AM',
      isUnread: true,
    ),
    NotificationItem(
      icon: Icons.lock,
      title: 'Password Reset Successful ✅',
      message: "Your password has been successfully reset. If you didn't request this change, please contact support immediately.",
      time: '20:30 PM',
      isUnread: false,
      isYesterday: true,
    ),
    NotificationItem(
      icon: Icons.new_releases,
      title: 'Exciting New Feature 🆕',
      message: "We've just launched a new feature that will enhance your user experience. Check it out now!",
      time: '16:29 PM',
      isUnread: false,
      isYesterday: true,
    ),
    NotificationItem(
      icon: Icons.event,
      title: 'Event Reminder 📅',
      message: 'Your scheduled event starts in 1 hour. Don\'t forget!',
      time: '14:30 PM',
      isUnread: false,
      isYesterday: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1A20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildTab('General', 0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTab('Smart Home', 1),
                ),
              ],
            ),
          ),
          
          // Notifications List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildNotificationItem(_notifications[0]),
                _buildNotificationItem(_notifications[1]),
                const SizedBox(height: 24),
                const Text(
                  'Yesterday',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildNotificationItem(_notifications[2]),
                _buildNotificationItem(_notifications[3]),
                _buildNotificationItem(_notifications[4]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B7CFF) : const Color(0xFF2A2930),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2930),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1A20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.message,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.time,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              if (item.isUnread)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5B7CFF),
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool isUnread;
  final bool isYesterday;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    this.isUnread = false,
    this.isYesterday = false,
  });
}