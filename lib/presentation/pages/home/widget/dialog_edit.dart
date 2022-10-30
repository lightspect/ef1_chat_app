import 'package:chat_app_ef1/core/utils/color_utils.dart';
import 'package:chat_app_ef1/core/widget/reusable_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogEditProfile extends StatelessWidget {
  DialogEditProfile({
    Key? key,
    required this.controller,
    required this.action,
  }) : super(key: key);

  TextEditingController controller;
  String action;

  @override
  Widget build(BuildContext context) {
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
                      controller: controller,
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
                          Get.back(result: controller.text);
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
  }
}
