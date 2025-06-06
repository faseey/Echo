
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../Screen/LoginScreen.dart';
import '../Screen/postScreen.dart';
import '../Screen/profileScreen.dart';
import '../controllers/register_controller.dart';

import 'myListTile.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(child: Icon(Icons.person, size: 62)),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('H O M E'),
            onTap: () => Get.offNamed('/home'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('P R O F I L E'),
            onTap: () => Get.toNamed('/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('L O G O U T'),
            onTap: () => controller.logOut(),
          ),
        ],
      ),
    );
  }
}
