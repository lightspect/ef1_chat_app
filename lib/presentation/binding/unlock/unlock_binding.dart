import 'package:chat_app_ef1/presentation/controller/unlock/unlock_controller.dart';
import 'package:get/instance_manager.dart';

class UnlockBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UnlockController());
  }
}
