import 'package:chat_app_ef1/data/repositories/user_repository_imp.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/domain/usecases/user_usecase.dart';
import 'package:chat_app_ef1/presentation/controller/auth/auth_controller.dart';
import 'package:chat_app_ef1/routes/routes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class UnlockController extends GetxController {
  UserUseCase useCase = UserUseCase(repository: UserRepositoryImp());

  bool isLoading = true;
  bool isLoggedIn = false;
  UserModel? user;

  AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    isSignedIn();
  }

  void isSignedIn() async {
    isLoggedIn = await authController.googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Get.toNamed(Routes.NAVIGATION_SCREEN);
    }

    isLoading = false;
    update();
  }

  handleSignIn() async {
    await authController.handleSignIn();

    if (authController.user != null) {
      Get.toNamed(Routes.NAVIGATION_SCREEN);
      Fluttertoast.showToast(msg: "Sign in success");
      isLoading = false;
      update();
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      isLoading = false;
      update();
    }
  }
}
