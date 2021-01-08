import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/Screen/contactDetail.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  String alert = "";

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    handleSelectMemberType();
  }

  void handleSelectMemberType() {
    filteredMembers = [];
    if (selectedIndex == 1) {
      for (int i = 0; i < groupMembers.length; i++) {
        if (groupMembers[i].role == 1 && groupMembers[i].isActive) {
          filteredMembers.add(members
              .where((element) => element.userId == groupMembers[i].userId)
              .first);
        }
      }
    } else {
      for (int i = 0; i < groupMembers.length; i++) {
        if (groupMembers[i].role == 2 && groupMembers[i].isActive) {
          filteredMembers.add(members
              .where((element) => element.userId == groupMembers[i].userId)
              .first);
        }
      }
    }
    setState(() {});
  }

  void removeMember(UserModel member) async {
    Members memberToBeRemove = groupMembers[
        groupMembers.indexWhere((element) => element.userId == member.userId)];
    memberToBeRemove.isActive = false;
    groupMembers[groupMembers.indexWhere(
        (element) => element.userId == member.userId)] = memberToBeRemove;
    await databaseService.updateGroupField({
      "membersList": groupMembers
          .map<Map<String, dynamic>>((member) => member.toMap())
          .toList()
    }, group.groupId).then((value) {
      alert = "success";
      handleSelectMemberType();
      _alertDialog(context, member);
    }).catchError((onError) {
      Fluttertoast.showToast(msg: onError.toString());
    });
  }

  Future<void> _alertDialog(
      BuildContext parentContext, UserModel member) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext bc, StateSetter setDialogState) {
          return CustomAlertDialog(
            title: alert == "success" ? "Success" : "Alert",
            bodyTitle: alert.isNotEmpty ? alert : "",
            bodySubtitle: "",
            icon: alert == "success"
                ? Icon(Icons.check_circle, size: 60, color: colorGreen)
                : Icon(Icons.warning, size: 60, color: colorRed),
            bodyAction: [
              Visibility(
                visible: alert != "success",
                child: LoginButton(
                  margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
                  color: colorBlue,
                  borderColor: colorBlue,
                  borderRadius: 4,
                  text: "Cancel",
                  onClick: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              LoginButton(
                margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
                color: alert == "success" ? colorGreen : colorRed,
                borderColor: alert == "success" ? colorGreen : colorRed,
                borderRadius: 4,
                text: alert == "success" ? "Back" : "Confirm",
                onClick: () {
                  if (alert == "success") {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                    removeMember(member);
                  }
                },
              ),
            ],
          );
        });
      },
    );
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
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) =>
                    buildItem(context, filteredMembers[index]),
                itemCount: filteredMembers.length,
              ),
            )
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
    return Container(
        margin: EdgeInsets.only(top: 12),
        padding: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Color(0xffEFEFEF),
                    width: 1,
                    style: BorderStyle.solid))),
        height: 48,
        child: Row(
          children: [
            InkWell(
              onTap: () => member.userId == databaseService.user.userId
                  ? null
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          settings: RouteSettings(name: "/contact/detail"),
                          builder: (context) =>
                              ContactDetailPage(contact, true))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Material(
                    child: member.photoUrl != null || member.photoUrl.isNotEmpty
                        ? CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
            Spacer(),
            (groupMembers
                        .where((element) =>
                            element.userId == databaseService.user.userId)
                        .first
                        .role ==
                    2)
                ? IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      alert = "Do you want to remove " + member.nickname + "?";
                      _alertDialog(context, member);
                    })
                : Container(),
          ],
        ));
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
            handleSelectMemberType();
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
