import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/emoji_menu.dart';
import 'package:chat_app_ef1/Common/loading.dart';
import 'package:chat_app_ef1/Common/my_icons.dart';
import 'package:chat_app_ef1/Common/photo.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/messagesModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/Screen/forward.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatGroupPage extends StatefulWidget {
  const ChatGroupPage({Key? key, this.group}) : super(key: key);

  final GroupModel? group;

  static const route = '/message/chat';

  @override
  _ChatGroupPageState createState() => _ChatGroupPageState(group);
}

class _ChatGroupPageState extends State<ChatGroupPage> with CustomPopupMenu {
  _ChatGroupPageState(this.group);
  SharedPreferences? prefs;
  DatabaseService? databaseService;
  final _chatController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  PersistentBottomSheetController? controller;

  final GroupModel? group;
  List<MessagesModel>? messages;
  List<UserModel> members = [];

  bool hasContent = false;
  bool isLoading = false;
  int limit = 20;
  final limitIncrease = 20;

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    listScrollController.addListener(_scrollListener);
    getMemberList();
    databaseService!.currentGroupId = group!.groupId;
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        limit += limitIncrease;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  void getMemberList() async {
    setState(() {
      isLoading = true;
    });
    for (String? id in group!.members as Iterable<String?>) {
      UserModel userModel = await databaseService!.getUserById(id);
      members.add(userModel);
    }
    setState(() {
      isLoading = false;
    });
  }

  void sendMessage(String message, int contentType) async {
    //type: 1 = Text, 2 = image, 3 = sticker, 4 = deleted
    _chatController.text = "";
    setState(() {
      hasContent = false;
    });
    if (message.trim() != "") {
      String dateTime = DateTime.now().toString();
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(group!.groupId)
          .collection("messages")
          .doc()
          .set({
            'messageContent': message,
            'sentAt': dateTime,
            'sentBy': databaseService!.user!.userId,
            'type': 1,
            'contentType': contentType
          })
          .then((value) => FirebaseFirestore.instance
                  .collection('groups')
                  .doc(group!.groupId)
                  .update({
                'recentMessage': contentType == 2 ? "Photo" : message,
                'recentMessageSender': databaseService!.user!.userId,
                'recentMessageTime': dateTime,
              }).catchError((onError) {
                Fluttertoast.showToast(msg: onError.toString());
              }))
          .catchError((onError) {
            Fluttertoast.showToast(msg: onError.toString());
          });
    }
  }

