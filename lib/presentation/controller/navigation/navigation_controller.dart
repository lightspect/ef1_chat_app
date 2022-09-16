import 'package:chat_app_ef1/Screen/contact.dart';
import 'package:chat_app_ef1/presentation/pages/home/home.dart';
import 'package:chat_app_ef1/Screen/message.dart';
import 'package:chat_app_ef1/Screen/wallet.dart';
import 'package:chat_app_ef1/core/helper/FCM_helper.dart';
import 'package:chat_app_ef1/core/widget/reusable_widget.dart';
import 'package:chat_app_ef1/data/repositories/user_repository_imp.dart';
import 'package:chat_app_ef1/domain/usecases/user_usecase.dart';
import 'package:chat_app_ef1/presentation/controller/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  List<Map<String, dynamic>> listScreen = [];
  var selectedIndex = 0.obs;
  PageController? pageController;

  UserUseCase _useCase = UserUseCase(repository: UserRepositoryImp());

  AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    listScreen = [
      {
        "screen": HomePage(),
        "label": 'My Profile',
        "icon": Icon(
          Icons.home,
          size: 16,
        ),
      },
      {
        "screen": MessagePage(),
        "label": 'Message',
        "icon": Icon(
          Icons.messenger,
          size: 16,
        ),
      },
      {
        "screen": WalletPage(),
        "label": 'Wallet',
        "icon": Icon(
          Icons.account_balance_wallet,
          size: 16,
        ),
      },
      {
        "screen": ContactPage(),
        "label": 'Contacts',
        "icon": Icon(
          Icons.group,
          size: 16,
        ),
      },
    ];
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
    if (selectedIndex.value != 0) {
      handleIndexChange(0);
      return false;
    } else {
      return await Get.dialog(ExitAlertDialog());
    }
  }

  updateUserStatus() {
    _useCase.updateUserStatus({
      "state": 'offline',
      "last_changed": FirebaseCloudMessageHelper.instance.serverTimestamp,
    }, _authController.user!.userId);
  }
}
