/*import 'package:flutter/material.dart';
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

      body: Column(
        children: [

          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xff30567c),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: Row(
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

        ],
      ),
    );
  }
}*/


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

  Future<void> searchUser() async {
    if (searchQuery.trim().isEmpty) return;
    bool found = await controller.searchUserAndLoadChat(searchQuery.trim());
    setState(() {
      userFound = found;
      foundUsername = found ? searchQuery.trim() : '';
      if (!found) messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> allChats = controller.getChatUsernames();
    List<String> filteredChats = allChats
        .where((user) => user.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [

          // Top curved container with Stack
          Container(
            // height: userFound ? 320 : 200,
            // width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xff30567c),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Messsage",style: TextStyle(color: Colors.white,fontSize: 18),),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search user...',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
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
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          backgroundColor: const Color(0xfff8f8f8),
                          elevation: 5,
                          shadowColor: Colors.black45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: Color(0xff30567c)),
                            SizedBox(width: 6),
                            Text(
                              'Search',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff30567c),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (userFound) ...[
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'User found: $foundUsername',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                        messageController.clear();

                        Get.to(() => ChatDetailScreen(username: foundUsername));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Send Message'),
                    ),
                  ]
                ],
              ),
            ),
          ),

          // List of chat users below the curved container
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final username = filteredChats[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Text(username[0].toUpperCase()),
                    ),
                    title: Text(username, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chat_bubble_outline),
                    onTap: () {
                      Get.to(() => ChatDetailScreen(username: username));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

