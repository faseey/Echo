import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../component/MyDrawer.dart';
import '../controllers/new_post_cont.dart';
import '../models/post_model.dart';
 // Assuming this is your image post model file

class NewPostScreen extends StatelessWidget {
  NewPostScreen({Key? key}) : super(key: key);

  final NewPostController controller = Get.put(NewPostController());

  void _showFullImage(BuildContext context, String base64Image) {
    final imageBytes = base64Decode(base64Image);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewPostController>(
      builder: (_) {
        final posts = controller.activeUserNode?.user.imagePostStack.toList() ?? [];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey,
            iconTheme: IconThemeData(color: Colors.white),
            title: Center(
              child: Text(
                "Echo Image Posts",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          drawer: MyDrawer(),
          body: Column(
            children: [
              Expanded(
                child: posts.isEmpty
                    ? Center(child: Text("No image posts yet"))
                    : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    itemCount: posts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final imageBytes = base64Decode(post.imageBase64);

                      return GestureDetector(
                        onTap: () => _showFullImage(context, post.imageBase64),
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
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    imageBytes,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              post.username,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              post.date.split('T').first,
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
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
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => controller.pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo),
                      label: Text("Gallery"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
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
