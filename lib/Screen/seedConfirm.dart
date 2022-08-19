import 'package:flutter/material.dart';
import 'package:chat_app_ef1/core/utils/color_utils.dart';
import 'package:chat_app_ef1/core/widget/reusable_widget.dart';
import 'package:provider/provider.dart';

class SeedConfirmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String seed = ModalRoute.of(context)!.settings.arguments as String;
    List<String> seedArray = seed.split(" ")..shuffle();

    return ChangeNotifierProvider<ButtonModel>(
      create: (context) => ButtonModel(),
      child: Builder(
        builder: (context) {
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
                  Container(
                    margin: EdgeInsets.only(top: 6, bottom: 24),
                    padding: EdgeInsets.only(
                      left: 60,
                      right: 60,
                    ),
                    child: Text(
                      "Confirm your Secret Backup Phrase",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    "Please select each phrase in order to make sure it is correct.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  Container(
                    height: 120,
                    padding: EdgeInsets.all(32.0),
                    margin: EdgeInsets.only(top: 28, bottom: 28),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: colorBlack),
                    child: Center(child: Consumer<ButtonModel>(
                        builder: (context, provider, child) {
                      return Text(
                        provider.seedString,
                        style: TextStyle(color: Colors.white),
                      );
                    })),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 120,
                    child: GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 5),
                      children: <Widget>[
                        for (var i = 0; i < seedArray.length; i++)
                          Consumer<ButtonModel>(
                              builder: (context, provider, child) {
                            return MaterialButton(
                              color: provider.clicked[i]
                                  ? colorBlack
                                  : Colors.white,
                              textColor: provider.clicked[i]
                                  ? Colors.white
                                  : colorBlack,
                              minWidth: MediaQuery.of(context).size.width,
                              height: 32,
                              child: Text(
                                seedArray[i],
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                provider.checkClicked(
                                    seedArray, seedArray[i], i);
                                provider.changeArray(seedArray, seedArray[i]);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          })
                      ],
                    ),
                  ),
                  Consumer<ButtonModel>(
                    builder: (context, provider, child) {
                      return AppButton(
                        text: "Next",
                        color: colorRed,
                        highlightColor: colorRed,
                        onClick: () => provider.checkArray(seed)
                            ? Navigator.pushNamed(context, '/seedSuccess')
                            : _showMyDialog(context),
                        borderColor: colorRed,
                        textColor: Colors.white,
                      );
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Secret Phrase Test'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'You have entered the wrong Key Phrase.\nPlease try again.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Try Again'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class ButtonModel with ChangeNotifier {
  List<String> seedArray = [];
  List<String> seedText = [];
  List<bool> clicked = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  String seedString = "";

  void checkClicked(List<String> array, String text, int pos) {
    seedArray = array;
    if (seedArray.contains(text) && seedText.contains(text)) {
      clicked[pos] = false;
    } else {
      clicked[pos] = true;
    }
    notifyListeners();
  }

  void changeArray(List<String> array, String text) {
    seedString = "";
    seedArray = array;
    if (seedArray.contains(text) && seedText.contains(text)) {
      seedText.remove(text);
    } else {
      seedText.add(text);
    }
    for (String seed in seedText) {
      seedString += seed + " ";
    }
    notifyListeners();
  }

  bool checkArray(String text) {
    return seedString.trim() == text;
  }
}
