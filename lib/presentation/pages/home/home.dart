import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_ef1/core/utils/color_utils.dart';
import 'package:chat_app_ef1/core/widget/reusable_widget.dart';
import 'package:chat_app_ef1/presentation/controller/home/home_controller.dart';
import 'package:chat_app_ef1/presentation/pages/home/widget/dialog_edit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends StatelessWidget {
  HomeController _homeController = Get.find<HomeController>();

  _showMyDialog(String action, TextEditingController controller) async {
    return Get.dialog(
      DialogEditProfile(controller: controller, action: action),
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
                onPressed: () => _homeController.handleSignOut())
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
                        onTap: _homeController.getImage,
                        child: profilePicture()),
                  ),
                ),
                InkWell(
                    onTap: () {
                      _showMyDialog(
                        "Nickname",
                        _homeController.nicknameController,
                      );
                    },
                    child: Container(
                      height: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Display Name: " +
                              _homeController.user!.nickname!),
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
                      _showMyDialog(
                        "Status Message",
                        _homeController.statusMessageController,
                      );
                    },
                    child: Container(
                      height: 28,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Status Message: " +
                              _homeController.user!.aboutMe),
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
                    data: _homeController.user!.userId,
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

  Widget profilePicture() {
    if (_homeController.user == null) {
      return Icon(
        Icons.account_circle,
        size: 120.0,
        color: Colors.grey,
      );
    } else if (_homeController.avatarImageFile == null) {
      if (_homeController.user!.photoUrl != null ||
          _homeController.user!.photoUrl!.isNotEmpty) {
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
            imageUrl: _homeController.user!.photoUrl!,
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
          _homeController.avatarImageFile!,
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
