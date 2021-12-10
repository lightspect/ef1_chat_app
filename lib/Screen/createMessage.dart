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
import 'package:grouped_list/grouped_list.dart';

class CreateMessagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CreateMessagePageState();
}

class _CreateMessagePageState extends State<CreateMessagePage> {
  DatabaseService? databaseService;
  final _searchController = TextEditingController();

  String alert = '';
  List<ContactModel?>? contacts;
  List<ContactModel?> searchList = [];

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    databaseService = locator<DatabaseService>();
    // Force refresh input
    contacts = databaseService!.contacts;
    setState(() {});
  }

  void handleCreateGroupMessage(ContactModel contact) async {
    Members peerUser =
        new Members(userId: contact.userId, isActive: true, role: 1);
    await databaseService!.refreshMessageList();
    if (!(databaseService!.groups!.any((element) =>
        element.type == 1 &&
        element.membersList!
            .any((member) => member!.userId == contact.userId)))) {
      Members currentUser = new Members(
          userId: databaseService!.user!.userId, isActive: true, role: 1);
      List<Members> membersList = [peerUser, currentUser];
      GroupModel group = new GroupModel(
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
      DocumentReference groupDocRef = await databaseService!.addGroup(group);
      await groupDocRef.update({'groupId': groupDocRef.id}).then((value) {
        group.groupId = groupDocRef.id;
        group.groupName = contact.nickname;
        group.groupPhoto = contact.photoUrl;
        Navigator.of(context).pop();
        Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (context) => ChatPage(group: group)));
      });
    } else {
      GroupModel group = databaseService!.groups!
          .where((element) =>
              element.type == 1 &&
              element.membersList!
                  .any((member) => member!.userId == contact.userId))
          .first;
      group.groupName = contact.nickname;
      group.groupPhoto = contact.photoUrl;
      Navigator.of(context).pop();
      Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => ChatPage(group: group)));
    }
  }

  void search(String search) {
    searchList = [];
    if (search.isNotEmpty) {
      for (int i = 0; i < contacts!.length; i++) {
        if (contacts![i]!.nickname!.toLowerCase().contains(search.toLowerCase()) ||
            contacts![i]!.userId!.toLowerCase().contains(search.toLowerCase())) {
          searchList.add(contacts![i]);
        }
      }
      setState(() {});
    } else {
      setState(() {
        searchList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Message",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("To: "),
                TextFormFieldWidget(
                  hintText: "Name or Group",
                  controller: _searchController,
                  width: MediaQuery.of(context).size.width - 60,
                  onChange: search,
                  textColor: colorBlack,
                  focusBorderColor: colorBlack,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: GestureDetector(
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                        builder: (context) => CreateGroupPage(
                              contact: null,
                            ))),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Icon(
                        Icons.group_add,
                        color: colorBlack,
                      ),
                      backgroundColor: Color(0xffE5E5E5),
                      radius: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Create Group",
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
                child: GroupedListView<ContactModel?, String>(
              elements: searchList.isEmpty ? contacts! : searchList,
              groupBy: (element) => element!.nickname!.substring(0, 1),
              groupSeparatorBuilder: (String groupByValue) => Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(groupByValue),
              ),
              itemBuilder: (context, element) => InkWell(
                onTap: () {
                  handleCreateGroupMessage(element!);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Material(
                      child: element!.photoUrl != null
                          ? CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey),
                                ),
                                width: 40.0,
                                height: 40.0,
                                padding: EdgeInsets.all(10.0),
                              ),
                              imageUrl: element.photoUrl!,
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
                        element.nickname!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              useStickyGroupSeparators: true,
              floatingHeader: false,
              order: GroupedListOrder.ASC,
              separator: Divider(),
            )),
          ],
        ),
      ),
    );
  }
}
