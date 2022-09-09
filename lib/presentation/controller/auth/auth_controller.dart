import 'package:chat_app_ef1/core/helper/FCM_helper.dart';
import 'package:chat_app_ef1/data/repositories/user_repository_imp.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/domain/usecases/user_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  UserUseCase useCase = UserUseCase(repository: UserRepositoryImp());

  UserModel? user;

  String currentGroupId = "";

  Map<String, List<UserModel>?> groupMembersList = {};

  handleSignIn() async {
    GoogleSignInAccount? googleUser = await (googleSignIn.signIn());
    GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    User? firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      // Check is already sign up
      UserModel? checkUser = await useCase.getUserById(firebaseUser.uid);
      if (checkUser == null) {
        String? token = FirebaseCloudMessageHelper.instance.deviceToken;
        user = new UserModel(
            userId: firebaseUser.uid,
            nickname: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
            createdAt: DateTime.now().toString(),
            aboutMe: "",
            token: token);
        // Update data to server if new user
        await useCase.setUser(user!, firebaseUser.uid);

        // Write data to local
        await useCase.setLocal(user!);
      } else {
        // Write data to local
        user = checkUser;
        if (checkUser.token !=
            FirebaseCloudMessageHelper.instance.deviceToken) {
          await useCase.updateUser(
              {"token": FirebaseCloudMessageHelper.instance.deviceToken},
              checkUser.userId);
        }
        await useCase.setLocal(user!);
      }
    }
  }
}
