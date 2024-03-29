import 'dart:async';

import 'package:chat_app_ef1/Common/share_prefs.dart';
import 'package:chat_app_ef1/Model/api.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/messagesModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class DatabaseService extends ChangeNotifier {
  Api? _api = locator<Api>();

  late SharedPref sharedPref;
  UserModel? user;
  List<UserModel>? users;
  List<ContactModel>? contacts;
  List<GroupModel>? groups;
  List<MessagesModel>? messages;
  Stream<List<GroupModel>>? groupStream;
  late FirebaseMessaging firebaseMessaging;
  String? currentGroupId;

  DatabaseService() {
    firebaseMessaging = FirebaseMessaging.instance;
    sharedPref = SharedPref();
    user = new UserModel(userId: "", nickname: "", aboutMe: "", photoUrl: "");
    currentGroupId = "";
    readLocal();
  }

  Future readLocal() async {
    user = UserModel.fromMap(await sharedPref.read("user"));
    notifyListeners();
  }

  Future setLocal() async {
    await sharedPref.save("user", user!.toMap());
    readLocal();
  }

  Future readContactsList() async {
    List<dynamic> contactList = await sharedPref.read("contactList");
    contacts = contactList
        .map<ContactModel>((contact) => ContactModel.fromMap(contact))
        .toList();
  }

  Future setContactsList() async {
    await sharedPref.save(
        "contactList",
        contacts!
            .map<Map<String, dynamic>>((contact) => contact.toMap())
            .toList());
    readContactsList();
  }

  Future<List<UserModel>?> fetchUsers() async {
    var result = await _api!.getDataCollection('users');
    users = result.docs.map((doc) => UserModel.fromMap(doc.data() as Map<dynamic, dynamic>?)).toList();
    return users;
  }

  Future<List<UserModel>?> fetchUsersById(String id) async {
    var result = await _api!.getCollectionByCondition('users', 'id', id);
    users = result.docs.map((doc) => UserModel.fromMap(doc.data() as Map<dynamic, dynamic>?)).toList();
    return users;
  }

  Stream<QuerySnapshot> fetchUsersAsStream() {
    return _api!.streamDataCollection('users');
  }

  Future<UserModel> getUserById(String? id) async {
    var doc = await _api!.getDocumentById('users', id);
    return UserModel.fromMap(doc.data() as Map<dynamic, dynamic>?);
  }

  Future removeUser(String id) async {
    await _api!.removeDocument('users', id);
    return;
  }

  Future updateUser(UserModel data, String? id) async {
    await _api!.updateDocument('users', data.toMap(), id);
    return;
  }

  Future<DocumentReference> addUser(UserModel data) async {
    return await _api!.addDocument('users', data.toMap());
  }

  Future setUser(UserModel data, String id) async {
    await _api!.setDocument('users', data.toMap(), id);
    return;
  }

  Future<List<ContactModel>?> fetchContacts(String? id) async {
    var result = await _api!.getSubCollection('users', id, 'contacts');
    contacts =
        result.docs.map((doc) => ContactModel.fromMap(doc.data() as Map<dynamic, dynamic>?)).toList();
    return contacts;
  }

  Stream<QuerySnapshot> fetchContactsAsStream(String? id) {
    return _api!.streamSubCollection('users', id, 'contacts');
  }

  Future<ContactModel> getContactById(String? id, String? subId) async {
    var doc = await _api!.getSubDocumentById('users', id, 'contacts', subId);
    if (doc.exists) {
      return ContactModel.fromMap(doc.data() as Map<dynamic, dynamic>?);
    } else {
      return ContactModel(nickname: "", photoUrl: "", userId: "");
    }
  }

  Future removeContact(String? id, String? subId) async {
    await _api!.removeSubDocument('users', 'contacts', id, subId);
    return;
  }

  Future updateContact(ContactModel data, String? id, String? subId) async {
    await _api!.updateSubDocument('users', 'contacts', id, subId, data.toMap());
    return;
  }

  Future<DocumentReference> addContact(ContactModel data, String id) async {
    return await _api!.addSubDocument('users', 'contacts', id, data.toMap());
  }

  Future setContact(ContactModel data, String? id, String? subId) async {
    await _api!.setSubDocument('users', 'contacts', id, subId, data.toMap());
    return;
  }

  Future<List<GroupModel>?> fetchGroups() async {
    var result = await _api!.getDataCollection('groups');
    groups = result.docs.map((doc) => GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?)).toList();
    return groups;
  }

  Future<List<GroupModel>?> fetchGroupsById(String id) async {
    var result = await _api!.getCollectionByCondition('groups', 'groupId', id);
    groups = result.docs.map((doc) => GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?)).toList();
    return groups;
  }

  Future<List<GroupModel>?> fetchGroupsByUserId(String? id) async {
    var result = await _api!.getCollectionByArray('groups', 'members', id);
    groups = result.docs.map((doc) => GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?)).toList();
    return groups;
  }

  Stream<QuerySnapshot> fetchGroupsByUserIdAsStream(
      String field, String? userId) {
    return _api!.streamCollectionByArray('groups', field, userId);
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

  Future<DocumentReference> addGroup(GroupModel data) async {
    return await _api!.addDocument('groups', data.toMap());
  }

  Future setGroup(GroupModel data, String id) async {
    await _api!.setDocument('users', data.toMap(), id);
    return;
  }

  Future<List<MessagesModel>?> fetchMessages(String id) async {
    var result = await _api!.getSubCollection('messages', id, 'messages');
    messages = result.docs
        .map((doc) => MessagesModel.fromMap(doc.data() as Map<dynamic, dynamic>?, doc.id))
        .toList();
    return messages;
  }

  Stream<QuerySnapshot> fetchMessagesAsStream(String id) {
    return _api!.streamSubCollection('messages', id, 'messages');
  }

  Stream<QuerySnapshot> fetchMessagesAsStreamPagination(String? id, int limit) {
    return _api!.streamSubCollectionOrderByLimit(
        'messages', id, 'messages', 'sentAt', limit);
  }

  Future<MessagesModel> getMessageById(String id, String subId) async {
    var doc = await _api!.getSubDocumentById('messages', id, 'messages', subId);
    return MessagesModel.fromMap(doc.data() as Map<dynamic, dynamic>?, doc.id);
  }

  Future removeMessage(String id, String subId) async {
    await _api!.removeSubDocument('messages', 'messages', id, subId);
    return;
  }

  Future updateMessage(MessagesModel data, String? id, String? subId) async {
    await _api!.updateSubDocument(
        'messages', 'messages', id, subId, data.toMap());
    return;
  }

  Future<DocumentReference> addMessage(MessagesModel data, String id) async {
    return await _api!.addSubDocument('messages', 'messages', id, data.toMap());
  }

  Future setMessage(MessagesModel data, String id, String subId) async {
    await _api!.setSubDocument('messages', 'messages', id, subId, data.toMap());
    return;
  }

  Future<ContactModel> getContactDetail(List<dynamic> members) async {
    members.remove(user!.userId);
    ContactModel contactModel =
        await getContactById(user!.userId, members.first.trim());
    if (contactModel != null && contactModel.userId!.isNotEmpty) {
      return contactModel;
    } else {
      return new ContactModel(
          userId: members.first.trim(), nickname: "", photoUrl: "");
    }
  }

  Future<GroupModel> generateGroupMessage(GroupModel group) async {
    if (group.type == 1) {
      ContactModel contactModel = await getContactDetail(group.members!);
      group.groupName = contactModel.nickname!.isNotEmpty
          ? contactModel.nickname
          : contactModel.userId;
      group.groupPhoto = contactModel.photoUrl;
    }
    return group;
  }

  void refreshMessageList() {
    groupStream = fetchGroupsByUserIdAsStream('members', user!.userId)
        .asyncMap((docs) => Future.wait([
              for (GroupModel group in docs.docs
                  .map((doc) => GroupModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
                  .toList())
                generateGroupMessage(group)
            ]));
  }
}

class Debouncer {
  final int? milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds!), action);
  }
}
