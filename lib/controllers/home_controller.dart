import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/echo.dart';
import '../models/friendlist.dart'; // your RequestQueue and Request models
import '../models/bst.dart';
import '../user_data_model/userService.dart';

class HomeController extends GetxController {
  final requestTextController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BSTNode? get activeUserNode => Echo.activeUser;
  User? get currentUser => activeUserNode?.user;

  // Observable list of friend requests for UI
  final allRequests = <String>[].obs;

  /// Send friend request
  Future<void> sendFriendRequest(String friendUsername) async {
    if (currentUser == null) {
      Get.snackbar("Error", "No active user");
      return;
    }

    final receiverNode = Echo.instance.bst.search(friendUsername.trim());
    if (receiverNode == null) {
      Get.snackbar("Error", "User not found");
      return;
    }

    final request = Request(
      friendUsername: currentUser!.username,
      senderIndex: currentUser!.user_index,
      receiverIndex: receiverNode.user.user_index,
    );

    receiverNode.user.requestQueue.addRequest(request);

    // Save updated requests to Firebase for the receiver
    await saveRequestsToFirestore(friendUsername);

    Get.snackbar("Success", "Friend request sent to $friendUsername");
  }

  /// Save friend requests of the user to Firestore
  Future<void> saveRequestsToFirestore(String username) async {
    final node = Echo.instance.bst.search(username);
    if (node == null) return;

    try {
      final jsonList = node.user.requestQueue.toJsonList();
      await _firestore.collection('users').doc(node.user.username).update({
        'friendRequests': jsonList,
      });
      log("Friend requests saved to Firestore for user $username");
    } catch (e) {
      log("Failed to save friend requests: $e");
    }
  }
  /// Load friend requests from Firestore for the current user
  Future<void> loadRequestsFromFirestore() async {
    if (currentUser == null) return;

    try {
      final doc = await _firestore.collection('users').doc(currentUser!.username).get();


      if (doc.exists && doc.data() != null) {
        final jsonList = doc.data()!['friendRequests'] as List<dynamic>? ?? [];

        currentUser!.requestQueue.loadFromJsonList(jsonList);
        allRequests.value = currentUser!.requestQueue.displayAllRequests();
      } else {
        currentUser!.requestQueue.clear();
        allRequests.clear();
      }
      update();
      log("Friend requests loaded from Firestore for ${currentUser!.username}");
    } catch (e) {
      log("Failed to load friend requests: $e");
    }
  }

  @override
  void onClose() {
    requestTextController.dispose();
    super.onClose();
  }
}
