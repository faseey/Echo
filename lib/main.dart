import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Screen/LoginScreen.dart';
import 'Screen/postScreen.dart';
import 'Screen/registerScreen.dart';
import 'component/bottomNavbar.dart';
import 'component/route.dart';

import 'controllers/MessageController.dart';
import 'controllers/register_controller.dart';
import 'models/echo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await Echo.instance.initialize();
  Get.put(Echo());
  Get.put(UserController());
  Get.put(MessageController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.onboarding_screen,
      getPages: AppRouter.route,
        theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,)
    );
  }
}
