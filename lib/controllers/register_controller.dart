import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_app/controllers/post_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../component/route.dart';
import '../models/bst.dart';
import '../user_data_model/userService.dart';
import '../models/echo.dart';  // Adjust path

class UserController extends GetxController {
  String error = '';
  var isLoggedIn = false;
  final userCollection = FirebaseFirestore.instance.collection('users');


  // Get Echo instance from GetX
  final Echo echo = Get.find<Echo>();

  Future<void> registerUser(User user) async {
    error = '';
    update();

    // Check if username already exists
    if (echo.bst.search(user.username) != null) {
      error = "Username already exists";
      update();
      return;
    }

    try {
      // Insert user into BST via Echo
      await echo.bst.insert(user);

      // Optionally set activeUser here if you want
      echo.activeUser = echo.bst.search(user.username) ;
      echo.activeUser?.user.user_index =  echo.userCount ;

      await userCollection.doc(user.username).update({
        'user_index': echo.userCount,
      });
      echo.userCount++;
      echo.usernames.add(user.username);
      await echo.saveUsernamesToFirebase();


      final newConnections = await echo.getUpdatedConnections();

      // Assign only if non-empty (optional check)
      if (newConnections.isNotEmpty) {
        echo.connections = newConnections;
        await echo.saveConnectionsToFirebase();
      }

      print('Saving connections matrix: $echo.connections');

      // Navigate or other logic
      Get.offNamed(AppRouter.profileScreen, arguments: user);



    } catch (e) {
      error = 'Registration failed: ${e.toString()}';
      update();
    }
  }
  /*Future<void> logIn(String userName, String password) async {
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
      final node = echo.bst.search(userName.trim());

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
      print("Login Successful");
      isLoggedIn = true;
      Echo.activeUser = node;
      // jab user login ho ya app reload ho

      update();
      // Navigate with guaranteed non-null user
      Get.toNamed(
        AppRouter.bottomnavbar,
        arguments: node.user,
      );

    } catch (e) {
      error = 'Login failed: ${e.toString()}';
      update();
    }
  }*/

  Future<void> logIn(String userName, String password) async {
    error = '';
    update();

    if (userName.isEmpty || password.isEmpty) {
      error = 'Please fill all fields';
      update();
      return;
    }

    try {
      final node = echo.bst.search(userName.trim());

      if (node == null) {
        error = 'Invalid username';
        update();
        return;
      }

      if (node.user.password != password) {
        error = 'Incorrect password';
        update();
        return;
      }

      final now = DateTime.now().toString();
      node.user.lastSignin = now;

      await userCollection.doc(userName.trim()).update({
        'lastSignIn': now,
        'lastSignin': now,
      });

      if (node.user.username.isEmpty) {
        throw Exception("User data corrupted");
      }

      print("Login Successful");
      print("notifications");
      print(echo.activeUser?.user.notifications.showNotifications());
      isLoggedIn = true;
      echo.activeUser = node;
      User? user = await loadUserFromFirebase(userName);
      await echo.loadUsernamesFromFirebase();
      if (user != null) {
        echo.activeUser = node;  // or however you're assigning it
      }
      BSTNode? root = echo.bst.root;

      printLevelOrder(root);



      update();
      print("Navigating to bottomnavbar...");
      Get.toNamed(
        AppRouter.bottomnavbar,
        arguments: node.user,
      );

    } catch (e) {
      error = 'Login failed: ${e.toString()}';
      update();
    }
  }

  Future<User?> loadUserFromFirebase(String username) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Get the document from 'users' collection by username
      final doc = await firestore.collection('users').doc(username).get();

      if (doc.exists) {
        final data = doc.data()!;
        final user = User.fromJson(data);
        print('[loadUserFromFirebase] Successfully loaded user: ${user.username}');
        return user;
      } else {
        print('[loadUserFromFirebase] User not found: $username');
        return null;
      }
    } catch (e) {
      print('[loadUserFromFirebase] Error: $e');
      return null;
    }
  }
  Future<void> logOut() async {
    try {
      echo.activeUser = null;
      isLoggedIn = false;
      update();
      Get.toNamed(AppRouter.loginScreen);
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: ${e.toString()}');
    }
  }
}
