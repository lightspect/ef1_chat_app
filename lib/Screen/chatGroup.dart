import 'dart:io';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/loading.dart';
import 'package:chat_app_ef1/Common/my_icons.dart';
import 'package:chat_app_ef1/Common/photo.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/messagesModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/Screen/forward.dart';
import 'package:chat_app_ef1/Screen/groupDetail.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
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

class _ChatGroupPageState extends State<ChatGroupPage> {
  _ChatGroupPageState(this.group);
  SharedPreferences? prefs;
  DatabaseService? databaseService;
  final _chatController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  GroupModel? group;
  List<MessagesModel>? messages;
  List<UserModel>? members = [];

  MessagesModel replyMessage = new MessagesModel();
  bool hasContent = false;
  bool isLoading = false;
  bool replyVisibility = false;
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
    if (!databaseService!.groupMembersList.containsKey(group!.groupId)) {
      for (Members? member in group!.membersList!) {
        UserModel memberUser =
            await databaseService!.getUserById(member!.userId);
        members!.add(memberUser);
      }
      databaseService!.groupMembersList[group!.groupId] = members;
      print("Get Online");
    } else {
      members = databaseService!.groupMembersList[group!.groupId];
      print("Get Offline");
    }
    if (this.mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<GroupModel> getGroupData(String groupId) async {
    GroupModel groupModel = await databaseService!.getGroupById(groupId);
    return groupModel;
  }

  UserModel getMemberData(String sentId) {
    UserModel member = members!.firstWhere(
        ((element) => element.userId == sentId),
        orElse: () => new UserModel());
    if (member != null) {
      return member;
    } else {
      return new UserModel(nickname: "", photoUrl: "");
    }
  }

  Future<MessagesModel> getMessageData(String? id) async {
    MessagesModel message = new MessagesModel();
    message = await databaseService!.getMessageById(group!.groupId, id);
    return message;
  }

  void sendMessage(String message, int contentType) async {
    //type: 1 = Text, 2 = image, 3 = sticker, 4 = deleted
    //messageType: 1 = normal, 2 = forward, 3 = reply, 4 = notification
    _chatController.text = "";
    setState(() {
      hasContent = false;
    });
    listScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    if (message.trim() != "") {
      String dateTime = DateTime.now().toString();
      MessagesModel messagesModel = new MessagesModel(
        messageContent: message,
        sentAt: dateTime,
        sentBy: databaseService!.user!.userId,
        type: replyMessage.messageId!.isNotEmpty ? 3 : 1,
        contentType: contentType,
        replyTo:
            replyMessage.messageId!.isNotEmpty ? replyMessage.messageId : '',
      );
      await databaseService!
          .addMessage(messagesModel, group!.groupId)
          .then((value) => databaseService!.updateGroupField({
                'recentMessage': contentType == 2 ? "Photo" : message,
                'recentMessageSender': databaseService!.user!.userId,
                'recentMessageTime': dateTime,
              }, group!.groupId).catchError((onError) {
                Fluttertoast.showToast(msg: onError.toString());
              }))
          .catchError((onError) {
        Fluttertoast.showToast(msg: onError.toString());
      });
    }
    setState(() {
      replyMessage = new MessagesModel();
      replyVisibility = false;
    });
  }

  void openGallery() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;
    File? image;

    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      image = File(pickedFile.path);
    }

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

