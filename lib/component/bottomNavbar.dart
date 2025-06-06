

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../Screen/postScreen.dart';
import '../Screen/profileScreen.dart';
import '../controllers/register_controller.dart';


class Bottomnavbar extends StatefulWidget {
  const Bottomnavbar({super.key});


  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}



class _BottomnavbarState extends State<Bottomnavbar> {

  final controller = PersistentTabController(initialIndex: 0);
  //var userManager = RegisterUser();



 List<Widget> _buildScreen(){
   return[
     PostScreen(),
     Text("Friends"),
     Text("add"),
     Text("Indox"),
     ProfileScreen(),   ];
 }
 List<PersistentBottomNavBarItem> _nabBarItem(){
    return[
         PersistentBottomNavBarItem(icon: Icon(Icons.home,color: Colors.black,),inactiveIcon: Icon(Icons.home,color: Colors.white,)),
         PersistentBottomNavBarItem(icon: Icon(Icons.person_add_alt,color: Colors.black,),inactiveIcon: Icon(Icons.person_add_alt,color: Colors.white,)),
         PersistentBottomNavBarItem(icon: Icon(Icons.add,color: Colors.black,),inactiveIcon: Icon(Icons.add,color: Colors.white,),activeColorPrimary: Colors.blueGrey,),
         PersistentBottomNavBarItem(icon: Icon(Icons.inbox,color: Colors.black,),inactiveIcon: Icon(Icons.inbox,color: Colors.white,)),
         PersistentBottomNavBarItem(icon: Icon(Icons.person,color: Colors.black),inactiveIcon: Icon(Icons.person,color: Colors.white,)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(context, screens: _buildScreen(),
      items: _nabBarItem(),
        backgroundColor: Colors.grey.shade400,
        decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(1)
    ),
      navBarStyle: NavBarStyle.style15,
    );
  }
}
