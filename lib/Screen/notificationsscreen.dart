


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifications.dart';
import '../models/echo.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

// Accessing the global Echo instance
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

  // Chooses appropriate icon for each notification type
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
      backgroundColor: const Color(0xffe2e7ed),
      // App Bar with refresh and clear all buttons
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff30567c),
        elevation: 4,
        title: const Text("Notifications", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Reload",
            onPressed: () {
              final username = echo.activeUser?.user.username;
              if (username != null) controller.loadFromFirestore(username);
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
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

      // Main Body using Stack to combine background + notification list

      body: Stack(
        children: [
          // Top blue curved header
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(

              color: Color(0xff30567c),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),

            ),
          ),

          // Notification List UI
          Padding(
            padding: const EdgeInsets.only(top: 100), // pushes list down
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xfff1f4f8), Color(0xffe1eaf1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Obx(() {
                if (controller.notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.notifications_off, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No notifications yet",
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final msg = controller.notifications[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Card(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(_getIcon(msg), color: Colors.blue),
                          ),
                          title: Text(
                            msg,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),

      // Optionally simulate a notification (disabled by default)
      /*
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff30567c),
        icon: const Icon(Icons.add_alert),
        label: const Text("Simulate"),
        onPressed: () {
          final username = echo.activeUser?.user.username;
          if (username != null) {
            controller.addNotification("post", username);
          }
        },
      ),
      */
    );
  }
}

