import 'dart:convert';
import 'package:echo_app/models/newsfeedheap.dart';
import 'package:flutter/material.dart';
import '../models/echo.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  List<NewsFeedNode> heap = [];

  @override
  void initState() {
    super.initState();
    Echo.instance.buildNewsFeed(); // or loadNewsFeed()
    heap = Echo.instance.activeUser?.user.newsfeedheap.heap ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (heap.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("News Feed"),
        ),
        body: const Center(
          child: Text("No posts to show. Follow some friends!"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("News Feed"),
      ),
      body: ListView.builder(
        itemCount: heap.length,
        itemBuilder: (context, index) {
          final post = heap[index];

          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        post.date,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (post.imageBase64.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(post.imageBase64),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    post.post,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
