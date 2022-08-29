import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/core/utils/color_utils.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/core/widget/reusable_widget.dart';
import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/Screen/chat.dart';
import 'package:chat_app_ef1/Screen/chatSearch.dart';
import 'package:chat_app_ef1/Screen/createGroup.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ContactDetailPage extends StatefulWidget {
  final ContactModel? contact;
  final GroupModel? groupChat;
  final bool chatDetail;
  ContactDetailPage(this.contact, this.groupChat, this.chatDetail);
  @override
  State<StatefulWidget> createState() =>
      _ContactDetailPageState(contact, groupChat, chatDetail);
}

enum OffNotificationTime { minutes10, hour1, hour8, hour24, forever }

class _ContactDetailPageState extends State<ContactDetailPage> {
  _ContactDetailPageState(this.contact, this.groupChat, this.chatDetail);
  DatabaseService? databaseService;
  QuerySnapshot? checkGroupResult;
  final _nicknameController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  OffNotificationTime? _time = OffNotificationTime.minutes10;

  ContactModel? contact;
  UserModel? contactUser;
  GroupModel? privateChat, groupChat;
  Members? currentUser, peerUser;
  String alert = '';
  bool chatDetail;
  String action = "";

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    getContactDetail();
    if (privateChatExist()) {
      privateChat = databaseService!.groups!
          .where((element) =>
              element.type == 1 &&
              element.membersList!
                  .any((member) => member!.userId == contact!.userId))
          .first;
    } else {
      privateChat = new GroupModel();
    }
    currentUser = new Members(
        userId: databaseService!.user!.userId, isActive: true, role: 1);
  }

  void getContactDetail() async {
    contactUser = await databaseService!.getUserById(contact!.userId);
    if (contact!.photoUrl != contactUser!.photoUrl &&
        contact!.photoUrl!.isNotEmpty) {
      contact!.photoUrl = contactUser!.photoUrl;
      await databaseService!
          .setContact(contact!, databaseService!.user!.userId, contact!.userId);
      databaseService!.contacts![databaseService!.contacts!
              .indexWhere((element) => element!.userId == contact!.userId)] =
          contact;
      //TODO
      //await databaseService!.setContactsList();
    }
    if (contactUser == null) {
      alert = 'Error getting user information';
      _alertDialog(context, () => goBackUntil("", false), "Alert", alert,
          Icon(Icons.warning, size: 60, color: colorRed), false, colorRed);
    }
    setState(() {});
  }

  bool checkUserAdmin(String? userId) {
    if (groupChat!.membersList!
            .firstWhere(
              (element) => element!.userId == userId,
              orElse: () => Members(),
            )!
            .role ==
        2) {
      return true;
    } else
      return false;
  }

  bool inContact() {
    if (databaseService!.contacts!
        .where((element) => element!.userId == contact!.userId)
        .isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  bool privateChatExist() {
    bool check = false;
    for (GroupModel groupModel in databaseService!.groups!) {
      if (groupModel.type == 1) {
        for (Members? member in groupModel.membersList!) {
          if (member!.userId == contact!.userId) {
            check = true;
            break;
          }
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
    _nicknameController.text = contact!.nickname!;
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
                              if (value!.isEmpty) {
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
                                var validate =
                                    _formKey.currentState!.validate();
                                if (validate) {
                                  setState(() {
                                    contact!.nickname =
                                        _nicknameController.text;
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

  Future<void> _searchMessageDialog() async {
    _messageController.text = "";
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Search Message",
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
                        Text("Enter Keyword"),
                        Container(
                          margin: EdgeInsets.only(top: 12, bottom: 16),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter a keyword to search for message";
                              } else if (value.length < 2) {
                                return "Please enter more than 1 letter to search";
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
                              hintText: "Keyword",
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
                            controller: _messageController,
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
                              text: "Search",
                              onClick: () {
                                var validate =
                                    _formKey.currentState!.validate();
                                if (validate) {
                                  Navigator.of(context).pop();
                                  handleMessageSearch();
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

  Future<void> _offNotificationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Turn off notification",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  child: Form(
                    key: _formKey,
                    child: StatefulBuilder(
                      builder: (context, radioListState) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RadioListTile<OffNotificationTime>(
                            title: const Text('10 minutes'),
                            value: OffNotificationTime.minutes10,
                            groupValue: _time,
                            onChanged: (OffNotificationTime? value) {
                              radioListState(() {
                                _time = value;
                              });
                            },
                          ),
                          RadioListTile<OffNotificationTime>(
                            title: const Text('1 hour'),
                            value: OffNotificationTime.hour1,
                            groupValue: _time,
                            onChanged: (OffNotificationTime? value) {
                              radioListState(() {
                                _time = value;
                              });
                            },
                          ),
                          RadioListTile<OffNotificationTime>(
                            title: const Text('8 hours'),
                            value: OffNotificationTime.hour8,
                            groupValue: _time,
                            onChanged: (OffNotificationTime? value) {
                              radioListState(() {
                                _time = value;
                              });
                            },
                          ),
                          RadioListTile<OffNotificationTime>(
                            title: const Text('24 hours'),
                            value: OffNotificationTime.hour24,
                            groupValue: _time,
                            onChanged: (OffNotificationTime? value) {
                              radioListState(() {
                                _time = value;
                              });
                            },
                          ),
                          RadioListTile<OffNotificationTime>(
                            title: const Text('Until I turn back on'),
                            value: OffNotificationTime.forever,
                            groupValue: _time,
                            onChanged: (OffNotificationTime? value) {
                              radioListState(() {
                                _time = value;
                              });
                            },
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
                                  var validate =
                                      _formKey.currentState!.validate();
                                  if (validate) {
                                    handleTurnOffNotification();
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void handleTurnOffNotification() {
    String timeOff = _time.toString().split(".")[1];
    Duration duration = new Duration(days: 0);
    switch (timeOff) {
      case "minutes10":
        duration = Duration(minutes: 10);
        break;
      case "hour1":
        duration = Duration(hours: 1);
        break;
      case "hour8":
        duration = Duration(hours: 8);
        break;
      case "hour24":
        duration = Duration(hours: 24);
        break;
      default:
        duration = new Duration(days: 0);
        break;
    }
    if (timeOff == "forever") {
      databaseService!.user!.offNotification![privateChat!.groupId] = "";
    } else {
      databaseService!.user!.offNotification![privateChat!.groupId] =
          DateTime.now().add(duration).toString();
      databaseService!.updateUserField(
          {"offNotification": databaseService!.user!.offNotification},
          databaseService!.user!.userId);
    }
    setState(() {});
  }

  void handleMessageSearch() async {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        settings: RouteSettings(name: "/message/detail/search"),
        builder: (context) => ChatSearchScreen(_messageController.text,
            privateChat, [contactUser, databaseService!.user])));
  }

  void handleUpdateNickName() async {
    await databaseService!
        .updateContact(contact!, databaseService!.user!.userId, contact!.userId)
        .then((value) async {
      databaseService!.contacts![databaseService!.contacts!
              .indexWhere((element) => element!.userId == contact!.userId)] =
          contact;
      //TODO
      //await databaseService!.setContactsList();
      Fluttertoast.showToast(msg: "Update success");
      databaseService!.refreshMessageList();
      setState(() {
        action = "change";
      });
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleRemoveFromContact() async {
    databaseService!
        .removeContact(databaseService!.user!.userId, contact!.userId)
        .then((value) {
      setState(() {
        databaseService!.contacts!
            .removeWhere((element) => element!.userId == contact!.userId);
        //TODO
        //databaseService!.setContactsList();
        databaseService!.fetchOnlineStatusAsStream();
        alert = "Success";
      });
      _alertDialog(context, () {
        if (groupChat != null) {
          goBackUntil("/chatGroup/detail/members", false);
        } else {
          setState(() {
            action = "remove";
          });
        }
      },
          "Removed successfully",
          alert,
          Icon(Icons.check_circle, size: 60, color: colorGreen),
          false,
          colorGreen);
      databaseService!.refreshMessageList();
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleCreateGroupMessage() async {
    peerUser = new Members(userId: contact!.userId, isActive: true, role: 1);
    await databaseService!.refreshMessageList();
    if (!privateChatExist()) {
      List<Members?> membersList = [peerUser, currentUser];
      privateChat = new GroupModel(
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
          createdBy: databaseService!.user!.userId,
          membersList: membersList,
          groupId: "",
          groupName: "",
          groupPhoto: "",
          recentMessageContent: "",
          recentMessageSender: "",
          recentMessageTime: "",
          type: 1);
      DocumentReference groupDocRef =
          await databaseService!.addGroup(privateChat!);
      await groupDocRef.update({'groupId': groupDocRef.id}).then((value) {
        privateChat!.groupId = groupDocRef.id;
        privateChat!.groupName = contact!.nickname;
        privateChat!.groupPhoto = contact!.photoUrl;
        if (groupChat != null) {
          goBackUntil("/navigationMenu", false);
        } else {
          Navigator.of(context).pop();
        }
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
            builder: (context) => ChatPage(group: privateChat)));
      });
      databaseService!.refreshMessageList();
    } else {
      privateChat!.groupName = contact!.nickname;
      privateChat!.groupPhoto = contact!.photoUrl;
      if (groupChat != null) {
        goBackUntil("/navigationMenu", false);
      } else {
        Navigator.of(context).pop();
      }
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
          builder: (context) => ChatPage(group: privateChat)));
    }
  }

  void handleAddNewContact() async {
    ContactModel newContact = new ContactModel(
        userId: contact!.userId,
        nickname: contactUser!.nickname,
        photoUrl: contactUser!.photoUrl);
    await databaseService!
        .setContact(newContact, databaseService!.user!.userId, contact!.userId)
        .then((value) {
      setState(() {
        databaseService!.contacts!.add(newContact);
        //TODO
        //databaseService!.setContactsList();
      });
      Fluttertoast.showToast(msg: "Add Contact Successfully");
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
    await databaseService!.refreshMessageList();
    if (groupChat != null) {
      goBackUntil("/chatGroup/detail/members", false);
    } else {
      setState(() {
        action = "add";
      });
    }
  }

  void handleChangeMemberRole() async {
    if (checkUserAdmin(contact!.userId)) {
      groupChat!
          .membersList![groupChat!.membersList!
              .indexWhere((element) => element!.userId == contact!.userId)]!
          .role = 1;
    } else {
      groupChat!
          .membersList![groupChat!.membersList!
              .indexWhere((element) => element!.userId == contact!.userId)]!
          .role = 2;
    }
    await databaseService!.updateGroupField({
      "membersList": groupChat!.membersList!
          .map<Map<String, dynamic>>((member) => member!.toMap())
          .toList()
    }, groupChat!.groupId).then((value) {
      setState(() {
        alert = "Change Role successfully";
      });
      _alertDialog(
          context,
          Navigator.of(context).pop,
          "Update successfully",
          alert,
          Icon(Icons.check_circle, size: 60, color: colorGreen),
          false,
          colorGreen);
      databaseService!.refreshMessageList();
      setState(() {});
    });
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
          inContact()
              ? databaseService!.contacts!
                  .firstWhere((element) => element!.userId == contact!.userId,
                      orElse: () => ContactModel())!
                  .nickname!
              : (contactUser != null ? contactUser!.nickname! : ""),
          style: TextStyle(color: colorBlack),
        ),
        leading: BackButton(
          color: colorBlack,
        ),
        backgroundColor: colorMainBG,
        elevation: 0,
      ),
      body: WillPopScope(
        onWillPop: () {
          Map<String, dynamic> arguments = {};
          arguments["action"] = action;
          if (action == "remove") {
            arguments["data"] = new ContactModel(
                userId: contact!.userId,
                nickname: contact!.userId,
                photoUrl: "");
          } else if (action == "add") {
            arguments["data"] = new ContactModel(
                userId: contact!.userId,
                nickname: contactUser!.nickname,
                photoUrl: contactUser!.photoUrl);
          } else {
            arguments["data"] = new ContactModel(
                userId: contact!.userId,
                nickname: contact!.nickname,
                photoUrl: contactUser!.photoUrl);
          }
          Navigator.of(context).pop(arguments);
          return Future.value(false);
        },
        child: SingleChildScrollView(
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
                    child: contactUser != null
                        ? CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
                              ),
                              width: 60.0,
                              height: 60.0,
                              padding: EdgeInsets.all(10.0),
                            ),
                            imageUrl: contact!.photoUrl!,
                            width: 60.0,
                            height: 60.0,
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.account_circle,
                            size: 60.0,
                            color: Colors.grey,
                          ),
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                ),
                Text(contactUser != null ? contactUser!.nickname! : ""),
                Text(contactUser != null ? contactUser!.aboutMe : "",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    )),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      privateChatExist()
                          ? SizedBox(
                              width: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: _searchMessageDialog,
                                    child: CircleAvatar(
                                      child: Icon(
                                        Icons.search,
                                        color: colorBlack,
                                      ),
                                      backgroundColor: Color(0xffE5E5E5),
                                      radius: 15,
                                    ),
                                  ),
                                  Text(
                                    "Search",
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              ),
                            )
                          : Container(),
                      inContact()
                          ? (!chatDetail
                              ? SizedBox(
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
                                )
                              : Container())
                          : SizedBox(
                              width: 100,
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      alert = "Add " +
                                          contact!.nickname! +
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
                            ),
                      privateChatExist()
                          ? SizedBox(
                              width: 100,
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (databaseService!
                                          .user!.offNotification!
                                          .containsKey(privateChat!.groupId)) {
                                        databaseService!.user!.offNotification!
                                            .remove(privateChat!.groupId);
                                        databaseService!.updateUserField({
                                          "offNotification": databaseService!
                                              .user!.offNotification
                                        }, databaseService!.user!.userId);
                                        setState(() {});
                                      } else {
                                        _offNotificationDialog();
                                      }
                                    },
                                    child: CircleAvatar(
                                      child: Icon(
                                        databaseService!.user!.offNotification!
                                                .containsKey(
                                                    privateChat!.groupId)
                                            ? Icons.notifications_off
                                            : Icons.notifications,
                                        color: colorBlack,
                                      ),
                                      backgroundColor: Color(0xffE5E5E5),
                                      radius: 15,
                                    ),
                                  ),
                                  Text(
                                    "Notification",
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Visibility(
                    visible: inContact(),
                    child: Column(
                      children: [
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
                        groupChat != null
                            ? (checkUserAdmin(databaseService!.user!.userId)
                                ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        alert = checkUserAdmin(contact!.userId)
                                            ? "Do you want to change this User Role to Member?"
                                            : "Do you want to promote this Member to Admin?";
                                      });
                                      _alertDialog(
                                          context,
                                          handleChangeMemberRole,
                                          "Notice",
                                          alert,
                                          Icon(
                                            Icons.info,
                                            size: 60,
                                            color: colorBlue,
                                          ),
                                          true,
                                          colorBlue);
                                    },
                                    child: Container(
                                      height: 28,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.group_add,
                                            color: colorBlack,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 40),
                                            child: Text(
                                                checkUserAdmin(contact!.userId)
                                                    ? "Demote to Member"
                                                    : "Promote to Group Admin"),
                                          ),
                                        ],
                                      ),
                                    ))
                                : Container())
                            : InkWell(
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
                        groupChat != null
                            ? (checkUserAdmin(databaseService!.user!.userId)
                                ? Divider()
                                : Container())
                            : Divider(),
                        InkWell(
                            onTap: () {
                              setState(() {
                                alert =
                                    "You are about to delete this contact. Continue?";
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
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
