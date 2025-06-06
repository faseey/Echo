import 'package:echo_app/component/route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';
import '../models/echo.dart';

import '../models/bst.dart';

class LoginScreen extends StatelessWidget {
   LoginScreen({super.key});

  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

   final controller = Get.find<UserController>();  // To access the existing controller


  @override
  Widget build(BuildContext context) {


        return Scaffold(
          appBar: AppBar(title: const Text('Login to Echo')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(

                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username',border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password',border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed:
                      () => controller.logIn(
                        usernameController.text.trim(),
                        passwordController.text.trim(),
                      ),
                  child: const Text('Log In'),
                ),
                if (controller.error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      controller.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        );


  }
}
