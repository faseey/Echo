import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../component/MyDrawer.dart';
import '../controllers/new_post_cont.dart';

class NewPostScreen extends StatelessWidget {
  NewPostScreen({Key? key}) : super(key: key);

  final NewPostController controller = Get.put(NewPostController());

  void _showFullImage(BuildContext context, String base64Image) {
    try {
      final imageBytes = base64Decode(base64Image);
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.black,
          child: InteractiveViewer(
            child: Image.memory(imageBytes),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to load full image.");
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.loadImagePostsFromFirestore();

    return GetBuilder<NewPostController>(
      builder: (_) {
        final posts = controller.firestorePosts;

        return Scaffold(

          appBar: AppBar(
            backgroundColor: Colors.grey.shade200,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              "EchoGram",
              style: TextStyle(
                fontFamily: 'Billabong',
                fontSize: 30,
                color: Colors.pinkAccent,
              ),
            ),
            centerTitle: true,
          ),
          drawer: MyDrawer(),
          body: Column(
            children: [
              Expanded(
                child: posts.isEmpty
                    ? Center(child: Text("No posts yet", style: TextStyle(color: Colors.black38)))
                    : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    Uint8List? imageBytes;

                    try {
                      if (post.imageBase64.isNotEmpty) {
                        imageBytes = base64Decode(post.imageBase64);
                      }
                    } catch (e) {
                      print("Error decoding image: $e");
                    }

                    return Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (imageBytes != null) {
                                _showFullImage(context, post.imageBase64);
                              }
                            },
                            onLongPress: () {
                              Get.defaultDialog(
                                title: "Delete Post",
                                middleText: "Are you sure you want to delete this post?",
                                textCancel: "No",
                                textConfirm: "Yes",
                                confirmTextColor: Colors.white,
                                onConfirm: () {
                                  controller.deletePostAtIndex(index);
                                  Get.back();
                                },
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              child: imageBytes != null
                                  ? AspectRatio(
                                aspectRatio: 1, // Square like Instagram
                                child: Image.memory(
                                  imageBytes,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Container(
                                height: 300,
                                color: Colors.grey[700],
                                child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                              ),

                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Text(
                              post.content,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.favorite_border, color: Colors.pinkAccent),
                                    SizedBox(width: 6),
                                    Text("Like", style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                Text(
                                  post.date.split('T').first,
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Post Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: controller.contentController,
                  maxLines: 2,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[800],
                    hintText: "Write a caption...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => controller.pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt),
                      label: Text("Camera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => controller.pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo),
                      label: Text("Gallery"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}