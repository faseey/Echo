// import 'package:get/get.dart';
// import '../models/bst.dart';
// import '../models/echo.dart';
// import '../models/messageLL.dart';
// import '../models/userService.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class MessageController extends GetxController {
//
//   final Echo echo = Get.find<Echo>();
//   BSTNode? get activeUserNode => echo.activeUser;
//   User? get currentUser => activeUserNode?.user;
//
//   // Send message: Adds to sender's and receiver's chat lists
//   Future<void> sendMessage( String receiver, String content) async {
//     String sender = currentUser!.username;
//     final timestamp = DateTime.now().toIso8601String();
//     print('[sendMessage] Called with sender: $sender, receiver: $receiver, content: $content');
//
//     // Create and add message to sender's chat list
//     final sentMsg = MessageNode(
//       sender: sender,
//       content: content,
//       timestamp: timestamp,
//       sentByMe: true,
//     );
//     currentUser?.message.addMessage(receiver, sentMsg);
//     print('[sendMessage] Sent message added to sender\'s chat list');
//     await saveUserToFirebase(activeUserNode!.user);
//     await loadUserFromFirebase(activeUserNode!.user.username);
//
//
//     // Create and add message to receiver's chat list
//     final receivedMsg = MessageNode(
//       sender: sender,
//       content: content,
//       timestamp: timestamp,
//       sentByMe: false,
//     );
//     final Echo echo = Get.find<Echo>();
//     final receiverNode = echo.bst.search(receiver);
//     if (receiverNode != null) {
//       receiverNode.user.message.addMessage(sender, receivedMsg);
//       receiverNode.user.notifications.addNotification('message', sender);
//       print('[sendMessage] Received message added to receiver\'s chat list');
//       await saveUserToFirebase(receiverNode!.user);
//       await loadUserFromFirebase(receiverNode!.user.username);
//
//     } else {
//       print('[sendMessage] Receiver not found in BST');
//
//     }
//      // Save updated sender data
//     update();
//
//   }
//
//
//   // Search a user in BST and load chat
//   Future<bool> searchUserAndLoadChat(String searchedUsername) async {
//     final Echo echo = Get.find<Echo>();
//     final trimmedUsername = searchedUsername.trim();
//
//
//     print('[searchUserAndLoadChat] Called with search: $trimmedUsername, current: $currentUser?.username');
//
//     // Check for self-chat
//     if (trimmedUsername == currentUser?.username ){
//       print('[searchUserAndLoadChat] Trying to chat with self');
//       Get.snackbar("Error", "You can't chat with yourself");
//       return false;
//     }
//
//     // Search in BST
//     final receiverNode = echo.bst.search(trimmedUsername);
//
//     if (receiverNode == null) {
//       print('[searchUserAndLoadChat] User not found in BST');
//       Get.snackbar("Error", "User not found");
//       return false;
//     }
//
//
//     return true;
//   }
//
//   // Returns list of chat usernames
//   List<String> getChatUsernames() {
//     print('[getChatUsernames] Called');
//     List<String> usernames = [];
//     ChatNode? current = currentUser?.message.chatList;
//     while (current != null) {
//       usernames.add(current.username);
//       print('[getChatUsernames] Found chat with: ${current.username}');
//       current = current.next;
//     }
//     return usernames;
//   }
//
//   List<MessageNode> getMessagesWith(String username) {
//     print('[getMessagesWith] Called for chat with: $username');
//     List<MessageNode> messageList = [];
//     ChatNode? chat = currentUser?.message.findChat(username);
//     if (chat == null) {
//       print('[getMessagesWith] Chat with $username not found');
//       return messageList;
//     }
//
//     MessageNode? msg = chat.messages;
//     while (msg != null) {
//       print('[getMessagesWith] Message: "${msg.content}" from ${msg.sender} at ${msg.timestamp}');
//       messageList.add(msg);
//       msg = msg.next;
//     }
//
//     // Reverse to show oldest messages first
//     return messageList.reversed.toList();
//   }
//
//
//
//   Future<void> saveUserToFirebase(User user) async {
//     final firestore = FirebaseFirestore.instance;
//     await firestore.collection('users').doc(user.username).set(user.toJson(), SetOptions(merge: true));
//     print('[saveUserToFirebase] Data saved for ${user.username}');
//   }
//
//
//   Future<User?> loadUserFromFirebase(String username) async {
//     final firestore = FirebaseFirestore.instance;
//     final doc = await firestore.collection('users').doc(username).get();
//
//     if (doc.exists) {
//       final data = doc.data()!;
//       print('[loadUserFromFirebase] Data loaded for $username');
//       return User.fromJson(data);
//     } else {
//       print('[loadUserFromFirebase] No data found for $username');
//       return null;
//     }
//   }
//
//
// }
import 'package:get/get.dart';
import '../models/bst.dart';
import '../models/echo.dart';
import '../models/messageLL.dart';
import '../models/userService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageController extends GetxController {
  final Echo echo = Get.find<Echo>();
  BSTNode? get activeUserNode => echo.activeUser;
  User? get currentUser => activeUserNode?.user;

  /// Sends a message to another user.
  /// Adds to both sender's and receiver's chat lists and saves to Firestore.
  Future<void> sendMessage(String receiver, String content) async {
    String sender = currentUser!.username;
    final timestamp = DateTime.now().toIso8601String();

    final sentMsg = MessageNode(
      sender: sender,
      content: content,
      timestamp: timestamp,
      sentByMe: true,
    );
    currentUser?.message.addMessage(receiver, sentMsg);
    await saveUserToFirebase(activeUserNode!.user);
    await loadUserFromFirebase(activeUserNode!.user.username);

    final receivedMsg = MessageNode(
      sender: sender,
      content: content,
      timestamp: timestamp,
      sentByMe: false,
    );

    final receiverNode = echo.bst.search(receiver);
    if (receiverNode != null) {
      receiverNode.user.message.addMessage(sender, receivedMsg);
      receiverNode.user.notifications.addNotification('message', sender);
      await saveUserToFirebase(receiverNode.user);
      await loadUserFromFirebase(receiverNode.user.username);
    } else {
      Get.snackbar("Error", "Receiver not found");
    }

    update();
  }

  /// Validates a username and checks if it's eligible for messaging.
  Future<bool> searchUserAndLoadChat(String searchedUsername) async {
    final trimmedUsername = searchedUsername.trim();

    if (trimmedUsername == currentUser?.username) {
      Get.snackbar("Error", "You can't chat with yourself");
      return false;
    }

    final receiverNode = echo.bst.search(trimmedUsername);
    if (receiverNode == null) {
      Get.snackbar("Error", "User not found");
      return false;
    }

    return true;
  }

  /// Returns all usernames with whom the current user has chatted.
  List<String> getChatUsernames() {
    List<String> usernames = [];
    ChatNode? current = currentUser?.message.chatList;
    while (current != null) {
      usernames.add(current.username);
      current = current.next;
    }
    return usernames;
  }

  /// Retrieves a list of messages exchanged with a specific user.
  List<MessageNode> getMessagesWith(String username) {
    List<MessageNode> messageList = [];
    ChatNode? chat = currentUser?.message.findChat(username);
    if (chat == null) return messageList;

    MessageNode? msg = chat.messages;
    while (msg != null) {
      messageList.add(msg);
      msg = msg.next;
    }

    return messageList.reversed.toList();
  }

  /// Saves the user's updated state to Firestore.
  Future<void> saveUserToFirebase(User user) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(user.username).set(user.toJson(), SetOptions(merge: true));
  }

  /// Loads a user's state from Firestore by username.
  Future<User?> loadUserFromFirebase(String username) async {
    final firestore = FirebaseFirestore.instance;
    final doc = await firestore.collection('users').doc(username).get();

    if (doc.exists) {
      final data = doc.data()!;
      return User.fromJson(data);
    } else {
      return null;
    }
  }
}
