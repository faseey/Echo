import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../component/MyDrawer.dart';
import '../component/button_container.dart';
import '../controllers/friends_connections.dart';

class FriendScreen extends StatelessWidget {
  FriendScreen({Key? key}) : super(key: key);

  final FriendController controller = Get.put(FriendController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // State observables for toggling views
  final RxBool showRequests = false.obs;
  final RxBool showFriends = false.obs;
  final RxBool showSuggestions = false.obs;

  void toggleRequests() async {
    if (!showRequests.value) {
      await controller.loadRequestsFromFirestore();
    }
    showRequests.value = !showRequests.value;
    showFriends.value = false;
    showSuggestions.value = false;
  }

  void toggleFriends() async {
    if (!showFriends.value) {
      await controller.loadFriendListFromFirestore(
        controller.currentUser!.username,
      );
    }
    showFriends.value = !showFriends.value;
    showRequests.value = false;
    showSuggestions.value = false;
  }

  void toggleSuggestions() async {
    if (!showSuggestions.value) {
      await controller.loadSuggestions();
    }
    showSuggestions.value = !showSuggestions.value;
    showRequests.value = false;
    showFriends.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffd5e4f1),
      key: _scaffoldKey,
      drawer: MyDrawer(),
      body: Column(
        children: [
          // Header Section
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
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Friends",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.requestTextController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            hintText: "Search username here...",
                            hintStyle: TextStyle(color: Colors.white70),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          style: TextStyle(color: Colors.white),
                          onFieldSubmitted: (value) {
                            controller.loadRequestsFromFirestore();
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
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
                ),
              ],
            ),
          ),

          // Button Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
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
                ButtonContainer(
                  title: 'Suggestions',
                  icon: Icons.recommend,
                  onTab: toggleSuggestions,
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Requests View
                  Obx(() {
                    if (!showRequests.value) return SizedBox.shrink();
                    final requests = controller.allRequest;
                    return requests.isEmpty
                        ? Center(child: Text("No pending friend requests."))
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Friend Requests",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...requests.map((senderUsername) => Card(
                          margin: EdgeInsets.only(bottom: 10),
                          color: Colors.blue[50],
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text(
                              "$senderUsername sent you a friend request",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  tooltip: "Accept",
                                  onPressed: () async {
                                    await controller.acceptRequestofSender(senderUsername,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: "Delete",
                                  onPressed: () async {
                                    await controller
                                        .deleteRequestBySender(
                                      senderUsername,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    );
                  }),

                  // Friends View
                  Obx(() {
                    if (!showFriends.value) return SizedBox.shrink();
                    final friends = controller.friendUsernames;
                    return friends.isEmpty
                        ? Center(child: Text("No friends to show."))
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Friends:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...friends.map((friend) => ListTile(
                          leading: Icon(Icons.person_outline),
                          title: Text(friend),
                        )),
                      ],
                    );
                  }),

                  // Suggestions View
                  Obx(() {
                    if (!showSuggestions.value) return SizedBox.shrink();
                    final suggestions = controller.suggestedUsernames;
                    return suggestions.isEmpty
                        ? Center(child: Text("No suggestions found."))
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Friend Suggestions:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...suggestions.map((username) => ListTile(
                          leading: Icon(Icons.person_outline),
                          title: Text(username),
                          trailing: IconButton(
                            icon: Icon(Icons.person_add_alt_1),
                            onPressed: () async {
                              await controller.sendFriendRequest(
                                username,
                              );
                            },
                          ),
                        )),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}