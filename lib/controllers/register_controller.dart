import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_app/controllers/post_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../component/route.dart';
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
      Echo.activeUser = echo.bst.search(user.username) ;
      Echo.activeUser?.user.user_index =  Echo.userCount ;
      await userCollection.doc(user.username).update({
        'user_index': Echo.userCount,
      });
      Echo.userCount++;
      final newConnections = await echo.getUpdatedConnections();

      // Assign only if non-empty (optional check)
      if (newConnections.isNotEmpty) {
        Echo.connections = newConnections;
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
      isLoggedIn = true;
      Echo.activeUser = node;

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


  Future<void> logOut() async {
    try {
      Echo.activeUser = null;
      isLoggedIn = false;
      update();
      Get.toNamed(AppRouter.loginScreen);
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: ${e.toString()}');
    }
  }
}
