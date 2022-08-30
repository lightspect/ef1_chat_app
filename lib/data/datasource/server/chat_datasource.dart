import 'package:chat_app_ef1/domain/entities/contact_model.dart';
import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDatasource {
  Future<GroupModel> generateGroupMessage(GroupModel group) async {
    if (group.type == 1) {
      // ContactModel contactModel = await getContactDetail(group.membersList!);
      // group.groupName = contactModel.nickname!.isNotEmpty
      //     ? contactModel.nickname
      //     : contactModel.userId;
      // group.groupPhoto = contactModel.photoUrl;
    }

    return group;
  }

  Future<List<GroupModel>?> mapGroupMessageData(QuerySnapshot docs) async {
    List<GroupModel> list = docs.docs
        .map((doc) => GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    List<GroupModel> groups = [];
    for (GroupModel group in list) {
      GroupModel addGroup = await generateGroupMessage(group);
      groups.add(addGroup);
    }
    return groups;
  }
}
