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
  int user_index;  // <-- keep as is
  PostStack postStack;
  RequestQueue requestQueue;

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
  })  : postStack = postStack ?? PostStack(),
        requestQueue = requestQueue ?? RequestQueue();

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
    'posts': postStack.toJsonList(),
    'friendRequests': requestQueue.toJsonList(),
  };

  static User fromJson(Map<String, dynamic> json) {
    final postStack = PostStack();
    if (json['posts'] != null) {
      postStack.loadFromJsonList(json['posts']);
    }

    final requestQueue = RequestQueue();
    if (json['friendRequests'] != null) {
      requestQueue.loadFromJsonList(json['friendRequests']);
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
      postStack: postStack,
      requestQueue: requestQueue,
    );
  }
}
