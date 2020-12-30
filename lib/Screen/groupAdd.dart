import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grouped_list/grouped_list.dart';

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({Key key, this.groupId, this.members}) : super(key: key);

  final String groupId;
  final List<dynamic> members;

  @override
  State<StatefulWidget> createState() => _AddMemberPageState(groupId, members);
}

class _AddMemberPageState extends State<AddMemberPage> {
  _AddMemberPageState(this.groupId, this.currentMembers);
  final String groupId;
  DatabaseService databaseService;
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  String alert = '';
  String groupName = '';
  List<dynamic> currentMembers;
  List<ContactModel> contacts = [];
  List<ContactModel> selectedContacts = [];
  List<ContactModel> searchList = [];
  Map<String, bool> contactMap = {};
  Map<String, bool> searchMap = {};

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    getContacts();
  }

  void getContacts() {
    databaseService.fetchContacts(databaseService.user.userId).then((snap) {
      contacts.clear();
      setState(() {
        snap.forEach((element) {
          if (!currentMembers.contains(element.userId)) {
            contacts.add(element);
          }
        });
        contacts.forEach((element) {
          contactMap[element.userId] = false;
        });
      });
    });
  }

  void handleAddMember() async {
    List<String> contactIdList = [];
    contactIdList.addAll(currentMembers.cast());
    selectedContacts.forEach((element) {
      contactIdList.add(element.userId);
    });
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .update({'members': contactIdList});

    Navigator.of(context).popUntil((route) {
      if (route.settings.name == '/message/chatGroup') {
        Fluttertoast.showToast(msg: "Add members successful");
        (route.settings.arguments as Map)['addMember'] = true;
        return true;
      } else {
        return false;
      }
    });
  }

  void search(String search) {
    searchMap = {};
    if (search.isNotEmpty) {
      for (int i = 0; i < contacts.length; i++) {
        if (contacts[i].nickname.toLowerCase().contains(search.toLowerCase()) ||
            contacts[i].userId.toLowerCase().contains(search.toLowerCase())) {
          searchList.add(contacts[i]);
          searchMap[contacts[i].userId] = contactMap[contacts[i].userId];
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
          "Add Member",
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
              child: GroupedListView<ContactModel, String>(
                elements: searchList.isEmpty ? contacts : searchList,
                groupBy: (element) => element.nickname.substring(0, 1),
                groupSeparatorBuilder: (String groupByValue) => Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(groupByValue),
                ),
                itemBuilder: (context, element) => StatefulBuilder(
                  builder: (context, checkListState) => CheckboxListTile(
                    title: Text(element.nickname),
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
                        if (value) {
                          if (!selectedContacts.contains(element)) {
                            selectedContacts.add(element);
                          }
                        } else {
                          selectedContacts.remove(selectedContacts
                              .where((contactModel) =>
                                  contactModel.userId == element.userId)
                              .first);
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
                text: "Add Members",
                textColor:
                    selectedContacts.isNotEmpty ? Colors.white : Colors.grey,
                fontSize: 20,
                borderColor:
                    selectedContacts.isNotEmpty ? colorLightGreen : Colors.grey,
                color:
                    selectedContacts.isNotEmpty ? colorLightGreen : colorMainBG,
                onClick: selectedContacts.isEmpty ? null : handleAddMember,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildItem(ContactModel contactModel) {
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
                              imageUrl: contactModel.photoUrl,
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
                            selectedContacts.remove(selectedContacts
                                .where((currentContact) =>
                                    currentContact.userId ==
                                    contactModel.userId)
                                .first);
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
                    contactModel.nickname,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Container(),
    );
  }
}
