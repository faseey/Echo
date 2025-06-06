import 'package:cloud_firestore/cloud_firestore.dart';
import '../user_data_model/userService.dart';

class BSTNode {
  User user;
  BSTNode? left;
  BSTNode? right;

  BSTNode(this.user);
}

class BST {
  BSTNode? root;
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  BST();

  Future<void> insert(User user) async {
    root = _insert(root, user);
    await userCollection.doc(user.username).set(user.toJson());
  }

  BSTNode _insert(BSTNode? node, User user) {
    if (node == null) return BSTNode(user);
    if (user.username.compareTo(node.user.username) < 0) {
      node.left = _insert(node.left, user);
    } else if (user.username.compareTo(node.user.username) > 0) {
      node.right = _insert(node.right, user);
    }
    return node;
  }

  BSTNode? search(String username) {
    return _search(root, username);
  }

  BSTNode? _search(BSTNode? node, String username) {
    if (node == null || node.user.username == username) return node;
    if (username.compareTo(node.user.username) < 0) {
      return _search(node.left, username);
    } else {
      return _search(node.right, username);
    }
  }

  Future<void> loadFromFirebase() async {
    final snapshot = await userCollection.get();
    for (var doc in snapshot.docs) {
      User user = User.fromJson(doc.data() as Map<String, dynamic>);
      root = _insert(root, user);
    }
  }
}