  void openGallery() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    File image = File(pickedFile!.path);
    if (image != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(image);
    }
  }

  void forwardMessage(MessagesModel message) {
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (context) => ForwardMessagePage(
              message: message,
            )));
  }

  void showEmojiMenu() {
    this.showMenu(
      context: context,
      items: <PopupMenuEntry<int>>[PlusMinusEntry()],
    ).then((value) {
      if (value == null) {
        //Navigator.of(context).pop();
        return;
      }
      if (controller != null) {
        controller!.close();
        controller = null;
      }
    });
  }

  Future uploadFile(File chatImageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(chatImageFile);
    TaskSnapshot storageTaskSnapshot;
    uploadTask.then((value) {
      storageTaskSnapshot = value;
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
        setState(() {
          isLoading = false;
          sendMessage(downloadUrl, 2);
        });
      }, onError: (err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      });
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
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Material(
                  child: group!.groupPhoto != ""
                      ? CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                            width: 50.0,
                            height: 50.0,
                            padding: EdgeInsets.all(15.0),
                          ),
                          imageUrl: group!.groupPhoto!,
                          width: 50.0,
                          height: 50.0,
                          fit: BoxFit.cover,
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 25,
                          child: Icon(
                            Icons.group,
                            size: 50.0,
                            color: Colors.white,
                          ),
                        ),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      group!.groupName!,
                      style: TextStyle(color: colorBlack),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          leading: BackButton(
            color: colorBlack,
          ),
          actions: [
            IconButton(
                icon: Icon(
                  MyIcon.ellipsis_v,
                  size: 24,
                  color: colorBlack,
                ),
                onPressed: () {})
          ],
          backgroundColor: colorMainBG,
          elevation: 0,
        ),
        body: WillPopScope(
            child: Stack(
              children: [
                buildBody(),
                buildLoading(),
              ],
            ),
            onWillPop: () {
              databaseService!.currentGroupId = "";
              return Future.value(true);
            }));
  }

  Widget buildBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Divider(),
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder(
                stream: databaseService!
                    .fetchMessagesAsStreamPagination(group!.groupId, limit),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    );
                  } else {
                    messages = snapshot.data!.docs
                        .map((doc) => MessagesModel.fromMap(
                            doc.data() as Map<dynamic, dynamic>?, doc.id))
                        .toList();
                    messages!.sort((element1, element2) {
                      if (DateTime.parse(element1.sentAt!)
                          .isAfter(DateTime.parse(element2.sentAt!))) {
                        return -1;
                      } else {
                        return 1;
                      }
                    });
                    return ListView.builder(
                      itemBuilder: (context, index) => GestureDetector(
                          onTapDown: storePosition,
                          onLongPress: () {
                            showEmojiMenu();
                            _settingModalBottomSheet(messages![index], context);
                          },
                          child: Column(
                            children: [
                              buildItem(index, messages![index]),
                              isLastMessageYesterday(index)
                                  ? Container(
                                      height: 40,
                                      child: Align(
                                        child: Container(
                                          width: 160,
                                          decoration: BoxDecoration(
                                            color: colorBlue,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10.0)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              messages![index - 1]
                                                  .sentAt!
                                                  .substring(0, 10),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          )),
                      reverse: true,
                      controller: listScrollController,
                      itemCount: messages!.length,
                    );
                  }
                },
              ),
            ),
          ),
          Container(
            color: Color(0xFFECEFF0),
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 120,
                    child: TextFormField(
                      cursorColor: colorBlue,
                      style: TextStyle(
                        color: colorBlack,
                        fontSize: 14.0,
                        letterSpacing: 1.2,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Text Message",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                          letterSpacing: 1.2,
                        ),
                        isDense: true,
                      ),
                      controller: _chatController,
                      onFieldSubmitted: (value) {},
                      onChanged: (value) {
                        if (_chatController.text.trim().isEmpty) {
                          setState(() {
                            hasContent = false;
                          });
                        } else {
                          setState(() {
                            hasContent = true;
                          });
                        }
                      },
                    ),
                  ),
                  Ink(
                    child: InkWell(
                      onTap: () {},
                      child: Icon(
                        Icons.emoji_emotions,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                  Ink(
                    child: InkWell(
                      onTap: () {
                        hasContent
                            ? sendMessage(_chatController.text, 1)
                            : openGallery();
                      },
                      child: Icon(
                        hasContent ? Icons.send : Icons.photo,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const Loading() : Container(),
    );
  }

  Widget buildItem(int index, MessagesModel message) {
    if (message.sentBy == databaseService!.user!.userId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          message.contentType == 1
              // Text
              ? Column(
                  children: [
                    Container(
                      child: Text(
                        message.messageContent!,
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      width: MediaQuery.of(context).size.width / 1.8,
                      decoration: BoxDecoration(
                          color: splashBG,
                          borderRadius: BorderRadius.circular(18.0)),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
                  ],
                )
              : message.contentType == 2
                  // Image
                  ? Container(
                      child: TextButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
                              ),
                              width: MediaQuery.of(context).size.width / 1.8,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'assets/images/logo_1.png',
                                width: MediaQuery.of(context).size.width / 1.8,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: message.messageContent!,
                            width: MediaQuery.of(context).size.width / 1.8,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FullPhoto(url: message.messageContent)));
                        },
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  // Sticker
                  : message.contentType == 4
                      ? Container(
                          child: Text(
                            message.messageContent!,
                            style: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic),
                          ),
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          width: MediaQuery.of(context).size.width / 1.8,
                          decoration: BoxDecoration(
                              color: splashBG,
                              borderRadius: BorderRadius.circular(18.0)),
                          margin: EdgeInsets.only(
                              bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                              right: 10.0),
                        )
                      : Container(
                          /*child: Image.asset(
                        message.messageContent,
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                          margin: EdgeInsets.only(
                              bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                              right: 10.0),*/
                          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                buildChatAvatar(message),
                message.contentType == 1
                    ? Container(
                        child: Text(
                          message.messageContent!,
                          style: TextStyle(color: colorBlack),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: MediaQuery.of(context).size.width / 1.8,
                        decoration: BoxDecoration(
                            color: Color(0xffE6E5E5),
                            borderRadius: BorderRadius.circular(18.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : message.contentType == 2
                        ? Container(
                            child: TextButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.grey),
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width / 1.8,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      'assets/images/logo_1.png',
                                      width: MediaQuery.of(context).size.width /
                                          1.8,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: message.messageContent!,
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                            url: message.messageContent)));
                              },
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : message.contentType == 4
                            ? Container(
                                child: Text(
                                  message.messageContent!,
                                  style: TextStyle(
                                      color: colorBlack,
                                      fontStyle: FontStyle.italic),
                                ),
                                padding:
                                    EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                                width: MediaQuery.of(context).size.width / 1.8,
                                decoration: BoxDecoration(
                                    color: Color(0xffE6E5E5),
                                    borderRadius: BorderRadius.circular(8.0)),
                                margin: EdgeInsets.only(left: 10.0),
                              )
                            : Container(
                                /*child: Image.asset(
                        message.messageContent,
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                                margin: EdgeInsets.only(
                                    bottom:
                                        isLastMessageRight(index) ? 20.0 : 10.0,
                                    right: 10.0),*/
                                ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      message.sentAt!,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            messages != null &&
            (messages![index - 1].sentBy == databaseService!.user!.userId ||
                messages![index].sentBy != messages![index - 1].sentBy)) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            messages != null &&
            messages![index - 1].sentBy != databaseService!.user!.userId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageYesterday(int index) {
    if (messages!.isNotEmpty && index > 0) {
      String lastDate =
          DateTime.parse(messages![index - 1].sentAt!).day.toString() +
              "" +
              DateTime.parse(messages![index - 1].sentAt!).month.toString() +
              "" +
              DateTime.parse(messages![index - 1].sentAt!).year.toString();
      String currentDate =
          DateTime.parse(messages![index].sentAt!).day.toString() +
              "" +
              DateTime.parse(messages![index].sentAt!).month.toString() +
              "" +
              DateTime.parse(messages![index].sentAt!).year.toString();
      if (currentDate != lastDate) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Widget buildChatAvatar(MessagesModel message) {
    if (members.isNotEmpty) {
      if (members
              .firstWhere(((element) => element.userId == message.sentBy),
                  orElse: () => new UserModel())
              .photoUrl !=
          null) {
        return Material(
          child: CachedNetworkImage(
            placeholder: (context, url) => Container(
              child: CircularProgressIndicator(
                strokeWidth: 1.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
              width: 35.0,
              height: 35.0,
              padding: EdgeInsets.all(10.0),
            ),
            imageUrl: members
                .where((element) => element.userId == message.sentBy)
                .first
                .photoUrl!,
            width: 35.0,
            height: 35.0,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(18.0),
          ),
          clipBehavior: Clip.hardEdge,
        );
      }
    }
    return Icon(
      Icons.account_circle,
      size: 35.0,
      color: Colors.grey,
    );
  }

  void _settingModalBottomSheet(MessagesModel message, BuildContext context) {
    FocusScope.of(context).unfocus();
    controller = Scaffold.of(context).showBottomSheet(
      (context) {
        return StatefulBuilder(
            builder: (BuildContext bc, StateSetter setSheetState) {
          return SingleChildScrollView(
              child: Container(
            height: 56,
            color: Color(0xFFECEFF0),
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.reply,
                    color: Colors.grey,
                    size: 36,
                  ),
                  onPressed: null,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.grey,
                    size: 36,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deleteConfirmBottomSheet(message);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.fast_forward,
                    color: Colors.grey,
                    size: 36,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    forwardMessage(message);
                  },
                ),
              ],
            ),
          ));
        });
      },
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
      //isScrollControlled: true,
    );
  }

  void _deleteConfirmBottomSheet(MessagesModel message) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext bc, StateSetter setSheetState) {
            return SingleChildScrollView(
                child: Container(
              height: 56,
              color: colorBlack,
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      message.contentType = 4;
                      message.messageContent = "This message has been deleted";
                      databaseService!.updateMessage(
                          message, group!.groupId, message.messageId);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 36,
                        ),
                        Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.cancel,
                          color: Colors.white,
                          size: 36,
                        ),
                        Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ));
          });
        }).whenComplete(() {});
  }
}

