import 'dart:io';

import 'package:chat_app_ef1/Model/navigationService.dart';
import 'package:chat_app_ef1/data/repositories/group_repository_imp.dart';
import 'package:chat_app_ef1/data/repositories/user_repository_imp.dart';
import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/domain/usecases/group_usecase.dart';
import 'package:chat_app_ef1/domain/usecases/user_usecase.dart';
import 'package:chat_app_ef1/presentation/controller/auth/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class FirebaseCloudMessageHelper {
  FirebaseCloudMessageHelper._();

  static final FirebaseCloudMessageHelper instance =
      FirebaseCloudMessageHelper._();
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? deviceToken;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  UserUseCase userUseCase = UserUseCase(repository: UserRepositoryImp());
  GroupUseCase groupUseCase = GroupUseCase(repository: GroupRepositoryImp());

  NavigationService navigationService = NavigationService();

  AuthController authController = Get.put(AuthController());

  registerNotification() {
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((event) {
      print('onMessage: ' + event.data.toString());
      var notification = (Platform.isAndroid
          ? event.data['notification']
          : event.data['aps']['alert']) as Map?;
      var data = event.data['data'] as Map;
      String groupId = data['groupId'].toString();
      String messageType = data['type'].toString();
      if (messageType == "newMessage") {
        if (groupId != authController.currentGroupId &&
            !authController.user!.offNotification!.containsKey(groupId)) {
          showNotification(notification, groupId);
        } else if (authController.user!.offNotification!.containsKey(groupId)) {
          if (authController.user!.offNotification![groupId].isNotEmpty) {
            if (DateTime.now().isAfter(DateTime.parse(
                authController.user!.offNotification![groupId]))) {
              authController.user!.offNotification!.remove(groupId);
              userUseCase.updateUser(
                  {"offNotification": authController.user!.offNotification},
                  authController.user!.userId);
              showNotification(notification, groupId);
            }
          }
        }
      } else if (messageType == "addMember") {
        List<UserModel>? groupMemberList =
            authController.groupMembersList[groupId];
        List<dynamic> newMembersData = data['result'].toList();
        List<UserModel> newMembers = newMembersData
            .map<UserModel>((member) => UserModel.fromMap(member))
            .toList();
        for (UserModel member in newMembers) {
          groupMemberList!.add(member);
        }
        authController.groupMembersList[groupId] = groupMemberList;
      }
      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      var data = event.data['data'] as Map;
      String groupId = data['groupId'].toString();
      selectNotification(groupId);
      print('onResume: $event.$data');
      return;
    });
    FirebaseMessaging.onBackgroundMessage((message) async {
      var data = message.data['data'] as Map;
      String groupId = data['groupId'].toString();
      selectNotification(groupId);
      print('onLaunch: $message.$data');
      return;
    });

    FirebaseMessaging.instance.getToken().then((token) {
      print('token: $token');
      deviceToken = token;
    }).catchError((err) {
      print(err);
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  registerBackgroundMessage(
      Future<void> Function(RemoteMessage message) backgroundMessage) {
    FirebaseMessaging.onBackgroundMessage(backgroundMessage);
  }

  void configLocalNotification() async {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future selectNotification(String? payload) async {
    if (payload != null) {
      print('notification payload: $payload');
      GroupModel? group = await groupUseCase.getGroupById(payload);
      if (group?.type == 1) {
        group = groupUseCase.generateGroupMessage(group!);
      }
      if (authController.currentGroupId.isNotEmpty) {
        Get.back();
      }
      navigationService.navigateToChat(group!);
    }
  }

  void showNotification(message, payload) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.example.chat_app_ef1'
          : 'com.example.chatAppEf1',
      'Flutter chat demo',
      channelDescription: 'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
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

  FieldValue getServerTimestamp() {
    return FieldValue.serverTimestamp();
  }
}
