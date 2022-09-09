import 'package:chat_app_ef1/core/widget/loading.dart';
import 'package:chat_app_ef1/core/widget/reusable_widget.dart';
import 'package:chat_app_ef1/presentation/controller/unlock/unlock_controller.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_ef1/core/utils/color_utils.dart';
import 'package:get/get.dart';

class UnlockPage extends StatelessWidget {
  final UnlockController controller = Get.find<UnlockController>();
  final bool keyboardIsOpen =
      MediaQuery.of(Get.context!).viewInsets.bottom != 0;

  Widget buildLoading() {
    return GetBuilder<UnlockController>(
      builder: (controller) {
        return Positioned(
          child: controller.isLoading ? const Loading() : Container(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    onClick: () => controller.handleSignIn(),
                    borderColor: colorRed,
                    textColor: Colors.white,
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
