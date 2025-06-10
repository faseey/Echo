import 'dart:convert';
import 'dart:io';

import 'package:echo_app/component/route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profileController.dart';
import '../models/post_model.dart';
import '../user_data_model/userService.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  void _showFullImage(BuildContext context, String base64Image) {
    final imageBytes = base64Decode(base64Image);
    showDialog(
      context: context,
      builder:
          (_) =>
          Dialog(child: InteractiveViewer(child: Image.memory(imageBytes))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    controller.initializeUser();
    final imagePosts = controller.getUserImagePosts();

    final user = Get.arguments;

    if (user == null || user is! User) {
      return const Scaffold(body: Center(child: Text("User data not found.")));
    }

    return GetBuilder<ProfileController>(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Center(
              child: Text("Profile", style: TextStyle(color: Colors.black)),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage:
                            controller.imagePath.isNotEmpty
                                ? FileImage(File(controller.imagePath))
                                : (controller.imageBase64.isNotEmpty &&
                                controller.imageBase64.startsWith(
                                  'data:image',
                                ))
                                ? MemoryImage(
                              base64Decode(
                                controller.imageBase64.split(',').last,
                              ),
                            )
                                : null,
                            child:
                            (controller.imagePath.isEmpty &&
                                controller.imageBase64.isEmpty)
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),

                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: IconButton(
                                  onPressed: () {
                                    _showBottomSheet(context, controller);
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      controller.bio.isNotEmpty
                          ? "@${controller.bio}"
                          : 'No bio added',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Posts",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                if (imagePosts.isEmpty) // ← new
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No image posts yet"),
                    ),
                  )
                else
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true, // important inside Column
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: imagePosts.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (_, index) {
                      final post = imagePosts[index];
                      final bytes = base64Decode(post.imageBase64);

                      return GestureDetector(
                        onTap: () => _showFullImage(context, post.imageBase64),
                        onLongPress: ()=> _showPostOptionsDialog(context, controller, post),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(bytes, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPostOptionsDialog(BuildContext context, ProfileController controller, Post post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Post'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditPostBottomSheet(context, controller, post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Post'),
                onTap: () async {
                  Navigator.pop(context);
                  await controller.deletePost(post);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void _showEditPostBottomSheet(BuildContext context, ProfileController controller, Post post) {
    final contentController = TextEditingController(text: post.content);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Edit Post", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "New Content"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await controller.editPost(post, contentController.text);
                  Navigator.pop(context);
                },
                child: const Text("Save Changes"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }







  void _showBottomSheet(BuildContext context, ProfileController controller) {
    final bioController = TextEditingController(text: controller.bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Edit Profile", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => controller.getImage(),
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: "Bio"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await controller.saveData(bioController.text);
                  await controller.loadPostsFromFirestore();
                  controller.initializeUser();

                  Get.back();
                  Get.snackbar(
                    "Profile Updated",
                    "Your profile has been updated successfully",
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.black26,
                    colorText: Colors.white,
                  );
                },
                child: const Text("Save"),
              ),
              const SizedBox(height: 20),
              Text(
                controller.bio.isNotEmpty ? controller.bio : 'No bio added',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}