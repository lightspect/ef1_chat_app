import 'package:chat_app_ef1/core/helper/api.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServerUserDatasource {
  static Api? _api = locator<Api>();

  static Future<List<UserModel>?> fetchUsers() async {
    var result = await _api!.getDataCollection('users');
    List<UserModel>? users = result.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return users;
  }

  static Future<List<UserModel>?> fetchUsersById(String id) async {
    var result = await _api!.getCollectionByCondition('users', 'id', id);
    List<UserModel>? users = result.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return users;
  }

  static Future<List<UserModel>?> fetchUsersByArray(List<String> id) async {
    var result = await _api!.getCollectionFromArray('users', 'id', id);
    List<UserModel>? users = result.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return users;
  }

  static Future<UserModel> getUserById(String? id) async {
    var doc = await _api!.getDocumentById('users', id);
    return UserModel.fromMap(doc.data() as Map<dynamic, dynamic>?);
  }

  static Future removeUser(String id) async {
    await _api!.removeDocument('users', id);
    return;
  }

  static Future updateUser(UserModel data, String id) async {
    await _api!.updateDocument('users', data.toMap(), id);
    return;
  }

  static Future updateUserField(Map<String, dynamic> data, String id) async {
    await _api!.updateDocument('users', data, id);
    return;
  }

  static Future<DocumentReference> addUser(UserModel data) async {
    return await _api!.addDocument('users', data.toMap());
  }

  static Future setUser(UserModel data, String id) async {
    await _api!.setDocument('users', data.toMap(), id);
    return;
  }

  static Future<List<UserModel>?> getUsersByContact(String contactId) async {
    List<UserModel>? users = [];
    var result = await _api!
        .getDataCollectionBySubCollection("contacts", "id", contactId);
    for (QueryDocumentSnapshot element in result.docs) {
      await element.reference.parent.parent!
          .get()
          .then((value) => users.add(UserModel.fromMap(value.data())));
    }
    return users;
  }
}
