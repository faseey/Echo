import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../component/MyDrawer.dart';
import '../controllers/home_controller.dart';
 // Your new controller

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
            // Search bar + search button
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
                      // Optional: You can add user search logic here if needed
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

            // Send friend request button
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

            SizedBox(height: 20),

            // Display all friend requests button
            ElevatedButton.icon(
              onPressed: () async {
                await controller.loadRequestsFromFirestore();
                if (controller.allRequests.isEmpty) {
                  Get.snackbar("Info", "No pending friend requests");
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Pending Friend Requests"),
                      content: Obx(() {
                        return SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.allRequests.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Icon(Icons.person),
                                title: Text(controller.allRequests[index]),
                              );
                            },
                          ),
                        );
                      }),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Close"),
                        )
                      ],
                    ),
                  );
                }
              },
              icon: Icon(Icons.list_alt),
              label: Text("Display Friend Requests"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