  Future uploadFile(File chatImageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;
    firebase_storage.Reference reference = storage.ref().child(fileName);
    firebase_storage.UploadTask uploadTask = reference.putFile(chatImageFile);
    firebase_storage.TaskSnapshot storageTaskSnapshot;
    uploadTask.then((value) {
      storageTaskSnapshot = value;
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
        group!.groupPhoto = downloadUrl;
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
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          settings: RouteSettings(name: "/chatGroup/detail"),
                          builder: (context) =>
                              GroupDetailPage(group, members))).then(
                      (value) async {
                    final arguments =
                        ModalRoute.of(context)!.settings.arguments as Map?;
                    bool result =
                        arguments != null ? arguments['addMember'] : false;
                    if (result) {
                      group = await getGroupData(group!.groupId);
                      getMemberList();
                      result = false;
                    }
                  });
                })
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
              if (isLoading) {
                return Future.value(false);
              } else {
                databaseService!.currentGroupId = "";
                return Future.value(true);
              }
            }));
  }

  Widget buildBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: Colors.grey,
            ),
          ),
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
                    return ListView.builder(
                      itemBuilder: (context, index) => GestureDetector(
                          onLongPress: () {
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
                                                  .sentAt
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
          Visibility(
            visible: replyVisibility,
            child: Container(
              color: Color(0xFFECEFF0),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Reply to ".replaceAll(" ", "\u00A0") +
                              (replyMessage.sentBy ==
                                      databaseService!.user!.userId
                                  ? "yourself"
                                  : members!
                                      .firstWhere(
                                          (element) =>
                                              element.userId ==
                                              replyMessage.sentBy,
                                          orElse: () => new UserModel())
                                      .nickname!),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          replyMessage.contentType == 2
                              ? "Photo"
                              : replyMessage.messageContent,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  replyMessage.contentType == 2
                      ? Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
                              ),
                              width: 20.0,
                              height: 20.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'assets/images/logo_1.png',
                                width: MediaQuery.of(context).size.width / 1.8,
                                height: 20.0,
                                fit: BoxFit.cover,
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: replyMessage.messageContent,
                            width: 20.0,
                            height: 20.0,
                            fit: BoxFit.cover,
                          ),
                          clipBehavior: Clip.hardEdge,
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          replyMessage = new MessagesModel();
                          replyVisibility = false;
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: colorBlack,
                        child: Icon(
                          Icons.close,
                          size: 12,
                        ),
                        radius: 8,
                      ),
                    ),
                  ),
                ],
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
    if (message.type == 4) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          (message.sentBy == databaseService!.user!.userId
                  ? "You"
                  : members!
                      .firstWhere((element) => element.userId == message.sentBy,
                          orElse: () => UserModel())
                      .nickname)! +
              " " +
              message.messageContent,
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else {
      if (message.sentBy == databaseService!.user!.userId) {
        // Right (my message)
        return Column(
          children: [
            buildForwardReply(message),
            ColumnSuper(
              children: [
                buildQuote(message),
                Row(
                  children: <Widget>[
                    message.contentType == 1 || message.contentType == 4
                        // Text
                        ? Container(
                            child: Text(
                              message.messageContent,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontStyle: message.contentType == 1
                                      ? FontStyle.normal
                                      : FontStyle.italic),
                            ),
                            padding:
                                EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                            width: MediaQuery.of(context).size.width / 1.8,
                            decoration: BoxDecoration(
                                color: splashBG,
                                borderRadius: BorderRadius.circular(18.0)),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
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
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.grey),
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.8,
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.8,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                      imageUrl: message.messageContent,
                                      width: MediaQuery.of(context).size.width /
                                          1.8,
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
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.all(0)),
                                ),
                                margin: EdgeInsets.only(
                                    bottom:
                                        isLastMessageRight(index) ? 20.0 : 10.0,
                                    right: 10.0),
                              )
                            // Sticker
                            : Container(),
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                )
              ],
              innerDistance: message.type == 3 ? -14 : 0,
            )
          ],
        );
      } else {
        // Left (peer message)
        return Container(
          child: Column(
            children: <Widget>[
              buildForwardReply(message),
              ColumnSuper(
                children: [
                  buildQuote(message),
                  Row(
                    children: <Widget>[
                      buildChatAvatar(message, index),
                      message.contentType == 1 || message.contentType == 4
                          ? Container(
                              child: Text(
                                message.messageContent,
                                style: TextStyle(
                                    color: colorBlack,
                                    fontStyle: message.contentType == 1
                                        ? FontStyle.normal
                                        : FontStyle.italic),
                              ),
                              padding:
                                  EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
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
                                        placeholder: (context, url) =>
                                            Container(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.grey),
                                          ),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.8,
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.8,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                        imageUrl: message.messageContent,
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => FullPhoto(
                                                  url:
                                                      message.messageContent)));
                                    },
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.all(0)),
                                  ),
                                  margin: EdgeInsets.only(left: 10.0),
                                )
                              : Container(),
                    ],
                  ),
                ],
                innerDistance: message.type == 3 ? -14 : 0,
              ),

              // Time
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        message.sentAt.substring(11, 16),
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                      margin:
                          EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                    )
                  : Container()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10.0),
        );
      }
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
          DateTime.parse(messages![index - 1].sentAt).day.toString() +
              "" +
              DateTime.parse(messages![index - 1].sentAt).month.toString() +
              "" +
              DateTime.parse(messages![index - 1].sentAt).year.toString();
      String currentDate =
          DateTime.parse(messages![index].sentAt).day.toString() +
              "" +
              DateTime.parse(messages![index].sentAt).month.toString() +
              "" +
              DateTime.parse(messages![index].sentAt).year.toString();
      if (currentDate != lastDate) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Widget buildForwardReply(MessagesModel message) {
    if (message.type == 2 || message.type == 3) {
      return Container(
        margin: EdgeInsets.only(left: 50, right: 15, bottom: 5),
        child: Row(
            mainAxisAlignment: message.sentBy == databaseService!.user!.userId
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Icon(
                message.type == 2 ? Icons.arrow_forward : Icons.reply,
                size: 14,
                color: Colors.grey,
              ),
              Flexible(
                child: Text(
                  members!.isNotEmpty
                      ? (message.sentBy == databaseService!.user!.userId
                          ? "You"
                          : getMemberData(message.sentBy).nickname!)
                      : "",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                message.type == 2 ? " forwarded a message" : " reply a message",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ]),
      );
    } else {
      return Container();
    }
  }

  Widget buildQuote(MessagesModel message) {
    if (message.type == 3) {
      return FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<MessagesModel> snap) {
          if (snap.hasData) {
            return Container(
              child: Row(
                children: <Widget>[
                  snap.data!.contentType == 1 || snap.data!.contentType == 4
                      // Text
                      ? Container(
                          child: Text(
                            snap.data!.messageContent,
                            style: TextStyle(
                                color: Colors.white,
                                fontStyle: snap.data!.contentType == 1
                                    ? FontStyle.normal
                                    : FontStyle.italic),
                            overflow: TextOverflow.ellipsis,
                          ),
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          margin:
                              message.sentBy == databaseService!.user!.userId
                                  ? EdgeInsets.only(right: 10)
                                  : EdgeInsets.only(left: 45),
                          width: MediaQuery.of(context).size.width / 2,
                          height: 48,
                          decoration: BoxDecoration(
                              color: Color(0xFF868B90),
                              borderRadius: message.sentBy ==
                                      databaseService!.user!.userId
                                  ? BorderRadius.only(
                                      bottomLeft: Radius.circular(18),
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18))
                                  : BorderRadius.only(
                                      bottomRight: Radius.circular(18),
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18))),
                        )
                      : snap.data!.contentType == 2
                          // Image
                          ? Container(
                              child: TextButton(
                                child: Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.grey),
                                      ),
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height: 100.0,
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
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        height: 100.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    imageUrl: snap.data!.messageContent,
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    height: 100.0,
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
                                              url: snap.data!.messageContent)));
                                },
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.all(0)),
                              ),
                              margin: message.sentBy ==
                                      databaseService!.user!.userId
                                  ? EdgeInsets.only(right: 10)
                                  : EdgeInsets.only(left: 45),
                            )
                          // Sticker
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
                mainAxisAlignment:
                    message.sentBy == databaseService!.user!.userId
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            );
          }
        },
        future: getMessageData(message.replyTo),
      );
    } else {
      return Container();
    }
  }

  Widget buildChatAvatar(MessagesModel message, int index) {
    if (isLastMessageLeft(index) || isLastMessageYesterday(index)) {
      if (members!.isNotEmpty) {
        if (getMemberData(message.sentBy).photoUrl!.isNotEmpty) {
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
              imageUrl: getMemberData(message.sentBy).photoUrl!,
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
    } else {
      return Container(
        width: 35,
      );
    }
  }

  void _settingModalBottomSheet(MessagesModel message, BuildContext context) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
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
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop();
                    replyMessage = message;
                    replyVisibility = true;
                  });
                },
              ),
              Visibility(
                visible: message.sentBy == databaseService!.user!.userId,
                child: IconButton(
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
      },
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
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
