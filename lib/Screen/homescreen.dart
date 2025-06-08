import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../component/MyDrawer.dart';
import '../controllers/home_controller.dart';

// ... imports

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final HomeController controller = Get.put(HomeController());

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
        child: Column(
          children: [
            // Search bar + Refresh
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.requestTextController,
                    decoration: InputDecoration(
                      hintText: "Search username here...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
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

            // Send Friend Request Button
            ElevatedButton.icon(
              onPressed: () async {
                final username = controller.requestTextController.text.trim();
                if (username.isEmpty) {
                  Get.snackbar("Error", "Please enter a username");
                  return;
                }
                await controller.sendFriendRequest(username);
                controller.requestTextController.clear();
              },
              icon: Icon(Icons.person_add),
              label: Text("Send Friend Request"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Colors.blueGrey,
              ),
            ),

            SizedBox(height: 16),

            // Display Friend Requests Button
            ElevatedButton.icon(
              onPressed: () async {
                await controller.loadRequestsFromFirestore();
              },
              icon: Icon(Icons.list_alt),
              label: Text("Display Friend Requests"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Colors.teal,
              ),
            ),

            SizedBox(height: 16),

            // Friend Requests List
            Expanded(
              child: Obx(() {
                final requests = controller.allRequest;
                if (requests.isEmpty) {
                  return Center(
                    child: Text("No pending friend requests."),
                  );
                }
                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final senderUsername = requests[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text("$senderUsername send you a friend request"),
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
