import 'package:chat_app_ef1/presentation/pages/navigation/navigation_menu.dart';
import 'package:chat_app_ef1/presentation/binding/binding.dart';
import 'package:chat_app_ef1/presentation/pages/unlock/unlock.dart';
import 'package:chat_app_ef1/routes/routes.dart';
import 'package:get/route_manager.dart';

class Pages {
  static final pages = [
    GetPage(
      name: Routes.UNLOCK,
      binding: UnlockBinding(),
      page: () => UnlockPage(),
    ),
    GetPage(
      name: Routes.NAVIGATION_SCREEN,
      binding: NavigationBinding(),
      page: () => NavigationMenu(),
    ),
  ];
}
