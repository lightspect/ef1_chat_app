import 'package:chat_app_ef1/Screen/contact.dart';
import 'package:chat_app_ef1/Screen/home.dart';
import 'package:chat_app_ef1/Screen/message.dart';
import 'package:chat_app_ef1/Screen/wallet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  List<Widget> listScreen = [];
  var selectedIndex = 0.obs;
  PageController? pageController;

  @override
  void onInit() {
    super.onInit();
    listScreen = [
      HomePage(),
      MessagePage(),
      WalletPage(),
      ContactPage(),
    ];
    pageController = PageController(initialPage: 0);
  }

  handleIndexChange(int index) {
    selectedIndex.value = index;
    if (pageController?.hasClients == true) {
      pageController?.jumpToPage(index);
    }
  }
}
