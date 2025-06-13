// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
//
// import '../models/bst.dart';
// import '../models/echo.dart';
// import '../models/newsfeedheap.dart';
// import '../models/postStack.dart';
// import '../models/userService.dart';
//
// class NewsFeedController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ImagePicker _picker = ImagePicker();
//
//   final Echo echo = Get.find<Echo>();
//   var newsFeed = <NewsFeedNode>[].obs;
//
//   Post? latestPost;
//
//   BSTNode? get activeUserNode => echo.activeUser;
//   User? get currentUser => activeUserNode?.user;
//   final TextEditingController contentController = TextEditingController();
//
//
//   /// Load in-memory news feed
//   void loadNewsFeed() {
//     if (echo.activeUser == null) {
//       print("No active user found.");
//       newsFeed.clear();
//       return;
//     }
//
//     echo.buildNewsFeed(); // rebuild heap
//     final heap = echo.activeUser!.user.newsfeedheap.heap;
//     newsFeed.value = List.from(heap);
//   }
//
//   /// Load news feed by calling Echo's async logic (Firebase based)
//   Future<void> loadNewsFeedFromFirebase() async {
//     if (echo.activeUser == null) {
//       newsFeed.clear();
//       return;
//     }
//
//     await echo.buildNewsFeed(); // async
//     newsFeed.value = List.from(echo.activeUser!.user.newsfeedheap.heap);
//   }
//
//   void refreshFeed() => loadNewsFeed();
//   void clearFeed() => newsFeed.clear();
// }
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/bst.dart';
import '../models/echo.dart';
import '../models/newsfeedheap.dart';
import '../models/postStack.dart';
import '../models/userService.dart';

class NewsFeedController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final Echo echo = Get.find<Echo>();

  final TextEditingController contentController = TextEditingController();

  var newsFeed = <NewsFeedNode>[].obs;
  Post? latestPost;

  BSTNode? get activeUserNode => echo.activeUser;
  User? get currentUser => activeUserNode?.user;

  /// Load local in-memory news feed from current user's heap
  void loadNewsFeed() {
    if (echo.activeUser == null) {
      newsFeed.clear();
      return;
    }

    echo.buildNewsFeed();
    final heap = echo.activeUser!.user.newsfeedheap.heap;
    newsFeed.value = List.from(heap);
  }

  /// Asynchronously load the news feed from Firebase via Echo's logic
  Future<void> loadNewsFeedFromFirebase() async {
    if (echo.activeUser == null) {
      newsFeed.clear();
      return;
    }

    await echo.buildNewsFeed();
    newsFeed.value = List.from(echo.activeUser!.user.newsfeedheap.heap);
  }

  /// Refresh feed using in-memory logic
  void refreshFeed() => loadNewsFeed();

  /// Clear the current in-memory feed
  void clearFeed() => newsFeed.clear();
}
