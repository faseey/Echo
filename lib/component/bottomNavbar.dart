import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../Screen/friendscreen.dart';
import '../Screen/postScreen.dart';
import '../Screen/profileScreen.dart';

class Bottomnavbar extends StatelessWidget {
  Bottomnavbar({Key? key}) : super(key: key);

  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  // Define screens list directly (alternative to _buildScreens method)
  final List<Widget> _screens = [

    Center(child: Text("News Feed")),
    FriendScreen(),
    PostScreen(),
    Center(child: Text("Inbox")),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _screens, // Use the list directly
      items: _navBarItems(),
      navBarStyle: NavBarStyle.style3,
      backgroundColor: Colors.white,
    );
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: "Home",
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.group),
        title: "Friends",
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.add_box, size: 28),
        title: "Add",
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.inbox),
        title: "Inbox",
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: "Profile",
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
}