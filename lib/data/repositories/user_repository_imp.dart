import 'package:chat_app_ef1/data/datasource/server/user_datasource.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/domain/entities/contact_model.dart';
import 'package:chat_app_ef1/domain/repositories/user_repository.dart';

class UserRepositoryImp extends UserRepository {
  @override
  Future addUser(UserModel data) async {
    await ServerUserDatasource.addUser(data);
  }

  @override
  Future<bool> checkUserExist() {
    // TODO: implement checkUserExist
    throw UnimplementedError();
  }

  @override
  Future<UserModel> getUserById(String? id) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<List<ContactModel>> readContactsList() {
    // TODO: implement readContactsList
    throw UnimplementedError();
  }

  @override
  Future<List<GroupModel>> readGroupList() {
    // TODO: implement readGroupList
    throw UnimplementedError();
  }

  @override
  Future<UserModel> readLocal() {
    // TODO: implement readLocal
    throw UnimplementedError();
  }

  @override
  Future setContactList() {
    // TODO: implement setContactList
    throw UnimplementedError();
  }

  @override
  Future setGroupList() {
    // TODO: implement setGroupList
    throw UnimplementedError();
  }

  @override
  Future setLocal() {
    // TODO: implement setLocal
    throw UnimplementedError();
  }

  @override
  Future setUser(UserModel data, String id) {
    // TODO: implement setUser
    throw UnimplementedError();
  }

  @override
  Future updateUser(Map<String, dynamic> data, String id) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }
}
