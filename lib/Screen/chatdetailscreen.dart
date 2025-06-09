import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/MessageController.dart';
import '../models/message.dart';

class ChatDetailScreen extends StatefulWidget {
  final String username;
  ChatDetailScreen({super.key, required this.username});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final MessageController controller = Get.find<MessageController>();
  final TextEditingController _textController = TextEditingController();

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      controller.sendMessage(widget.username, text); // Implement this in your controller
      _textController.clear();
      setState(() {}); // Refresh UI to show new message
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MessageNode> messages = controller.getMessagesWith(widget.username).reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.username}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text("No messages yet."))
                : ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isSent = msg.sentByMe;

                return Align(
                  alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSent ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg.content, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          msg.timestamp,
                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
