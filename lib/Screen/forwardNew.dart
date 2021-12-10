import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/messagesModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForwardMessagePage extends StatefulWidget {
  const ForwardMessagePage({Key? key, this.message}) : super(key: key);

  final MessagesModel? message;

  static const route = '/message';

  @override
  _ForwardMessagePageState createState() => _ForwardMessagePageState(message);
}

class _ForwardMessagePageState extends State<ForwardMessagePage> {
  final _searchController = TextEditingController();
  final MessagesModel? message;
  //final _debouncer = Debouncer(milliseconds: 500);
  DatabaseService? databaseService;

  List<GroupModel>? groups = [];

  _ForwardMessagePageState(this.message);

  List<String> id = [];

  Map<GroupModel, bool> groupsMap = {};

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    databaseService!.refreshMessageList();
    getGroups();
  }

  void search(String search) {}

  void getGroups() {
    databaseService!
        .fetchGroupsByUserId(databaseService!.user!.userId)
        .then((value) async => setState(() {
              groups = value;
              for (int i = 0; i < groups!.length; i++) {
                generateGroupMessage(groups![i]).then((value) => setState(() {
                      groups![i] = value;
                    }));
              }
              groups!.forEach((element) {
                groupsMap[element] = false;
              });
            }));
  }

  Future<ContactModel> getContactDetail(List<dynamic> members) async {
    members.removeWhere(
        (element) => element.userId == databaseService!.user!.userId);
    ContactModel contactModel = await databaseService!.getContactById(
        databaseService!.user!.userId, members.first.userId);
    if (contactModel != null && contactModel.userId!.isNotEmpty) {
      return contactModel;
    } else {
      return new ContactModel(
          userId: members.first.userId, nickname: "", photoUrl: "");
    }
  }

  Future<GroupModel> generateGroupMessage(GroupModel group) async {
    if (group.type == 1) {
      ContactModel contactModel = await getContactDetail(group.membersList!);
      group.groupName = contactModel.nickname!.isNotEmpty
          ? contactModel.nickname
          : contactModel.userId;
      group.groupPhoto = contactModel.photoUrl;
    }
    return group;
  }

  void sendMessage(String groupId, String message, int contentType) async {
    //type: 1 = Text, 2 = image, 3 = sticker, 4 = deleted
    if (message.trim() != "") {
      String dateTime = DateTime.now().toString();
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(groupId)
          .collection("messages")
          .doc()
          .set({
        'messageContent': message,
        'sentAt': dateTime,
        'sentBy': databaseService!.user!.userId,
        'type': 1,
        'contentType': contentType
      }).then((value) {
        FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .update({
              'recentMessage': contentType == 2 ? "Photo" : message,
              'recentMessageSender': databaseService!.user!.userId,
              'recentMessageTime': dateTime,
            })
            .then((value) => setState(() {}))
            .catchError((onError) {
              Fluttertoast.showToast(msg: onError.toString());
            });
      }).catchError((onError) {
        Fluttertoast.showToast(msg: onError.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Send",
          style: TextStyle(color: colorBlack),
        ),
        backgroundColor: colorMainBG,
        leading: BackButton(
          color: colorBlack,
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16),
        margin: EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Container(
              child: TextFormField(
                cursorColor: colorBlue,
                style: TextStyle(
                  color: colorBlack,
                  fontSize: 14.0,
                  letterSpacing: 1.2,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search",
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
                    fontSize: 14.0,
                    letterSpacing: 1.2,
                  ),
                  isDense: true,
                ),
                controller: _searchController,
                onFieldSubmitted: (value) {
                  search(value);
                },
                onChanged: (value) {
                  search(value);
                },
              ),
            ),
            Flexible(
                child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) {
                return buildItem(context, groups![index], groupsMap);
              },
              itemCount: groups!.length,
            )),
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, GroupModel group, Map groupsMap) {
    if (group.recentMessageContent == '') {
      return Container();
    } else {
      return Column(
        children: [
          Container(
            child: Row(
              children: <Widget>[
                Material(
                  child: group.groupPhoto!.isNotEmpty
                      ? CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                            width: 60.0,
                            height: 60.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: group.groupPhoto!,
                          width: 60.0,
                          height: 60.0,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.account_circle,
                          size: 50.0,
                          color: Colors.grey,
                        ),
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                SizedBox(
                  width: 150,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          group.groupName!,
                          style: TextStyle(
                              color: colorBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          group.recentMessageContent,
                          style: TextStyle(
                              color: Colors.grey, fontSize: 10, height: 1.6),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 12.0),
                  ),
                ),
                Spacer(),
                LoginButton(
                  text: "Send",
                  onClick: () {
                    if (!groupsMap[group]) {
                      sendMessage(group.groupId, message!.messageContent,
                          message!.contentType);
                      groupsMap[group] = true;
                    }
                  },
                  color: groupsMap[group] ? colorMainBG : colorLightGreen,
                  textColor: groupsMap[group] ? Colors.grey : Colors.white,
                  minWidth: 56,
                  height: 20,
                  borderRadius: 10,
                  borderColor: groupsMap[group] ? Colors.grey : colorLightGreen,
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
        ],
      );
    }
  }
}
