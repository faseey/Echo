import 'package:echo_app/Screen/messagescreen.dart';
import 'package:echo_app/Screen/newsfeedscreen.dart';
import 'package:get/get.dart';

import '../Screen/LoginScreen.dart';
import '../Screen/friendscreen.dart';
import '../Screen/new_post_screen.dart';
import '../Screen/postScreen.dart';
import '../Screen/profileScreen.dart';
import '../Screen/registerScreen.dart';
import '../models/echo.dart';
import 'bottomNavbar.dart';

class AppRouter{
  static const registerScreen = "/registerScreen";
  static const loginScreen = "/loginScreen";
  static const postScreen = "/postScreen";
  static const profileScreen = "/profileScreen";
  static const bottomnavbar = "/bottomnavbar";
  static const friendscreen = "/friendscreen";
  static const newPostScreen = "/newPostScreen";
  static const messagescreen = "/messagescreen";
  static const newsfeedscreen = "/newsfeedscreen";


  static final route = [
    GetPage(name: registerScreen, page: ()=>RegisterScreen()),
    GetPage(name: loginScreen, page: ()=>LoginScreen()),
    //GetPage(name: postScreen, page: ()=>PostScreen()),
    GetPage(name: profileScreen, page: ()=>ProfileScreen()),
    GetPage(name: friendscreen, page: ()=>FriendScreen()),
    GetPage(name: newPostScreen, page: ()=>NewPostScreen()),
    GetPage(name: bottomnavbar, page: ()=>Bottomnavbar()),
    GetPage(name: messagescreen, page: ()=>MessageScreen()),
    GetPage(name: newsfeedscreen, page: ()=>NewsFeedScreen()),


  ];
}