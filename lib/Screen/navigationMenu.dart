import 'dart:io';

import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/navigationModel.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/navigationService.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatefulWidget {
  final String currentUserId;

  static const route = '/';

  NavigationMenu({Key key, this.currentUserId}) : super(key: key);

  @override
  State createState() => NavigationMenuState(currentUserId: currentUserId);
}

class NavigationMenuState extends State<NavigationMenu> {
  NavigationMenuState({Key key, this.currentUserId});

  final String currentUserId;
  DatabaseService databaseService;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    registerNotification();
    configLocalNotification();
  }

  void registerNotification() {
    databaseService.firebaseMessaging.requestNotificationPermissions();

    databaseService.firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      var notification = (Platform.isAndroid
          ? message['notification']
          : message['aps']['alert']) as Map;
      var data = message['data'] as Map;
      String groupId = data['groupId'].toString();
      if (groupId != databaseService.currentGroupId) {
        showNotification(notification, groupId);
      }
      return;
    }, onResume: (Map<String, dynamic> message) {
      var data = message['data'] as Map;
      String groupId = data['groupId'].toString();
      selectNotification(groupId);
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      var data = message['data'] as Map;
      String groupId = data['groupId'].toString();
      selectNotification(groupId);
      print('onLaunch: $message');
      return;
    });
    databaseService.firebaseMessaging.getToken().then((token) {
      print('token: $token');
      FirebaseFirestore.instance
          .collection('users')
          .doc(databaseService.user.userId)
          .update({'token': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() async {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
      GroupModel group = await databaseService.getGroupById(payload);
      if (group.type == 1) {
        group = await databaseService.generateGroupMessage(group);
      }
      if (databaseService.currentGroupId.isNotEmpty) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      locator<NavigationService>().navigateToChat(group);
    }
  }

  void showNotification(message, payload) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.example.chat_app_ef1'
          : 'com.example.chatAppEf1',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    print(message);
//    print(message['body'].toString());
//    print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: payload);

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
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
                onWillPop: () async => provider.onWillPop(context),
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
