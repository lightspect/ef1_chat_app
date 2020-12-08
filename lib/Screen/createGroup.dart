import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/Screen/chat.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class CreateMessagePage extends StatefulWidget {
  const CreateMessagePage({Key key, this.contact}) : super(key: key);

  final ContactModel contact;

  @override
  State<StatefulWidget> createState() => _CreateMessagePageState(contact);
}

class _CreateMessagePageState extends State<CreateMessagePage> {
  _CreateMessagePageState(this.contact);
  final ContactModel contact;
  DatabaseService databaseService;
  final _searchController = TextEditingController();

  String alert = '';
  List<ContactModel> contacts;

  @override
  void initState() {
    super.initState();

    readLocal();
  }

  void readLocal() async {
    databaseService = locator<DatabaseService>();
    // Force refresh input
    setState(() {});
  }

  void handleCreateGroupMessage(ContactModel contact) async {
    final QuerySnapshot checkGroupResult = await FirebaseFirestore.instance
        .collection('groups')
        .where('type', isEqualTo: 1)
        .where('members', arrayContains: contact.userId)
        .get();
    final List<DocumentSnapshot> contactDoc = checkGroupResult.docs;
    if (contactDoc.length == 0) {
      GroupModel group = new GroupModel(
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
          createdBy: databaseService.user.userId,
          members: [databaseService.user.userId, contact.userId],
          groupId: "",
          groupName: "",
          groupPhoto: "",
          recentMessageContent: "",
          recentMessageSender: "",
          recentMessageTime: "",
          type: 1);
      DocumentReference groupDocRef = await databaseService.addGroup(group);
      await groupDocRef.update({'groupId': groupDocRef.id}).then((value) {
        group.groupName = contact.nickname;
        group.groupPhoto = contact.photoUrl;
        Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (context) => ChatPage(group: group)));
      });
    } else {
      GroupModel group = GroupModel.fromMap(contactDoc.first.data());
      if (group.type == 1) {
        group.groupName = contact.nickname;
        group.groupPhoto = contact.photoUrl;
      }
      Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => ChatPage(group: group)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Choose from Contact",
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
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  contact != null
                      ? Material(
                          child: contact.photoUrl != null
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
                                  imageUrl: contact.photoUrl,
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
                        )
                      : Container(),
                ],
              ),
            ),
            Flexible(
              child: StreamBuilder(
                stream: databaseService
                    .fetchContactsAsStream(databaseService.user.userId),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    );
                  } else {
                    contacts = snapshot.data.docs
                        .map((doc) => ContactModel.fromMap(doc.data()))
                        .toList();
                    return GroupedListView<ContactModel, String>(
                      elements: contacts,
                      groupBy: (element) => element.nickname.substring(0, 1),
                      groupSeparatorBuilder: (String groupByValue) => Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(groupByValue),
                      ),
                      itemBuilder: (context, element) => InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          handleCreateGroupMessage(element);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Material(
                              child: element.photoUrl != null
                                  ? CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.grey),
                                        ),
                                        width: 40.0,
                                        height: 40.0,
                                        padding: EdgeInsets.all(10.0),
                                      ),
                                      imageUrl: element.photoUrl,
                                      width: 40.0,
                                      height: 40.0,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.account_circle,
                                      size: 40.0,
                                      color: Colors.grey,
                                    ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 12),
                              child: Text(
                                element.nickname,
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
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
