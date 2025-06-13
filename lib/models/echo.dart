import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_app/models/postStack.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'bst.dart';

class Echo extends GetxController {
  static final Echo instance = Echo._internal();

  Echo._internal(); // Private constructor
  factory Echo() => instance;

  int userCount = 0;
  BST bst = BST();
  List<List<int>>? connections;
  BSTNode? activeUser;
  List<String> usernames = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String connectionsDocId = "connections_matrix";

  // ----------------------- Initialization -----------------------

  Future<void> initialize() async {
    userCount = 0;
    bst = BST();
    connections = null;
    activeUser = null;
    await bst.loadFromFirebase();
    await loadConnectionsFromFirebase();
  }

  // ----------------------- News Feed -----------------------

  Future<void> buildNewsFeed() async {
    if (activeUser == null) return;

    activeUser!.user.newsfeedheap.clearNewsFeed();

    int activeUserIndex = activeUser!.user.userIndex;
    if (activeUserIndex == -1) return;

    List<int> directFriends = [];
    for (int i = 0; i < userCount; i++) {
      if (connections?[activeUserIndex][i] == 1) {
        directFriends.add(i);
      }
    }

    List<String> friendUsernames = getUsernamesFromIndices(directFriends);

    for (String username in friendUsernames) {
      BSTNode? friendNode = bst.search(username);
      if (friendNode != null) {
        await loadUserPostsFromFirestore(friendNode);

        if (friendNode.user.postStack.isNotEmpty()) {
          PostNode? topPost = friendNode.user.postStack.peek();
          if (topPost != null) {
            activeUser!.user.newsfeedheap.addPost(
              topPost.post.content,
              topPost.post.date,
              topPost.post.username,
              topPost.post.imageBase64,
              friendNode.user.profileImageUrl,
            );
          }
        }
      }
    }
  }

  Future<void> loadUserPostsFromFirestore(BSTNode userNode) async {
    final username = userNode.user.username;

    try {
      final doc = await _firestore.collection('users').doc(username).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final postsJson = data['posts'] ?? [];

        final posts = postsJson.map((json) => Post.fromJson(json)).toList();

        userNode.user.postStack.clear();
        for (var post in posts.reversed) {
          userNode.user.postStack.push(post);
        }
      }
    } catch (_) {
      // Silent fail; optionally log in production
    }
  }

  // ----------------------- Username Helpers -----------------------

  List<String> getUsernamesFromIndices(List<int> indices) {
    List<String> result = [];
    for (int index in indices) {
      if (index >= 0 && index < usernames.length) {
        result.add(usernames[index]);
      }
    }
    return result;
  }

  Future<void> saveUsernamesToFirebase() async {
    try {
      await _firestore.collection('app_data').doc('usernames').set({
        'usernames': usernames,
      });
    } catch (_) {
      // Silent fail; optionally log in production
    }
  }

  Future<void> loadUsernamesFromFirebase() async {
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection('app_data').doc('usernames').get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && data['usernames'] is List) {
          usernames = List<String>.from(data['usernames']);
        }
      }
    } catch (_) {
      // Silent fail; optionally log in production
    }
  }

  // ----------------------- Connection Matrix -----------------------

  Future<List<List<int>>> getUpdatedConnections() async {
    if (userCount <= 0) return [];

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
      List<Map<String, dynamic>> converted = connections!.map((row) {
        return {'row': row};
      }).toList();

      await _firestore.collection('app_data').doc(connectionsDocId).set({
        'connections': converted,
        'userCount': userCount,
      });
    } catch (_) {
      // Silent fail; optionally log in production
    }
  }

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
}
