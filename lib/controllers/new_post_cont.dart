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

import '../models/post_model.dart';
import '../user_data_model/userService.dart';

class NewPostController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final textController = TextEditingController();

  ImagePost? latestPost;

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


      activeUserNode!.user.imagePostStack.push(imagePost);

      await saveImagePostsToFirestore();

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
  Future<void> saveImagePostsToFirestore() async {
    if (currentUser == null || activeUserNode == null) return;

    try {
      final imgJson = activeUserNode!.user.imagePostStack.toJsonList();
      await _firestore
          .collection('users')
          .doc(currentUser!.username)
          .set({'imagePosts': imgJson}, SetOptions(merge: true));

      log("✅ Image posts saved to Firestore");
    } catch (e) {
      log("❌ Failed to save image posts: $e");
      Get.snackbar("Error", "Could not save image posts");
    }
  }

  Future<void> loadImagePostsFromFirestore() async {
    if (currentUser == null || activeUserNode == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.username)
          .get();

      final list = (doc.data()?['imagePosts'] as List<dynamic>?) ?? [];

      activeUserNode!.user.imagePostStack
        ..clear()
        ..loadFromJsonList(list);  // Use your existing helper

      update();

      log("✅ Image posts loaded from Firestore");
    } catch (e) {
      log("❌ Failed to load image posts: $e");
      Get.snackbar("Error", "Could not load image posts");
    }
  }


  void deletePostAtIndex(int index) async {
    if (activeUserNode == null) return;

    final stack = activeUserNode!.user.postStack;

    // Convert to list, reverse, and remove post at index
    final posts = stack.toList();
    posts.removeAt(index);

    // Clear and re-push remaining posts
    stack.clear();
    for (var post in posts.reversed) {
      stack.push(post);
    }


    await _firestore.doc(activeUserNode!.user.username).update({
      'posts': stack.toJsonList(),
    });

    update();
    Get.snackbar("Success", "Post deleted");
  }



  void clearLatestPost() {
    latestPost = null;
    loadImagePostsFromFirestore();
    update();
  }
}
