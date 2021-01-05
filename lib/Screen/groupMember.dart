import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/Screen/contactDetail.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

class GroupMemberScreen extends StatefulWidget {
  final GroupModel group;
  final List<UserModel> members;
  final List<Members> groupMembers;
  GroupMemberScreen(this.group, this.members, this.groupMembers);
  @override
  _GroupMemberState createState() =>
      new _GroupMemberState(group, members, groupMembers);
}

class _GroupMemberState extends State<GroupMemberScreen> {
  _GroupMemberState(this.group, this.members, this.groupMembers);
  GroupModel group;
  List<Members> groupMembers;
  List<UserModel> members;
  List<UserModel> filteredMembers = [];
  DatabaseService databaseService;
  Map<int, String> memberType = {1: "Member", 2: "Admin"};
  int selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
  }

  void handleSelectMemberType() {
    filteredMembers = [];
    if (selectedIndex == 1) {
      filteredMembers = members.where((element) =>
          element.userId ==
          groupMembers
              .where((groupMember) =>
                  groupMember.userId == element.userId &&
                  groupMember.isActive == true &&
                  groupMember.role == 1)
              .first
              .userId);
    } else {
      filteredMembers = members.where((element) =>
          element.userId ==
          groupMembers
              .where((groupMember) =>
                  groupMember.userId == element.userId &&
                  groupMember.isActive == true &&
                  groupMember.role == 2)
              .first
              .userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Member",
          style: TextStyle(color: colorBlack),
        ),
        leading: BackButton(
          color: colorBlack,
        ),
        backgroundColor: colorMainBG,
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: buildMemberType(),
            ),
            ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(context, filteredMembers[index]),
              itemCount: filteredMembers.length,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, UserModel member) {
    ContactModel contact = new ContactModel(
        nickname: member.nickname,
        photoUrl: member.photoUrl,
        userId: member.userId);
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                settings: RouteSettings(name: "/contact/detail"),
                builder: (context) => ContactDetailPage(contact)));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Material(
            child: member.photoUrl != null || member.photoUrl.isNotEmpty
                ? CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                      width: 40.0,
                      height: 40.0,
                      padding: EdgeInsets.all(10.0),
                    ),
                    imageUrl: member.photoUrl,
                    width: 40.0,
                    height: 40.0,
                    fit: BoxFit.cover,
                  )
                : Icon(
                    Icons.account_circle,
                    size: 40.0,
                    color: Colors.grey,
                  ),
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            clipBehavior: Clip.hardEdge,
          ),
          Container(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              member.nickname,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildMemberType() {
    List<Widget> typeList = [];
    for (MapEntry<int, String> type in memberType.entries) {
      Widget button = FlatButton(
        height: 24,
        minWidth: MediaQuery.of(context).size.width / 2.4,
        onPressed: () {
          setState(() {
            selectedIndex = type.key;
          });
        },
        child: Text(type.value),
        color: selectedIndex == type.key ? Color(0xffAAAAAA) : colorMainBG,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(width: 1, color: Color(0xffAAAAAA)),
        ),
      );
      typeList.add(button);
    }
    return typeList;
  }
}
