import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bst.dart';
import '../models/echo.dart';
import '../models/friendlist.dart'; // your RequestQueue and Request models

import '../user_data_model/userService.dart';

class FriendController extends GetxController {
  final requestTextController = TextEditingController();
  final Echo echo = Get.find<Echo>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BSTNode? get activeUserNode => Echo.activeUser;
  User? get currentUser => activeUserNode?.user;

  // Observable list of friend requests for UI
  final allRequest = <String>[].obs;



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
  if(friendUsername == currentUser?.username){
    Get.snackbar("Error","YOU CANNOT send request to yourself");
    return;
  }
    int senderIndex =  currentUser!.user_index;
    int receiverIndex =  receiverNode.user.user_index;

    if(Echo.connections?[senderIndex][receiverIndex] ==1 && Echo.connections?[receiverIndex][senderIndex] ==1 ){
      Get.snackbar("Error","You are already friends with $friendUsername");
      return;
    }
    else if(Echo.connections?[senderIndex][receiverIndex] ==1){
      Get.snackbar("Error","You have already sent Friend Request  to  $friendUsername");
      return;
    }
    if( Echo.connections![receiverIndex][senderIndex] ==1){
      Get.snackbar("Error","$friendUsername has already sent you a friend request");
      return;
    }
    else{
      Echo.connections![senderIndex][receiverIndex] = 1;
      await echo.saveConnectionsToFirebase();


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
  }
  Future<void> acceptRequestBySender(String senderUsername) async {
    if (currentUser == null) return;

    final requestNode = currentUser!.requestQueue.getRequestBySender(senderUsername);
    if (requestNode != null) {
      // Step 1: Accept connection in Echo matrix
      Echo.connections![requestNode.request.senderIndex][requestNode.request.receiverIndex] = 1;
      Echo.connections![requestNode.request.receiverIndex][requestNode.request.senderIndex] = 1;
      await echo.saveConnectionsToFirebase();

      // Step 2: Add each other to friendList in Firestore
      await addFriendsToEachOther(currentUser!.username, senderUsername);

      // Step 3: Remove request and update
      currentUser!.requestQueue.deleteRequestBySender(senderUsername);
      await saveRequestsToFirestore(currentUser!.username);
      await loadRequestsFromFirestore();
    }
  }


  Future<void> deleteRequestBySender(String senderUsername) async {
    if (currentUser == null) return;
    final requestNode = currentUser!.requestQueue.getRequestBySender(senderUsername);
    if (requestNode != null) {

      Echo.connections![requestNode.request.senderIndex][requestNode.request.receiverIndex] = 0;
      await echo.saveConnectionsToFirebase();
      currentUser!.requestQueue.deleteRequestBySender(senderUsername);
      await saveRequestsToFirestore(currentUser!.username);

      await loadRequestsFromFirestore();
    }

 // Refresh requests list after update
  }

  Future<void> addFriendsToEachOther(String user1, String user2) async {
    final firestore = FirebaseFirestore.instance;

    Future<List<String>> getFriendList(String username) async {
      final doc = await firestore.collection('users').doc(username).get();
      final data = doc.data();
      if (data != null && data.containsKey('friendList')) {
        return List<String>.from(data['friendList']);
      }
      return [];
    }

    Future<void> updateFriendList(String username, List<String> updatedList) async {
      await firestore.collection('users').doc(username).update({
        'friendList': updatedList,
      });
    }

    List<String> user1List = await getFriendList(user1);
    List<String> user2List = await getFriendList(user2);

    if (!user1List.contains(user2)) user1List.add(user2);
    if (!user2List.contains(user1)) user2List.add(user1);

    await updateFriendList(user1, user1List);
    await updateFriendList(user2, user2List);
  }
  RxList<String> friendUsernames = <String>[].obs;

  Future<void> loadFriendListFromFirestore(String username) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final doc = await firestore.collection('users').doc(username).get();
      final data = doc.data();

      if (data != null && data.containsKey('friendList')) {
        friendUsernames.value = List<String>.from(data['friendList']);
      } else {
        friendUsernames.clear(); // If no list found
      }
    } catch (e) {
      print("Failed to load friend list: $e");
    }
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

        allRequest.value = currentUser!.requestQueue.displayAllRequests(fullMessage: false);


      } else {
        currentUser!.requestQueue.clear();
        allRequest.clear();

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
  @override
  void onInit() {
    super.onInit();
    if (currentUser != null) {
      loadFriendListFromFirestore(currentUser!.username);
    }
  }

}
