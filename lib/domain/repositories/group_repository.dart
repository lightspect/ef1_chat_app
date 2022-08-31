import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class GroupRepository {
  Future<List<GroupModel>?> fetchGroups();

  Future<List<GroupModel>?> fetchGroupsById(String id);

  Future<List<GroupModel>?> fetchGroupsByUserId(String id);

  Stream<QuerySnapshot> fetchGroupsByUserIdAsStream(
      String field, String userId);

  Stream<QuerySnapshot> fetchGroupsByMemberArrayAsStream(
      String field, dynamic condition);

  Future<GroupModel> getGroupById(String id);

  Future removeGroup(String id);

  Future updateGroup(GroupModel data, String id);

  Future updateGroupField(Map<String, dynamic> data, String? id);

  Future<DocumentReference> addGroup(GroupModel data);

  Future setGroup(GroupModel data, String id);

  GroupModel generateGroupMessage(GroupModel group);

  List<GroupModel>? mapGroupMessageData(QuerySnapshot docs);

  Future<void> refreshMessageList();
}
