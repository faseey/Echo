import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:echo_app/controllers/profileController.dart';
import 'package:echo_app/models/poststack.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
  final contentController = TextEditingController();
  final Echo echo = Get.find<Echo>();
  List<Post> firestorePosts = [];


  Post? latestPost;

  BSTNode? get activeUserNode => echo.activeUser;
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

      final imagePost = Post(
        username: currentUser!.username,
        imageBase64: imageBase64,
        date: DateTime.now().toIso8601String(),
        content: contentController.text.trim(),
      );

      latestPost = imagePost;

      // final postData = {
      //   'username': imagePost.username,
      //   'imageBase64': imagePost.imageBase64,
      //   'date': imagePost.date,
      //   'content': imagePost.content,
      // };

      //  1. Save to global 'posts' collection
      // await _firestore.collection('posts').add(postData);

      // Add to user stack
      currentUser!.postStack.push(imagePost);

      await _firestore.collection('users')
          .doc(currentUser!.username)
          .set({
        'posts': currentUser!.postStack.toJsonList(),
      }, SetOptions(merge: true));


      final jsonList = currentUser!.postStack.toJsonList();
      log("🟡 Uploading post data: $jsonList");



      await loadImagePostsFromFirestore();

      log(" Post uploaded successfully");
      contentController.clear(); // Clear content field

      update();
      Get.snackbar("Success", "Post uploaded successfully");
    } catch (e) {
      log("Upload error: $e");
      Get.snackbar("Error", "Failed to upload post");
    }
  }

  /// Save post stack to Firestore


  Future<void> loadImagePostsFromFirestore() async {
    if (currentUser == null) return;

    try {
      firestorePosts.clear(); // Clear any old posts

      // Use username instead of email
      final userDoc = await _firestore.collection('users').doc(currentUser!.username).get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        final List<dynamic> postsJson = data['posts'] ?? [];

        firestorePosts = postsJson.map((postData) {
          return Post.fromJson(postData);
        }).toList();
      }

      log("✅ User posts loaded from their own document");
      update(); // Notify UI
    } catch (e) {
      log("❌ Failed to load user posts: $e");
      Get.snackbar("Error", "Failed to load your posts");
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
    //loadImagePostsFromFirestore();
    update();
  }
}