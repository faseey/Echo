import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/posts.dart';
import '../controllers/profile.dart';
import '../constant/post_card_builder.dart';
import '../component/MyDrawer.dart';

class NewPostScreen extends StatelessWidget {
  NewPostScreen({Key? key}) : super(key: key);

  final PostController controller = Get.put(PostController());
  final profileController = Get.put(ProfileController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    controller.loadImagePostsFromFirestore();

    return GetBuilder<PostController>(builder: (_) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[200],
       // drawer: MyDrawer(),
        body: Column(
          children: [
            // Curved Top Header
            Container(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
              decoration: const BoxDecoration(
                color: Color(0xff30567c),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  // Builder(
                  //   builder: (context) => IconButton(
                  //     icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  //     onPressed: () => Scaffold.of(context).openDrawer(),
                  //   ),
                  // ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Echo',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Create & View Posts',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: profileController.imagePath.isNotEmpty
                        ? FileImage(File(profileController.imagePath))
                        : (profileController.imageBase64.isNotEmpty &&
                        profileController.imageBase64.startsWith('data:image'))
                        ? MemoryImage(base64Decode(profileController.imageBase64.split(',').last))
                        : null,
                    child: (profileController.imagePath.isEmpty &&
                        profileController.imageBase64.isEmpty)
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ],
              ),
            ),

            // Post list
            Expanded(
              child: controller.firestorePosts.isEmpty
                  ? const Center(
                  child: Text("No posts yet", style: TextStyle(color: Colors.black38)))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
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

            // Create Post Section
            _buildCreatePostSection(),
          ],
        ),
      );
    });
  }

  Widget _buildCreatePostSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
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
