import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Screen/chat.dart';
import 'package:chat_app_ef1/Screen/chatGroup.dart';
import 'package:get/get.dart';

class NavigationService {
  Future<dynamic> navigateToChat(GroupModel group) {
    switch (group.type) {
      case 2:
        return Get.to(
          ChatGroupPage(group: group),
        )!;
      case 1:
        return Get.to(
          ChatPage(group: group),
        )!;
      default:
        return Get.to(
          ChatPage(group: group),
        )!;
    }
  }
}
