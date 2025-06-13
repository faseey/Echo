// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../component/route.dart';
// import '../models/bst.dart';
// import '../models/userService.dart';
// import '../models/echo.dart';  // Adjust path
//
// class UserController extends GetxController {
//   String error = '';
//   var isLoggedIn = false;
//
//   bool isPasswordHidden = true;
//   final userCollection = FirebaseFirestore.instance.collection('users');
//
//
//   // Get Echo instance from GetX
//   final Echo echo = Get.find<Echo>();
//
//   void togglePasswordVisibility(){
//     isPasswordHidden = !isPasswordHidden;
//     update();
//   }
//
//   Future<void> registerUser(User user) async {
//     error = '';
//     update();
//
//     // Check if username already exists
//     if (echo.bst.search(user.username) != null) {
//       error = "Username already exists";
//       update();
//       return;
//     }
//
//     try {
//       // Insert user into BST via Echo
//       await echo.bst.insert(user);
//
//       // Optionally set activeUser here if you want
//       echo.activeUser = echo.bst.search(user.username) ;
//       echo.activeUser?.user.user_index =  echo.userCount ;
//       await userCollection.doc(user.username).update({
//         'user_index': echo.userCount,
//       });
//       echo.userCount++;
//       echo.usernames.add(user.username);
//       await echo.saveUsernamesToFirebase();
//
//
//       final newConnections = await echo.getUpdatedConnections();
//
//       // Assign only if non-empty (optional check)
//       if (newConnections.isNotEmpty) {
//         echo.connections = newConnections;
//         await echo.saveConnectionsToFirebase();
//       }
//
//       print('Saving connections matrix: $echo.connections');
//
//       // Navigate or other logic
//       Get.offNamed(AppRouter.profileScreen, arguments: user);
//
//
//
//     } catch (e) {
//       error = 'Registration failed: ${e.toString()}';
//       update();
//     }
//   }
//   /*Future<void> logIn(String userName, String password) async {
//     // Clear previous errors
//     error = '';
//     update();
//
//     // Validate input
//     if (userName.isEmpty || password.isEmpty) {
//       error = 'Please fill all fields';
//       update();
//       return;
//     }
//
//     try {
//       // Search in BST
//       final node = echo.bst.search(userName.trim());
//
//       // Validate credentials
//       if (node == null || node.user.password != password) {
//         error = 'Invalid username or password';
//         update();
//         return;
//       }
//
//       // Update last sign-in time
//       final now = DateTime.now().toString();
//       node.user.lastSignin = now;
//
//       // Update in Firestore
//       await userCollection.doc(userName.trim()).update({
//         'lastSignIn': now,
//         'lastSignin': now, // Consistent field naming
//       });
//
//       // Ensure user data is valid before navigation
//       if (node.user.username.isEmpty) {
//         throw Exception("User data corrupted");
//       }
//       print("Login Successful");
//       isLoggedIn = true;
//       Echo.activeUser = node;
//       // jab user login ho ya app reload ho
//
//       update();
//       // Navigate with guaranteed non-null user
//       Get.toNamed(
//         AppRouter.bottomnavbar,
//         arguments: node.user,
//       );
//
//     } catch (e) {
//       error = 'Login failed: ${e.toString()}';
//       update();
//     }
//   }*/
//
//   Future<void> logIn(String userName, String password) async {
//     error = '';
//     update();
//
//     if (userName.isEmpty || password.isEmpty) {
//       error = 'Please fill all fields';
//       update();
//       return;
//     }
//
//     try {
//       final node = echo.bst.search(userName.trim());
//
//       if (node == null) {
//         error = 'Invalid username';
//         update();
//         return;
//       }
//
//       if (node.user.password != password) {
//         error = 'Incorrect password';
//         update();
//         return;
//       }
//
//       final now = DateTime.now().toString();
//       node.user.lastSignin = now;
//
//       await userCollection.doc(userName.trim()).update({
//         'lastSignIn': now,
//         'lastSignin': now,
//       });
//
//       if (node.user.username.isEmpty) {
//         throw Exception("User data corrupted");
//       }
//
//       print("Login Successful");
//       isLoggedIn = true;
//       echo.activeUser = node;
//       User? user = await loadUserFromFirebase(userName);
//       await echo.loadUsernamesFromFirebase();
//       if (user != null) {
//         echo.activeUser = node;  // or however you're assigning it
//       }
//
//
//
//
//       update();
//       print("Navigating to bottomnavbar...");
//       Get.toNamed(
//         AppRouter.bottomnavbar,
//         arguments: node.user,
//       );
//
//     } catch (e) {
//       error = 'Login failed: ${e.toString()}';
//       update();
//     }
//   }
//
//   Future<User?> loadUserFromFirebase(String username) async {
//     try {
//       final firestore = FirebaseFirestore.instance;
//
//       // Get the document from 'users' collection by username
//       final doc = await firestore.collection('users').doc(username).get();
//
//       if (doc.exists) {
//         final data = doc.data()!;
//         final user = User.fromJson(data);
//         print('[loadUserFromFirebase] Successfully loaded user: ${user.username}');
//         return user;
//       } else {
//         print('[loadUserFromFirebase] User not found: $username');
//         return null;
//       }
//     } catch (e) {
//       print('[loadUserFromFirebase] Error: $e');
//       return null;
//     }
//   }
//   Future<void> logOut() async {
//     try {
//       echo.activeUser = null;
//       isLoggedIn = false;
//       update();
//       Get.toNamed(AppRouter.loginScreen);
//     } catch (e) {
//       Get.snackbar('Error', 'Logout failed: ${e.toString()}');
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../component/route.dart';
import '../models/bst.dart';
import '../models/userService.dart';
import '../models/echo.dart';

