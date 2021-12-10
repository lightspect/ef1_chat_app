import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/Screen/chatGroup.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({Key? key, this.contact}) : super(key: key);

  final ContactModel? contact;

  @override
  State<StatefulWidget> createState() => _CreateGroupPageState(contact);
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  _CreateGroupPageState(this.contact);
  final ContactModel? contact;
  DatabaseService? databaseService;
  final _searchController = TextEditingController();
  final _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _debouncer = Debouncer(milliseconds: 500);

  String alert = '';
  String groupName = '';
  List<ContactModel?>? contacts = [];
  List<ContactModel?> selectedContacts = [];
  List<ContactModel?> searchList = [];
  Map<String?, bool?> contactMap = {};
  Map<String?, bool?> searchMap = {};

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    getContacts();
  }

  void getContacts() {
    contacts = databaseService!.contacts;
    if (contact != null) {
      ContactModel element = new ContactModel(
          userId: contact!.userId,
          nickname: contact!.nickname,
          photoUrl: contact!.photoUrl);
      selectedContacts.add(element);
    }
    for (ContactModel? element in contacts!) {
      if (selectedContacts
          .where((contact) => element!.userId == contact!.userId)
          .isNotEmpty) {
        contactMap[element!.userId] = true;
      } else {
        contactMap[element!.userId] = false;
      }
    }
  }

  Future<void> createDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Create Group",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("New Group name"),
                        Container(
                          margin: EdgeInsets.only(top: 12, bottom: 16),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter a group Name";
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
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: colorRed),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: colorRed),
                              ),
                              errorStyle: TextStyle(
                                color: colorRed,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.normal,
                                letterSpacing: 1.2,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0,
                                letterSpacing: 1.2,
                              ),
                              isDense: true,
                            ),
                            controller: _groupNameController,
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
                              text: "Create",
                              onClick: () {
                                var validate = _formKey.currentState!.validate();
                                if (validate) {
                                  _formKey.currentState!.save();
                                  groupName = _groupNameController.text;
                                  handleCreateGroupMessage();
                                  Navigator.of(context).pop();
                                }
                              },
                            )
                          ],
                        )
                      ]),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void handleCreateGroupMessage() async {
    List<Members> groupMember = [];
    for (ContactModel? element in selectedContacts) {
      Members member =
          new Members(userId: element!.userId, isActive: true, role: 1);
      groupMember.add(member);
    }
    groupMember.add(new Members(
        userId: databaseService!.user!.userId, isActive: true, role: 2));
    GroupModel group = new GroupModel(
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        createdBy: databaseService!.user!.userId,
        membersList: groupMember,
        groupId: "",
        groupName: groupName,
        groupPhoto: "",
        recentMessageContent: "",
        recentMessageSender: "",
        recentMessageTime: "",
        type: 2);
    DocumentReference groupDocRef = await databaseService!.addGroup(group);
    await groupDocRef.update({'groupId': groupDocRef.id}).then((value) {
      group.groupId = groupDocRef.id;
      Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => ChatGroupPage(group: group)));
    });
  }

  void search(String search) {
    searchMap = {};
    if (search.isNotEmpty) {
      for (int i = 0; i < contacts!.length; i++) {
        if (contacts![i]!.nickname!.toLowerCase().contains(search.toLowerCase()) ||
            contacts![i]!.userId!.toLowerCase().contains(search.toLowerCase())) {
          searchList.add(contacts![i]);
          searchMap[contacts![i]!.userId] = contactMap[contacts![i]!.userId];
        }
      }
      setState(() {});
    } else {
      setState(() {
        searchList = [];
        searchMap = {};
      });
    }
  }

  void _navigateAndReturnData() async {
    final result = await Navigator.of(context, rootNavigator: true)
        .pushNamed('/qrscan', arguments: "getAddress");
    setState(() {
      if (result.toString() != "null") {
        _searchController.text = result.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Choose Member",
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
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: TextFormField(
                cursorColor: colorBlue,
                style: TextStyle(
                  color: colorBlack,
                  fontSize: 14.0,
                  letterSpacing: 1.2,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.qr_code_scanner),
                    onPressed: () {
                      _navigateAndReturnData();
                      search(_searchController.text);
                    },
                  ),
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
                  _debouncer.run(() {
                    search(value);
                  });
                },
              ),
            ),
            Container(
              height: selectedContacts.isNotEmpty ? 80 : 0,
              child: ListView.builder(
                itemBuilder: (context, index) =>
                    buildItem(selectedContacts[index]),
                itemCount: selectedContacts.length,
                scrollDirection: Axis.horizontal,
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
                itemBuilder: (context, element) => StatefulBuilder(
                  builder: (context, checkListState) => CheckboxListTile(
                    title: Text(element!.nickname!),
                    value: searchMap.isEmpty
                        ? (contactMap[element.userId] ?? false)
                        : (searchMap[element.userId] ?? false),
                    onChanged: (value) {
                      checkListState(() {
                        contactMap[element.userId] = value;
                        if (searchMap.isNotEmpty) {
                          searchMap[element.userId] = value;
                        }
                      });
                      setState(() {
                        if (value!) {
                          if (!selectedContacts.contains(element)) {
                            selectedContacts.add(element);
                          }
                        } else {
                          selectedContacts.removeWhere((selectedContact) =>
                              selectedContact!.userId == element.userId);
                        }
                      });
                    },
                    secondary: Material(
                      child: element.photoUrl != null
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
                  ),
                ),
                useStickyGroupSeparators: true,
                floatingHeader: false,
                order: GroupedListOrder.ASC,
                separator: Divider(),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: LoginButton(
                margin: EdgeInsets.only(bottom: 32),
                text: "Create Group",
                textColor:
                    selectedContacts.length > 1 ? Colors.white : Colors.grey,
                fontSize: 20,
                borderColor:
                    selectedContacts.length > 1 ? colorLightGreen : Colors.grey,
                color:
                    selectedContacts.length > 1 ? colorLightGreen : colorMainBG,
                onClick: selectedContacts.length < 1 ? null : createDialog,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildItem(ContactModel? contactModel) {
    return Container(
      alignment: Alignment.center,
      width: 60,
      child: contactModel != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Material(
                      child: contactModel.photoUrl != null
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
                              imageUrl: contactModel.photoUrl!,
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
                    Positioned(
                      right: 0.0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedContacts.removeWhere((element) =>
                                element!.userId == contactModel.userId);
                            contactMap[contactModel.userId] = false;
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
                    )
                  ],
                ),
                Flexible(
                  child: Text(
                    contactModel.nickname!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Container(),
    );
  }
}
