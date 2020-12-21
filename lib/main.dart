import 'package:chat_app_ef1/Model/databaseService.dart';
import 'package:chat_app_ef1/Model/navigationService.dart';
import 'package:chat_app_ef1/Screen/navigationMenu.dart';
import 'package:chat_app_ef1/Screen/qrcode.dart';
import 'package:chat_app_ef1/Screen/registration.dart';
import 'package:chat_app_ef1/Screen/seedConfirm.dart';
import 'package:chat_app_ef1/Screen/seedCreate.dart';
import 'package:chat_app_ef1/Screen/seedSuccess.dart';
import 'package:chat_app_ef1/Screen/splash.dart';
import 'package:chat_app_ef1/Screen/term.dart';
import 'package:chat_app_ef1/Screen/unlock.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        child: RefreshConfiguration(
          footerTriggerDistance: 15,
          dragSpeedRatio: 0.91,
          headerBuilder: () => MaterialClassicHeader(),
          footerBuilder: () => ClassicFooter(),
          enableLoadingWhenNoData: false,
          enableRefreshVibrate: false,
          enableLoadMoreVibrate: false,
          shouldFooterFollowWhenNotFull: (state) {
            // If you want load more with noMoreData state ,may be you should return false
            return false;
          },
          child: MaterialApp(
            navigatorKey: locator<NavigationService>().navigatorKey,
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
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
        ));
  }
}
