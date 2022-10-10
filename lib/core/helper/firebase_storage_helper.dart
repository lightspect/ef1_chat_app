import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirebaseStorageHelper {
  FirebaseStorageHelper._();

  static final FirebaseStorageHelper instance = FirebaseStorageHelper._();
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  Future<String> uploadFile(String fileName, File avatarImageFile) async {
    Reference reference = firebaseStorage.ref().child(fileName);
    await reference.putFile(avatarImageFile).catchError((err) {
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
    return reference.getDownloadURL();
  }
}
