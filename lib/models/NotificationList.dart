import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationNode {
  String type;
  String username;
  String message;
  NotificationNode? next;

  NotificationNode({
    required this.type,
    required this.username,
    required this.message,
    this.next,
  });
}

class NotificationStack {
  NotificationNode? top;

  final Map<String, String> messages = {
    'post': ' made a new post!',
    'request': ' sent you a follow request!',
    'accepted': ' accepted your follow request!',
    'message': ' sent you a message!',
  };

  void addNotification(String type, String username) {
    if (!messages.containsKey(type)) {
      print("Unknown notification type");
      return;
    }

    final message = '$username${messages[type]}';
    final newNode = NotificationNode(
      type: type,
      username: username,
      message: message,
      next: top,
    );
    top = newNode;
  }

  List<String> showNotifications() {
    List<String> notis = [];
    NotificationNode? current = top;
    while (current != null) {
      notis.add(current.message);  // ✅ FIXED
      current = current.next;
    }
    return notis;
  }



  void clearNotifications() {
    top = null;
  }


  List<String> toList() {
    return showNotifications();  // Same logic, reuse
  }

  void loadFromList(List<dynamic> data) {
    for (var message in data.reversed) {
      final parts = message.split(' ');
      if (parts.length >= 2) {
        final username = parts[0];
        if (message.contains('new post')) {
          addNotification('post', username);
        } else if (message.contains('follow request')) {
          addNotification('request', username);
        } else if (message.contains('accepted')) {
          addNotification('accepted', username);
        } else if (message.contains('sent you a message')) {
          addNotification('message', username);
        }
      }
    }
  }
}