class PlusMinusEntry extends PopupMenuEntry<int> {
  @override
  final double height = 60;

  // height doesn't matter, as long as we are not giving
  // initialValue to showMenu().

  @override
  bool represents(int? n) => n == 1 || n == 2 || n == 3 || n == 4 || n == 5;

  @override
  PlusMinusEntryState createState() => PlusMinusEntryState();
}

class PlusMinusEntryState extends State<PlusMinusEntry> {
  void _love() {
    // This is how you close the popup menu and return user selection.
    Navigator.pop<int>(context, 1);
  }

  void _happy() {
    Navigator.pop<int>(context, 2);
  }

  void _surprise() {
    Navigator.pop<int>(context, 3);
  }

  void _sad() {
    Navigator.pop<int>(context, 4);
  }

  void _angry() {
    Navigator.pop<int>(context, 5);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: TextButton(
                onPressed: _love,
                child: Text(
                  '❤',
                  style: TextStyle(fontSize: 15),
                ))),
        Expanded(
            child: TextButton(
                onPressed: _happy,
                child: Text(
                  '😂',
                  style: TextStyle(fontSize: 15),
                ))),
        Expanded(
            child: TextButton(
                onPressed: _surprise,
                child: Text(
                  '😮',
                  style: TextStyle(fontSize: 15),
                ))),
        Expanded(
            child: TextButton(
                onPressed: _sad,
                child: Text(
                  '😢',
                  style: TextStyle(fontSize: 15),
                ))),
        Expanded(
            child: TextButton(
                onPressed: _angry,
                child: Text(
                  '😠',
                  style: TextStyle(fontSize: 15),
                ))),
      ],
    );
  }
}
