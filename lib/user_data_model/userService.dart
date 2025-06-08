import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

import '../models/friendlist.dart';
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
  PostStack postStack;       // posts
  RequestQueue requestList;   // friend requests

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
    PostStack? postStack,
    RequestQueue? requestList,
  })  : postStack = postStack ?? PostStack(),
        requestList = requestList ?? RequestQueue();

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
    'posts': postStack.toJsonList(),
    'friendRequests': requestList.toJsonList(),
  };

  static User fromJson(Map<String, dynamic> json) {
    final postStack = PostStack();
    if (json['posts'] != null) {
      postStack.loadFromJsonList(json['posts']);
    }

    final requestList = RequestQueue();
    if (json['friendRequests'] != null) {
      requestList.loadFromJsonList(json['friendRequests']);
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
      postStack: postStack,
      requestList: requestList,
    );
  }
}
