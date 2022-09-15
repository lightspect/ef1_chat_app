import 'package:chat_app_ef1/Screen/contact.dart';
import 'package:chat_app_ef1/Screen/home.dart';
import 'package:chat_app_ef1/Screen/message.dart';
import 'package:chat_app_ef1/Screen/wallet.dart';
import 'package:chat_app_ef1/core/widget/reusable_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  List<Widget> listScreen = [];
  List<String> screensName = [];
  List<Icon> screensIcon = [];
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
    screensIcon = [
      Icon(
        Icons.home,
        size: 16,
      ),
      Icon(
        Icons.messenger,
        size: 16,
      ),
      Icon(
        Icons.account_balance_wallet,
        size: 16,
      ),
      Icon(
        Icons.group,
        size: 16,
      ),
    ];
    screensName = ['My Profile', 'Message', 'Wallet', 'Contact'];
    pageController = PageController(initialPage: 0);
  }

  handleIndexChange(int index) {
    selectedIndex.value = index;
    if (pageController?.hasClients == true) {
      pageController?.jumpToPage(index);
    }
  }

  /// Provide this to [WillPopScope] callback.
  Future<bool?> onWillPop() async {
    //final currentNavigatorState = currentScreen!.navigatorState.currentState!;
    var temp = false;
    if (temp /*currentNavigatorState.canPop()*/) {
      //currentNavigatorState.pop();
      return false;
    } else {
      if (selectedIndex.value != 0) {
        handleIndexChange(0);
        return false;
      } else {
        return await Get.dialog(ExitAlertDialog());
      }
    }
  }
}
