import 'dart:async';

import 'package:chat_app_ef1/core/widget/loading.dart';
import 'package:chat_app_ef1/core/widget/reusable_widget.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_ef1/core/utils/color_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UnlockPage extends StatefulWidget {
  UnlockPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _UnlockPageState createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  Color _buttonTextColor = Colors.white;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseService? databaseService;

  bool isLoading = false;
  bool isLoggedIn = false;
  late User currentUser;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    isSignedIn();
    databaseService = locator<DatabaseService>();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });

    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Navigator.of(context).pushNamed("/navigationMenu");
    }

    this.setState(() {
      isLoading = false;
    });
  }

  Future<Null> handleSignIn() async {
    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount? googleUser = await (googleSignIn.signIn());
    GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    User? firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.length == 0) {
        currentUser = firebaseUser;
        String? token = await FirebaseMessaging.instance.getToken();
        user = new UserModel(
            userId: currentUser.uid,
            nickname: currentUser.displayName,
            photoUrl: currentUser.photoURL,
            createdAt: DateTime.now().toString(),
            aboutMe: "",
            token: token);
        // Update data to server if new user
        await databaseService!.setUser(user!, currentUser.uid);

        // Write data to local
        await databaseService!.setLocal();
      } else {
        // Write data to local
        user = UserModel.fromMap(documents[0].data() as Map<dynamic, dynamic>?);
        databaseService!.user = user;
        await databaseService!.setLocal();
      }
      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        isLoading = false;
      });

      Navigator.pushNamed(context, '/navigationMenu');
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const Loading() : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
        backgroundColor: splashBG,
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 50),
                      child: Image(
                        image: AssetImage('assets/images/logo_1.png'),
                      ),
                    ),
                  ),
                  Text(
                    "Welcome to EagleF1nance",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "We're happy to see you",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  TextFormFieldWidget(
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  LoginButton(
                    text: "Unlock",
                    color: colorRed,
                    borderRadius: 5,
                    fontSize: 20,
                    highlightColor: colorRed,
                    onClick: () {
                      handleSignIn();
                    },
                    borderColor: colorRed,
                    textColor: _buttonTextColor,
                  ),
                  LoginButton(
                    text: "Create Wallet",
                    color: splashBG,
                    borderRadius: 5,
                    highlightColor: colorRed,
                    borderColor: Colors.white,
                    textColor: Colors.white,
                    onClick: () {},
                  ),
                  Visibility(
                    visible: !keyboardIsOpen,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 80.0),
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(bottom: 8.0, top: 8.0),
                              child: Text(
                                "Restore Account?",
                                style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(bottom: 8.0, top: 8.0),
                              child: Text(
                                "Import using account seed phrase",
                                style: TextStyle(
                                    color: colorRed,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            buildLoading(),
          ],
        ));
  }
}
