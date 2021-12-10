import 'package:flutter/material.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  Color _buttonTextColor = Colors.white;
  @override
  Widget build(BuildContext context) {
    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Term of Use'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Please agree to our Term of Use to proceed.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    bool? checkedValue = false;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: splashBG,
          leading: BackButton(color: Colors.white),
          title: Text("Back"),
        ),
        backgroundColor: splashBG,
        body: Container(
            child: Column(
          children: <Widget>[
            Flexible(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Image(
                  image: AssetImage('assets/images/logo_1.png'),
                ),
              ),
            ),
            Text(
              "Create Password",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppTextField(
              hintText: 'Password (Minimum of 8 characters)',
              isPassword: true,
            ),
            AppTextField(
              hintText: 'Re-enter Password',
              isPassword: true,
            ),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return CheckboxListTile(
                title: new RichText(
                  text: new TextSpan(
                    style: new TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                    children: <TextSpan>[
                      new TextSpan(text: 'I have read and agree to the'),
                      new TextSpan(
                          text: ' Term of Use',
                          style: new TextStyle(color: colorRed)),
                    ],
                  ),
                ),
                value: checkedValue,
                onChanged: (newValue) {
                  setState(() {
                    checkedValue = newValue;
                  });
                },
                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
              );
            }),
            AppButton(
              text: "Registration",
              color: colorRed,
              borderRadius: 5,
              highlightColor: colorRed,
              onClick: () {
                if (checkedValue!) {
                  Navigator.pushNamed(context, '/seedCreate');
                } else {
                  _showMyDialog();
                }
              },
              borderColor: colorRed,
              textColor: _buttonTextColor,
            ),
          ],
        )));
  }
}
