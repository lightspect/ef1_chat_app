import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/Screen/createGroup.dart';
import 'package:chat_app_ef1/Screen/groupMember.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GroupDetailPage extends StatefulWidget {
  final GroupModel group;
  final List<UserModel> members;
  GroupDetailPage(this.group, this.members);
  @override
  State<StatefulWidget> createState() => _GroupDetailPageState(group, members);
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  _GroupDetailPageState(this.group, this.members);
  DatabaseService databaseService;
  final _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<UserModel> members;
  GroupModel group;
  String alert = '';

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    //contact = new ContactModel();
  }

  Future<void> _changeNicknameDialog() async {
    _nicknameController.text = "";
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Change Alias",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("New Alias"),
                        Container(
                          margin: EdgeInsets.only(top: 12, bottom: 16),
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter a new nickname";
                              }
                              return null;
                            },
                            cursorColor: colorBlue,
                            style: TextStyle(
                              color: colorBlack,
                              fontSize: 12.0,
                              letterSpacing: 1.2,
                            ),
                            decoration: InputDecoration(
                              hintText: "Alias",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: colorBlack),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: colorBlack),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: colorBlack),
                              ),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0,
                                letterSpacing: 1.2,
                              ),
                              isDense: true,
                            ),
                            controller: _nicknameController,
                            onFieldSubmitted: (value) {},
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            LoginButton(
                              margin: EdgeInsets.symmetric(vertical: 16),
                              height: 40,
                              minWidth: MediaQuery.of(context).size.width / 4,
                              color: colorMainBG,
                              borderColor: colorBlack,
                              borderRadius: 4,
                              text: "Cancel",
                              textColor: colorBlack,
                              onClick: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            LoginButton(
                              margin: EdgeInsets.symmetric(vertical: 16),
                              height: 40,
                              minWidth: MediaQuery.of(context).size.width / 4,
                              color: colorBlue,
                              borderColor: colorBlue,
                              borderRadius: 4,
                              text: "Save",
                              onClick: () {
                                var validate = _formKey.currentState.validate();
                                if (validate) {
                                  setState(() {
                                    group.groupName = _nicknameController.text;
                                  });
                                  handleUpdateGroupName();
                                  Navigator.of(context).pop();
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void handleAddMember() {}

  void handleUpdateGroupName() async {
    databaseService.updateGroup(group, group.groupId).then((value) {
      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) => Fluttertoast.showToast(msg: err.toString()));
  }

  void handleLeaveGroup() async {
    members.remove(databaseService.user.userId);
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(group.groupId)
        .update({'member': members}).then((value) {
      setState(() {
        alert = "success";
      });
      _alertDialog(context);
      databaseService.refreshMessageList();
    }).catchError((err) => Fluttertoast.showToast(msg: err.toString()));
  }

  Future<void> _alertDialog(BuildContext parentContext) async {
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
                    Navigator.of(parentContext).pop();
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                    handleLeaveGroup();
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
            Divider(
              color: Colors.grey,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                    width: 60.0,
                    height: 60.0,
                    padding: EdgeInsets.all(10.0),
                  ),
                  imageUrl: group.groupPhoto,
                  width: 60.0,
                  height: 60.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                clipBehavior: Clip.hardEdge,
              ),
            ),
            Text(group != null ? group.groupName : ""),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.search,
                            color: colorBlack,
                          ),
                          backgroundColor: Color(0xffE5E5E5),
                          radius: 15,
                        ),
                        Text(
                          "Search",
                          style: TextStyle(fontSize: 10),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: handleAddMember,
                          child: CircleAvatar(
                            child: Icon(
                              Icons.group_add,
                              color: colorBlack,
                            ),
                            backgroundColor: Color(0xffE5E5E5),
                            radius: 15,
                          ),
                        ),
                        Text(
                          "Message",
                          style: TextStyle(fontSize: 10),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Column(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.notifications,
                            color: colorBlack,
                          ),
                          backgroundColor: Color(0xffE5E5E5),
                          radius: 15,
                        ),
                        Text(
                          "Notification",
                          style: TextStyle(fontSize: 10),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            InkWell(
                onTap: () {
                  _changeNicknameDialog();
                },
                child: Container(
                  height: 28,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.edit,
                        color: colorBlack,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 40),
                        child: Text("Edit group Name"),
                      ),
                    ],
                  ),
                )),
            Divider(),
            InkWell(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              GroupMemberScreen(group, members)));
                },
                child: Container(
                  height: 28,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.group,
                        color: colorBlack,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 40),
                        child: Text("All Member"),
                      ),
                    ],
                  ),
                )),
            Divider(),
            InkWell(
                onTap: () {
                  setState(() {
                    alert = "Do you want to leave the group?";
                  });
                  _alertDialog(context);
                },
                child: Container(
                  height: 28,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.logout,
                        color: colorBlack,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 40),
                        child: Text("Leave Group"),
                      ),
                    ],
                  ),
                )),
            Divider(),
          ],
        ),
      ),
    );
  }
}
