import 'package:get/get.dart';
import '../models/bst.dart';
import '../models/echo.dart';
import '../models/message.dart';
import '../user_data_model/userService.dart';

class MessageController extends GetxController {

  BSTNode? get activeUserNode => Echo.activeUser;
  User? get currentUser => activeUserNode?.user;

  // Send message: Adds to sender's and receiver's chat lists
  Future<void> sendMessage( String receiver, String content) async {
    String sender = currentUser!.username;
    final timestamp = DateTime.now().toIso8601String();
    print('[sendMessage] Called with sender: $sender, receiver: $receiver, content: $content');

    // Create and add message to sender's chat list
    final sentMsg = MessageNode(
      sender: sender,
      content: content,
      timestamp: timestamp,
      sentByMe: true,
    );
    currentUser?.message.addMessage(receiver, sentMsg);
    print('[sendMessage] Sent message added to sender\'s chat list');

    // Create and add message to receiver's chat list
    final receivedMsg = MessageNode(
      sender: sender,
      content: content,
      timestamp: timestamp,
      sentByMe: false,
    );
    final Echo echo = Get.find<Echo>();
    final receiverNode = echo.bst.search(receiver);
    if (receiverNode != null) {
      receiverNode.user.message.addMessage(sender, receivedMsg);
      print('[sendMessage] Received message added to receiver\'s chat list');
    } else {
      print('[sendMessage] Receiver not found in BST');

    }
     // Save updated sender data
    update();

  }

  // Search a user in BST and load chat
  Future<bool> searchUserAndLoadChat(String searchedUsername) async {
    final Echo echo = Get.find<Echo>();
    final trimmedUsername = searchedUsername.trim();


    print('[searchUserAndLoadChat] Called with search: $trimmedUsername, current: $currentUser?.username');

    // Check for self-chat
    if (trimmedUsername == currentUser?.username ){
      print('[searchUserAndLoadChat] Trying to chat with self');
      Get.snackbar("Error", "You can't chat with yourself");
      return false;
    }

    // Search in BST
    final receiverNode = echo.bst.search(trimmedUsername);

    if (receiverNode == null) {
      print('[searchUserAndLoadChat] User not found in BST');
      Get.snackbar("Error", "User not found");
      return false;
    }


    return true;
  }

  // Returns list of chat usernames
  List<String> getChatUsernames() {
    print('[getChatUsernames] Called');
    List<String> usernames = [];
    ChatNode? current = currentUser?.message.chatList;
    while (current != null) {
      usernames.add(current.username);
      print('[getChatUsernames] Found chat with: ${current.username}');
      current = current.next;
    }
    return usernames;
  }

  List<MessageNode> getMessagesWith(String username) {
    print('[getMessagesWith] Called for chat with: $username');
    List<MessageNode> messageList = [];
    ChatNode? chat = currentUser?.message.findChat(username);
    if (chat == null) {
      print('[getMessagesWith] Chat with $username not found');
      return messageList;
    }

    MessageNode? msg = chat.messages;
    while (msg != null) {
      print('[getMessagesWith] Message: "${msg.content}" from ${msg.sender} at ${msg.timestamp}');
      messageList.add(msg);
      msg = msg.next;
    }

    // Reverse to show oldest messages first
    return messageList.reversed.toList();
  }

}
