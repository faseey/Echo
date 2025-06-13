
/*import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';



import '../models/bst.dart';
import '../models/echo.dart';

import '../models/poststack.dart';
import '../user_data_model/userService.dart';


class ProfileController extends GetxController {
  String imagePath = '';
  String imageBase64 = '';
  String bio = '';

  // Reference to the active logged-in UserNode from Echo
  BSTNode? get activeUserNode => Echo.activeUser;
  User? get currentUser => activeUserNode?.user;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void initializeUser() {
    if (currentUser != null) {
      bio = currentUser!.bio ?? '';
       imageBase64 = currentUser!.profileImageUrl ?? ''; // Use for base64
      update();
    } else {
      log("No active user node found");
    }
  }

  Future<void> getImage() async {
    if (currentUser == null) {
      Get.snackbar("Error", "No user initialized");
      return;
    }

    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      imageBase64 = base64Encode(bytes);
      imagePath = image.path;
      update();
    }
  }

  Future<void> uploadImageToFirebase() async {
    if (imagePath.isEmpty) {
      Get.snackbar('Error', "No Image selected");
      return;
    }

    try {
      final fileName = "user_images/${currentUser!.username}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = _storage.ref().child(fileName);

      await ref.putFile(File(imagePath));
      imageUrl = await ref.getDownloadURL();

      log("Image uploaded: $imageUrl");
      update();
    } catch (e) {
      log("Upload error: $e");
      Get.snackbar("Error", "Failed to upload image");
    }
  }

  Future<void> saveData(String newBio) async {
    if (currentUser == null) {
      log("No user set in controller");
      return;
    }

    try {
      // Upload image if new one selected
      if (imagePath.isNotEmpty) {
        await uploadImageToFirebase();
        currentUser!.profileImageUrl = imageUrl;
      }

      // Update bio
      currentUser!.bio = newBio;
      bio = newBio;

      // Prepare update data
      Map<String, dynamic> updateData = {
        'bio': newBio,
        'profileImageUrl': currentUser!.profileImageUrl ?? '',
      };

      // Update Firestore
      await _firestore.collection('users').doc(currentUser!.username).update(updateData);

      log("Updated profile: $updateData");
      update(); // Refresh UI

    } catch (e) {
      log("Error saving data: $e");
      Get.snackbar("Error", "Failed to save profile data");
    }
  }

  // PostStack related methods

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

    activeUserNode!.user.postStack.push(newPost);
    update();
  }

  List<ImagePost> getPostsList() {
    if (activeUserNode == null) return [];
    return activeUserNode!.user.imagePostStack.toList();
  }

  void clearPosts() {
    if (activeUserNode == null) return;
    activeUserNode!.user.imagePostStack.clear();
    update();
  }

  // Optionally: Save posts list to Firestore under user document (if you want)
  Future<void> savePostsToFirestore() async {
    if (currentUser == null || activeUserNode == null) return;

    try {
      final postsJsonList = activeUserNode!.user.imagePostStack.toJsonList();
      await _firestore.collection('users').doc(currentUser!.username).update({
        'posts': postsJsonList,
      });
      log("Posts saved to Firestore");
    } catch (e) {
      log("Error saving posts: $e");
    }
  }

  // Load posts from Firestore on init or when needed
  Future<void> loadPostsFromFirestore() async {
    if (currentUser == null || activeUserNode == null) return;

    try {
      final doc = await _firestore.collection('users').doc(currentUser!.username).get();
      if (doc.exists) {
        final postsJsonList = doc.data()?['posts'] as List<dynamic>? ?? [];
        activeUserNode!.user.imagePostStack.clear();
        activeUserNode!.user.imagePostStack.loadFromJsonList(postsJsonList);
        update();
      }
    } catch (e) {
      log("Error loading posts: $e");
    }
  }
}*/

import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_app/component/route.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/bst.dart';
import '../models/echo.dart';
import '../models/postStack.dart';
import '../models/userService.dart';

