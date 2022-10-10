import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class Api {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  DatabaseReference? databaseReference = FirebaseDatabase.instance.ref();

  Api();

  Future<QuerySnapshot> getDataCollection(String path) {
    return _db.collection(path).get();
  }

  Stream<QuerySnapshot> streamDataCollection(String path) {
    return _db.collection(path).snapshots();
  }

  Future<QuerySnapshot> getDataCollectionBySubCollection(
      String path, String field, String id) {
    return _db.collectionGroup(path).where(field, isEqualTo: id).get();
  }

  Stream<QuerySnapshot> streamCollectionByArray(
      String path, String field, dynamic condition) {
    return _db
        .collection(path)
        .where(field, arrayContains: condition)
        .snapshots();
  }

  Stream<QuerySnapshot> streamCollectionByArrayAny(
      String path, String field, dynamic condition) {
    return _db
        .collection(path)
        .where(field, arrayContainsAny: condition)
        .snapshots();
  }

  Stream<QuerySnapshot> streamCollectionFromArray(
      String path, dynamic field, dynamic condition) {
    return _db.collection(path).where(field, whereIn: condition).snapshots();
  }

  Future<QuerySnapshot> getCollectionByCondition(
      String path, String field, dynamic condition) {
    return _db.collection(path).where(field, isEqualTo: condition).get();
  }

  Future<QuerySnapshot> getCollectionByArray(
      String path, String field, dynamic condition) {
    return _db.collection(path).where(field, arrayContains: condition).get();
  }

  Future<QuerySnapshot> getCollectionFromArray(
      String path, String field, dynamic condition) {
    return _db.collection(path).where(field, whereIn: condition).get();
  }

  Future<DocumentSnapshot> getDocumentById(String path, String? id) {
    return _db.collection(path).doc(id).get();
  }

  Future<void> removeDocument(String path, String id) {
    return _db.collection(path).doc(id).delete();
  }

  Future<DocumentReference> addDocument(String path, Map data) {
    return _db.collection(path).add(data as Map<String, dynamic>);
  }

  Future<void> setDocument(String path, Map data, String id) {
    return _db.collection(path).doc(id).set(data as Map<String, dynamic>);
  }

  Future<void> setDocumentMerge(String path, Map data, String id) {
    return _db
        .collection(path)
        .doc(id)
        .set(data as Map<String, dynamic>, SetOptions(merge: true));
  }

  Future<void> updateDocument(String path, Map data, String? id) {
    return _db.collection(path).doc(id).update(data as Map<String, Object?>);
  }

  Future<void> updateDocumentID(String field, DocumentReference doc) {
    return doc.update({field: doc.id});
  }

  Future<QuerySnapshot> getSubCollection(
      String path, String id, String subName) {
    return _db.collection(path).doc(id).collection(subName).get();
  }

  Stream<QuerySnapshot> streamSubCollection(
      String path, String id, String subName) {
    return _db.collection(path).doc(id).collection(subName).snapshots();
  }

  Stream<QuerySnapshot> streamSubCollectionOrderByLimit(
      String path, String id, String subName, String field, int limit) {
    return _db
        .collection(path)
        .doc(id)
        .collection(subName)
        .orderBy(field, descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<QuerySnapshot> getSubCollectionByCondition(
      String path, String id, String subName, String field, dynamic condition) {
    return _db
        .collection(path)
        .doc(id)
        .collection(subName)
        .where(field, isEqualTo: condition)
        .get();
  }

  Future<QuerySnapshot> getSubCollectionByArray(
      String path, String id, String subName, String field, dynamic condition) {
    return _db
        .collection(path)
        .doc(id)
        .collection(subName)
        .where(field, arrayContains: condition)
        .get();
  }

  Future<DocumentSnapshot> getSubDocumentById(
      String path, String id, String subName, String? subId) {
    return _db.collection(path).doc(id).collection(subName).doc(subId).get();
  }

  Future<void> removeSubDocument(
      String path, String subName, String id, String? subId) {
    return _db.collection(path).doc(id).collection(subName).doc(subId).delete();
  }

  Future<DocumentReference> addSubDocument(
      String path, String subName, String? id, Map data) {
    return _db
        .collection(path)
        .doc(id)
        .collection(subName)
        .add(data as Map<String, dynamic>);
  }

  Future<void> updateSubDocument(
      String path, String subName, String id, String? subId, Map data) {
    return _db
        .collection(path)
        .doc(id)
        .collection(subName)
        .doc(subId)
        .update(data as Map<String, Object?>);
  }

  Future<void> setSubDocument(
      String path, String subName, String id, String? subId, Map data) {
    return _db
        .collection(path)
        .doc(id)
        .collection(subName)
        .doc(subId)
        .set(data as Map<String, dynamic>);
  }

  rtdbAndLocalFsPresence(String uid) async {
    var userStatusDatabaseRef = databaseReference!..child('/status/' + uid);

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

    databaseReference!
        .child('.info/connected')
        .onValue
        .listen((DatabaseEvent event) async {
      if (event.snapshot.value == false) {
        // Instead of simply returning, we'll also set Firestore's state
        // to 'offline'. This ensures that our Firestore cache is aware
        // of the switch to 'offline.'
        setDocumentMerge('status', isOfflineForFirestore, uid);
        return;
      }

      await userStatusDatabaseRef
          .onDisconnect()
          .update(isOfflineForDatabase)
          .then((snap) {
        userStatusDatabaseRef.set(isOnlineForDatabase);

        // We'll also add Firestore set here for when we come online.
        setDocumentMerge('status', isOnlineForFirestore, uid);
      });
    });
  }
}
