import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

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
  PostStack postStack; // new field

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
  }) : postStack = postStack ?? PostStack(); // initialize empty if null

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
    'posts': postStack.toJsonList(), // Save posts to Firebase
  };

  static User fromJson(Map<String, dynamic> json) {
    final postStack = PostStack();
    if (json['posts'] != null) {
      postStack.loadFromJsonList(json['posts']);
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
    );
  }
}
