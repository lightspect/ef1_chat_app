import 'package:chat_app_ef1/core/helper/api.dart';
import 'package:chat_app_ef1/domain/entities/groups_model.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupDatasource {
  Api? _api = locator<Api>();
  List<GroupModel>? groups;

  Future<List<GroupModel>?> fetchGroups() async {
    var result = await _api!.getDataCollection('groups');
    groups = result.docs
        .map((doc) => GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return groups;
  }

  Future<List<GroupModel>?> fetchGroupsById(String id) async {
    var result = await _api!.getCollectionByCondition('groups', 'groupId', id);
    groups = result.docs
        .map((doc) => GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return groups;
  }

  Future<List<GroupModel>?> fetchGroupsByUserId(String id) async {
    var result = await _api!.getCollectionByArray('groups', 'members', id);
    groups = result.docs
        .map((doc) => GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return groups;
  }

  Stream<QuerySnapshot> fetchGroupsByUserIdAsStream(
      String field, String userId) {
    return _api!.streamCollectionByArray('groups', field, userId);
  }

  Stream<QuerySnapshot> fetchGroupsByMemberArrayAsStream(
      String field, dynamic condition) {
    return _api!.streamCollectionByArrayAny('groups', field, condition);
  }

  Future<GroupModel> getGroupById(String id) async {
    var doc = await _api!.getDocumentById('groups', id);
    return GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?);
  }

  Future removeGroup(String id) async {
    await _api!.removeDocument('groups', id);
    return;
  }

  Future updateGroup(GroupModel data, String id) async {
    await _api!.updateDocument('groups', data.toMap(), id);
    return;
  }

  Future updateGroupField(Map<String, dynamic> data, String? id) async {
    await _api!.updateDocument('groups', data, id);
    return;
  }

  Future<DocumentReference> addGroup(GroupModel data) async {
    return await _api!.addDocument('groups', data.toMap());
  }

  Future setGroup(GroupModel data, String id) async {
    await _api!.setDocument('users', data.toMap(), id);
    return;
  }
}
