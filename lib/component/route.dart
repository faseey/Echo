import 'package:get/get.dart';

import '../Screen/LoginScreen.dart';
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


  static final route = [
    GetPage(name: registerScreen, page: ()=>RegisterScreen()),
    GetPage(name: loginScreen, page: ()=>LoginScreen()),
    GetPage(name: postScreen, page: ()=>PostScreen()),
    GetPage(name: profileScreen, page: ()=>ProfileScreen()),
    GetPage(name: bottomnavbar, page: ()=>Bottomnavbar()),


  ];
}