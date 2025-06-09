import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../component/MyDrawer.dart';
import '../component/button_container.dart';
import '../controllers/friend_controller.dart';

class FriendScreen extends StatelessWidget {
  FriendScreen({Key? key}) : super(key: key);

  final FriendController controller = Get.put(FriendController());

  // State observables for toggling views
  final RxBool showRequests = false.obs;
  final RxBool showFriends = false.obs;

  void toggleRequests() async {
    if (!showRequests.value) {
      await controller.loadRequestsFromFirestore();
    }
    showRequests.value = !showRequests.value;
    showFriends.value = false; // Hide friends list when showing requests
  }

  void toggleFriends() async {
    if (!showFriends.value) {
      await controller.loadFriendListFromFirestore(
        controller.currentUser!.username,
      );
    }
    showFriends.value = !showFriends.value;
    showRequests.value = false; // Hide requests list when showing friends
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        iconTheme: IconThemeData(color: Colors.white),
        title: Center(
          child: Text(
            "Echo",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.requestTextController,
                      decoration: InputDecoration(
                        hintText: "Search username here...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        controller.loadRequestsFromFirestore();
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    height: 52,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        controller.loadRequestsFromFirestore();
                      },
                      icon: Icon(Icons.refresh, color: Colors.white),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Buttons for actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ButtonContainer(
                    title: 'Send Request',
                    icon: Icons.person_add,
                    onTab: () async {
                      final username = controller.requestTextController.text.trim();
                      if (username.isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Please enter a username",
                          backgroundColor: Colors.black38,
                          duration: Duration(seconds: 2),
                          colorText: Colors.white,
                        );
                        return;
                      }
                      await controller.sendFriendRequest(username);
                      controller.requestTextController.clear();
                    },
                  ),
                  ButtonContainer(
                    title: 'Display Requests',
                    icon: Icons.display_settings,
                    onTab: toggleRequests,
                  ),
                  ButtonContainer(
                    title: 'Show Friends',
                    icon: Icons.group,
                    onTab: toggleFriends,
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Requests View
              Obx(() {
                if (!showRequests.value) return SizedBox.shrink();
                final requests = controller.allRequest;
                return requests.isEmpty
                    ? Text("No pending friend requests.")
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Friend Requests",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final senderUsername = requests[index];
                        return Card(
                          color: Colors.blue[50],
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text("$senderUsername sent you a friend request"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  tooltip: "Accept",
                                  onPressed: () async {
                                    await controller.acceptRequestBySender(senderUsername);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: "Delete",
                                  onPressed: () async {
                                    await controller.deleteRequestBySender(senderUsername);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),

              SizedBox(height: 24),

              // Friends View
              Obx(() {
                if (!showFriends.value) return SizedBox.shrink();
                final friends = controller.friendUsernames;
                return friends.isEmpty
                    ? Text("No friends to show.")
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Friends:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.person_outline),
                          title: Text(friends[index]),
                        );
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
