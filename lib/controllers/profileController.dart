import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_app/controllers/register_controller.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../user_data_model/userService.dart';

class profileController extends GetxController {
  String imagePath = '';
  String imageUrl = '';
  String bio = '';

  User? currentUser;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void initializeUser(User user) {
    currentUser = user;
    bio = user.bio ?? '';
    imageUrl = user.profileImageUrl ?? '';
    update();
  }

  Future<void> getImage() async {
    if (currentUser == null) {  // Add null check
      Get.snackbar("Error", "No user initialized");
      return;
    }

    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      imagePath = image.path;
      update();
    }
  }

  /*Future<void> uploadImageToFirebase() async {
    if (imagePath.isNotEmpty) {
      File file = File(imagePath);
      try {
        final fileName =
            "user_image/${DateTime.now().microsecondsSinceEpoch}.jpg";
        TaskSnapshot snapshot = await _storage.ref(fileName).putFile(file);
        imageUrl = await snapshot.ref.getDownloadURL();
        update();
      } catch (e) {
        Get.snackbar("Error", "Error Uploading Image");
      }
    } else {
      Get.snackbar('Error', "No Image selected");
    }
  }*/

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

  // In profileController.dart
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
      await _firestore
          .collection('users')
          .doc(currentUser!.username)
          .update(updateData);

      log("Updated: $updateData");
      update(); // Refresh UI

    } catch (e) {
      log("Error saving data: $e");
      Get.snackbar("Error", "Failed to save profile data");
    }
  }
}
