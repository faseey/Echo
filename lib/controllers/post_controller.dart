import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../models/bst.dart';
import '../models/echo.dart';
import '../models/poststack.dart';
import '../user_data_model/userMessage.dart';
import '../user_data_model/userService.dart';
// Assuming your Post model is here
import 'package:cloud_firestore/cloud_firestore.dart';

class PostController extends GetxController {
  final textController = TextEditingController();
  final userMessage = userMessageStack<dynamic>();
  int? selectedIndex;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to the active logged-in UserNode from Echo
  BSTNode? get activeUserNode => Echo.activeUser;
  User? get currentUser => activeUserNode?.user;

  void addMessage() {
    final text = textController.text.trim();
    if (text.isNotEmpty) {
      final String date = DateTime.now().toString(); // or use a formatted date
      addNewPost(text, date);
      textController.clear();
      update();
    }
  }

  void addNewPost(String content, String date) {
    if (activeUserNode == null) {
      Get.snackbar("Error", "No active user");
      return;
    }

    final newPost = Post(
      username: currentUser!.username,
      content: content,
      date: date,
    );

    // Push to in-memory PostStack
    activeUserNode!.user.postStack.push(newPost);

    // Save to Firebase
    savePostsToFirestore();

    update();
  }

  Future<void> savePostsToFirestore() async {
    if (currentUser == null || activeUserNode == null) return;

    try {
      final postsJsonList = activeUserNode!.user.postStack.toJsonList();
      await _firestore.collection('users').doc(currentUser!.username).update({
        'posts': postsJsonList,
      });
      log("Posts saved to Firestore");
    } catch (e) {
      log("Error saving posts: $e");
    }
  }
}
