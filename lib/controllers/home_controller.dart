import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/bst.dart';
import '../models/echo.dart';


class HomeController extends GetxController {
  final textController = TextEditingController();
  final foundUser = Rxn<BSTNode>(); // null = not searched yet
  final errorMessage = RxString('');

  void searchUser(String username) {
    final result = Echo.instance.bst.search(username.trim());

    if (result == null) {
      foundUser.value = null;
      errorMessage.value = 'User not found';
    } else {
      foundUser.value = result;
      errorMessage.value = '';
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
