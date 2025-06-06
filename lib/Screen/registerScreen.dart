import 'package:echo_app/Screen/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/register_controller.dart';

import 'package:echo_app/Screen/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bst.dart';
import '../models/echo.dart';
import '../user_data_model/userService.dart';

// Assuming BST is here

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  final userController = Get.put(UserController());


  // Controllers for all User fields
  final usernameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final firstnameController = TextEditingController();

  final lastnameController = TextEditingController();

  final dobController = TextEditingController();

  final genderController = TextEditingController();

  // BST instance
  @override
  Widget build(BuildContext context) {


        return Scaffold(
          appBar: AppBar(
            title: Center(
              child: const Text(
                'Register',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  fontSize: 30,
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 20),

                  // Username
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Enter username'
                                : null,
                  ),
                  const SizedBox(height: 10),

                  // Email
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter email';
                      if (!value.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Enter password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // First Name
                  TextFormField(
                    controller: firstnameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Enter first name'
                                : null,
                  ),
                  const SizedBox(height: 10),

                  // Last Name
                  TextFormField(
                    controller: lastnameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Enter last name'
                                : null,
                  ),
                  const SizedBox(height: 10),

                  // DOB
                  TextFormField(
                    controller: dobController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Enter DOB'
                                : null,
                  ),
                  const SizedBox(height: 10),

                  // Gender
                  TextFormField(
                    controller: genderController,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Enter gender'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  GetBuilder<UserController>(
                    builder: (controller) => controller.error.isNotEmpty
                        ? Text(
                      controller.error,
                      style: const TextStyle(color: Colors.red),
                    )
                        : const SizedBox.shrink(),
                  ),



                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Create User object
                        final newUser = User(
                          username: usernameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                          firstname: firstnameController.text,
                          lastname: lastnameController.text,
                          DOB: dobController.text,
                          lastSignin: DateTime.now().toIso8601String(),
                          gender: genderController.text,
                          profileImageUrl: '',
                          bio: '',
                        );

                        // Insert into BST and Firestore
                        await userController.registerUser(newUser);


                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User Registered Successfully'),
                          ),
                        );

                        // Clear inputs
                        usernameController.clear();
                        emailController.clear();
                        passwordController.clear();
                        firstnameController.clear();
                        lastnameController.clear();
                        dobController.clear();
                        genderController.clear();

                        //  Navigate to Login Screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Center(
                      child: Text(
                        "Already have an account? Sign in",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );


  }
}
