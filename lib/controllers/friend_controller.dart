import 'dart:collection';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bst.dart';
import '../models/echo.dart';
import '../models/friendlist.dart'; // your RequestQueue and Request models
import '../user_data_model/userService.dart';



class FriendController extends GetxController {
  final suggestedUsernames = <String>[].obs;
  final requestTextController = TextEditingController();
  final Echo echo = Get.find<Echo>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BSTNode? get activeUserNode => echo.activeUser;
  User? get currentUser => activeUserNode?.user;

  // Observable list of friend requests for UI
  final allRequest = <String>[].obs;



  ///////////////// Send friend request//////////////////////////
  Future<void> sendFriendRequest(String friendUsername) async {
    if (currentUser == null) {
      Get.snackbar("Error", "No active user",backgroundColor: Color(0xfffffff),duration: Duration(seconds: 2),colorText: Color(0xffffffff));
      return;
    }
    //////////////////the person who will recieve the request////////////////
    final receiverNode = Echo.instance.bst.search(friendUsername.trim());
    if (receiverNode == null) {
      Get.snackbar("Error", "User not found");
      return;
    }
  if(friendUsername == currentUser?.username){
    Get.snackbar("Error","YOU CANNOT send request to yourself");
    return;
  }

  //////////taking indexes for connections///////////
    int senderIndex =  currentUser!.userIndex;
    int receiverIndex =  receiverNode.user.userIndex;




    /////////////////////validation//////////////////
    if(echo.connections?[senderIndex][receiverIndex] ==1 && echo.connections?[receiverIndex][senderIndex] ==1 ){
      Get.snackbar("Error","You are already friends with $friendUsername");
      return;
    }
    else if(echo.connections?[senderIndex][receiverIndex] ==1){
      Get.snackbar("Error","You have already sent Friend Request  to  $friendUsername");
      return;
    }
    if( echo.connections![receiverIndex][senderIndex] ==1){
      Get.snackbar("Error","$friendUsername has already sent you a friend request");
      return;
    }
    else{

      /////////////////////validation passed//////////////////
      echo.connections![senderIndex][receiverIndex] = 1;
      await echo.saveConnectionsToFirebase();


    final request = Request(
      friendUsername: currentUser!.username,
      senderIndex: currentUser!.userIndex,
      receiverIndex: receiverNode.user.userIndex,
      /////indexes////for updating connections upon action
    );
    //////////////apeended to receiverr Q///////////////////
    receiverNode.user.requestQueue.addRequest(request);
    ///////adding notifcation  to the receiver side/////////
    receiverNode.user.notifications.addNotification('request',currentUser!.username);
    await receiverNode.user.saveNotificationsToFirestore();





    // Save updated requests to Firebase for the receiver
    await saveRequestsToFirestore(friendUsername);

    Get.snackbar("Success", "Friend request sent to $friendUsername");
  }
  }


  Future<void> acceptRequestofSender(String senderUsername) async {
    if (currentUser == null) return;
    //////////here the current user will accept the received requests////////
    final requestNode = currentUser!.requestQueue.getNodeOfSender(senderUsername);
    if (requestNode != null) {
      // /////////Step 1: Establishing connection///////////
      echo.connections![requestNode.request.senderIndex][requestNode.request.receiverIndex] = 1;
      echo.connections![requestNode.request.receiverIndex][requestNode.request.senderIndex] = 1;


      ////////the one who sent req is sendernode noti will be added to his stack/////
      final senderNode = Echo.instance.bst.search(senderUsername);

      senderNode?.user.notifications.addNotification('accepted', currentUser!.username);
      await senderNode?.user.saveNotificationsToFirestore();
        ////finally saving connection its a collection  (overall matrix)////////
      await echo.saveConnectionsToFirebase();

      // Step 2: Add each other to friendList in Firestore
      await addFriendsToEachOther(currentUser!.username, senderUsername);

      // Step 3: Remove request and update
      //since current user accpeted request so it will be dno more available there/////
      currentUser!.requestQueue.deleteRequestBySender(senderUsername);
      await saveRequestsToFirestore(currentUser!.username);
      await loadRequestsFromFirestore();
    }
  }


  Future<void> deleteRequestBySender(String senderUsername) async {
    if (currentUser == null) return;


    ///current user fining the specifec request to be deleted//////
    final requestNode = currentUser!.requestQueue.getNodeOfSender(senderUsername);
    if (requestNode != null) {
        ////upaditing connection back to 0 of the sender of the req
      echo.connections![requestNode.request.senderIndex][requestNode.request.receiverIndex] = 0;
      await echo.saveConnectionsToFirebase();

      //now removing it from the request list as well//////
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
  Future<List<String>> getFriendSuggestions() async {
    // Step 1: Get the adjacency matrix from Echo
    List<List<int>> adj = echo.connections ?? [];
    int? userIndex = currentUser?.userIndex;



    // Step 2: BFS to find level-2 friends
    List<int> level2Indexes = await getFriendsOfFriends(userIndex!, adj);

    // Step 3: Sort the indexes
    level2Indexes.sort();

    print("level2 indexes");
    print(level2Indexes);
    await echo.loadUsernamesFromFirebase();
    print("userlist");
    print(echo.usernames);
    // Step 4: Map to usernames
    List<String> suggestions = level2Indexes
        .where((i) => i >= 0 && i < echo.usernames.length)
        .map((i) => echo.usernames[i])
        .toList();
    print("[suggestions]");
    print(suggestions);
    return suggestions;

  }

  Future<List<int>> getFriendsOfFriends(int startIndex, List<List<int>> adj) async {
    int n = adj.length;
    List<bool> visited = List.filled(n, false);
    List<int> level = List.filled(n, 0);
    Queue<int> queue = Queue();

    visited[startIndex] = true;
    level[startIndex] = 0;
    queue.add(startIndex);

    List<int> friendsOfFriends = [];

    while (queue.isNotEmpty) {
      int node = queue.removeFirst();

      if (level[node] >= 3) continue; // stop processing if we reached level 3

      for (int neighbor = 0; neighbor < n; neighbor++) {
        if (adj[node][neighbor] == 1 && !visited[neighbor]) {
          visited[neighbor] = true;
          level[neighbor] = level[node] + 1;
          queue.add(neighbor);

          if (level[neighbor] == 2) {
            friendsOfFriends.add(neighbor);
          }
        }
      }
    }
    print(friendsOfFriends);
    return friendsOfFriends;

  }
  Future<void> loadSuggestions() async {
    try {
      List<String> suggestions = await getFriendSuggestions();
      suggestedUsernames.assignAll(suggestions);
    } catch (e) {
      print("Error loading BFS suggestions: $e");
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
