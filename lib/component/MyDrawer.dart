
import 'package:flutter/material.dart';

import '../Screen/LoginScreen.dart';
import '../Screen/postScreen.dart';
import '../Screen/profileScreen.dart';
import '../controllers/register_controller.dart';

import 'myListTile.dart';

class MyDrawer extends StatefulWidget {
 // final RegisterUser userManager;
  const MyDrawer({super.key, });

  @override
  State<MyDrawer> createState() => _MydrawerState();
}

class _MydrawerState extends State<MyDrawer> {
 // RegisterUser userManager = RegisterUser();

  void GotoProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade900,
      child: Column(
        children: [
          DrawerHeader(
            child: Icon(Icons.person, color: Colors.white, size: 62),
          ),

          Expanded(
            flex: 0,
            child: MyListTile(text: 'H O M E', icon: Icons.home, onTab: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreen(),));
            }),
          ),
          Expanded(
            child: MyListTile(
              text: 'P R O F I L E',
              icon: Icons.person,
              onTab: GotoProfileScreen,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: MyListTile(
              text: 'L O G O U T',
              icon: Icons.login,
              onTab: () {
               // userManager.logoutUser();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
