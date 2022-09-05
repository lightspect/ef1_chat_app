import 'package:chat_app_ef1/data/datasource/server/group_datasource.dart';
import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/domain/repositories/group_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupRepositoryImp implements GroupRepository {
  @override
  Future<DocumentReference<Object?>> addGroup(GroupModel data) async {
    return await GroupDatasource.addGroup(data);
  }

  @override
  Future<List<GroupModel>?> fetchGroups() async {
    return await GroupDatasource.fetchGroups();
  }

  @override
  Future<List<GroupModel>?> fetchGroupsById(String id) async {
    return await GroupDatasource.fetchGroupsById(id);
  }

  @override
  Stream<QuerySnapshot<Object?>> fetchGroupsByMemberArrayAsStream(
      String field, condition) {
    return GroupDatasource.fetchGroupsByMemberArrayAsStream(field, condition);
  }

  @override
  Future<List<GroupModel>?> fetchGroupsByUserId(String id) async {
    return await GroupDatasource.fetchGroupsById(id);
  }

  @override
  Stream<QuerySnapshot<Object?>> fetchGroupsByUserIdAsStream(
      String field, String userId) {
    return GroupDatasource.fetchGroupsByUserIdAsStream(field, userId);
  }

  @override
  GroupModel generateGroupMessage(GroupModel group) {
    return GroupDatasource.generateGroupMessage(group);
  }

  @override
  Future<GroupModel> getGroupById(String id) async {
    return GroupDatasource.getGroupById(id);
  }

  @override
  List<GroupModel>? mapGroupMessageData(QuerySnapshot<Object?> docs) {
    return GroupDatasource.mapGroupMessageData(docs);
  }

  @override
  Future<void> refreshMessageList() async {
    await GroupDatasource.refreshMessageList();
  }

  @override
  Future removeGroup(String id) async {
    await GroupDatasource.removeGroup(id);
  }

  @override
  Future setGroup(GroupModel data, String id) async {
    await GroupDatasource.setGroup(data, id);
  }

  @override
  Future updateGroup(GroupModel data, String id) async {
    await GroupDatasource.updateGroup(data, id);
  }

  @override
  Future updateGroupField(Map<String, dynamic> data, String? id) async {
    await GroupDatasource.updateGroupField(data, id);
  }
}
