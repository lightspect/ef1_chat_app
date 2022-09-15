import 'package:chat_app_ef1/core/utils/color_utils.dart';
import 'package:chat_app_ef1/Model/navigationModel.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:chat_app_ef1/presentation/controller/navigation/navigation_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatelessWidget {
  DatabaseService? databaseService = locator<DatabaseService>();

  NavigationController _controller = Get.find<NavigationController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavigationController>(builder: (context) {
      return WillPopScope(
        onWillPop: () async => _controller
            .onWillPop()
            .then((value) => databaseService!.setFirestoreStatus({
                  "state": 'offline',
                  "last_changed": FieldValue.serverTimestamp(),
                }, databaseService!.user!.userId)),
        child: Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: _controller.listScreen[_controller.selectedIndex.value],
            switchInCurve: Curves.fastLinearToSlowEaseIn,
            switchOutCurve: Curves.linear,
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: colorBlack,
            unselectedItemColor: Colors.grey,
            backgroundColor: colorBlack,
            items: bottomNavigationBarItems(),
            currentIndex: _controller.selectedIndex.value,
            onTap: (int index) {
              _controller.handleIndexChange(index);
            },
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      );
    });
  }

  List<BottomNavigationBarItem> bottomNavigationBarItems() {
    List<BottomNavigationBarItem> navBarItem = [];
    for (int i = 0; i < _controller.screensName.length; i++) {
      navBarItem.add(BottomNavigationBarItem(
        icon: CircleAvatar(
          radius: 12,
          backgroundColor:
              _controller.selectedIndex.value == i ? Colors.white : colorBlack,
          child: _controller.screensIcon[i],
        ),
        label: _controller.screensName[i],
      ));
    }
    return navBarItem;
  }
}
