import 'package:flutter/material.dart';
import 'package:chat_app_ef1/Common/color_utils.dart';
import 'package:chat_app_ef1/Common/reusableWidgetClass.dart';

class SeedCreatePage extends StatefulWidget {
  SeedCreatePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _SeedCreatePageState createState() => _SeedCreatePageState();
}

class _SeedCreatePageState extends State<SeedCreatePage> {
  Color _buttonTextColor = Colors.white;
  bool reveal = false;
  String seed =
      "Your seed phrase makes it easy to back up and restore account.";
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
                  "Secret Backup Phrase",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 16, bottom: 16),
                    child: Column(
                      children: [
                        Text(
                          "Your secret backup phrase makes it easy to back up and restore your account.",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: 'WARNING: ',
                                  style: new TextStyle(color: colorRed)),
                              new TextSpan(
                                  text:
                                      'Never disclose your backup phrase. Anyone with this phrase can take your Ether forever.'),
                            ],
                          ),
                        ),
                      ],
                    )),
                Ink(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colorBlack),
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          reveal = true;
                        });
                      },
                      child: Container(
                        height: 120,
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            children: [
                              Visibility(
                                visible: !reveal,
                                child: Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                reveal
                                    ? seed
                                    : "Click here to reveal secret words",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: reveal ? 14 : 12),
                              )
                            ],
                          ),
                        ),
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppButton(
                      text: "Remind me later",
                      color: splashBG,
                      borderRadius: 5,
                      onClick: () {
                        Navigator.pushNamed(context, '/term');
                      },
                      borderColor: Colors.white,
                      textColor: _buttonTextColor,
                    ),
                    AppButton(
                      text: "Next",
                      color: colorRed,
                      borderRadius: 5,
                      onClick: () {
                        Navigator.pushNamed(context, '/seedConfirm',
                            arguments: seed);
                      },
                      borderColor: colorRed,
                      textColor: _buttonTextColor,
                    ),
                  ],
                ),
                Text(
                  'Tips: \nStore this phrase in a password manager like 1Password. Write this phrase on a piece of paper and store in a secure location. If you want even more security, write it down on multiple pieces of paper and store each in 2 - 3 different locations. \nMemorize this phrase',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "Download this Secret Backup Phrase and keep it stored safely on an external encrypted hard drive or storage medium.",
                  style: TextStyle(color: colorRed, fontSize: 12),
                ),
              ],
            )));
  }
}
