import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

class GroupMemberScreen extends StatefulWidget {
  final GroupModel group;
  final List<UserModel> members;
  GroupMemberScreen(this.group, this.members);
  @override
  _GroupMemberState createState() => new _GroupMemberState(group, members);
}

class _GroupMemberState extends State<GroupMemberScreen> {
  _GroupMemberState(this.group, this.members);
  GroupModel group;
  List<UserModel> members;
  DatabaseService databaseService;

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
