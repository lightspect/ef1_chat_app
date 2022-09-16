import 'package:chat_app_ef1/data/repositories/user_repository_imp.dart';
import 'package:chat_app_ef1/domain/usecases/user_usecase.dart';
import 'package:chat_app_ef1/presentation/controller/auth/auth_controller.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  UserUseCase _useCase = UserUseCase(repository: UserRepositoryImp());

  AuthController _authController = Get.find<AuthController>();

  bool isLoading = false;

  void handleSignOut() async {
    isLoading = true;

    await _authController.handleSignOutGoogle();

    isLoading = false;
  }
}
