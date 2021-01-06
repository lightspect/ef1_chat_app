import 'package:cloud_firestore/cloud_firestore.dart';

class Api {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Api();

  Future<QuerySnapshot> getDataCollection(String path) {
    return _db.collection(path).get();
  }

  Stream<QuerySnapshot> streamDataCollection(String path) {
    return _db.collection(path).snapshots();
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
      String path, String field, dynamic condition) {
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

  Future<DocumentSnapshot> getDocumentById(String path, String id) {
    return _db.collection(path).doc(id).get();
  }

  Future<void> removeDocument(String path, String id) {
    return _db.collection(path).doc(id).delete();
  }

  Future<DocumentReference> addDocument(String path, Map data) {
    return _db.collection(path).add(data);
  }

  Future<void> setDocument(String path, Map data, String id) {
    return _db.collection(path).doc(id).set(data);
  }

  Future<void> updateDocument(String path, Map data, String id) {
    return _db.collection(path).doc(id).update(data);
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
      String path, String id, String subName, String subId) {
    return _db.collection(path).doc(id).collection(subName).doc(subId).get();
  }

  Future<void> removeSubDocument(
      String path, String subName, String id, String subId) {
    return _db.collection(path).doc(id).collection(subName).doc(subId).delete();
  }

  Future<DocumentReference> addSubDocument(
      String path, String subName, String id, Map data) {
    return _db.collection(path).doc(id).collection(subName).add(data);
  }

  Future<void> updateSubDocument(
      String path, String subName, String id, String subId, Map data) {
    return _db
        .collection(path)
        .doc(id)
        .collection(subName)
        .doc(subId)
        .update(data);
  }

  Future<void> setSubDocument(
      String path, String subName, String id, String subId, Map data) {
    return _db
        .collection(path)
        .doc(id)
        .collection(subName)
        .doc(subId)
        .set(data);
  }
}
