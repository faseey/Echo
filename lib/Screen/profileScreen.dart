import 'dart:io';

import 'package:echo_app/component/route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/profileController.dart';
import '../controllers/register_controller.dart';
import '../user_data_model/userService.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(profileController());
    controller.initializeUser(); // <- Initialize bio and image URL

    final user = Get.arguments;

    if (user == null || user is! User) {
      return const Scaffold(
        body: Center(child: Text("User data not found.")),
      );
    }

    return GetBuilder<profileController>(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey.shade300,
            title: Center(
              child: Text(
                "Profile Screen",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: controller.imagePath.isNotEmpty
                                ? FileImage(File(controller.imagePath))
                                : (controller.imageUrl.isNotEmpty
                                ? NetworkImage(controller.imageUrl)
                            as ImageProvider
                                : null),
                            child: (controller.imagePath.isEmpty &&
                                controller.imageUrl.isEmpty)
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: IconButton(
                                  onPressed: () {
                                    _showBottomSheet(context, controller);
                                  },
                                  icon: Icon(
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
                    SizedBox(height: 10),
                    Text(
                      user.username,
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      controller.bio.isNotEmpty
                          ? controller.bio
                          : 'No bio added',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Posts",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: controller.getPostsList().isEmpty
                    ? const Center(child: Text("No posts yet"))
                    : ListView.builder(
                  itemCount: controller.getPostsList().length,
                  itemBuilder: (context, index) {
                    final post = controller.getPostsList()[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(post.content),
                        subtitle: Text("Posted on: ${post.date}"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBottomSheet(
      BuildContext context, profileController controller) {
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
              top: 20),
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
                  Get.back(); // Close the bottom sheet
                },
                child: const Text("Save"),
              ),
              const SizedBox(height: 20),
              Text(
                controller.bio.isNotEmpty
                    ? controller.bio
                    : 'No bio added',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
