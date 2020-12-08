import 'package:flutter/material.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';

class SeedSuccessPage extends StatefulWidget {
  SeedSuccessPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SeedSuccessPageState createState() => _SeedSuccessPageState();
}

class _SeedSuccessPageState extends State<SeedSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: splashBG,
          leading: BackButton(color: Colors.white),
          title: Text("Back"),
        ),
        backgroundColor: splashBG,
        body: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            child: Column(
              children: <Widget>[
                Flexible(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Image(
                      image: AssetImage('assets/images/logo_1.png'),
                    ),
                  ),
                ),
                Text(
                  "Congratulation",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 16),
                  child: Column(),
                ),
                AppButton(
                  text: "All Done",
                  color: colorRed,
                  highlightColor: colorRed,
                  onClick: () {
                    Navigator.pushNamed(context, '/seedCreate');
                  },
                  borderColor: colorRed,
                  textColor: Colors.white,
                ),
              ],
            )));
  }
}
