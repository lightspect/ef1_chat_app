import 'dart:async';

import 'package:chat_app_ef1/Common/share_prefs.dart';
import 'package:chat_app_ef1/Model/api.dart';
import 'package:chat_app_ef1/Model/groupsModel.dart';
import 'package:chat_app_ef1/Model/messagesModel.dart';
import 'package:chat_app_ef1/Model/userModel.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseService extends ChangeNotifier {
  Api _api = locator<Api>();

  SharedPref sharedPref;
  UserModel user;
  List<UserModel> users;
  List<ContactModel> contacts;
  List<GroupModel> groups;
  List<MessagesModel> messages;
  List<OnlineStatusModel> statusList;
  Stream<List<OnlineStatusModel>> contactStatusList;
  Stream<List<GroupModel>> groupStream;
  String currentGroupId;
  Map<String, List<UserModel>> groupMembersList;
  DatabaseReference databaseReference;

  DatabaseService() {
    sharedPref = SharedPref();
    user = new UserModel(userId: "", nickname: "", aboutMe: "", photoUrl: "");
    contacts = [];
    groups = [];
    statusList = [];
    currentGroupId = "";
    groupMembersList = {};
    readLocal();
    readContactsList();
    databaseReference = FirebaseDatabase.instance.reference();
  }

  Future readLocal() async {
    user = UserModel.fromMap(await sharedPref.read("user"));
    notifyListeners();
  }

  Future setLocal() async {
    await sharedPref.save("user", user.toMap());
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
        contacts
            .map<Map<String, dynamic>>((contact) => contact.toMap())
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
        groups.map<Map<String, dynamic>>((group) => group.toMap()).toList());
    readGroupsList();
  }

  Future<List<UserModel>> fetchUsers() async {
    var result = await _api.getDataCollection('users');
    users = result.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    return users;
  }

  Future<List<UserModel>> fetchUsersById(String id) async {
    var result = await _api.getCollectionByCondition('users', 'id', id);
    users = result.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    return users;
  }

  Future<List<UserModel>> fetchUsersByArray(List<String> id) async {
    var result = await _api.getCollectionFromArray('users', 'id', id);
    users = result.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    return users;
  }

  Future<UserModel> getUserById(String id) async {
    var doc = await _api.getDocumentById('users', id);
    return UserModel.fromMap(doc.data());
  }

  Future removeUser(String id) async {
    await _api.removeDocument('users', id);
    return;
  }

  Future updateUser(UserModel data, String id) async {
    await _api.updateDocument('users', data.toMap(), id);
    return;
  }

  Future updateUserField(Map<String, dynamic> data, String id) async {
    await _api.updateDocument('users', data, id);
    return;
  }

  Future<DocumentReference> addUser(UserModel data) async {
    return await _api.addDocument('users', data.toMap());
  }

  Future setUser(UserModel data, String id) async {
    await _api.setDocument('users', data.toMap(), id);
    return;
  }

  Future<List<UserModel>> getUsersByContact(String contactId) async {
    users = [];
    var result = await _api.getDataCollectionBySubCollection(
        "contacts", "id", contactId);
    for (QueryDocumentSnapshot element in result.docs) {
      await element.reference.parent.parent
          .get()
          .then((value) => users.add(UserModel.fromMap(value.data())));
    }
    return users;
  }

  Future<List<ContactModel>> fetchContacts(String id) async {
    var result = await _api.getSubCollection('users', id, 'contacts');
    contacts =
        result.docs.map((doc) => ContactModel.fromMap(doc.data())).toList();
    return contacts;
  }

  Stream<QuerySnapshot> fetchContactsAsStream(String id) {
    return _api.streamSubCollection('users', id, 'contacts');
  }

  Future<ContactModel> getContactById(String id, String subId) async {
    var doc = await _api.getSubDocumentById('users', id, 'contacts', subId);
    if (doc.exists) {
      return ContactModel.fromMap(doc.data());
    } else {
      return ContactModel(nickname: "", photoUrl: "", userId: "");
    }
  }

  Future removeContact(String id, String subId) async {
    await _api.removeSubDocument('users', 'contacts', id, subId);
    return;
  }

  Future updateContact(ContactModel data, String id, String subId) async {
    await _api.updateSubDocument('users', 'contacts', id, subId, data.toMap());
    return;
  }

  Future updateContactField(
      Map<String, dynamic> data, String id, String subId) async {
    await _api.updateSubDocument('users', 'contacts', id, subId, data);
    return;
  }

  Future<DocumentReference> addContact(ContactModel data, String id) async {
    return await _api.addSubDocument('users', 'contacts', id, data.toMap());
  }

  Future setContact(ContactModel data, String id, String subId) async {
    await _api.setSubDocument('users', 'contacts', id, subId, data.toMap());
    return;
  }

  Future<List<GroupModel>> fetchGroups() async {
    var result = await _api.getDataCollection('groups');
    groups = result.docs.map((doc) => GroupModel.fromMap(doc.data())).toList();
    return groups;
  }

  Future<List<GroupModel>> fetchGroupsById(String id) async {
    var result = await _api.getCollectionByCondition('groups', 'groupId', id);
    groups = result.docs.map((doc) => GroupModel.fromMap(doc.data())).toList();
    return groups;
  }

  Future<List<GroupModel>> fetchGroupsByUserId(String id) async {
    var result = await _api.getCollectionByArray('groups', 'members', id);
    groups = result.docs.map((doc) => GroupModel.fromMap(doc.data())).toList();
    return groups;
  }

  Stream<QuerySnapshot> fetchGroupsByUserIdAsStream(
      String field, String userId) {
    return _api.streamCollectionByArray('groups', field, userId);
  }

  Stream<QuerySnapshot> fetchGroupsByMemberArrayAsStream(
      String field, dynamic condition) {
    return _api.streamCollectionByArrayAny('groups', field, condition);
  }

  Future<GroupModel> getGroupById(String id) async {
    var doc = await _api.getDocumentById('groups', id);
    return GroupModel.fromMap(doc.data());
  }

  Future removeGroup(String id) async {
    await _api.removeDocument('groups', id);
    return;
  }

  Future updateGroup(GroupModel data, String id) async {
    await _api.updateDocument('groups', data.toMap(), id);
    return;
  }

  Future updateGroupField(Map<String, dynamic> data, String id) async {
    await _api.updateDocument('groups', data, id);
    return;
  }

  Future<DocumentReference> addGroup(GroupModel data) async {
    return await _api.addDocument('groups', data.toMap());
  }

  Future setGroup(GroupModel data, String id) async {
    await _api.setDocument('users', data.toMap(), id);
    return;
  }

  Future<List<MessagesModel>> fetchMessages(String id) async {
    var result = await _api.getSubCollection('messages', id, 'messages');
    messages = result.docs
        .map((doc) => MessagesModel.fromMap(doc.data(), doc.id))
        .toList();
    return messages;
  }

  Stream<QuerySnapshot> fetchMessagesAsStream(String id) {
    return _api.streamSubCollection('messages', id, 'messages');
  }

  Stream<QuerySnapshot> fetchMessagesAsStreamPagination(String id, int limit) {
    return _api.streamSubCollectionOrderByLimit(
        'messages', id, 'messages', 'sentAt', limit);
  }

  Future<MessagesModel> getMessageById(String id, String subId) async {
    var doc = await _api.getSubDocumentById('messages', id, 'messages', subId);
    return MessagesModel.fromMap(doc.data(), doc.id);
  }

  Future removeMessage(String id, String subId) async {
    await _api.removeSubDocument('messages', 'messages', id, subId);
    return;
  }

  Future updateMessage(MessagesModel data, String id, String subId) async {
    await _api.updateSubDocument(
        'messages', 'messages', id, subId, data.toMap());
    return;
  }

  Future<DocumentReference> addMessage(MessagesModel data, String id) async {
    return await _api.addSubDocument('messages', 'messages', id, data.toMap());
  }

  Future setMessage(MessagesModel data, String id, String subId) async {
    await _api.setSubDocument('messages', 'messages', id, subId, data.toMap());
    return;
  }

  Future<List<OnlineStatusModel>> mapContactStatusData(
      QuerySnapshot docs) async {
    List<OnlineStatusModel> list = docs.docs
        .map((doc) => OnlineStatusModel.fromMap(doc.data(), doc.id))
        .toList();
    statusList = [];
    for (OnlineStatusModel status in list) {
      ContactModel contactModel = contacts.firstWhere(
          (element) => element.userId == status.userId,
          orElse: () => ContactModel());
      status.nickname = contactModel.nickname;
      status.photoUrl = contactModel.photoUrl;
      statusList.add(status);
    }
    return statusList;
  }

  Future<void> fetchOnlineStatusAsStream() async {
    List<String> contactId = [];
    for (ContactModel contact in contacts) {
      contactId.add(contact.userId);
    }
    List<List<String>> contactChunk =
        splitListToChunk(contactId, 10).cast<List<String>>().toList();
    List<Stream<List<OnlineStatusModel>>> streams = [];
    contactChunk.forEach((element) {
      streams.add(_api
          .streamCollectionFromArray('status', FieldPath.documentId, element)
          .asyncMap((event) => mapContactStatusData(event)));
    });
    contactStatusList = ZipStream(streams, (value) => value.last);
  }

  Future<ContactModel> getContactDetail(List<dynamic> members) async {
    members.removeWhere((element) => element.userId == user.userId);
    ContactModel contactModel = contacts.firstWhere(
        (element) => element.userId == members.first.userId,
        orElse: () => null);
    if (contactModel != null && contactModel.userId.isNotEmpty) {
      return contactModel;
    } else {
      return new ContactModel(
          userId: members.first.userId, nickname: "", photoUrl: "");
    }
  }

  Future<GroupModel> generateGroupMessage(GroupModel group) async {
    if (group.type == 1) {
      ContactModel contactModel = await getContactDetail(group.membersList);
      group.groupName = contactModel.nickname.isNotEmpty
          ? contactModel.nickname
          : contactModel.userId;
      group.groupPhoto = contactModel.photoUrl;
    }

    return group;
  }

  Future<List<GroupModel>> mapGroupMessageData(QuerySnapshot docs) async {
    List<GroupModel> list =
        docs.docs.map((doc) => GroupModel.fromMap(doc.data())).toList();
    groups = [];
    for (GroupModel group in list) {
      GroupModel addGroup = await generateGroupMessage(group);
      groups.add(addGroup);
    }
    return groups;
  }

  Future<void> refreshMessageList() async {
    print("refresh");
    groupStream = fetchGroupsByMemberArrayAsStream('membersList', [
      {"isActive": true, "role": 1, "userId": user.userId},
      {"isActive": true, "role": 2, "userId": user.userId}
    ]).asyncMap((docs) => mapGroupMessageData(docs));
  }

  List<dynamic> splitListToChunk(List<dynamic> input, int size) {
    var len = input.length;
    var chunks = [];

    for (var i = 0; i < len; i += size) {
      var end = (i + size < len) ? i + size : len;
      chunks.add(input.sublist(i, end));
    }
    return chunks;
  }

  void turnOffGroupNotification(String groupId, String dateTime) {
    user.offNotification[groupId] = dateTime;
  }

  rtdbAndLocalFsPresence() async {
    var uid = user.userId;
    var userStatusDatabaseRef =
        databaseReference.reference().child('/status/' + uid);

    var isOfflineForDatabase = {
      "state": 'offline',
      "last_changed": ServerValue.timestamp,
    };

    var isOnlineForDatabase = {
      "state": 'online',
      "last_changed": ServerValue.timestamp,
    };

    // Firestore uses a different server timestamp value, so we'll
    // create two more constants for Firestore state.
    var isOfflineForFirestore = {
      "state": 'offline',
      "last_changed": FieldValue.serverTimestamp(),
    };

    var isOnlineForFirestore = {
      "state": 'online',
      "last_changed": FieldValue.serverTimestamp(),
    };

    databaseReference
        .reference()
        .child('.info/connected')
        .onValue
        .listen((Event event) async {
      if (event.snapshot.value == false) {
        // Instead of simply returning, we'll also set Firestore's state
        // to 'offline'. This ensures that our Firestore cache is aware
        // of the switch to 'offline.'
        setFirestoreStatus(isOfflineForFirestore, uid);
        return;
      }

      await userStatusDatabaseRef
          .onDisconnect()
          .update(isOfflineForDatabase)
          .then((snap) {
        userStatusDatabaseRef.set(isOnlineForDatabase);

        // We'll also add Firestore set here for when we come online.
        setFirestoreStatus(isOnlineForFirestore, uid);
      });
    });
  }

  setFirestoreStatus(Map<String, dynamic> data, String uid) {
    _api.setDocumentMerge('status', data, uid);
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
