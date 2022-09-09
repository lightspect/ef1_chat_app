import 'package:chat_app_ef1/core/helper/FCM_helper.dart';
import 'package:chat_app_ef1/core/helper/share_prefs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static Future<void> settingApp() async {
    await dotenv.load(fileName: 'env/.env_dev');
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await SharedPref.init();
    await FirebaseCloudMessageHelper.instance.registerNotification();
  }
}