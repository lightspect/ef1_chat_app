import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';
import 'package:chat_app_ef1/Common/share_prefs.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/navigationService.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key, this.title}) : super(key: key);

  final String title;

  static const route = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPref sharedPref;
  DatabaseService databaseService;

  bool isLoading = false;
  File avatarImageFile;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  final _nicknameController = TextEditingController();
  final _statusMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    readLocal();
  }

  void handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(databaseService.user.userId)
        .update({'token': ""});

    databaseService.user = new UserModel(
        userId: "",
        aboutMe: "",
        chattingWith: "",
        createdAt: "",
        nickname: "",
        photoUrl: "",
        token: "");
    databaseService.setLocal();

    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil('/unlock', (Route<dynamic> route) => false);
  }

  void readLocal() async {
    await databaseService.readLocal();
    await databaseService.fetchContacts(databaseService.user.userId);
    await databaseService.setContactsList();
    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    File image = File(pickedFile.path);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = databaseService.user.userId;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          databaseService.user.photoUrl = downloadUrl;
          databaseService
              .updateUser(databaseService.user, databaseService.user.userId)
              .then((data) async {
            await databaseService.setLocal();
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

  void handleUpdateData() {
    setState(() {
      isLoading = true;
    });

    databaseService
        .updateUser(databaseService.user, databaseService.user.userId)
        .then((data) async {
      await databaseService.setLocal();
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

  Future<void> _showMyDialog(String action) async {
    _nicknameController.text = "";
    _statusMessageController.text = "";
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Edit " + action,
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("New " + action),
                      Container(
                        margin: EdgeInsets.only(top: 12, bottom: 16),
                        child: TextFormField(
                          cursorColor: colorBlue,
                          style: TextStyle(
                            color: colorBlack,
                            fontSize: 12.0,
                            letterSpacing: 1.2,
                          ),
                          decoration: InputDecoration(
                            hintText: action,
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
                          controller: action == "Nickname"
                              ? _nicknameController
                              : _statusMessageController,
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
                              setState(() {
                                if (_nicknameController.text.isNotEmpty) {
                                  databaseService.user.nickname =
                                      _nicknameController.text;
                                } else if (_statusMessageController
                                    .text.isNotEmpty) {
                                  databaseService.user.aboutMe =
                                      _statusMessageController.text;
                                }
                              });
                              handleUpdateData();
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'My Profile',
            style: TextStyle(fontSize: 20, color: colorBlack),
          ),
          centerTitle: true,
          backgroundColor: colorMainBG,
          elevation: 0,
          actions: [
            IconButton(
                icon: Icon(
                  Icons.logout,
                  color: colorBlack,
                ),
                onPressed: handleSignOut)
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: InkWell(
                        borderRadius: BorderRadius.circular(90),
                        onTap: getImage,
                        child: profilePicture(context)),
                  ),
                ),
                InkWell(
                    onTap: () {
                      _showMyDialog("Nickname");
                    },
                    child: Container(
                      height: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                              "Display Name: " + databaseService.user.nickname),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                          )
                        ],
                      ),
                    )),
                Divider(),
                InkWell(
                    onTap: () {
                      _showMyDialog("Status Message");
                    },
                    child: Container(
                      height: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Status Message: " +
                              databaseService.user.aboutMe),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                          )
                        ],
                      ),
                    )),
                Divider(),
                InkWell(
                    onTap: () {},
                    child: Container(
                      height: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("My Wallet: "),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                          )
                        ],
                      ),
                    )),
                Divider(),
                InkWell(
                    onTap: () {},
                    child: Container(
                      height: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Scan QR Code:"),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                          )
                        ],
                      ),
                    )),
                Divider(),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "QR Code:",
                    textAlign: TextAlign.left,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(12),
                  alignment: Alignment.center,
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                      border: Border.all(color: colorBlack, width: 1.0)),
                  child: QrImage(
                    data: databaseService.user.userId,
                  ),
                ),
                LoginButton(
                  minWidth: 128,
                  height: 40,
                  text: "Copy QR",
                  onClick: () {},
                )
              ],
            ),
          ),
        ));
  }

  Widget profilePicture(BuildContext context) {
    if (databaseService.user == null) {
      return Icon(
        Icons.account_circle,
        size: 120.0,
        color: Colors.grey,
      );
    } else if (avatarImageFile == null) {
      if (databaseService.user.photoUrl != null ||
          databaseService.user.photoUrl.isNotEmpty) {
        return Material(
          child: CachedNetworkImage(
            placeholder: (context, url) => Container(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
              width: 120.0,
              height: 120.0,
              padding: EdgeInsets.all(20.0),
            ),
            imageUrl: databaseService.user.photoUrl,
            width: 120.0,
            height: 120.0,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(Radius.circular(60.0)),
          clipBehavior: Clip.hardEdge,
        );
      } else {
        return Icon(
          Icons.account_circle,
          size: 120.0,
          color: Colors.grey,
        );
      }
    } else {
      return Material(
        child: Image.file(
          avatarImageFile,
          width: 120.0,
          height: 120.0,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(60.0)),
        clipBehavior: Clip.hardEdge,
      );
    }
  }
}
