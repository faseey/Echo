import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../component/MyDrawer.dart';
import '../controllers/home_controller.dart';

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.textController,
                    decoration: InputDecoration(
                      hintText: "Search username here...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onFieldSubmitted: (value) {
                      controller.searchUser(value);
                    },
                  ),
                ),
                SizedBox(width: 5),
                Container(
                  height: 52,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      controller.searchUser(controller.textController.text);
                    },
                    icon: Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Obx(() {
            if (controller.errorMessage.isNotEmpty) {
              return Text(controller.errorMessage.value, style: TextStyle(color: Colors.red));
            } else if (controller.foundUser.value != null) {
              final user = controller.foundUser.value!.user;
              return Card(
                margin: EdgeInsets.all(12),
                child: ListTile(
                  title: Text(user.username, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user.email), // or any other info you want to show
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(onPressed: () {/* Add Friend Logic */}, child: Text("Add Friend")),
                      TextButton(onPressed: () {/* Message Logic */}, child: Text("Message")),
                    ],
                  ),
                ),
              );
            } else {
              return SizedBox.shrink(); // Show nothing if no search made yet
            }
          }),

        ],
      ),
    );
  }
}
