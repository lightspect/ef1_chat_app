import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/core/utils/color_utils.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/navigationModel.dart';
import 'package:chat_app_ef1/core/widget/reusable_widget.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/Screen/contactDetail.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key, this.title}) : super(key: key);

  final String? title;

  static const route = '/contact';

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _searchController = TextEditingController();
  final _idController = TextEditingController();
  final _aliasController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _debouncer = Debouncer(milliseconds: 500);
  DatabaseService? databaseService;

  late List<OnlineStatusModel> contacts;
  late List<OnlineStatusModel> searchList;
  ContactModel? contact;

  String alert = '';

  bool isEnterID = false;

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    print("refresh Contact");
    databaseService!.fetchOnlineStatusAsStream();
    setState(() {});
  }

  void search(String search) {
    searchList = [];
    if (search.isNotEmpty) {
      for (int i = 0; i < contacts.length; i++) {
        if (contacts[i]
                .nickname!
                .toLowerCase()
                .contains(search.toLowerCase()) ||
            contacts[i].userId.toLowerCase().contains(search.toLowerCase())) {
          searchList.add(contacts[i]);
        }
      }
      setState(() {});
    } else {
      setState(() {
        searchList = [];
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

  Future<void> _alertDialog() async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: alert == "success" ? "Success" : "Error",
          bodyTitle: alert.isNotEmpty ? alert : "",
          bodySubtitle: "",
          icon: alert == "success"
              ? Icon(Icons.check_circle, size: 60, color: Colors.green)
              : Icon(Icons.warning, size: 60, color: Colors.yellow),
          bodyAction: [
            LoginButton(
              margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
              color: alert == "success" ? colorGreen : colorRed,
              borderColor: alert == "success" ? colorGreen : colorRed,
              borderRadius: 4,
              text: alert == "success" ? "Confirm" : "Try again",
              onClick: () {
                setState(() {
                  _idController.text = "";
                  _aliasController.text = "";
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addContactDialog() async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext bc, StateSetter setDialogState) {
          return CustomAlertDialog(
            title: "Add New Contact",
            bodyTitle: "",
            bodySubtitle: "",
            bodyAction: [
              Visibility(
                  visible: !isEnterID,
                  child: Column(
                    children: [
                      LoginButton(
                        margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
                        color: colorBlue,
                        borderColor: colorBlue,
                        borderRadius: 4,
                        text: "Scan QR Code",
                        onClick: () {
                          Navigator.of(context).pop();
                          Navigator.of(context, rootNavigator: true)
                              .pushNamed("/qrscan");
                        },
                      ),
                      LoginButton(
                        margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
                        color: colorRed,
                        borderColor: colorRed,
                        borderRadius: 4,
                        text: "Enter ID",
                        onClick: () {
                          setDialogState(() {
                            isEnterID = true;
                          });
                        },
                      ),
                    ],
                  )),
              Form(
                key: _formKey,
                child: Visibility(
                  visible: isEnterID,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("New Contact"),
                        Container(
                          margin: EdgeInsets.only(top: 12, bottom: 16),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter an ID";
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
                              hintText: "ID",
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
                            controller: _idController,
                            onFieldSubmitted: (value) {},
                          ),
                        ),
                        Text("Enter alias"),
                        Container(
                          margin: EdgeInsets.only(top: 12, bottom: 16),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter a nickname";
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
                            controller: _aliasController,
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
                                setDialogState(() {
                                  isEnterID = false;
                                });
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
                                  _formKey.currentState!.save();
                                  handleAddNewContact();
                                  Navigator.of(context).pop();
                                }
                              },
                            )
                          ],
                        )
                      ]),
                ),
              )
            ],
          );
        });
      },
    );
  }

  void handleAddNewContact() async {
    bool existContact = false;
    List<UserModel> userList = await (databaseService!
        .fetchUsersById(_idController.text) as FutureOr<List<UserModel>>);
    //check if user existed
    if (userList.length > 0) {
      //check if user is self
      contact = new ContactModel(
          userId: userList[0].userId,
          nickname: _aliasController.text,
          photoUrl: userList[0].photoUrl);
      print("Contact ID: " + contact!.userId!);
      if (contact!.userId != databaseService!.user!.userId) {
        //check if user already in contact
        if (contacts.length == 0) {
          existContact = false;
        } else {
          for (OnlineStatusModel findContact in contacts) {
            if (findContact.userId == _idController.text) {
              existContact = true;
              break;
            }
          }
        }
        print("Exist Contact: " + existContact.toString());
        //check if user already in contact list
        if (!existContact) {
          await databaseService!
              .setContact(
                  contact!, databaseService!.user!.userId, contact!.userId)
              .then((value) async {
            databaseService!.contacts!.add(contact);
            await databaseService!.setContactsList();
            setState(() {
              alert = "success";
              isEnterID = false;
              _idController.text = "";
              _aliasController.text = "";
            });
          }).catchError((err) {
            setState(() {
              alert = err.toString();
            });
          });
        } else {
          setState(() {
            alert = 'User is already in Contact List';
          });
        }
      } else {
        setState(() {
          alert = 'You cannot add yourself';
        });
      }
    } else {
      setState(() {
        alert = 'User does not exist';
      });
    }
    databaseService!.refreshMessageList();
    _alertDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16),
        margin: EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (databaseService!.user != null ||
                          databaseService!.user!.photoUrl != null ||
                          databaseService!.user!.photoUrl!.isNotEmpty
                      ? Material(
                          child: CachedNetworkImage(
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
                            imageUrl: databaseService!.user!.photoUrl!,
                            width: 60.0,
                            height: 60.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          clipBehavior: Clip.hardEdge,
                        )
                      : Icon(
                          Icons.account_circle,
                          size: 60.0,
                          color: Colors.grey,
                        )),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Contacts",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        _addContactDialog();
                      })
                ],
              ),
            ),
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
            Divider(
              color: Colors.grey,
            ),
            Flexible(
              child: StreamBuilder(
                stream: databaseService!.contactStatusList,
                builder: (context,
                    AsyncSnapshot<List<OnlineStatusModel>?> snapshot) {
                  if (!snapshot.hasData) {
                    print("No data");
                    return Center(
                        child: Text(
                      "Please add someone to Contact or wait for data to finish loading.",
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    print("Has data");
                    contacts = List.from(snapshot.data!);
                    return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: GroupedListView<OnlineStatusModel, String>(
                          controller: NavigationProvider.of(context)
                              .screens[FOURTH_SCREEN]
                              .scrollController,
                          elements: _searchController.text.isEmpty
                              ? contacts
                              : searchList,
                          groupBy: (element) =>
                              element.nickname!.substring(0, 1).toUpperCase(),
                          groupSeparatorBuilder: (String groupByValue) =>
                              Container(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(groupByValue),
                          ),
                          itemBuilder: (context, element) => InkWell(
                            onTap: () {
                              print(element.status);
                              ContactModel contact = new ContactModel(
                                  nickname: element.nickname,
                                  photoUrl: element.photoUrl,
                                  userId: element.userId);
                              Navigator.of(context).push(MaterialPageRoute(
                                  settings:
                                      RouteSettings(name: "/contact/detail"),
                                  builder: (context) =>
                                      ContactDetailPage(contact, null, false)));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Material(
                                      child: element.photoUrl != null
                                          ? CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 1.0,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.grey),
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    element.status == "online"
                                        ? Positioned(
                                            right: 0.0,
                                            bottom: 0.0,
                                            child: CircleAvatar(
                                              backgroundColor: colorGreen,
                                              radius: 6,
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Text(
                                    element.nickname!,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          useStickyGroupSeparators: true,
                          floatingHeader: false,
                          order: GroupedListOrder.ASC,
                          separator: Divider(),
                        ));
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
