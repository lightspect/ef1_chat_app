import 'package:chat_app_ef1/domain/entities/contact_model.dart';
import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';
import 'package:chat_app_ef1/domain/repositories/user_repository.dart';

class UserUseCase {
  UserUseCase({required this.repository});

  UserRepository? repository;

  Future<UserModel?> readLocal() async {
    return await repository?.readLocal();
  }

  Future setLocal(UserModel user) async {
    await repository?.setLocal(user);
  }

  Future<List<ContactModel?>?> readContactsList() async {
    return await repository?.readContactsList();
  }

  Future setContactList(List<ContactModel> contacts) async {
    await repository?.setContactList(contacts);
  }

  Future<List<GroupModel?>?> readGroupList() async {
    return await repository?.readGroupList();
  }

  Future setGroupList(List<GroupModel> groups) async {
    await repository?.setGroupList(groups);
  }

  Future<bool> checkUserExist() async {
    return true;
  }

  Future<UserModel?> getUserById(String? id) async {
    return await repository?.getUserById(id);
  }

  Future updateUser(Map<String, dynamic> data, String id) async {
    await repository?.updateUser(data, id);
  }

  Future setUser(UserModel data, String id) async {
    await repository?.setUser(data, id);
  }

  Future addUser(UserModel data) async {
    await repository?.addUser(data);
  }

  Future updateUserStatus(Map<String, dynamic> data, String uid) async {
    await repository?.updateUserStatus(data, uid);
  }
}
