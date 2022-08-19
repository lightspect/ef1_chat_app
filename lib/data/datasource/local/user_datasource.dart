import 'package:chat_app_ef1/core/helper/share_prefs.dart';
import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/domain/entities/user_model.dart';

class UserDatasource {
  late SharedPref sharedPref;
  UserModel? user;
  List<UserModel>? users;
  List<ContactModel?>? contacts;
  List<GroupModel>? groups;

  UserDatasource() {
    sharedPref = SharedPref();
    readLocal();
    readContactsList();
    user = new UserModel(userId: "", nickname: "", aboutMe: "", photoUrl: "");
    contacts = [];
    groups = [];
  }

  Future readLocal() async {
    user = UserModel.fromMap(await sharedPref.read("user"));
  }

  Future setLocal() async {
    await sharedPref.save("user", user!.toMap());
    readLocal();
  }

  Future readContactsList() async {
    List<dynamic> contactList = await sharedPref.read("contactList");
    contacts = contactList
        .map<ContactModel?>((contact) => ContactModel.fromMap(contact))
        .toList();
  }

  Future setContactsList() async {
    await sharedPref.save(
        "contactList",
        contacts!
            .map<Map<String, dynamic>>((contact) => contact!.toMap())
            .toList());
    readContactsList();
  }

  Future readGroupsList() async {
    List<dynamic> groupList = await sharedPref.read("groupList");
    groups = groupList
        .map<GroupModel>((group) => GroupModel.fromMap(group))
        .toList();
  }

  Future setGroupList() async {
    await sharedPref.save("groupList",
        groups!.map<Map<String, dynamic>>((group) => group.toMap()).toList());
    readGroupsList();
  }
}
