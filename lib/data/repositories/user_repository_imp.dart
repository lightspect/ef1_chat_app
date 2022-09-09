import 'package:chat_app_ef1/data/datasource/local/user_datasource.dart';
import 'package:chat_app_ef1/data/datasource/server/user_datasource.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/domain/entities/contact_model.dart';
import 'package:chat_app_ef1/domain/repositories/user_repository.dart';

class UserRepositoryImp implements UserRepository {
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
  Future<UserModel?> getUserById(String? id) async {
    return await ServerUserDatasource.getUserById(id);
  }

  @override
  Future<List<ContactModel?>> readContactsList() async {
    return await LocalUserDatasource.readContactsList();
  }

  @override
  Future<List<GroupModel?>> readGroupList() async {
    return await LocalUserDatasource.readGroupsList();
  }

  @override
  Future<UserModel> readLocal() async {
    return await LocalUserDatasource.readLocal();
  }

  @override
  Future setContactList(contacts) async {
    await LocalUserDatasource.setContactsList(contacts);
  }

  @override
  Future setUser(UserModel data, String id) async {
    await ServerUserDatasource.setUser(data, id);
  }

  @override
  Future updateUser(Map<String, dynamic> data, String id) async {
    await ServerUserDatasource.updateUserField(data, id);
  }

  @override
  Future setGroupList(List<GroupModel> groups) async {
    await LocalUserDatasource.setGroupList(groups);
  }

  @override
  Future setLocal(UserModel user) async {
    await LocalUserDatasource.setLocal(user);
  }
}
