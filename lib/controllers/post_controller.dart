import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../user_data_model/userMessage.dart';

class PostController extends GetxController{
  final textController = TextEditingController();
  final userMessage = userMessageStack<dynamic>();
  int? selectedIndex;


  void addMessage(){
    final text = textController.text.trim();
    if(text.isNotEmpty){

        userMessage.Push(text);
        textController.clear();
        update();


    }
  }
}