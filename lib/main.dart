import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/presentation/binding/unlock/unlock_binding.dart';
import 'package:chat_app_ef1/presentation/controller/auth/auth_controller.dart';
import 'package:chat_app_ef1/presentation/pages/navigation/navigation_menu.dart';
import 'package:chat_app_ef1/Screen/qrcode.dart';
import 'package:chat_app_ef1/Screen/registration.dart';
import 'package:chat_app_ef1/Screen/seedConfirm.dart';
import 'package:chat_app_ef1/Screen/seedCreate.dart';
import 'package:chat_app_ef1/Screen/seedSuccess.dart';
import 'package:chat_app_ef1/Screen/splash.dart';
import 'package:chat_app_ef1/Screen/term.dart';
import 'package:chat_app_ef1/presentation/pages/unlock/unlock.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:chat_app_ef1/routes/pages.dart';
import 'package:chat_app_ef1/setting/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await Config.settingApp();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<DatabaseService>()),
      ],
      child: GetMaterialApp(
        title: 'EF1 ChatApp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        getPages: Pages.pages,
        initialBinding: UnlockBinding(),
        home: SplashScreenDemo(),
        initialRoute: '/',
        routes: {
          '/unlock': (context) => UnlockPage(),
          '/term': (context) => TermService(),
          '/registration': (context) => RegistrationPage(),
          '/seedCreate': (context) => SeedCreatePage(),
          '/seedConfirm': (context) => SeedConfirmPage(),
          '/seedSuccess': (context) => SeedSuccessPage(),
          '/navigationMenu': (context) => NavigationMenu(),
          '/qrscan': (context) => ScanScreen(),
        },
      ),
    );
  }
}
