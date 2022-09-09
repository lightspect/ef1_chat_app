import 'package:chat_app_ef1/core/utils/color_utils.dart';
import 'package:chat_app_ef1/Model/navigationModel.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatefulWidget {
  static const route = '/';

  NavigationMenu({Key? key}) : super(key: key);

  @override
  State createState() => NavigationMenuState();
}

class NavigationMenuState extends State<NavigationMenu> {
  NavigationMenuState();

  DatabaseService? databaseService;

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ],
        child: Builder(builder: (context) {
          return Consumer<NavigationProvider>(
            builder: (context, provider, child) {
              // Create bottom navigation bar items from screens.
              List<BottomNavigationBarItem> bottomNavigationBarItems() {
                List<BottomNavigationBarItem> navBarItem = [];
                for (int i = 0; i < provider.screens.length; i++) {
                  navBarItem.add(BottomNavigationBarItem(
                    icon: CircleAvatar(
                      radius: 12,
                      backgroundColor: provider.currentTabIndex == i
                          ? Colors.white
                          : colorBlack,
                      child: provider.screens[i].icon,
                    ),
                    label: provider.screens[i].title,
                  ));
                }
                return navBarItem;
              }

              // Initialize [Navigator] instance for each screen.
              final screens = provider.screens
                  .map(
                    (screen) => Navigator(
                      key: screen.navigatorState,
                      onGenerateRoute: screen.onGenerateRoute,
                    ),
                  )
                  .toList();

              return WillPopScope(
                onWillPop: () async => provider
                    .onWillPop(context)
                    .then((value) => databaseService!.setFirestoreStatus({
                          "state": 'offline',
                          "last_changed": FieldValue.serverTimestamp(),
                        }, databaseService!.user!.userId)),
                child: Scaffold(
                  body: IndexedStack(
                    children: screens,
                    index: provider.currentTabIndex,
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    selectedItemColor: colorBlack,
                    unselectedItemColor: Colors.grey,
                    backgroundColor: colorBlack,
                    items: bottomNavigationBarItems(),
                    currentIndex: provider.currentTabIndex,
                    onTap: (int index) {
                      provider.setTab(index);
                    },
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    type: BottomNavigationBarType.fixed,
                  ),
                ),
              );
            },
          );
        }));
  }
}
