import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/messagesModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/Screen/chatSearch.dart';
import 'package:chat_app_ef1/Screen/groupAdd.dart';
import 'package:chat_app_ef1/Screen/groupMember.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class GroupDetailPage extends StatefulWidget {
  final GroupModel group;
  final List<UserModel> members;
  GroupDetailPage(this.group, this.members);
  @override
  State<StatefulWidget> createState() => _GroupDetailPageState(group, members);
}

enum OffNotificationTime { minutes10, hour1, hour8, hour24, forever }

class _GroupDetailPageState extends State<GroupDetailPage> {
  _GroupDetailPageState(this.group, this.members);
  DatabaseService databaseService;
  final _nicknameController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  OffNotificationTime _time = OffNotificationTime.minutes10;

  bool isLoading = false;
  File avatarImageFile;
  List<UserModel> members;
  GroupModel group;
  String alert = '';

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    if (databaseService.user.offNotification.containsKey(group.groupId)) {
      if (databaseService.user.offNotification[group.groupId].isNotEmpty) {
        if (DateTime.now().isAfter(DateTime.parse(
            databaseService.user.offNotification[group.groupId]))) {
          databaseService.user.offNotification.remove(group.groupId);
          setState(() {});
        }
      }
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
            "Change Group Name",
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
                        Text("New Group Name"),
                        Container(
                          margin: EdgeInsets.only(top: 12, bottom: 16),
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter a new group name";
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
                              hintText: "Group Name",
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
                              if (value.isEmpty) {
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
                                var validate = _formKey.currentState.validate();
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
                            onChanged: (OffNotificationTime value) {
                              radioListState(() {
                                _time = value;
                              });
                            },
                          ),
                          RadioListTile<OffNotificationTime>(
                            title: const Text('1 hour'),
                            value: OffNotificationTime.hour1,
                            groupValue: _time,
                            onChanged: (OffNotificationTime value) {
                              radioListState(() {
                                _time = value;
                              });
                            },
                          ),
                          RadioListTile<OffNotificationTime>(
                            title: const Text('8 hours'),
                            value: OffNotificationTime.hour8,
                            groupValue: _time,
                            onChanged: (OffNotificationTime value) {
                              radioListState(() {
                                _time = value;
                              });
                            },
                          ),
                          RadioListTile<OffNotificationTime>(
                            title: const Text('24 hours'),
                            value: OffNotificationTime.hour24,
                            groupValue: _time,
                            onChanged: (OffNotificationTime value) {
                              radioListState(() {
                                _time = value;
                              });
                            },
                          ),
                          RadioListTile<OffNotificationTime>(
                            title: const Text('Until I turn back on'),
                            value: OffNotificationTime.forever,
                            groupValue: _time,
                            onChanged: (OffNotificationTime value) {
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
                                      _formKey.currentState.validate();
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

  void handleTurnOffNotification() async {
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
      databaseService.user.offNotification[group.groupId] = "";
    } else {
      databaseService.user.offNotification[group.groupId] =
          DateTime.now().add(duration).toString();
    }
    databaseService.updateUserField(
        {"offNotification": databaseService.user.offNotification},
        databaseService.user.userId);
    setState(() {});
  }

  void handleMessageSearch() async {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        settings: RouteSettings(name: "/chatGroup/detail/search"),
        builder: (context) =>
            ChatSearchScreen(_messageController.text, group, members)));
  }

  void handleUpdateGroupName() async {
    await databaseService.updateGroupField(
        {"groupName": group.groupName}, group.groupId).then((value) {
      databaseService
          .groups[databaseService.groups
              .indexWhere((element) => element.groupId == group.groupId)]
          .groupName = group.groupName;
      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) => Fluttertoast.showToast(msg: err.toString()));
  }

  void handleLeaveGroup() async {
    Members memberToBeRemove = group.membersList[group.membersList.indexWhere(
        (element) => element.userId == databaseService.user.userId)];
    memberToBeRemove.isActive = false;
    group.membersList[group.membersList.indexWhere(
            (element) => element.userId == databaseService.user.userId)] =
        memberToBeRemove;
    await databaseService.updateGroupField({
      'membersList': group.membersList
          .map<Map<String, dynamic>>((member) => member.toMap())
          .toList()
    }, group.groupId).then((value) {
      setState(() {
        alert = "success";
      });
      _alertDialog(context);
      databaseService.refreshMessageList();
    }).catchError((err) => Fluttertoast.showToast(msg: err.toString()));
    MessagesModel message = new MessagesModel(
        messageContent: "has left the group",
        contentType: 1,
        type: 4,
        sentAt: DateTime.now().toString(),
        sentBy: databaseService.user.userId);
    await databaseService.addMessage(message, group.groupId);
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
                    Navigator.of(context, rootNavigator: true)
                        .popUntil(ModalRoute.withName('/navigationMenu'));
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

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;
    File image;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      image = File(pickedFile.path);
    }

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = group.groupId;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          group.groupPhoto = downloadUrl;
          databaseService.updateGroup(group, group.groupId).then((data) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Upload success");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              child: Center(
                child: InkWell(
                    borderRadius: BorderRadius.circular(60),
                    onTap: getImage,
                    child: groupPhoto()),
              ),
            ),
            Text(
              group != null ? group.groupName : "",
              style: TextStyle(fontSize: 16),
            ),
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
                        InkWell(
                          onTap: () {
                            _searchMessageDialog();
                          },
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
                          "  Search\nMessage",
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
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AddMemberPage(
                                      groupId: group.groupId,
                                      members: group.membersList,
                                    )));
                          },
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
                          " Add\nMember",
                          style: TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            if (databaseService.user.offNotification
                                .containsKey(group.groupId)) {
                              databaseService.user.offNotification
                                  .remove(group.groupId);
                              databaseService.updateUserField({
                                "offNotification":
                                    databaseService.user.offNotification
                              }, databaseService.user.userId);
                              setState(() {});
                            } else {
                              _offNotificationDialog();
                            }
                          },
                          child: CircleAvatar(
                            child: Icon(
                              databaseService.user.offNotification
                                      .containsKey(group.groupId)
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
                          settings:
                              RouteSettings(name: "/chatGroup/detail/members"),
                          builder: (context) => GroupMemberScreen(
                              group, members, group.membersList)));
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

  Widget groupPhoto() {
    if (group.groupPhoto.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 30,
        child: Icon(
          Icons.group,
          size: 60.0,
          color: Colors.white,
        ),
      );
    } else if (avatarImageFile == null) {
      return Material(
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
      );
    } else {
      return Material(
        child: Image.file(
          avatarImageFile,
          width: 60.0,
          height: 60.0,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(60.0)),
        clipBehavior: Clip.hardEdge,
      );
    }
  }
}
