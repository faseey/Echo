import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import 'bst.dart';



class Echo extends GetxController {
  int userCount = 0;
  BST bst = BST();
  List<List<int>>? connections;
  BSTNode? activeUser;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String connectionsDocId = "connections_matrix";  // document ID for adjacency matrix

  Echo() {
    userCount = 0;
    bst = BST();
    connections = null;
    activeUser = null;
  }

  //  Find index of user in BST (in-order)
  int getUserIndex(String username) {
    List<int> resultIndex = [-1];
    _findIndexInBST(bst.root, username, 0, resultIndex);
    return resultIndex[0];
  }

  int _findIndexInBST(BSTNode? node, String username, int currentIndex, List<int> resultIndex) {
    if (node == null) return currentIndex;

    // Traverse left
    currentIndex = _findIndexInBST(node.left, username, currentIndex, resultIndex);

    // Check current node
    if (node.user.username == username) {
      resultIndex[0] = currentIndex;
    }
    currentIndex++;

    // Traverse right
    return _findIndexInBST(node.right, username, currentIndex, resultIndex);
  }
  // Update local adjacency matrix size and sync to Firebase
  Future<void> updateConnections() async {
    if (userCount <= 0) {
      connections = [];
      await _saveConnectionsToFirebase();
      return;
    }

    List<List<int>> tempConnections = List.generate(
      userCount,
          (_) => List.generate(userCount, (_) => 0),
    );

    if (connections != null) {
      int oldSize =  connections?.length ?? 0;

      for (int i = 0; i < oldSize; i++) {
        for (int j = 0; j < oldSize; j++) {
          tempConnections[i][j] = connections![i][j];
        }
      }
    }

    connections = tempConnections;

    // Save updated connections to Firebase
    await _saveConnectionsToFirebase();
  }

  // Save adjacency matrix to Firestore
  Future<void> _saveConnectionsToFirebase() async {
    if (connections == null) return;

    // Firestore does not support nested List<List<int>> directly
    // So convert List<List<int>> to List<List<dynamic>> (int is dynamic so it's fine)
    await _firestore.collection('app_data').doc(connectionsDocId).set({
      'connections': connections,
      'userCount': userCount,
    });
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

        // Convert List<dynamic> to List<List<int>>
        connections = rawConnections
            .map<List<int>>((row) => List<int>.from(row))
            .toList();
      }
    }
  }
}
