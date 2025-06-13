/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/newsfeed.dart';
import '../component/MyDrawer.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({Key? key}) : super(key: key);

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final NewsFeedController controller = Get.put(NewsFeedController());

  @override
  void initState() {
    super.initState();
    controller.loadNewsFeedFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),


          title: ListTile(
            title: Text('Echo'),
            subtitle: Text("News Feed"),
          ),

          // Text(
          //   "Newsfeed",
          //   style: TextStyle(
          //     fontFamily: 'Billabong',
          //     fontSize: 30,
          //     color: Colors.black,
          //   ),
          // ),
          centerTitle: true,
          elevation: 0,


        ),
        drawer: MyDrawer(),
        backgroundColor: Colors.white,
        body: controller.newsFeed.isEmpty
            ? const Center(
            child: Text("No posts to show. Follow some friends!",
                style: TextStyle(color: Colors.black38)))
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.newsFeed.length,
          itemBuilder: (context, index) {
            final post = controller.newsFeed[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Avatar + Username + Date
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          post.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          post.date.split("T").first,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Image (square)
                  if (post.imageBase64.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: Image.memory(
                        base64Decode(post.imageBase64),
                        height: MediaQuery.of(context).size.width,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Caption header (avatar + username again)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          child: Icon(Icons.person, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          post.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Caption text (content)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      post.post,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        )


      );
    });
  }
}*/



import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/newsfeed.dart';
import '../component/MyDrawer.dart';
import '../controllers/profile.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({Key? key}) : super(key: key);

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final NewsFeedController controller = Get.put(NewsFeedController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final profilecontroller = Get.put(ProfileController());



  @override
  void initState() {
    super.initState();
    controller.loadNewsFeedFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(


        key: _scaffoldKey,
        backgroundColor: Colors.grey[200],
        drawer: MyDrawer(),
        body: Column(
          children: [
            // Curved Top Container
            Container(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
              decoration: const BoxDecoration(
                color: Color(0xff30567c),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu,color: Colors.white,size: 30,),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Echo',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                      Text(
                        'News Feed',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: profilecontroller.imagePath.isNotEmpty
                        ? FileImage(File(profilecontroller.imagePath))
                        : (profilecontroller.imageBase64.isNotEmpty &&
                        profilecontroller.imageBase64.startsWith('data:image'))
                        ? MemoryImage(base64Decode(profilecontroller.imageBase64.split(',').last))
                        : null,
                    child: (profilecontroller.imagePath.isEmpty &&
                        profilecontroller.imageBase64.isEmpty)
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ],
              ),
            ),

            // Posts Area
            Expanded(
              child: controller.newsFeed.isEmpty
                  ? const Center(
                  child: Text("No posts to show. Follow some friends!",
                      style: TextStyle(color: Colors.black38)))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.newsFeed.length,
                itemBuilder: (context, index) {
                  final post = controller.newsFeed[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar: avatar + username + date
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: (post.profileimg.isNotEmpty &&
                                    post.profileimg.startsWith('data:image'))
                                    ? MemoryImage(base64Decode(post.profileimg.split(',').last))
                                    : null,
                                child: (post.profileimg.isEmpty ||
                                    !post.profileimg.startsWith('data:image'))
                                    ? const Icon(Icons.person, size: 20)
                                    : null,
                              ),

                              const SizedBox(width: 10),
                              Text(
                                post.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                post.date.split("T").first,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Post image
                        if (post.imageBase64.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.zero,
                            child: Image.memory(
                              base64Decode(post.imageBase64),
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        const SizedBox(height: 10),

                        // Caption
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            post.post,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
