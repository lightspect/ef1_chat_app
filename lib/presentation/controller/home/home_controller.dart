import 'dart:io';

import 'package:chat_app_ef1/core/helper/firebase_storage_helper.dart';
import 'package:chat_app_ef1/data/repositories/user_repository_imp.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/domain/usecases/user_usecase.dart';
import 'package:chat_app_ef1/presentation/controller/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class HomeController extends GetxController {
  UserUseCase _userUseCase = UserUseCase(repository: UserRepositoryImp());

  AuthController _authController = Get.find<AuthController>();

  var isLoading = false.obs;

  UserModel? user;

  File? avatarImageFile;

  final nicknameController = TextEditingController();
  final statusMessageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    readLocal();
  }

  void handleSignOut() async {
    isLoading.value = true;

    await _authController.handleSignOutGoogle();

    isLoading.value = false;
  }

  void readLocal() async {
    isLoading.value = true;
    if (_authController.user == null) {
      user = await _userUseCase.readLocal();
    } else {
      user = _authController.user;
    }
    isLoading.value = false;
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;
    File? image;

    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      image = File(pickedFile.path);
    }

    if (image != null) {
      avatarImageFile = image;
      isLoading.value = true;
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = user?.userId ?? _authController.user!.userId;
    await FirebaseStorageHelper.instance
        .uploadFile(fileName, avatarImageFile!)
        .then((value) {
      user?.photoUrl = value;
      _authController.user?.photoUrl = value;
      _userUseCase.setLocal(user!);
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });

    await _userUseCase.updateUser(user!.toMap(), user!.userId);
    Fluttertoast.showToast(msg: "Upload success");
    isLoading.value = false;
  }

  void handleUpdateData() {
    isLoading.value = true;

    _userUseCase.updateUser(user!.toMap(), user!.userId).then((data) async {
      await _userUseCase.setLocal(user!);
      isLoading.value = false;

      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) {
      isLoading.value = false;
      Fluttertoast.showToast(msg: err.toString());
    });
  }
}
