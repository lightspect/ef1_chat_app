import 'package:chat_app_ef1/core/helper/api.dart';
import 'package:chat_app_ef1/domain/entities/contact_model.dart';
import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupDatasource {
  static Api? _api = locator<Api>();
  static List<GroupModel>? groups;

  static Future<List<GroupModel>?> fetchGroups() async {
    var result = await _api!.getDataCollection('groups');
    groups = result.docs
        .map((doc) => GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return groups;
  }

  static Future<List<GroupModel>?> fetchGroupsById(String id) async {
    var result = await _api!.getCollectionByCondition('groups', 'groupId', id);
    groups = result.docs
        .map((doc) => GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return groups;
  }

  static Future<List<GroupModel>?> fetchGroupsByUserId(String id) async {
    var result = await _api!.getCollectionByArray('groups', 'members', id);
    groups = result.docs
        .map((doc) => GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return groups;
  }

  static Stream<QuerySnapshot> fetchGroupsByUserIdAsStream(
      String field, String userId) {
    return _api!.streamCollectionByArray('groups', field, userId);
  }

  static Stream<QuerySnapshot> fetchGroupsByMemberArrayAsStream(
      String field, dynamic condition) {
    return _api!.streamCollectionByArrayAny('groups', field, condition);
  }

  static Future<GroupModel> getGroupById(String id) async {
    var doc = await _api!.getDocumentById('groups', id);
    return GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?);
  }

  static Future removeGroup(String id) async {
    await _api!.removeDocument('groups', id);
    return;
  }

  static Future updateGroup(GroupModel data, String id) async {
    await _api!.updateDocument('groups', data.toMap(), id);
    return;
  }

  static Future updateGroupField(Map<String, dynamic> data, String? id) async {
    await _api!.updateDocument('groups', data, id);
    return;
  }

  static Future<DocumentReference> addGroup(GroupModel data) async {
    return await _api!.addDocument('groups', data.toMap());
  }

  static Future setGroup(GroupModel data, String id) async {
    await _api!.setDocument('users', data.toMap(), id);
    return;
  }

  static GroupModel generateGroupMessage(GroupModel group) {
    if (group.type == 1) {
      ContactModel contactModel = getContactDetail(group.membersList!);
      group.groupName = contactModel.nickname!.isNotEmpty
          ? contactModel.nickname
          : contactModel.userId;
      group.groupPhoto = contactModel.photoUrl;
    }

    return group;
  }

  static List<GroupModel>? mapGroupMessageData(QuerySnapshot docs) {
    List<GroupModel> list = docs.docs
        .map((doc) => GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    List<GroupModel> groups = [];
    for (GroupModel group in list) {
      GroupModel addGroup = generateGroupMessage(group);
      groups.add(addGroup);
    }
    return groups;
  }

  static ContactModel getContactDetail(List<dynamic> members) {
    // members.removeWhere((element) => element.userId == user!.userId);
    // ContactModel? contactModel = contacts!.firstWhere(
    //     (element) => element!.userId == members.first.userId,
    //     orElse: () => null);
    // if (contactModel != null && contactModel.userId!.isNotEmpty) {
    //   return contactModel;
    // } else {
    return new ContactModel(
        userId: members.first.userId, nickname: "", photoUrl: "");
    // }
  }

  static Future<void> refreshMessageList() async {
    print("refresh");
    // groupStream = fetchGroupsByMemberArrayAsStream('membersList', [
    //   {"isActive": true, "role": 1, "userId": user!.userId},
    //   {"isActive": true, "role": 2, "userId": user!.userId}
    // ]).asyncMap((docs) => mapGroupMessageData(docs));
  }
}
