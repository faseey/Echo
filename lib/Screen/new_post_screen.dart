


/*import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../component/MyDrawer.dart';
import '../constant/post_card_builder.dart';
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

    return GetBuilder<NewPostController>(builder: (_) {
      final posts = controller.firestorePosts;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade200,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "Echo",
            style: TextStyle(
              fontFamily: 'Billabong',
              fontSize: 20,
              color: Colors.blueGrey,
            ),
          ),
          centerTitle: true,
        ),
        drawer: MyDrawer(),
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            Expanded(
              child: posts.isEmpty
                  ? Center(child: Text("No posts yet", style: TextStyle(color: Colors.black38)))
                  : ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostCardBuilder(
                    post: posts[index],
                    index: index,
                    onDelete: () {
                      controller.deletePostAtIndex(index);
                    },
                    onViewImage: () {
                      _showFullImage(context, posts[index].imageBase64);
                    },
                  );
                },
              ),
            ),
            Divider(),
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
<<<<<<< HEAD
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
=======
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
>>>>>>> f08f2e65a236d3bbbb574decaebe4d4dce740b08
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo),
                  label: Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}*/


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../component/MyDrawer.dart';
import '../constant/post_card_builder.dart';
import '../controllers/new_post_cont.dart';


class NewPostScreen extends StatelessWidget {
  NewPostScreen({Key? key}) : super(key: key);
  final NewPostController controller = Get.put(NewPostController());

  @override
  Widget build(BuildContext context) {
    controller.loadImagePostsFromFirestore();

    return GetBuilder<NewPostController>(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            "Echo",
            style: TextStyle(
              fontFamily: 'Billabong',
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        //drawer:  MyDrawer(),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: controller.firestorePosts.isEmpty
                  ? const Center(
                  child: Text("No posts yet",
                      style: TextStyle(color: Colors.black38)))
                  : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.firestorePosts.length,
                itemBuilder: (context, index) {
                  return PostCardBuilder(
                    post: controller.firestorePosts[index],
                    index: index,
                    onDelete: () => controller.deletePostAtIndex(index),
                  );
                },
              ),
            ),
            _buildCreatePostSection(),
          ],
        ),
      );
    });
  }

  Widget _buildCreatePostSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/user_placeholder.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller.contentController,
                  decoration: const InputDecoration(
                    hintText: "Write a caption...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => controller.pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () => controller.pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
