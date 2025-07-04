import 'package:echo_app/Screen/LoginScreen.dart';
import 'package:echo_app/component/route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_login.dart';
import '../models/echo.dart';
import '../models/bst.dart';
import '../models/userService.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final userController = Get.put(UserController());

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final dobController = TextEditingController();

  final RxString selectedGender = ''.obs;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(builder: (_){
      return  Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,

        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Icon(Icons.lock,size: 50,color: Color(0xff123456),),
                Center(child: Text("Lets create an account for you",style: TextStyle(color: Colors.black,fontSize: 13),)),
                const SizedBox(height: 20),
                // Username
                TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {

                      if(value == null || value.isEmpty)  return 'Enter username' ;


                    }



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
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Password
                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: userController.isPasswordHidden,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        userController.isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        userController.togglePasswordVisibility();
                      },
                    ),
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter password';
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
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
                  validator: (value) =>
                  (value == null || value.isEmpty) ? 'Enter first name' : null,
                ),
                const SizedBox(height: 10),

                // Last Name
                TextFormField(
                  controller: lastnameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  (value == null || value.isEmpty) ? 'Enter last name' : null,
                ),
                const SizedBox(height: 10),

                // DOB
                TextFormField(
                  controller: dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  (value == null || value.isEmpty) ? 'Enter DOB' : null,
                ),
                const SizedBox(height: 10),

                // Gender Dropdown
                Obx(() {
                  return DropdownButtonFormField<String>(
                    value: selectedGender.value.isEmpty ? null : selectedGender.value,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Male', 'Female'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) selectedGender.value = value;
                    },
                    validator: (value) =>
                    (value == null || value.isEmpty) ? 'Select gender' : null,
                  );
                }),
                const SizedBox(height: 20),

                // Error message
                GetBuilder<UserController>(
                  builder: (controller) => controller.error.isNotEmpty
                      ? Text(
                    controller.error,
                    style: const TextStyle(color: Colors.red),
                  )
                      : const SizedBox.shrink(),
                ),

                // Register Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final newUser = User(
                        username: usernameController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        firstname: firstnameController.text.trim(),
                        lastname: lastnameController.text.trim(),
                        DOB: dobController.text.trim(),
                        gender: selectedGender.value,
                        lastSignin: DateTime.now().toIso8601String(),
                        profileImageUrl: '',
                        bio: '',
                      );

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
                      selectedGender.value = '';

                      // Navigate to Login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff123456),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRouter.loginScreen);

                  },
                  child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: 'Already Have an Account?',style: TextStyle(color: Colors.black)),
                            TextSpan(
                              text: 'sigIn',
                              style: TextStyle(fontSize: 15,color: Colors.blue),
                            ),

                          ],
                        ),
                      )
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });


  }
}