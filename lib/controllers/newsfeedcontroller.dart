import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/bst.dart';
import '../models/echo.dart';
import '../models/newsfeedheap.dart';
import '../models/post_model.dart';
import '../user_data_model/userService.dart';

class NewsFeedController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final Echo echo = Get.find<Echo>();
  var newsFeed = <NewsFeedNode>[].obs;

  Post? latestPost;

  BSTNode? get activeUserNode => echo.activeUser;
  User? get currentUser => activeUserNode?.user;
  final TextEditingController contentController = TextEditingController();

  /// Pick image from camera or gallery and upload
  Future<void> pickImage(ImageSource source, text, {required String content}) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        final compressedBytes = await FlutterImageCompress.compressWithFile(
          imageFile.absolute.path,
          quality: 50,
          minWidth: 800,
          minHeight: 800,
          format: CompressFormat.jpeg,
        );

        if (compressedBytes == null) {
          Get.snackbar("Error", "Image compression failed");
          return;
        }

        final imageBase64 = base64Encode(compressedBytes);

        if (imageBase64.length > 1000000) {
          Get.snackbar("Error", "Image too large even after compression");
          return;
        }

        await addPost(content: content, imageBase64: imageBase64);
      } else {
        Get.snackbar("Cancelled", "No image selected");
      }
    } catch (e) {
      log("❌ Image pick error: $e");
      Get.snackbar("Error", "Failed to pick image");
    }
  }

  /// Add a new post (with optional image), save to Firestore
  Future<void> addPost({required String content, String? imageBase64}) async {
    if (currentUser == null || activeUserNode == null) {
      Get.snackbar("Error", "No active user");
      return;
    }

    try {
      final newPost = Post(
        username: currentUser!.username,
        content: content.trim(),
        date: DateTime.now().toIso8601String(),
        imageBase64: imageBase64 ?? "",
      );

      currentUser!.postStack.push(newPost);

      final postList = currentUser!.postStack.toJsonList();

      await _firestore.collection('users')
          .doc(currentUser!.username)
          .set({'posts': postList}, SetOptions(merge: true));

      latestPost = newPost;
      update();

      log("✅ Post saved to Firebase: $newPost");
      Get.snackbar("Success", "Post uploaded successfully");
    } catch (e) {
      log("❌ Error uploading post: $e");
      Get.snackbar("Error", "Failed to upload post");
    }
  }

  /// Load in-memory news feed
  void loadNewsFeed() {
    if (echo.activeUser == null) {
      print("No active user found.");
      newsFeed.clear();
      return;
    }

    echo.buildNewsFeed(); // rebuild heap
    final heap = echo.activeUser!.user.newsfeedheap.heap;
    newsFeed.value = List.from(heap);
  }

  /// Load news feed by calling Echo's async logic (Firebase based)
  Future<void> loadNewsFeedFromFirebase() async {
    if (echo.activeUser == null) {
      newsFeed.clear();
      return;
    }

    await echo.buildNewsFeed(); // async
    newsFeed.value = List.from(echo.activeUser!.user.newsfeedheap.heap);
  }

  void refreshFeed() => loadNewsFeed();
  void clearFeed() => newsFeed.clear();
}
