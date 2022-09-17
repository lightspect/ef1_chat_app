import 'package:chat_app_ef1/data/repositories/contact_repository_imp.dart';
import 'package:chat_app_ef1/data/repositories/user_repository_imp.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/domain/usecases/contact_usecase.dart';
import 'package:chat_app_ef1/domain/usecases/user_usecase.dart';
import 'package:chat_app_ef1/presentation/controller/auth/auth_controller.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  UserUseCase _userUseCase = UserUseCase(repository: UserRepositoryImp());
  ContactUseCase _contactUseCase =
      ContactUseCase(repository: ContactRepositoryImp());

  AuthController _authController = Get.find<AuthController>();

  bool isLoading = false;

  UserModel? user;

  @override
  void onInit() {
    super.onInit();
    readLocal();
  }

  void handleSignOut() async {
    isLoading = true;

    await _authController.handleSignOutGoogle();

    isLoading = false;
  }

  void readLocal() async {
    isLoading = true;
    user = await _userUseCase.readLocal();
    if (user != null) {
      await _contactUseCase.fetchContacts(user!.userId);
    }
  }
}
