import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../component/MyDrawer.dart';
import '../controllers/post_controller.dart';
import '../models/poststack.dart';

class PostScreen extends StatelessWidget {
  PostScreen({Key? key}) : super(key: key);

  final PostController controller = Get.put(PostController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostController>(builder: (_) {
      final Post? recentPost = controller.latestPost;

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
          actions: [],
        ),
        drawer: MyDrawer(),
        body: Column(
          children: [
            Expanded(
              child: recentPost == null
                  ? Center(child: Text("No recent post"))
                  : Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade100, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10),
                    topLeft: Radius.circular(15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recentPost.username,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      recentPost.content,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 6),
                    Text(
                      recentPost.date,
                      style:
                      TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Post added successfully!",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30, left: 10, right: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.textController,
                      decoration: InputDecoration(
                        hintText: "Write Something in Echo...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
                        controller.addMessage();
                        controller.savePostsToFirestore();
                      },
                      icon: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
