


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../component/route.dart';
import '../user_data_model/userService.dart';

class BSTNode {
  User user;
  BSTNode? left;
  BSTNode? right;

  BSTNode(this.user);
}

class BST extends GetxController{
  String error =' ';

  @override
  void onInit() {
    super.onInit();
    loadFromFirebase(); // Load existing users on start (optional)
  }




  BSTNode? root;
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> insert(User user) async {
    root = _insert(root, user);

    // Save user to Firestore
    await userCollection.doc(user.username).set(user.toJson());
  }

  BSTNode _insert(BSTNode? node, User user) {
    if (node == null) {
      return BSTNode(user);
    }

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

  BSTNode? getRoot() {
    return root;
  }

  Future<void> loadFromFirebase() async {
    QuerySnapshot snapshot = await userCollection.get();

    for (var doc in snapshot.docs) {
      User user = User.fromJson(doc.data() as Map<String, dynamic>);
      root = _insert(root, user);
    }
  }



  Future<void> logIn(String userName, String password) async {
    // Clear previous errors
    error = '';
    update();

    // Validate input
    if (userName.isEmpty || password.isEmpty) {
      error = 'Please fill all fields';
      update();
      return;
    }

    try {
      // Search in BST
      final node = search(userName.trim());

      // Validate credentials
      if (node == null || node.user.password != password) {
        error = 'Invalid username or password';
        update();
        return;
      }

      // Update last sign-in time
      final now = DateTime.now().toString();
      node.user.lastSignin = now;

      // Update in Firestore
      await userCollection.doc(userName.trim()).update({
        'lastSignIn': now,
        'lastSignin': now, // Consistent field naming
      });

      // Ensure user data is valid before navigation
      if (node.user.username.isEmpty) {
        throw Exception("User data corrupted");
      }

      // Navigate with guaranteed non-null user
      Get.offNamed(
        AppRouter.profileScreen,
        arguments: node.user,
      );

    } catch (e) {
      error = 'Login failed: ${e.toString()}';
      update();
    }
  }



}