import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notificationController.dart';

import '../models/echo.dart'; // Assuming Echo class is defined here

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}
final Echo echo = Get.find<Echo>();
class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController controller = Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    final username = echo.activeUser?.user.username;
    if (username != null) {
      controller.loadFromFirestore(username);
    } else {
      Get.snackbar("Error", "User not logged in",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: Duration(seconds: 2));
    }
  }

  IconData _getIcon(String message) {
    if (message.contains("new post")) return Icons.post_add;
    if (message.contains("follow request")) return Icons.person_add;
    if (message.contains("accepted")) return Icons.check_circle;
    if (message.contains("message")) return Icons.message;
    return Icons.notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "Reload",
            onPressed: () {
              final username = echo.activeUser?.user.username;
              if (username != null) controller.loadFromFirestore(username);
            },
          ),
          IconButton(
            icon: Icon(Icons.clear_all),
            tooltip: "Clear All",
            onPressed: () {
              controller.clearAll();
              Get.snackbar("Cleared", "All notifications removed",
                  backgroundColor: Colors.grey[800],
                  colorText: Colors.white,
                  duration: Duration(seconds: 2));
            },
          )
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 60, color: Colors.grey),
                SizedBox(height: 12),
                Text("No notifications yet",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(12),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) => SizedBox(height: 8),
          itemBuilder: (context, index) {
            final msg = controller.notifications[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(_getIcon(msg), color: Colors.blueAccent),
                title: Text(msg,
                    style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add_alert),
        label: Text("Simulate"),
        onPressed: () {
          final username = echo.activeUser?.user.username;
          if (username != null) {
            controller.addNotification("post", username);
          }
        },
      ),
    );
  }
}
