
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:echo_app/controllers/profile.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../models/bst.dart';
// import '../models/echo.dart';
// import '../models/postStack.dart';
// import '../models/userService.dart';
//
// class PostController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ImagePicker _picker = ImagePicker();
//   final contentController = TextEditingController();
//   final Echo echo = Get.find<Echo>();
//
//   List<Post> firestorePosts = [];
//   Post? latestPost;
//
//   BSTNode? get activeUserNode => echo.activeUser;
//   User? get currentUser => activeUserNode?.user;
//
//   /// Pick image from camera or gallery and initiate post creation
//   Future<void> pickImage(ImageSource source) async {
//     try {
//       final pickedFile = await _picker.pickImage(source: source);
//       if (pickedFile != null) {
//         File imageFile = File(pickedFile.path);
//         await addImagePost(imageFile);
//       } else {
//         Get.snackbar("Cancelled", "No image selected");
//       }
//     } catch (e) {
//       Get.snackbar("Error", "Failed to pick image");
//     }
//   }
//
//   /// Create a post from selected image and upload it
//   Future<void> addImagePost(File imageFile) async {
//     if (currentUser == null || activeUserNode == null) {
//       Get.snackbar("Error", "No active user");
//       return;
//     }
//
//     try {
//       final compressedBytes = await FlutterImageCompress.compressWithFile(
//         imageFile.absolute.path,
//         quality: 50,
//         minWidth: 800,
//         minHeight: 800,
//         format: CompressFormat.jpeg,
//       );
//
//       if (compressedBytes == null) {
//         Get.snackbar("Error", "Image compression failed");
//         return;
//       }
//
//       final imageBase64 = base64Encode(compressedBytes);
//
//       if (imageBase64.length > 1000000) {
//         Get.snackbar("Error", "Image too large even after compression");
//         return;
//       }
//
//       final imagePost = Post(
//         username: currentUser!.username,
//         imageBase64: imageBase64,
//         date: DateTime.now().toIso8601String(),
//         content: contentController.text.trim(),
//       );
//
//       latestPost = imagePost;
//
//       currentUser!.postStack.push(imagePost);
//
//       final postList = currentUser!.postStack.toJsonList();
//
//       if (postList.isNotEmpty) {
//         await _firestore
//             .collection('users')
//             .doc(currentUser!.username)
//             .set({'posts': postList}, SetOptions(merge: true));
//       }
//
//       await loadImagePostsFromFirestore();
//       contentController.clear();
//       update();
//       Get.snackbar("Success", "Post uploaded successfully");
//     } catch (e) {
//       Get.snackbar("Error", "Failed to upload post");
//     }
//   }
//
//   /// Load user's posts from Firestore
//   Future<void> loadImagePostsFromFirestore() async {
//     if (currentUser == null) return;
//
//     try {
//       final userDoc = await _firestore.collection('users').doc(currentUser!.username).get();
//
//       if (userDoc.exists && userDoc.data() != null) {
//         final data = userDoc.data()!;
//         final List<dynamic> postsJson = data['posts'] ?? [];
//
//         firestorePosts = postsJson.map((postData) {
//           return Post.fromJson(postData);
//         }).toList();
//       }
//
//       update();
//     } catch (e) {
//       Get.snackbar("Error", "Failed to load your posts");
//     }
//   }
//
//   /// Delete a post at a specific index and update Firestore
//   void deletePostAtIndex(int index) async {
//     if (activeUserNode == null) return;
//
//     final stack = activeUserNode!.user.postStack;
//     final posts = stack.toList();
//
//     posts.removeAt(index);
//
//     stack.clear();
//     for (var post in posts.reversed) {
//       stack.push(post);
//     }
//
//     await _firestore
//         .collection('users')
//         .doc(activeUserNode!.user.username)
//         .update({'posts': stack.toJsonList()});
//
//     update();
//     Get.snackbar("Success", "Post deleted");
//   }
//
//   /// Initialize controller and load saved posts
//   @override
//   void onInit() {
//     super.onInit();
//     loadImagePostsFromFirestore();
//   }
//
//   /// Clear the latest post and refresh the post list
//   void clearLatestPost() {
//     latestPost = null;
//     loadImagePostsFromFirestore();
//     update();
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:echo_app/controllers/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bst.dart';
import '../models/echo.dart';
import '../models/postStack.dart';
import '../models/userService.dart';

class PostController extends GetxController {
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
    } catch (_) {
      Get.snackbar("Error", "Failed to pick image");
    }
  }

  /// Create and upload a new image post
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
      currentUser!.postStack.push(imagePost);

      final postList = currentUser!.postStack.toJsonList();

      if (postList.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUser!.username)
            .set({'posts': postList}, SetOptions(merge: true));
      }

      await loadImagePostsFromFirestore();
      contentController.clear();
      update();

      Get.snackbar("Success", "Post uploaded successfully");
    } catch (_) {
      Get.snackbar("Error", "Failed to upload post");
    }
  }

  /// Load posts for current user from Firestore
  Future<void> loadImagePostsFromFirestore() async {
    if (currentUser == null) return;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.username)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        final List<dynamic> postsJson = data['posts'] ?? [];

        firestorePosts = postsJson.map((postData) {
          return Post.fromJson(postData);
        }).toList();
      }

      update();
    } catch (_) {
      Get.snackbar("Error", "Failed to load your posts");
    }
  }

  /// Delete post by index and update Firestore
  void deletePostAtIndex(int index) async {
    if (activeUserNode == null) return;

    final stack = activeUserNode!.user.postStack;
    final posts = stack.toList();

    posts.removeAt(index);
    stack.clear();

    for (var post in posts.reversed) {
      stack.push(post);
    }

    await _firestore
        .collection('users')
        .doc(activeUserNode!.user.username)
        .update({'posts': stack.toJsonList()});

    update();
    Get.snackbar("Success", "Post deleted");
  }

  /// Initialize and load posts from Firestore
  @override
  void onInit() {
    super.onInit();
    loadImagePostsFromFirestore();
  }

  /// Clear the latest post reference and reload posts
  void clearLatestPost() {
    latestPost = null;
    loadImagePostsFromFirestore();
    update();
  }
}
