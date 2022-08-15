import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/loading.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';
import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/domain/entities/userModel.dart';
import 'package:chat_app_ef1/Screen/contactDetail.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<ScanScreen> {
  String? _qrInfo = 'Scan a QR/Bar code';
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  QRViewController? controller;
  bool _camState = false;
  bool isLoading = false;
  String? _argument = "";
  String alert = "";
  bool isInContact = true;
  DatabaseService? databaseService;
  UserModel? userModel;
  ContactModel? contactModel;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
    _qrCallback(result.code, context);
  }

  _qrCallback(String? code, BuildContext context) async {
    _argument = ModalRoute.of(context)!.settings.arguments as String?;
    setState(() {
      _camState = false;
      _qrInfo = code;
    });
    if (_argument == "getAddress") {
      //Navigator.pop(context, code);
    } else {
      //check if user existed
      userModel = await databaseService!.getUserById(code);
      if (userModel != null) {
        //check if user is not self
        if (userModel!.userId != databaseService!.user!.userId) {
          contactModel = await databaseService!
              .getContactById(databaseService!.user!.userId, code);
          //check if user not in contact list
          if (contactModel == null) {
            contactModel = new ContactModel(
                nickname: userModel!.nickname,
                photoUrl: userModel!.photoUrl,
                userId: userModel!.userId);
            setState(() {
              isInContact = false;
            });
          } else {
            setState(() {
              isInContact = true;
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
      _settingModalBottomSheet(context);
    }
  }

  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  @override
  void initState() {
    super.initState();
    databaseService = locator<DatabaseService>();
    _scanCode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Scan QR Code",
            style: TextStyle(color: colorBlack),
          ),
          backgroundColor: colorMainBG,
          iconTheme: IconThemeData(color: colorBlack),
        ),
        body: _camState
            ? Center(
                child: SizedBox(
                  height: 1000,
                  width: 500,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
              )
            : Container(
                color: colorBlack,
              ));
  }

  void handleAddNewContact() async {
    setState(() {
      isLoading = true;
    });
    databaseService!
        .setContact(
            contactModel!, databaseService!.user!.userId, contactModel!.userId)
        .then(
            (value) => Fluttertoast.showToast(msg: "Add Contact Successfully"))
        .catchError((err) => Fluttertoast.showToast(msg: err.toString()));
    setState(() {
      isLoading = false;
    });
    databaseService!.refreshMessageList();
  }

  void _settingModalBottomSheet(parentContext) {
    final _aliasController = TextEditingController();
    _aliasController.text = contactModel!.nickname!;
    bool _visible = false;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
        isScrollControlled: true,
        context: parentContext,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext bc, StateSetter setSheetState) {
            return SingleChildScrollView(
              child: Stack(children: [
                Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Visibility(
                            visible: alert.isNotEmpty,
                            child: Column(
                              children: [
                                Icon(Icons.warning, size: 60, color: colorRed),
                                Text(
                                  alert,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: alert.isEmpty,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.grey),
                                          ),
                                          width: 60.0,
                                          height: 60.0,
                                          padding: EdgeInsets.all(10.0),
                                        ),
                                        imageUrl: contactModel!.photoUrl!,
                                        width: 60.0,
                                        height: 60.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 24),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _qrInfo!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          MaterialButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            height: 16,
                                            minWidth: 40,
                                            onPressed: () {},
                                            textColor: Colors.white,
                                            color: colorRed,
                                            child: Text(
                                              "Copy",
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: LoginButton(
                                    minWidth:
                                        MediaQuery.of(context).size.width - 32,
                                    margin: EdgeInsets.zero,
                                    borderRadius: 8,
                                    text: !isInContact
                                        ? "Add to Contact"
                                        : "View Detail",
                                    onClick: () {
                                      if (!isInContact) {
                                        setSheetState(() {
                                          _visible = true;
                                        });
                                      } else {
                                        Navigator.of(parentContext).pop();
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ContactDetailPage(
                                                        contactModel,
                                                        null,
                                                        false)));
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _visible,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Add Alias"),
                                Container(
                                  margin: EdgeInsets.only(top: 8, bottom: 16),
                                  child: TextFormField(
                                    cursorColor: colorBlue,
                                    style: TextStyle(
                                      color: colorBlack,
                                      fontSize: 12.0,
                                      letterSpacing: 1.2,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Alias",
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: colorBlack),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: colorBlack),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: colorBlack),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    LoginButton(
                                      margin: EdgeInsets.zero,
                                      height: 48,
                                      minWidth: 160,
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
                                      margin: EdgeInsets.zero,
                                      height: 48,
                                      minWidth: 160,
                                      color: colorBlue,
                                      borderColor: colorBlue,
                                      borderRadius: 4,
                                      text: "Add",
                                      onClick: () {
                                        handleAddNewContact();
                                        Navigator.of(parentContext).pop();
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                Positioned(
                  child: isLoading ? const Loading() : Container(),
                )
              ]),
            );
          });
        }).whenComplete(() {
      setState(() {
        _camState = true;
        _visible = false;
      });
    });
  }
}
