import 'package:chat_app_ef1/core/utils/color_utils.dart';
import 'package:chat_app_ef1/core/widget/reusable_widget.dart';
import 'package:flutter/material.dart';

class TermService extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TermServiceState();
}

class _TermServiceState extends State<TermService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: splashBG,
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Flexible(
              child: Container(
                margin: EdgeInsets.only(top: 50),
                child: Image(
                  width: MediaQuery.of(context).size.width / 1.5,
                  image: AssetImage('assets/images/logo_1.png'),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 12.0),
              child: Text(
                "Help Us Improve EagleF1nance",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.1,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppButton(
                    color: splashBG,
                    textColor: Colors.white,
                    text: "No Thanks",
                    fontSize: 20,
                    borderColor: Colors.white,
                  ),
                  AppButton(
                    color: colorRed,
                    textColor: Colors.white,
                    text: "I agree",
                    fontSize: 20,
                    borderColor: colorRed,
                    onClick: () {
                      Navigator.pushNamed(context, '/registration');
                    },
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
