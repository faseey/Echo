// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import '../models/notificationStack.dart';
//
// class NotificationController extends GetxController {
//   final NotificationStack _notification = NotificationStack();
//   var notifications = <String>[].obs;
//
//   void addNotification(String type, String username) {
//     _notification.addNotification(type, username);
//     notifications.value = _notification.showNotifications();
//   }
//
//   void clearAll() {
//     _notification.clearNotifications();
//     notifications.clear();
//   }
//
//   void refreshNotifications() {
//     notifications.value = _notification.showNotifications();
//   }
//
//
//   Future<void> loadFromFirestore(String username) async {
//     // Clear before loading fresh
//     _notification.clearNotifications();
//     notifications.clear();
//
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(username)
//           .get();
//
//       if (doc.exists && doc.data()?['notifications'] != null) {
//         List<dynamic> stored = doc.data()!['notifications'];
//         _notification.loadFromList(stored);
//         notifications.value = _notification.showNotifications();
//       }
//     } catch (e) {
//       print("Error loading notifications: $e");
//       Get.snackbar("Error", "Failed to load notifications",
//           backgroundColor: Get.theme.colorScheme.error,
//           colorText: Get.theme.colorScheme.onError);
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/notificationStack.dart';

class NotificationController extends GetxController {
  final NotificationStack _notification = NotificationStack();
  var notifications = <String>[].obs;

  /// Add a notification to the stack and update observable list
  void addNotification(String type, String username) {
    _notification.addNotification(type, username);
    notifications.value = _notification.showNotifications();
  }

  /// Clear all notifications from stack and UI
  void clearAll() {
    _notification.clearNotifications();
    notifications.clear();
  }

  /// Refresh observable list from the stack
  void refreshNotifications() {
    notifications.value = _notification.showNotifications();
  }

  /// Load notifications from Firestore for a given user
  Future<void> loadFromFirestore(String username) async {
    _notification.clearNotifications();
    notifications.clear();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .get();

      if (doc.exists && doc.data()?['notifications'] != null) {
        List<dynamic> stored = doc.data()!['notifications'];
        _notification.loadFromList(stored);
        notifications.value = _notification.showNotifications();
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load notifications",
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }
}
