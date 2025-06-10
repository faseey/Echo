import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../user_data_model/userService.dart';

class BSTNode {
  User user;
  BSTNode? left;
  BSTNode? right;
  int height;

  BSTNode(this.user) : height = 1;
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
    } else {
      return node; // Duplicate not inserted
    }

    node.height = 1 + _maxHeight(node.left, node.right);
    int balance = _getBalance(node);

    // 🔁 Rotations if unbalanced
    if (balance > 1 && user.username.compareTo(node.left!.user.username) < 0) {
      return _rightRotate(node); // LL
    }
    if (balance < -1 && user.username.compareTo(node.right!.user.username) > 0) {
      return _leftRotate(node); // RR
    }
    if (balance > 1 && user.username.compareTo(node.left!.user.username) > 0) {
      node.left = _leftRotate(node.left!); // LR
      return _rightRotate(node);
    }
    if (balance < -1 && user.username.compareTo(node.right!.user.username) < 0) {
      node.right = _rightRotate(node.right!); // RL
      return _leftRotate(node);
    }

    return node;
  }
  int _height(BSTNode? node) => node?.height ?? 0;

  int _getBalance(BSTNode? node) => node == null ? 0 : _height(node.left) - _height(node.right);

  int _maxHeight(BSTNode? a, BSTNode? b) => (_height(a) > _height(b)) ? _height(a) : _height(b);

  BSTNode _rightRotate(BSTNode y) {
    BSTNode x = y.left!;
    BSTNode? T2 = x.right;

    x.right = y;
    y.left = T2;

    y.height = 1 + _maxHeight(y.left, y.right);
    x.height = 1 + _maxHeight(x.left, x.right);

    return x;
  }

  BSTNode _leftRotate(BSTNode x) {
    BSTNode y = x.right!;
    BSTNode? T2 = y.left;

    y.left = x;
    x.right = T2;

    x.height = 1 + _maxHeight(x.left, x.right);
    y.height = 1 + _maxHeight(y.left, y.right);

    return y;
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

void printLevelOrder(BSTNode? root) {
  if (root == null) return;
  Queue<BSTNode> queue = Queue();
  queue.add(root);
print("entered");
  while (queue.isNotEmpty) {
    int size = queue.length;
    for (int i = 0; i < size; i++) {
      BSTNode current = queue.removeFirst();
      print('${current.user.username} ');
      if (current.left != null) queue.add(current.left!);
      if (current.right != null) queue.add(current.right!);
    }
    print(''); // Newline for each level
  }
}
