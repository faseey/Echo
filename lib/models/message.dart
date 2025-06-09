import 'package:get/get.dart';

import 'echo.dart';

class MessageNode {
  String sender;
  String content;
  String timestamp;
  bool sentByMe; // ✅ true = sent, false = received
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
  ChatNode? chatList;

  Messages();

  ChatNode? findChat(String username) {
    ChatNode? current = chatList;
    while (current != null) {
      if (current.username == username) return current;
      current = current.next;
    }
    return null;
  }
  // void addMessage(String receiver, MessageNode newMessage) {
  //   final Echo echo = Get.find<Echo>();
  //
  //   // Special case: head is the receiver
  //   if (chatList != null && chatList!.username == receiver) {
  //     newMessage.next = chatList!.messages;
  //     chatList!.messages = newMessage;
  //     return;
  //   }
  //
  //   ChatNode? prev = null;
  //   ChatNode? current = chatList;
  //
  //   while (current != null && current.username != receiver) {
  //     prev = current;
  //     current = current.next;
  //   }
  //
  //   if (current != null) {
  //     // Move existing chat to head
  //     prev?.next = current.next;
  //     current.next = chatList;
  //     chatList = current;
  //
  //     // Add message to front of message list
  //     newMessage.next = current.messages;
  //     current.messages = newMessage;
  //   } else {
  //     // New chat node
  //     ChatNode newChat = ChatNode(username: receiver);
  //     newMessage.next = null;
  //     newChat.messages = newMessage;
  //     newChat.next = chatList;
  //     chatList = newChat;
  //   }
  // }
  void addMessage(String receiver, MessageNode newMessage) {
    final Echo echo = Get.find<Echo>();

    print('[addMessage] Adding message for receiver: $receiver');
    if (chatList != null) {
      print('[addMessage] Current chatList head username: ${chatList!.username}');
    } else {
      print('[addMessage] chatList is currently empty');
    }

    // Special case: head is the receiver
    if (chatList != null && chatList!.username == receiver) {
      newMessage.next = chatList!.messages;
      chatList!.messages = newMessage;
      print('[addMessage] Added message to head chat node: ${chatList!.username}');
      _printChatList();
      return;
    }

    ChatNode? prev = null;
    ChatNode? current = chatList;

    while (current != null && current.username != receiver) {
      prev = current;
      current = current.next;
    }

    if (current != null) {
      // Move existing chat to head
      prev?.next = current.next;
      current.next = chatList;
      chatList = current;

      // Add message to front of message list
      newMessage.next = current.messages;
      current.messages = newMessage;

      print('[addMessage] Added message to existing chat node: ${current.username}');
    } else {
      // New chat node
      ChatNode newChat = ChatNode(username: receiver);
      newMessage.next = null;
      newChat.messages = newMessage;
      newChat.next = chatList;
      chatList = newChat;

      print('[addMessage] Created new chat node for receiver: $receiver');
    }

    _printChatList();
  }

  void _printChatList() {
    print('--- Chat List Start ---');
    ChatNode? current = chatList;
    while (current != null) {
      int messageCount = 0;
      MessageNode? msg = current.messages;
      while (msg != null) {
        messageCount++;
        msg = msg.next;
      }
      print('ChatNode: ${current.username}, Messages: $messageCount');
      current = current.next;
    }
    print('--- Chat List End ---');
  }

    void showChat( String user2) {
    final chat = findChat(user2);
    if (chat == null) {
      print("No chat with $user2.");
      return;
    }

    MessageNode? msg = chat.messages;
    while (msg != null) {
      String direction = msg.sentByMe ? "Sent ➡️" : "⬅️ Received";
      print("[$direction] ${msg.sender}: ${msg.content} (${msg.timestamp})");
      msg = msg.next;
    }
  }

  // void showInbox(String username) {
  //   ChatNode? current = chatList;
  //   print("Inbox for $username:");
  //   while (current != null) {
  //     print("- ${current.username}");
  //     current = current.next;
  //   }
  // }
  //
  // bool hasChat(String user1, String user2) {
  //   return findChat(user2) != null;
  // }
  //
  // void loadChat(String user1, String user2) {
  //   print("Loading chat between $user1 and $user2...");
  //   // Placeholder
  // }

  void deleteAllChats() {
    chatList = null;
  }
  List<Map<String, dynamic>> toJsonList() {
    List<Map<String, dynamic>> chatData = [];
    ChatNode? currentChat = chatList;
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
    chatList = null; // Clear existing
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

      newChat.next = chatList;
      chatList = newChat;
    }
  }

}
