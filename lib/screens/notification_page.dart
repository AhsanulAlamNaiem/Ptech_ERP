import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ptech_erp/services/app_provider.dart';
import '../services/database_helper.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<AppProvider>().loadNotification();
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
              // await DatabaseHelper().deleteNotification(notification['id']);
              context.read<AppProvider>().loadNotification(); // Refresh UI
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<AppProvider>().notifications;
    return notifications.isEmpty
          ? Center(child: Text('No notifications'))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            child: ListTile(
              title: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Text(notification['title'])),
                    Expanded(
                        flex: 1,
                        child: IconButton(onPressed: () async{
                          await DatabaseHelper().deleteNotification(notification['id']);
                          context.read<AppProvider>().loadNotification();
                        }, icon: Icon(Icons.delete)),
                  )]),
              onTap: () => _showNotificationPopup(context, notification),
            ),
          );
        },
      );
  }
}
