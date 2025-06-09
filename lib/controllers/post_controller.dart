// import 'dart:developer';
// import 'package:echo_app/controllers/profileController.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import '../models/bst.dart';
// import '../models/echo.dart';
// import '../models/poststack.dart';
// import '../user_data_model/userMessage.dart';
// import '../user_data_model/userService.dart';
// // Assuming your Post model is here
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class PostController extends GetxController {
//   final textController = TextEditingController();
//   final userMessage = userMessageStack<dynamic>();
//   int? selectedIndex;
//   Post? latestPost; // sirf latest post store karne ke liye
//   BSTNode? get activeUserNode => Echo.activeUser;
//   User? get currentUser => activeUserNode?.user;
//    // aapka existing user node, define according to your code
//
//   void addMessage() {
//     final text = textController.text.trim();
//     if (text.isNotEmpty) {
//       final newPost = Post(
//         username: activeUserNode?.user.username ?? "Unknown",
//         content: text,
//         date: DateTime.now().toString(),
//       );
//
//       latestPost = newPost;
//
//       // Post ko user ke postStack me add karo
//       activeUserNode?.user.postStack.push(newPost);
//
//       textController.clear();
//       update();
//       savePostsToFirestore();
//       final profileController = Get.find<ProfileController>();
//       profileController.loadPostsFromFirestore(); // Refresh karwa do after post
//
//       Get.snackbar("Success", "Post added successfully");
//     }
//   }
//
//
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Reference to the active logged-in UserNode from Echo
//
//
//
//
//   void addNewPost(String content, String date) {
//     if (activeUserNode == null) {
//       Get.snackbar("Error", "No active user");
//       return;
//     }
//
//     final newPost = Post(
//       username: currentUser!.username,
//       content: content,
//       date: date,
//     );
//
//     // Push to in-memory PostStack
//     activeUserNode!.user.postStack.push(newPost);
//
//     // Save to Firebase
//     savePostsToFirestore();
//
//     update();
//   }
//   void clearLatestPost() {
//     latestPost = null;
//     update();
//   }
//
//
//   Future<void> savePostsToFirestore() async {
//     if (currentUser == null || activeUserNode == null) return;
//
//     try {
//       final postsJsonList = activeUserNode!.user.postStack.toJsonList();
//       await _firestore.collection('users').doc(currentUser!.username).update({
//         'posts': postsJsonList,
//       });
//       log("Posts saved to Firestore");
//     } catch (e) {
//       log("Error saving posts: $e");
//     }
//   }
//
//
// }
