import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/friendlist.dart';
import '../models/message.dart';
import '../models/newsfeedheap.dart';
import '../models/post_model.dart';
import '../models/poststack.dart';

class User {
  String _username;
  String _email;
  String _password;
  String _firstname;
  String _lastname;
  String _DOB;
  String _lastSignin;
  String _gender;
  String _profileImageUrl;
  String _bio;
  int _userIndex;
  PostStack _postStack;
  RequestQueue _requestQueue;
  ImagePostStack _imagePostStack;
  Messages _message;
  NewsFeedHeap _newsfeedheap;

  User({
    required String username,
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    required String DOB,
    required String lastSignin,
    required String gender,
    String profileImageUrl = '',
    String bio = '',
    int user_index = -1,
    PostStack? postStack,
    RequestQueue? requestQueue,
    ImagePostStack? imagePostStack,
    Messages? message,
    NewsFeedHeap? newsfeedheap,
  })  : _username = username,
        _email = email,
        _password = password,
        _firstname = firstname,
        _lastname = lastname,
        _DOB = DOB,
        _lastSignin = lastSignin,
        _gender = gender,
        _profileImageUrl = profileImageUrl,
        _bio = bio,
        _userIndex = user_index,
        _postStack = postStack ?? PostStack(),
        _requestQueue = requestQueue ?? RequestQueue(),
        _imagePostStack = imagePostStack ?? ImagePostStack(),
        _message = message ?? Messages(),
        _newsfeedheap = newsfeedheap ?? NewsFeedHeap();


  //  Public getters
  String get username => _username;
  String get email => _email;
  String get password => _password;
  String get firstname => _firstname;
  String get lastname => _lastname;
  String get DOB => _DOB;
  String get lastSignin => _lastSignin;
  String get gender => _gender;
  String get profileImageUrl => _profileImageUrl;
  String get bio => _bio;
  int get userIndex => _userIndex;
  PostStack get postStack => _postStack;
  RequestQueue get requestQueue => _requestQueue;
  ImagePostStack get imagePostStack => _imagePostStack;
  Messages get message => _message;
  NewsFeedHeap get newsfeedheap => _newsfeedheap;


  // Public setters
  set profileImageUrl(String url) => _profileImageUrl = url;
  set bio(String b) => _bio = b;
  set lastSignin(String value) => _lastSignin = value;
  set user_index(int value) => user_index = value;


  Map<String, dynamic> toJson() => {
    'username': _username,
    'email': _email,
    'password': _password,
    'firstname': _firstname,
    'lastname': _lastname,
    'DOB': _DOB,
    'lastSignin': _lastSignin,
    'gender': _gender,
    'profileImageUrl': _profileImageUrl,
    'bio': _bio,
    'user_index': _userIndex,
    'posts': _imagePostStack.toJsonList(),
    'friendRequests': _requestQueue.toJsonList(),
    'chatList': _message.toJsonList(),
    'newsFeed': _newsfeedheap.toJsonList(),

  };

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
    final newsFeed = NewsFeedHeap();
    if (json['newsFeed'] != null) {
      newsFeed.loadFromJsonList(json['newsFeed']);
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
      user_index: json['user_index'] ?? -1,
      imagePostStack: imagePostStack,
      requestQueue: requestQueue,
      message: messages,
      newsfeedheap: newsFeed,

    );
  }

}
