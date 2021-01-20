import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

class TestScreen extends StatefulWidget {
  TestScreen();
  @override
  _TestScreenState createState() => new _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  _TestScreenState();
  List<UserModel> users;
  DatabaseService databaseService;

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    users = [];
    setUsersList();
  }

  Future<void> setUsersList() async {
    users =
        await databaseService.getUsersByContact(databaseService.user.userId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All User with Contact",
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
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                users.length.toString() + " users contain this user as Contact",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) =>
                    buildItem(context, users[index]),
                itemCount: users.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, UserModel user) {
    return Container(
        margin: EdgeInsets.only(top: 12),
        padding: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Color(0xffEFEFEF),
                    width: 1,
                    style: BorderStyle.solid))),
        height: 48,
        child: Row(
          children: [
            InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Material(
                    child: user.photoUrl != null || user.photoUrl.isNotEmpty
                        ? CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.grey),
                              ),
                              width: 40.0,
                              height: 40.0,
                              padding: EdgeInsets.all(10.0),
                            ),
                            imageUrl: user.photoUrl,
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
                      user.nickname,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
