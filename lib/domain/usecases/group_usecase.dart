import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/domain/repositories/group_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupUseCase {
  GroupRepository? repository;

  GroupUseCase({required this.repository});

  Future<List<GroupModel>?> fetchGroups() async {
    return await repository?.fetchGroups();
  }

  Future<List<GroupModel>?> fetchGroupsById(String id) async {
    return await repository?.fetchGroupsById(id);
  }

  Future<List<GroupModel>?> fetchGroupsByUserId(String id) async {
    return await repository?.fetchGroupsByUserId(id);
  }

  Stream<QuerySnapshot>? fetchGroupsByUserIdAsStream(
      String field, String userId) {
    return repository?.fetchGroupsByUserIdAsStream(field, userId);
  }

  Stream<QuerySnapshot>? fetchGroupsByMemberArrayAsStream(
      String field, dynamic condition) {
    return repository?.fetchGroupsByMemberArrayAsStream(field, condition);
  }

  Future<GroupModel?> getGroupById(String id) async {
    return await repository?.getGroupById(id);
  }

  Future removeGroup(String id) async {
    await repository?.removeGroup(id);
  }

  Future updateGroup(GroupModel data, String id) async {
    await repository?.updateGroup(data, id);
  }

  Future updateGroupField(Map<String, dynamic> data, String? id) async {
    await repository?.updateGroupField(data, id);
  }

  Future<DocumentReference?> addGroup(GroupModel data) async {
    return await repository?.addGroup(data);
  }

  Future setGroup(GroupModel data, String id) async {
    await repository?.setGroup(data, id);
  }

  GroupModel generateGroupMessage(GroupModel group) {
    return GroupModel();
  }

  List<GroupModel>? mapGroupMessageData(QuerySnapshot docs) {
    return [];
  }

  Future<void> refreshMessageList() async {}
}
