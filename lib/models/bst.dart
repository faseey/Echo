import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userService.dart';

class BSTNode {
  User _user;
  BSTNode? _left;
  BSTNode? _right;
  int _height;

  BSTNode(this._user) : _height = 1;

  // Getters
  User get user => _user;
  BSTNode? get left => _left;
  BSTNode? get right => _right;
  int get height => _height;

  // Setters
  set user(User value) => _user = value;
  set left(BSTNode? value) => _left = value;
  set right(BSTNode? value) => _right = value;
  set height(int value) => _height = value;
}

class BST {
  BSTNode? _root;
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');

  // Getter for root (optional)
  BSTNode? get root => _root;

  // Public insert
  Future<void> insert(User user) async {
    _root = _insert(_root, user);
    await _userCollection.doc(user.username).set(user.toJson());
  }

  // Private insert
  BSTNode _insert(BSTNode? node, User user) {
    if (node == null) return BSTNode(user);

    if (user.username.compareTo(node.user.username) < 0) {
      node.left = _insert(node.left, user);
    } else if (user.username.compareTo(node.user.username) > 0) {
      node.right = _insert(node.right, user);
    } else {
      return node; // Duplicate
    }

    node.height = 1 + _maxHeight(node.left, node.right);
    int balance = _getBalance(node);

    // Rebalance
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

  // Balance and height utilities
  int _height(BSTNode? node) => node?.height ?? 0;

  int _getBalance(BSTNode? node) => node == null ? 0 : _height(node.left) - _height(node.right);

  int _maxHeight(BSTNode? a, BSTNode? b) => (_height(a) > _height(b)) ? _height(a) : _height(b);

  // Rotations
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

  // Public search
  BSTNode? search(String username) {
    return _search(_root, username);
  }

  // Private search
  BSTNode? _search(BSTNode? node, String username) {
    if (node == null || node.user.username == username) return node;
    if (username.compareTo(node.user.username) < 0) {
      return _search(node.left, username);
    } else {
      return _search(node.right, username);
    }
  }

  // Public load
  Future<void> loadFromFirebase() async {
    final snapshot = await _userCollection.get();
    for (var doc in snapshot.docs) {
      User user = User.fromJson(doc.data() as Map<String, dynamic>);
      _root = _insert(_root, user);
    }
  }
}

// Level-order traversal utility
// void printLevelOrder(BSTNode? root) {
//   if (root == null) return;
//
//   Queue<BSTNode> queue = Queue();
//   queue.add(root);
//
//   while (queue.isNotEmpty) {
//     int size = queue.length;
//     for (int i = 0; i < size; i++) {
//       BSTNode current = queue.removeFirst();
//       stdout.write('${current.user.username} ');
//       if (current.left != null) queue.add(current.left!);
//       if (current.right != null) queue.add(current.right!);
//     }
//     stdout.writeln();
//   }
// }
