import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profileController.dart';
import '../models/post_model.dart';
import '../user_data_model/userService.dart';
import 'notificationsscreen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  void _showFullImage(BuildContext context, String base64Image) {
    final imageBytes = base64Decode(base64Image);
    showDialog(
      context: context,
      builder: (_) => Dialog(child: InteractiveViewer(child: Image.memory(imageBytes))),
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
                    duration: const Duration(seconds: 2),
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


  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    controller.initializeUser();
    final imagePosts = controller.getUserImagePosts();

    final user = Get.arguments;

    if (user == null || user is! User) {
      return const Scaffold(body: Center(child: Text("User data not found.")));
    }

    return Scaffold(
      backgroundColor: const Color(0xffd5e4f1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top curved container
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xff30567c),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: const Center(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Profile Info Section
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: controller.imagePath.isNotEmpty
                        ? FileImage(File(controller.imagePath))
                        : (controller.imageBase64.isNotEmpty &&
                        controller.imageBase64.startsWith('data:image'))
                        ? MemoryImage(base64Decode(controller.imageBase64.split(',').last))
                        : null,
                    child: (controller.imagePath.isEmpty &&
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
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.add, size: 15, color: Colors.white),
                        onPressed: () => _showBottomSheet(context, controller),
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
              controller.bio.isNotEmpty ? "@${controller.bio}" : 'No bio added',
              style: const TextStyle(fontSize: 15),
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

            // Post Grid Section
            if (imagePosts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No image posts yet"),
                ),
              )
            else
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: imagePosts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final post = imagePosts[index];
                  final base64Image = post.imageBase64;
                  return GestureDetector(
                    onTap: () => _showFullImage(context, base64Image),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: MemoryImage(base64Decode(base64Image)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff30567c),
        icon: const Icon(Icons.camera, color: Colors.white,size: 20,),
        label: const SizedBox.shrink(), // Hides the text
        onPressed: () {
          controller.gotoHoneScreen();
        },
      ),

    );
  }
}


/*import 'dart:convert';
import 'dart:io';

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
      builder: (_) => Dialog(
        child: InteractiveViewer(child: Image.memory(imageBytes)),
      ),
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

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf3e5f5), Color(0xFFe1bee7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildProfileContent(context, controller, user, imagePosts),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.camera),
        label: const Text(""),
        onPressed: () {
          controller.gotoHoneScreen();
        },
      ),
    );
  }

  Widget _buildProfileContent(
      BuildContext context,
      ProfileController controller,
      User user,
      List<Post> imagePosts,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: controller.imagePath.isNotEmpty
                    ? FileImage(File(controller.imagePath))
                    : (controller.imageBase64.isNotEmpty &&
                    controller.imageBase64.startsWith('data:image'))
                    ? MemoryImage(
                  base64Decode(controller.imageBase64.split(',').last),
                )
                    : null,
                child: (controller.imagePath.isEmpty &&
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
                      icon: const Icon(Icons.add, size: 15, color: Colors.white),
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
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          controller.bio.isNotEmpty ? "@${controller.bio}" : 'No bio added',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15),
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
        if (imagePosts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text("No image posts yet"),
            ),
          )
        else
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: imagePosts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                onLongPress: () => _showPostOptionsDialog(context, controller, post),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(bytes, fit: BoxFit.cover),
                ),
              );
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showPostOptionsDialog(
      BuildContext context, ProfileController controller, Post post) {
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

  void _showEditPostBottomSheet(
      BuildContext context, ProfileController controller, Post post) {
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
                    duration: const Duration(seconds: 2),
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
}*/