class ProfileController extends GetxController {
  String imagePath = '';
  String imageBase64 = '';
  String coverPhotoPath = '';
  String coverPhotoBase64 = '';
  String bio = '';
  final Echo echo = Get.find<Echo>();
  // Reference to the active logged-in UserNode from Echo
  BSTNode? get activeUserNode => echo.activeUser;
  User? get currentUser => activeUserNode?.user;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void initializeUser() {
    if (currentUser != null) {
      bio = currentUser!.bio ?? '';
      imageBase64 = currentUser!.profileImageUrl ?? ''; // Use for base64
      update();
    } else {
      log("No active user node found");
    }
  }


  void gotoHoneScreen(){
    Get.toNamed(AppRouter.newPostScreen);
  }

  Future<void> getImage() async {
    if (currentUser == null) {
      Get.snackbar("Error", "No user initialized");
      return;
    }

    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      imageBase64 = base64Encode(bytes);
      imagePath = image.path;
      update();
    }
  }

  Future<void> getCoverPhoto() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Update local path
        coverPhotoPath = pickedFile.path;

        // Convert to base64
        final bytes = await File(pickedFile.path).readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        // Update controller
        coverPhotoBase64 = base64String;

        // Upload to Firebase Storage
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('cover_photos/${currentUser!.username}.jpg');

        await storageRef.putFile(File(pickedFile.path));
        final downloadUrl = await storageRef.getDownloadURL();

        // Update Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.username)
            .update({
          'coverPhotoUrl': downloadUrl,
          'coverPhotoBase64': base64String,
        });

        update(); // Refresh UI
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update cover photo: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> saveData(String newBio) async {
    if (currentUser == null) {
      log("No user set in controller");
      return;
    }

    try {
      bio = newBio;
      currentUser!.bio = newBio;

      if (imageBase64.isNotEmpty) {
        final prefixedBase64 = 'data:image/jpeg;base64,$imageBase64';
        currentUser!.profileImageUrl = prefixedBase64;
      }

      // Prepare data to update in Firestore
      final updateData = {
        'bio': currentUser!.bio,
        'profileImageUrl': currentUser!.profileImageUrl ?? '',
      };

      // Update Firestore using username as document ID
      await _firestore
          .collection('users')
          .doc(currentUser!.username)
          .update(updateData);

      log("Updated profile: $updateData");
      update(); // Refresh GetBuilder UI
    } catch (e) {
      log("Error saving data: $e");
      Get.snackbar("Error", "Failed to save profile data");
    }
  }

  // PostStack related methods

  void addNewPost(String content, String date) {
    if (activeUserNode == null) {
      Get.snackbar("Error", "No active user");
      return;
    }

    final newPost = Post(
      username: currentUser!.username,
      content: content,
      date: date, imageBase64: '',
    );

    activeUserNode!.user.postStack.push(newPost);
    update();
  }

  List<Post> getPostsList() {
    if (activeUserNode == null) return [];
    return activeUserNode!.user.postStack.toList();
  }

  void clearPosts() {
    if (activeUserNode == null) return;
    activeUserNode!.user.postStack.clear();
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

  Future<void> loadPostsFromFirestore() async {
    if (currentUser == null || activeUserNode == null) return;

    try {
      final doc =
      await _firestore.collection('users').doc(currentUser!.username).get();
      if (doc.exists) {
        final postsJsonList = doc.data()?['posts'] as List<dynamic>? ?? [];
        activeUserNode!.user.postStack.clear();
        activeUserNode!.user.postStack.loadFromJsonList(postsJsonList);
        update();
      }
    } catch (e) {
      log("Error loading posts: $e");
    }
  }

  List<Post> getUserImagePosts() {
    if (activeUserNode == null || currentUser == null) return [];

    return activeUserNode!.user.postStack
        .toList()
        .where((p) => p.username == currentUser!.username)
        .toList();
  }



  Future<void> deletePost(Post post) async {
    if (currentUser == null || activeUserNode == null) return;
    activeUserNode!.user.postStack.remove(post); // remove from stack

    await savePostsToFirestore(); // update Firestore
    update();
    Get.snackbar("Deleted", "Post deleted successfully");
  }



  Future<void> editPost(Post post, String newContent) async {
    if (currentUser == null || activeUserNode == null) return;

    post.content = newContent;
    await savePostsToFirestore();
    update();
    Get.snackbar("Updated", "Post updated successfully");
  }


}
