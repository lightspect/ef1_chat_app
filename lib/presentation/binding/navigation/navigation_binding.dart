import 'package:chat_app_ef1/presentation/controller/navigation/navigation_controller.dart';
import 'package:get/instance_manager.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NavigationController());
  }
}