class UserController extends GetxController {
  String error = '';
  bool isLoggedIn = false;
  bool isPasswordHidden = true;

  final userCollection = FirebaseFirestore.instance.collection('users');
  final Echo echo = Get.find<Echo>();

  /// Toggles visibility for password field (login/register)
  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    update();
  }

  /// Registers a new user after checking for duplicate usernames
  Future<void> registerUser(User user) async {
    error = '';
    update();

    // Check for existing username in BST
    if (echo.bst.search(user.username) != null) {
      error = "Username already exists";
      update();
      return;
    }

    try {
      // Insert new user into BST
      await echo.bst.insert(user);

      // Set the newly registered user as the active user
      echo.activeUser = echo.bst.search(user.username);
      echo.activeUser?.user.user_index = echo.userCount;

      // Update Firestore with user index
      await userCollection.doc(user.username).update({
        'user_index': echo.userCount,
      });


      echo.userCount++;
      await echo.loadUsernamesFromFirebase();
      echo.usernames.add(user.username);
      await echo.saveUsernamesToFirebase();

      // Update connections matrix if changed
      final newConnections = await echo.getUpdatedConnections();
      if (newConnections.isNotEmpty) {
        echo.connections = newConnections;
        await echo.saveConnectionsToFirebase();
      }

      // Navigate to profile screen
      Get.offNamed(AppRouter.loginScreen);
    } catch (e) {
      error = 'Registration failed: ${e.toString()}';
      update();
    }
  }

  /// Logs in an existing user after verifying credentials
  Future<void> logIn(String userName, String password) async {
    error = '';
    update();

    if (userName.isEmpty || password.isEmpty) {
      error = 'Please fill all fields';
      update();
      return;
    }

    try {
      // Search for the user in the BST
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

      // Update last sign-in timestamp
      final now = DateTime.now().toString();
      node.user.lastSignin = now;

      await userCollection.doc(userName.trim()).update({
        'lastSignIn': now,
        'lastSignin': now,
      });

      if (node.user.username.isEmpty) {
        throw Exception("User data corrupted");
      }

      // Successful login
      isLoggedIn = true;
      echo.activeUser = node;

      // Reload user data and usernames from Firebase
      final user = await loadUserFromFirebase(userName);
      await echo.loadUsernamesFromFirebase();

      if (user != null) {
        echo.activeUser = node;
      }

      update();

      // Navigate to main app screen
      Get.toNamed(AppRouter.bottomnavbar, arguments: node.user);
    } catch (e) {
      error = 'Login failed: ${e.toString()}';
      update();
    }
  }

  /// Loads full user data from Firebase using username
  Future<User?> loadUserFromFirebase(String username) async {
    try {
      final doc = await userCollection.doc(username).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return User.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Logs the user out and resets session state
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
