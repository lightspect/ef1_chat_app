import 'package:chat_app_ef1/core/helper/api.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDatasource {
  Api? _api = locator<Api>();

  UserModel? user;
  List<UserModel>? users;

  UserDatasource() {
    user = new UserModel(userId: "", nickname: "", aboutMe: "", photoUrl: "");
  }

  Future<List<UserModel>?> fetchUsers() async {
    var result = await _api!.getDataCollection('users');
    users = result.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return users;
  }

  Future<List<UserModel>?> fetchUsersById(String id) async {
    var result = await _api!.getCollectionByCondition('users', 'id', id);
    users = result.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return users;
  }

  Future<List<UserModel>?> fetchUsersByArray(List<String> id) async {
    var result = await _api!.getCollectionFromArray('users', 'id', id);
    users = result.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return users;
  }

  Future<UserModel> getUserById(String? id) async {
    var doc = await _api!.getDocumentById('users', id);
    return UserModel.fromMap(doc.data() as Map<dynamic, dynamic>?);
  }

  Future removeUser(String id) async {
    await _api!.removeDocument('users', id);
    return;
  }

  Future updateUser(UserModel data, String id) async {
    await _api!.updateDocument('users', data.toMap(), id);
    return;
  }

  Future updateUserField(Map<String, dynamic> data, String id) async {
    await _api!.updateDocument('users', data, id);
    return;
  }

  Future<DocumentReference> addUser(UserModel data) async {
    return await _api!.addDocument('users', data.toMap());
  }

  Future setUser(UserModel data, String id) async {
    await _api!.setDocument('users', data.toMap(), id);
    return;
  }

  Future<List<UserModel>?> getUsersByContact(String contactId) async {
    users = [];
    var result = await _api!
        .getDataCollectionBySubCollection("contacts", "id", contactId);
    for (QueryDocumentSnapshot element in result.docs) {
      await element.reference.parent.parent!
          .get()
          .then((value) => users!.add(UserModel.fromMap(value.data())));
    }
    return users;
  }
}
