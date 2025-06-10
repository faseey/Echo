import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_app/models/post_model.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import 'bst.dart';



class Echo extends GetxController {
  static final Echo instance = Echo._internal();

  Echo._internal(); // private constructor
  factory Echo() => instance;

   int userCount = 0;
  BST bst = BST();
  List<List<int>>? connections;
  BSTNode? activeUser;
  List<String> usernames = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String connectionsDocId = "connections_matrix";

  // Do not load in constructor
  Future<void> initialize() async {
    userCount = 0;
    bst = BST();
    connections = null;
    activeUser = null;
    await bst.loadFromFirebase();
    await loadConnectionsFromFirebase();
  }

  void buildNewsFeed() {
    if (activeUser == null) {
      print("Error: No active user");
      return;
    }

    activeUser!.user.newsfeedheap.clearNewsFeed();

    int activeUserIndex = activeUser!.user.userIndex;
    if (activeUserIndex == -1) {
      print("Error: Active user not found in the system");
      return;
    }
    print(activeUser?.user.username);
    print(activeUser?.user.userIndex);
    List<int> directFriends = [];

    for (int i = 0; i < userCount; i++) {
      if (connections?[activeUserIndex][i] == 1) {
        print(i);
        directFriends.add(i);
      }
    }
    print("printing name $directFriends");
    List<String> directFriendsUsernames = getUsernamesFromIndices(directFriends);
    //  print("News Feed for ${activeUser!.username}:");
    print("printing name $directFriendsUsernames");
    for (String username in directFriendsUsernames) {

      BSTNode? friendUser = bst.search(username);
      print(friendUser?.user.username);// You'll need to implement this method if it's not already there
      if (friendUser != null && friendUser.user.postStack.isNotEmpty()) {
        print(username);
        PostNode? topPost = friendUser.user.postStack.peek(); // top of stack
        activeUser!.user.newsfeedheap.addPost(topPost!.post.content,  topPost!.post.date,topPost!.post.username,topPost!.post.imageBase64);

      }
    }

  }

  List<String> getUsernamesFromIndices(List<int> indices) {
    List<String> username = [];
    for (int index in indices) {
      if (index >= 0 && index < usernames.length) {
        username.add(usernames[index]);
      }
    }
    return username;
  }

  // Update local adjacency matrix size and sync to Firebase
  Future<List<List<int>>> getUpdatedConnections() async {
    if (userCount <= 0) {
      return [];
    }

    List<List<int>> tempConnections = List.generate(
      userCount,
          (index) => List.generate(userCount, (index) => 0),
    );

    if (connections != null) {
      int oldSize = connections!.length;
      for (int i = 0; i < oldSize; i++) {
        for (int j = 0; j < oldSize; j++) {
          tempConnections[i][j] = connections![i][j];
        }
      }
    }

    return tempConnections;
  }

  Future<void> saveConnectionsToFirebase() async {
    if (connections == null) return;

    try {
      // Convert List<List<int>> to List<Map<String, dynamic>> for Firestore
      List<Map<String, dynamic>> converted = connections!.map((row) {
        return {
          'row': row,
        };
      }).toList();

      await _firestore.collection('app_data').doc(connectionsDocId).set({
        'connections': converted,
        'userCount': userCount,
      });

      print('Connections saved to Firestore successfully.');

    } catch (e) {
      print('Error saving connections to Firestore: $e');
    }
  }




  // Load adjacency matrix from Firestore
  Future<void> loadConnectionsFromFirebase() async {
    DocumentSnapshot snapshot =
    await _firestore.collection('app_data').doc(connectionsDocId).get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        userCount = data['userCount'] ?? 0;

        List<dynamic> rawConnections = data['connections'] ?? [];

        connections = rawConnections.map<List<int>>((rowMap) {
          return List<int>.from(rowMap['row']);
        }).toList();
      }
    }
  }
  Future<void> saveUsernamesToFirebase() async {
    try {
      await _firestore.collection('app_data').doc('usernames').set({
        'usernames': usernames,
      });

      print('Usernames saved to Firestore successfully.');
    } catch (e) {
      print('Error saving usernames to Firestore: $e');
    }
  }
  Future<void> loadUsernamesFromFirebase() async {
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection('app_data').doc('usernames').get();

      if (snapshot.exists) {
        Map<String, dynamic>? data =
        snapshot.data() as Map<String, dynamic>?;

        if (data != null && data['usernames'] is List) {
          usernames = List<String>.from(data['usernames']);
          print('Usernames loaded successfully.');
        }
      }
    } catch (e) {
      print('Error loading usernames from Firestore: $e');
    }
  }


}