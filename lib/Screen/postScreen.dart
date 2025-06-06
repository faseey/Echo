
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../component/MyDrawer.dart';
import '../component/MyTextBox.dart';

import '../controllers/post_controller.dart';
import '../controllers/register_controller.dart';
import '../user_data_model/userMessage.dart';
import '../user_data_model/userService.dart';
import 'LoginScreen.dart';

class PostScreen extends StatefulWidget {


  const PostScreen({super.key, });



  @override
  State<PostScreen> createState() => _PostscreenState();
}

class _PostscreenState extends State<PostScreen> {
  final controller = Get.put(PostController());
 // final _userMessage = userMessageStack<dynamic>();




  @override
  Widget build(BuildContext context) {
    final messages = controller.userMessage.toList();

    final User user = Get.arguments;
    return GetBuilder(builder: (_){
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          iconTheme: IconThemeData(color: Colors.white),

          title: Center(
            child: Text(
              "Echo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: controller.selectedIndex != null ?
          [
            IconButton(onPressed: (){

                controller.userMessage.pop();
                controller.selectedIndex = null;

            }, icon: Icon(Icons.delete,color: Colors.white,))


          ]: [],
        ),
        drawer: MyDrawer(),
        body: Column(
          children: [
            Expanded(
              child: Container(


                child: ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: (){
                        setState(() {
                          controller.selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade100, Colors.blue.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(10),topLeft: Radius.circular(15)),
                          border: controller.selectedIndex == index
                              ? Border.all(color: Colors.redAccent, width: 2)
                              : null,
                        ),
                        child: Text(
                          messages[index],
                          style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold),
                        ),
                      ),
                    );

                  },),


              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30,left: 10,right: 10),
              child: Row(

                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.textController,
                      decoration: InputDecoration(

                        hintText: "Write Something in Echo...",

                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                      height: 52,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: IconButton(onPressed: controller.addMessage, icon: Icon(Icons.add,color: Colors.white,)))
                ],
              ),
            ),
          ],
        ),
      );
    });

  }
}
