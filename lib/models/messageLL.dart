import 'package:get/get.dart';
import 'echo.dart';

class MessageNode {
  String sender;
  String content;
  String timestamp;
  bool sentByMe;
  MessageNode? next;

  MessageNode({
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.sentByMe,
    this.next,
  });
}

class ChatNode {
  String username;
  MessageNode? messages;
  ChatNode? next;

  ChatNode({
    required this.username,
    this.messages,
    this.next,
  });
}

class Messages extends GetxController {
  ChatNode? _chatList;

  ChatNode? get chatList => _chatList;

  ChatNode? findChat(String username) {
    ChatNode? current = _chatList;
    while (current != null) {
      if (current.username == username) return current;
      current = current.next;
    }
    return null;
  }

  void addMessage(String receiver, MessageNode newMessage) {
    final Echo echo = Get.find<Echo>();

    if (_chatList != null && _chatList!.username == receiver) {
      newMessage.next = _chatList!.messages;
      _chatList!.messages = newMessage;
      return;
    }

    ChatNode? prev;
    ChatNode? current = _chatList;

    while (current != null && current.username != receiver) {
      prev = current;
      current = current.next;
    }

    if (current != null) {
      prev?.next = current.next;
      current.next = _chatList;
      _chatList = current;

      newMessage.next = current.messages;
      current.messages = newMessage;
    } else {
      ChatNode newChat = ChatNode(username: receiver);
      newMessage.next = null;
      newChat.messages = newMessage;
      newChat.next = _chatList;
      _chatList = newChat;
    }
  }

  void deleteAllChats() {
    _chatList = null;
  }

  List<Map<String, dynamic>> toJsonList() {
    List<Map<String, dynamic>> chatData = [];
    ChatNode? currentChat = _chatList;

    while (currentChat != null) {
      List<Map<String, dynamic>> messageList = [];
      MessageNode? currentMsg = currentChat.messages;

      while (currentMsg != null) {
        messageList.add({
          'sender': currentMsg.sender,
          'content': currentMsg.content,
          'timestamp': currentMsg.timestamp,
          'sentByMe': currentMsg.sentByMe,
        });
        currentMsg = currentMsg.next;
      }

      chatData.add({
        'username': currentChat.username,
        'messages': messageList,
      });

      currentChat = currentChat.next;
    }

    return chatData;
  }

  void loadFromJsonList(List<dynamic> jsonList) {
    _chatList = null;

    for (var chat in jsonList.reversed) {
      ChatNode newChat = ChatNode(username: chat['username']);
      List<dynamic> messagesJson = chat['messages'] ?? [];

      for (var msg in messagesJson.reversed) {
        MessageNode msgNode = MessageNode(
          sender: msg['sender'],
          content: msg['content'],
          timestamp: msg['timestamp'],
          sentByMe: msg['sentByMe'],
        );
        msgNode.next = newChat.messages;
        newChat.messages = msgNode;
      }

      newChat.next = _chatList;
      _chatList = newChat;
    }
  }
}
