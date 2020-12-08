import 'package:flutter/material.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';

class SplashScreenDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenDemo> {
  @override
  Widget build(BuildContext context) {
    String assets = "assets/welcome_page.flr";
    var _size = MediaQuery.of(context).size;
    return SplashScreen.callback(
      name: assets,
      onSuccess: (_) {
        Navigator.of(context).pushReplacementNamed('/unlock');
      },
      onError: (e, s) {},
      height: _size.height,
      alignment: Alignment.center,
      until: () => Future.delayed(Duration(seconds: 3)),
      backgroundColor: Colors.white,
      startAnimation: "welcome",
    );
  }
}
