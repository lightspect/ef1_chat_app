import 'package:chat_app_ef1/Screen/chat.dart';
import 'package:chat_app_ef1/Screen/contact.dart';
import 'package:chat_app_ef1/presentation/pages/home/home.dart';
import 'package:chat_app_ef1/Screen/message.dart';
import 'package:chat_app_ef1/presentation/pages/navigation/navigation_menu.dart';
import 'package:chat_app_ef1/Screen/wallet.dart';
import 'package:chat_app_ef1/core/widget/reusable_widget.dart';
import 'package:chat_app_ef1/domain/entities/screen_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const FIRST_SCREEN = 0;
const SECOND_SCREEN = 1;
const THIRD_SCREEN = 2;
const FOURTH_SCREEN = 3;

class NavigationProvider extends ChangeNotifier {
  /// Shortcut method for getting [NavigationProvider].
  static NavigationProvider of(BuildContext context) =>
      Provider.of<NavigationProvider>(context, listen: false);

  int _currentScreenIndex = FIRST_SCREEN;

  int get currentTabIndex => _currentScreenIndex;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    print('Generating route: ${settings.name}');
    switch (settings.name) {
      case ChatPage.route:
        return MaterialPageRoute(builder: (_) => ChatPage());
      default:
        return MaterialPageRoute(builder: (_) => NavigationMenu());
    }
  }

  final Map<int, Screen> _screens = {
    FIRST_SCREEN: Screen(
      title: 'My Profile',
      icon: Icon(
        Icons.home,
        size: 16,
      ),
      child: HomePage(),
      initialRoute: HomePage.route,
      navigatorState: GlobalKey<NavigatorState>(),
      onGenerateRoute: (settings) {
        print('Generating route: ${settings.name}');
        switch (settings.name) {
          default:
            return MaterialPageRoute(
                settings: RouteSettings(name: "/home"),
                builder: (_) => HomePage());
        }
      },
    ),
    SECOND_SCREEN: Screen(
      title: 'Message',
      icon: Icon(
        Icons.messenger,
        size: 16,
      ),
      child: MessagePage(),
      initialRoute: MessagePage.route,
      navigatorState: GlobalKey<NavigatorState>(),
      onGenerateRoute: (settings) {
        print('Generating route: ${settings.name}');
        switch (settings.name) {
          default:
            return MaterialPageRoute(
                settings: RouteSettings(name: "/message"),
                builder: (_) => MessagePage());
        }
      },
      //scrollController: ScrollController(),
    ),
    THIRD_SCREEN: Screen(
      title: 'Wallet',
      icon: Icon(
        Icons.account_balance_wallet,
        size: 16,
      ),
      child: WalletPage(),
      initialRoute: WalletPage.route,
      navigatorState: GlobalKey<NavigatorState>(),
      onGenerateRoute: (settings) {
        print('Generating route: ${settings.name}');
        switch (settings.name) {
          default:
            return MaterialPageRoute(
                settings: RouteSettings(name: "/wallet"),
                builder: (_) => WalletPage());
        }
      },
      //scrollController: ScrollController(),
    ),
    FOURTH_SCREEN: Screen(
      title: 'Contact',
      icon: Icon(
        Icons.group,
        size: 16,
      ),
      child: ContactPage(),
      initialRoute: ContactPage.route,
      navigatorState: GlobalKey<NavigatorState>(),
      onGenerateRoute: (settings) {
        print('Generating route: ${settings.name}');
        switch (settings.name) {
          default:
            return MaterialPageRoute(
                settings: RouteSettings(name: "/contact"),
                builder: (_) => ContactPage());
        }
      },
      //scrollController: ScrollController(),
    ),
  };

  List<Screen> get screens => _screens.values.toList();

  Screen? get currentScreen => _screens[_currentScreenIndex];

  /// Set currently visible tab.
  void setTab(int tab) {
    if (tab == currentTabIndex) {
      _scrollToStart();
    } else {
      _currentScreenIndex = tab;
      notifyListeners();
    }
  }

  /// If currently displayed screen has given [ScrollController] animate it
  /// to the start of scroll view.
  void _scrollToStart() {
    if (currentScreen!.scrollController != null) {
      currentScreen!.scrollController!.animateTo(
        0,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Provide this to [WillPopScope] callback.
  Future<bool?> onWillPop(BuildContext context) async {
    final currentNavigatorState = currentScreen!.navigatorState.currentState!;

    if (currentNavigatorState.canPop()) {
      currentNavigatorState.pop();
      return false;
    } else {
      if (currentTabIndex != FIRST_SCREEN) {
        setTab(FIRST_SCREEN);
        notifyListeners();
        return false;
      } else {
        return await showDialog(
          context: context,
          builder: (context) => ExitAlertDialog(),
        );
      }
    }
  }
}
