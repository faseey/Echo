/*import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/post_model.dart'; // Update with actual model import

class PostCardBuilder extends StatelessWidget {
  final dynamic post;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onViewImage;

  const PostCardBuilder({
    Key? key,
    required this.post,
    required this.index,
    required this.onDelete,
    required this.onViewImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    try {
      if (post.imageBase64.isNotEmpty) {
        imageBytes = base64Decode(post.imageBase64);
      }
    } catch (e) {
      print("Error decoding image: $e");
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/user_placeholder.png'),
                ),
                SizedBox(width: 12),
                Text(
                  post.username ?? "User",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Delete Post",
                      middleText: "Are you sure you want to delete this post?",
                      textCancel: "No",
                      textConfirm: "Yes",
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        onDelete();
                        Get.back();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/




import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PostCardBuilder extends StatelessWidget {
  final dynamic post;
  final int index;
  final VoidCallback onDelete;

  const PostCardBuilder({
    Key? key,
    required this.post,
    required this.index,
    required this.onDelete,
  }) : super(key: key);

  void _showFullImage(BuildContext context, String base64Image) {
    try {
      final imageBytes = base64Decode(base64Image);
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.black,
          child: InteractiveViewer(
            child: Image.memory(imageBytes),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to load full image.");
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    try {
      if (post.imageBase64.isNotEmpty) {
        imageBytes = base64Decode(post.imageBase64);
      }
    } catch (e) {
      print("Error decoding image: $e");
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/user_placeholder.png'),
                ),
                const SizedBox(width: 12),
                Text(
                  post.username ?? "User",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showDeleteDialog(context),
                ),
              ],
            ),
          ),
          Divider(),

          // Post image
          GestureDetector(
            onTap: () => _showFullImage(context, post.imageBase64),
            child: imageBytes != null
                ? Image.memory(
              imageBytes,
              width: double.infinity,
              height: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            )
                : Container(
              height: MediaQuery.of(context).size.width,
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.broken_image, size: 50)),
            ),
          ),
          Divider(),

          // Action buttons
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          //   child: Row(
          //     children: [
          //       IconButton(
          //         icon: const Icon(Icons.favorite_border, size: 28),
          //         onPressed: () {},
          //       ),
          //       IconButton(
          //         icon: const Icon(Icons.chat_bubble_outline, size: 28),
          //         onPressed: () {},
          //       ),
          //       IconButton(
          //         icon: const Icon(Icons.send, size: 28),
          //         onPressed: () {},
          //       ),
          //       const Spacer(),
          //       IconButton(
          //         icon: const Icon(Icons.bookmark_border, size: 28),
          //         onPressed: () {},
          //       ),
          //     ],
          //   ),
          // ),

          // Likes count
          // const Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 16),
          //   child: Text(
          //     "62 likes",
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //   ),
          // ),
          const SizedBox(height: 4),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: "${post.username} ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: post.content),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Comments
          // const Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 16),
          //   child: Text(
          //     "View all 21 comments",
          //     style: TextStyle(color: Colors.grey),
          //   ),
          // ),
          const SizedBox(height: 4),

          // Timestamp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.date.split('T').first,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Delete Post",
      middleText: "Are you sure you want to delete this post?",
      textCancel: "No",
      textConfirm: "Yes",
      confirmTextColor: Colors.white,
      onConfirm: () {
        onDelete();
        Get.back();
      },
    );
  }
}


