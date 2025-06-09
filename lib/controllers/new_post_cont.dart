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

  List<ImagePost> firestorePosts = [];


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

      final imagePost = ImagePost(
        username: currentUser!.username,
        imageBase64: imageBase64,
        date: DateTime.now().toIso8601String(),
        content: contentController.text.trim(),
      );

      latestPost = imagePost;

      final postData = {
        'username': imagePost.username,
        'imageBase64': imagePost.imageBase64,
        'date': imagePost.date,
        'content': imagePost.content,
      };

      //  1. Save to global 'posts' collection
     // await _firestore.collection('posts').add(postData);

      // ✅ 2. Also save to the current user's document in 'users' collection
      final userDocRef = _firestore.collection('users').doc(currentUser!.username);
      await userDocRef.update({
        'posts': FieldValue.arrayUnion([postData])
      });

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
      // Fetch documents from 'posts' collection where username matches, ordered by date
      final querySnapshot = await _firestore
          .collection('posts')
          .where('username', isEqualTo: currentUser!.username)
          .orderBy('date', descending: true)
          .get();

      // Map each document into your ImagePost model
      firestorePosts = querySnapshot.docs.map((doc) {
        return ImagePost(
          username: doc['username'],
          imageBase64: doc['imageBase64'],
          date: doc['date'],
          content: doc['content'],
        );
      }).toList();

      log("✅ Posts loaded from Firestore");
      update(); // notify GetX to rebuild UI
    } catch (e) {
      log("❌ Failed to load posts: $e");
      Get.snackbar("Error", "Could not load posts");
    }
  }



  void deletePostAtIndex(int index) async {
    if (activeUserNode == null) return;

    final stack = activeUserNode!.user.imagePostStack;

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