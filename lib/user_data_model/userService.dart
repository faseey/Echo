import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/friendlist.dart';
import '../models/message.dart';
import '../models/post_model.dart';
import '../models/poststack.dart';

class User {
  String username;
  String email;
  String password;
  String firstname;
  String lastname;
  String DOB;
  String lastSignin;
  String gender;
  String profileImageUrl;
  String bio;
  int user_index;  // <-- keep as is
  PostStack postStack;
  RequestQueue requestQueue;
  ImagePostStack imagePostStack;
  Messages message;



  User({
    required this.username,
    required this.email,
    required this.password,
    required this.firstname,
    required this.lastname,
    required this.DOB,
    required this.lastSignin,
    required this.gender,
    this.profileImageUrl = '',
    this.bio = '',
    this.user_index = -1,  // <-- default value
   PostStack? postStack,
    RequestQueue? requestQueue,
    ImagePostStack? imagePostStack,
    Messages? message,
  })  : postStack = postStack ?? PostStack(),
        requestQueue = requestQueue ?? RequestQueue(),
        imagePostStack = imagePostStack ?? ImagePostStack(),
        message = message ?? Messages();




  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'password': password,
    'firstname': firstname,
    'lastname': lastname,
    'DOB': DOB,
    'lastSignin': lastSignin,
    'gender': gender,
    'profileImageUrl': profileImageUrl,
    'bio': bio,
    'user_index': user_index,      // <-- add here
    'posts': imagePostStack.toJsonList(),
    'friendRequests': requestQueue.toJsonList(),
    'chatList': message.toJsonList(),

  };
  static final Map<String, User> _userMemoryStore = {};

  // Save user data in memory


  static User fromJson(Map<String, dynamic> json) {
    final imagePostStack = ImagePostStack();
    if (json['posts'] != null) {
      imagePostStack.loadFromJsonList(json['posts']);
    }

    final requestQueue = RequestQueue();
    if (json['friendRequests'] != null) {
      requestQueue.loadFromJsonList(json['friendRequests']);
    }
    final messages = Messages();
    if (json['chatList'] != null) {
      messages.loadFromJsonList(json['chatList']);
    }




    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      DOB: json['DOB'] ?? '',
      lastSignin: json['lastSignin'] ?? '',
      gender: json['gender'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      bio: json['bio'] ?? '',
      user_index: json['user_index'] ?? -1,  // <-- add here, default -1
      imagePostStack: imagePostStack,
      requestQueue: requestQueue,
      message: messages,
    );
  }

}
