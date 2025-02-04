import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/app_provider.dart';
import '../services/database_helper.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    notifications = await DatabaseHelper().getNotifications();
    setState(() {

    });
  }

  void _showNotificationPopup(BuildContext context, Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title']),
        content: Text(notification['body']),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper().deleteNotification(notification['id']);
              _loadNotifications(); // Refresh UI
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return notifications.isEmpty
          ? Center(child: Text('No notifications'))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            child: ListTile(
              title: Text(notification['title']),
              onTap: () => _showNotificationPopup(context, notification),
            ),
          );
        },
      );
  }
}
