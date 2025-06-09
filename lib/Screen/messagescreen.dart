import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/MessageController.dart';
import 'chatdetailscreen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final MessageController controller = Get.find<MessageController>();

  String searchQuery = '';
  bool userFound = false;
  String foundUsername = '';
  TextEditingController messageController = TextEditingController();

  // Current logged in user - replace with your actual current user logic
 // String currentUsername = 'currentUser';

  // Call this to search user in BST and validate
  Future<void> searchUser() async {
    if (searchQuery.trim().isEmpty) return;

    bool found = await controller.searchUserAndLoadChat(searchQuery);
    setState(() {
      userFound = found;
      foundUsername = found ? searchQuery.trim() : '';
      if (!found) messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Existing chats filtered for display
    List<String> allChats = controller.getChatUsernames();
    List<String> filteredChats = allChats
        .where((user) => user.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search box + search button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search user...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        userFound = false;
                        foundUsername = '';
                      });
                    },
                    onSubmitted: (value) => searchUser(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: searchUser,
                  child: const Text('Search'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // If user is found show UI to send message
            if (userFound)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User found: $foundUsername', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final content = messageController.text.trim();
                      if (content.isEmpty) return;

                      await controller.sendMessage(foundUsername, content);

                      // Clear message box
                      messageController.clear();

                      // Reload chats if needed
                     // await controller.loadChatsFromFirestore(currentUsername);

                      // Navigate to chat details screen
                      Get.to(() => ChatDetailScreen(username: foundUsername));
                    },
                    child: const Text('Send Message'),
                  ),
                  const Divider(height: 30),
                ],
              ),

            // Otherwise show list of existing chats filtered by searchQuery
            Expanded(
              child: ListView.builder(
                itemCount: filteredChats.length,
                itemBuilder: (context, index) {
                  final username = filteredChats[index];
                  return ListTile(
                    title: Text(username),
                    trailing: const Icon(Icons.chat),
                    onTap: () {
                      Get.to(() => ChatDetailScreen(username: username));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
