import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:echo_app/controllers/profileController.dart';
import 'package:echo_app/models/poststack.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bst.dart';
import '../models/echo.dart';
// ✅ new stack
import '../models/post_model.dart';
import '../user_data_model/userService.dart';

class NewPostController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final textController = TextEditingController();

  ImagePost? latestPost; // ✅ use ImagePost

  BSTNode? get activeUserNode => Echo.activeUser;
  User? get currentUser => activeUserNode?.user;

  /// Pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        await addImagePost(imageFile);
      } else {
        Get.snackbar("Cancelled", "No image selected");
      }
    } catch (e) {
      log("❌ Image pick error: $e");
      Get.snackbar("Error", "Failed to pick image");
    }
  }

  /// Add a post with image (as base64)
  Future<void> addImagePost(File imageFile) async {
    if (currentUser == null || activeUserNode == null) {
      Get.snackbar("Error", "No active user");
      return;
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      final imagePost = ImagePost(
        username: currentUser!.username,
        imageBase64: imageBase64,
        date: DateTime.now().toIso8601String(),
      );

      latestPost = imagePost;

      // ✅ Use imagePostStack
      activeUserNode!.user.imagePostStack.push(imagePost);

      await savePostsToFirestore();

      final profileController = Get.find<ProfileController>();
      profileController.loadPostsFromFirestore(); // Refresh UI

      update();

      Get.snackbar("Success", "Image post uploaded");
    } catch (e) {
      log("❌ Upload error: $e");
      Get.snackbar("Error", "Failed to upload image");
    }
  }

  /// Save post stack to Firestore
  Future<void> savePostsToFirestore() async {
    if (currentUser == null || activeUserNode == null) return;

    try {
      final postsJsonList = activeUserNode!.user.postStack.toJsonList();

      await _firestore.collection('users').doc(currentUser!.username).update({
        'posts': postsJsonList,
      });

      log("✅ Posts saved to Firestore");
    } catch (e) {
      log("❌ Error saving posts: $e");
    }
  }


  void deletePostAtIndex(int index) {
    if (activeUserNode == null) return;

    final stack = activeUserNode!.user.postStack;
    final reversed = stack.toList().reversed.toList();

    reversed.removeAt(index); // remove image at index
    stack.clear(); // clear current stack

    // re-push remaining posts
    for (var post in reversed.reversed) {
      stack.push(post);
    }

    savePostsToFirestore();
    update();
  }


  void clearLatestPost() {
    latestPost = null;
    update();
  }
}
