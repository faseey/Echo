import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import 'bst.dart';



class Echo extends GetxController {
  static final Echo instance = Echo._internal();

  Echo._internal(); // private constructor
  factory Echo() => instance;

  static int userCount = 0;
  BST bst = BST();
  List<List<int>>? connections;
  static BSTNode? activeUser;

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

  //  Find index of user in BST (in-order)
  int getUserIndex(String username) {
    List<int> resultIndex = [-1];
    _findIndexInBST(bst.root, username, 0, resultIndex);
    return resultIndex[0];
  }

  int _findIndexInBST(BSTNode? node, String username, int currentIndex,
      List<int> resultIndex) {
    if (node == null) return currentIndex;

    // Traverse left
    currentIndex =
        _findIndexInBST(node.left, username, currentIndex, resultIndex);

    // Check current node
    if (node.user.username == username) {
      resultIndex[0] = currentIndex;
    }
    currentIndex++;

    // Traverse right
    return _findIndexInBST(node.right, username, currentIndex, resultIndex);
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
}