import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:flutter/material.dart';

class GroupMemberScreen extends StatefulWidget {
  final GroupModel group;
  final List<UserModel> members;
  GroupMemberScreen(this.group, this.members);
  @override
  _GroupMemberState createState() => new _GroupMemberState();
}

class _GroupMemberState extends State<GroupMemberScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
