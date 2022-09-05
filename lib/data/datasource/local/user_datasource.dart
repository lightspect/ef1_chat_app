import 'package:chat_app_ef1/core/helper/share_prefs.dart';
import 'package:chat_app_ef1/domain/entities/contact_model.dart';
import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';

class LocalUserDatasource {
  static SharedPref sharedPref = SharedPref.getInstance();

  static Future<UserModel> readLocal() async {
    UserModel localUser = UserModel.fromMap(await sharedPref.read("user"));
    return localUser;
  }

  static Future setLocal(UserModel? user) async {
    await sharedPref.save("user", user!.toMap());
  }

  static Future<List<ContactModel?>> readContactsList() async {
    List<dynamic> contactList = await sharedPref.read("contactList");
    List<ContactModel?> contacts = contactList
        .map<ContactModel?>((contact) => ContactModel.fromMap(contact))
        .toList();
    return contacts;
  }

  static Future setContactsList(List<ContactModel?> contacts) async {
    await sharedPref.save(
        "contactList",
        contacts
            .map<Map<String, dynamic>>((contact) => contact!.toMap())
            .toList());
  }

  static Future<List<GroupModel?>> readGroupsList() async {
    List<dynamic> groupList = await sharedPref.read("groupList");
    List<GroupModel?> groups = groupList
        .map<GroupModel>((group) => GroupModel.fromMap(group))
        .toList();
    return groups;
  }

  static Future setGroupList(List<GroupModel>? groups) async {
    await sharedPref.save("groupList",
        groups!.map<Map<String, dynamic>>((group) => group.toMap()).toList());
  }
}
