import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/Screen/chat.dart';
import 'package:chat_app_ef1/Screen/createGroup.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ContactDetailPage extends StatefulWidget {
  final ContactModel contact;
  final bool fromGroup;
  ContactDetailPage(this.contact, this.fromGroup);
  @override
  State<StatefulWidget> createState() =>
      _ContactDetailPageState(contact, fromGroup);
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  _ContactDetailPageState(this.contact, this.fromGroup);
  DatabaseService databaseService;
  QuerySnapshot checkGroupResult;
  final _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ContactModel contact;
  UserModel contactUser;
  String alert = '';
  bool fromGroup;
  Members currentUser, peerUser;

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    getContactDetail();
    currentUser = new Members(
        userId: databaseService.user.userId, isActive: true, role: 1);
  }

  void getContactDetail() async {
    contactUser = await databaseService.getUserById(contact.userId);
    if (contactUser == null) {
      alert = 'Error getting user information';
      _alertDialog(context, () => goBackUntil("", false), "Alert", alert,
          Icon(Icons.warning, size: 60, color: colorRed), false, colorRed);
    }
    setState(() {});
  }

  Future<bool> inContact() async {
    ContactModel contactModel = await databaseService.getContactById(
        databaseService.user.userId, contact.userId);
    if (contactModel.userId.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> groupChatExist() async {
    bool check = false;
    for (GroupModel group in databaseService.groups) {
      if (group.type == 1) {
        if (group.membersList.any((element) {
          return element.userId == contact.userId;
        })) {
          check = true;
          break;
        }
      }
    }
    return check;
  }

  void goBackUntil(String route, bool rootNavigation) {
    if (route.isEmpty) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context, rootNavigator: rootNavigation)
          .popUntil(ModalRoute.withName(route));
    }
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
                                    contact.nickname = _nicknameController.text;
                                  });
                                  handleUpdateNickName();
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

  void handleUpdateNickName() async {
    databaseService
        .updateContact(contact, databaseService.user.userId, contact.userId)
        .then((value) {
      Fluttertoast.showToast(msg: "Update success");
      databaseService.refreshMessageList();
    }).catchError((err) => Fluttertoast.showToast(msg: err.toString()));
  }

  void handleRemoveFromContact() async {
    databaseService
        .removeContact(databaseService.user.userId, contact.userId)
        .then((value) {
      setState(() {
        alert = "Success";
      });
      _alertDialog(
          context,
          () => fromGroup
              ? goBackUntil("/chatGroup/detail/members", false)
              : goBackUntil("/contact", false),
          "Removed successfully",
          alert,
          Icon(Icons.check_circle, size: 60, color: colorGreen),
          false,
          colorGreen);
      databaseService.refreshMessageList();
    }).catchError((err) => Fluttertoast.showToast(msg: err.toString()));
  }

  void handleCreateGroupMessage() async {
    peerUser = new Members(userId: contact.userId, isActive: true, role: 1);
    if (!databaseService.groups.any((element) =>
        element.type == 1 &&
        element.membersList.any((member) => member.userId == contact.userId))) {
      List<Members> membersList = [peerUser, currentUser];
      GroupModel group = new GroupModel(
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
          createdBy: databaseService.user.userId,
          membersList: membersList,
          groupId: "",
          groupName: "",
          groupPhoto: "",
          recentMessageContent: "",
          recentMessageSender: "",
          recentMessageTime: "",
          type: 1);
      DocumentReference groupDocRef = await databaseService.addGroup(group);
      await groupDocRef.update({'groupId': groupDocRef.id}).then((value) {
        group.groupId = groupDocRef.id;
        group.groupName = contact.nickname;
        group.groupPhoto = contact.photoUrl;
        Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (context) => ChatPage(group: group)));
      });
      databaseService.refreshMessageList();
    } else {
      GroupModel group = databaseService.groups
          .where((element) =>
              element.type == 1 &&
              element.membersList
                  .any((member) => member.userId == contact.userId))
          .first;
      print(group.groupId);
      group.groupName = contact.nickname;
      group.groupPhoto = contact.photoUrl;
      Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => ChatPage(group: group)));
    }
  }

  void handleAddNewContact() async {
    await databaseService
        .setContact(contact, databaseService.user.userId, contact.userId)
        .then(
            (value) => Fluttertoast.showToast(msg: "Add Contact Successfully"))
        .catchError((err) => Fluttertoast.showToast(msg: err.toString()));
    goBackUntil("/chatGroup/detail/members", false);
    databaseService.refreshMessageList();
  }

  Future<void> _alertDialog(
      BuildContext parentContext,
      Function function,
      String title,
      String alert,
      Icon icon,
      bool secondButtonVisibility,
      Color buttonColor) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext bc, StateSetter setDialogState) {
          return CustomAlertDialog(
            title: title,
            bodyTitle: alert,
            bodySubtitle: "",
            icon: icon,
            bodyAction: [
              Visibility(
                visible: secondButtonVisibility,
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
                color: buttonColor,
                borderColor: buttonColor,
                borderRadius: 4,
                text: "Confirm",
                onClick: () {
                  Navigator.of(context).pop();
                  function();
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
          contact.nickname,
          style: TextStyle(color: colorBlack),
        ),
        leading: BackButton(
          color: colorBlack,
        ),
        backgroundColor: colorMainBG,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
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
                    imageUrl: contact.photoUrl,
                    width: 60.0,
                    height: 60.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  clipBehavior: Clip.hardEdge,
                ),
              ),
              Text(contactUser != null ? contactUser.nickname : ""),
              Text(contactUser != null ? contactUser.aboutMe : "",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  )),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder(
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snap) {
                        if (snap.hasData) {
                          if (snap.data) {
                            return SizedBox(
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
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                      future: groupChatExist(),
                    ),
                    FutureBuilder(
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snap) {
                        if (snap.hasData) {
                          if (snap.data) {
                            return SizedBox(
                              width: 100,
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: handleCreateGroupMessage,
                                    child: CircleAvatar(
                                      child: Icon(
                                        Icons.message,
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
                            );
                          } else {
                            return SizedBox(
                              width: 100,
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      alert = "Add " +
                                          contact.nickname +
                                          " to contact?";
                                      _alertDialog(
                                          context,
                                          () => handleAddNewContact(),
                                          "Add to Contact",
                                          "Do you want to add this person to contact?",
                                          Icon(Icons.info,
                                              size: 60, color: colorBlue),
                                          true,
                                          colorBlue);
                                    },
                                    child: CircleAvatar(
                                      child: Icon(
                                        Icons.add_circle_outline,
                                        color: colorBlack,
                                      ),
                                      backgroundColor: Color(0xffE5E5E5),
                                      radius: 15,
                                    ),
                                  ),
                                  Text(
                                    "Add to Contact",
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              ),
                            );
                          }
                        } else {
                          return Container();
                        }
                      },
                      future: fromGroup ? inContact() : Future.value(true),
                    ),
                    FutureBuilder(
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snap) {
                        if (snap.hasData) {
                          if (snap.data) {
                            return SizedBox(
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
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                      future: groupChatExist(),
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
                          child: Text("Change Name"),
                        ),
                      ],
                    ),
                  )),
              Divider(),
              InkWell(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true)
                        .push(MaterialPageRoute(
                            builder: (context) => CreateGroupPage(
                                  contact: contact,
                                )));
                  },
                  child: Container(
                    height: 28,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.group_add,
                          color: colorBlack,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 40),
                          child: Text("Add to Group"),
                        ),
                      ],
                    ),
                  )),
              Divider(),
              InkWell(
                  onTap: () {
                    setState(() {
                      alert = "You are about to delete this contact. Continue?";
                    });
                    _alertDialog(
                        context,
                        () => handleRemoveFromContact(),
                        "Alert",
                        alert,
                        Icon(Icons.info, size: 60, color: colorRed),
                        true,
                        colorBlue);
                  },
                  child: Container(
                    height: 28,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.delete,
                          color: colorBlack,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 40),
                          child: Text("Remove from Contact"),
                        ),
                      ],
                    ),
                  )),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
