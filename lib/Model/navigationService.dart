import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Screen/chat.dart';
import 'package:chat_app_ef1/Screen/chatGroup.dart';
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
  Future<dynamic> navigateToChat(GroupModel group) {
    switch (group.type) {
      case 2:
        return navigatorKey.currentState!.push(MaterialPageRoute(
            builder: (context) => ChatGroupPage(group: group)));
      case 1:
        return navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (context) => ChatPage(group: group)));
      default:
        return navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (context) => ChatPage(group: group)));
    }
  }
}
