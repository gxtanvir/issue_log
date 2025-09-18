import 'package:flutter/material.dart';
import 'package:issue_log/services/api_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<dynamic>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = ApiService.getUserNotifications();
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _notificationsFuture = ApiService.getUserNotifications();
    });
  }

  Future<void> _markAsRead(int id) async {
    final success = await ApiService.markNotificationRead(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification marked as read")),
      );
      _refreshNotifications();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to mark as read")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: FutureBuilder<List<dynamic>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text("Error: ${snapshot.error.toString()}"));
            }
            final notifications = snapshot.data ?? [];
            if (notifications.isEmpty) {
              return const Center(child: Text("No notifications"));
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final id = notif["id"] as int;
                final title = notif["title"] ?? "Notification";
                final message = notif["message"] ?? "";
                final isRead = notif["is_read"] == true;

                return Card(
                  child: ListTile(
                    leading: Icon(
                      isRead
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: isRead ? Colors.grey : Colors.blue,
                    ),
                    title: Text(title,
                        style: TextStyle(
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Text(message),
                    onTap: () => _markAsRead(id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
