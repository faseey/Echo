import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

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
  // Message message;

  User({
    required this.username,
    required this.email,
    required this.password,
    required this.firstname,
    required this.lastname,
    required this.DOB,
    required this.lastSignin,
    required this.gender,
    this.profileImageUrl= '',
    this.bio= '',
    // Message? message,
  }) ;//: message = message ?? Message();

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'password': password,
    'firstname': firstname,
    'lastname': lastname,
    'DOB': DOB,
    'lastSignin': lastSignin,
    'gender': gender,
    'profileImageUrl': profileImageUrl ?? '',
    'bio': bio ?? '',
    //'message': message.toJson(),
  };



  static User fromJson(Map<String, dynamic> json) => User(
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
  );


}

