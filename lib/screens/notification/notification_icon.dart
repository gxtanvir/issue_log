import 'dart:async';
import 'package:flutter/material.dart';
import 'package:issue_log/services/api_service.dart';
import '../notification/notification_screen.dart';

class NotificationIcon extends StatefulWidget {
  const NotificationIcon({super.key});
  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon>
    with WidgetsBindingObserver {
  int _unread = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshCount();
    // poll every 20s (adjust if you like)
    _timer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _refreshCount(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // when app resumes, refresh count
    if (state == AppLifecycleState.resumed) _refreshCount();
  }

  Future<void> _refreshCount() async {
    try {
      final n = await ApiService.getUnreadNotificationCount();
      if (mounted) setState(() => _unread = n);
    } catch (e) {
      // ignore or log
      // print("notif count error: $e");
    }
  }

  void _openNotifications() async {
    // push notifications screen and refresh after it returns
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => NotificationScreen()));
    _refreshCount();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "Notifications",
      onPressed: _openNotifications,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none),
          if (_unread > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 209, 137, 132),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Center(
                  child: Text(
                    _unread > 99 ? '99+' : '$_unread',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
