import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/domain/entities/contact_model.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> readLocal();

  Future setLocal(UserModel user);

  Future<List<ContactModel?>> readContactsList();

  Future setContactList(List<ContactModel> contacts);

  Future<List<GroupModel?>> readGroupList();

  Future setGroupList(List<GroupModel> groups);

  Future<bool> checkUserExist();

  Future<UserModel?> getUserById(String? id);

  Future updateUser(Map<String, dynamic> data, String id);

  Future setUser(UserModel data, String id);

  Future addUser(UserModel data);
}
