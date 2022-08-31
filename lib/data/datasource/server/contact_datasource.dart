import 'package:chat_app_ef1/core/helper/api.dart';
import 'package:chat_app_ef1/domain/entities/contact_model.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactDatasource {
  static Api? _api = locator<Api>();
  static List<ContactModel?>? contacts;

  static Future<List<ContactModel?>?> fetchContacts(String id) async {
    var result = await _api!.getSubCollection('users', id, 'contacts');
    contacts = result.docs
        .map(
            (doc) => ContactModel.fromMap(doc.data() as Map<dynamic, dynamic>?))
        .toList();
    return contacts;
  }

  static Stream<QuerySnapshot> fetchContactsAsStream(String id) {
    return _api!.streamSubCollection('users', id, 'contacts');
  }

  static Future<ContactModel> getContactById(String id, String? subId) async {
    var doc = await _api!.getSubDocumentById('users', id, 'contacts', subId);
    if (doc.exists) {
      return ContactModel.fromMap(doc.data() as Map<dynamic, dynamic>?);
    } else {
      return ContactModel(nickname: "", photoUrl: "", userId: "");
    }
  }

  static Future removeContact(String id, String? subId) async {
    await _api!.removeSubDocument('users', 'contacts', id, subId);
    return;
  }

  static Future updateContact(
      ContactModel data, String id, String? subId) async {
    await _api!.updateSubDocument('users', 'contacts', id, subId, data.toMap());
    return;
  }

  static Future updateContactField(
      Map<String, dynamic> data, String id, String subId) async {
    await _api!.updateSubDocument('users', 'contacts', id, subId, data);
    return;
  }

  static Future<DocumentReference> addContact(
      ContactModel data, String id) async {
    return await _api!.addSubDocument('users', 'contacts', id, data.toMap());
  }

  static Future setContact(ContactModel data, String id, String? subId) async {
    await _api!.setSubDocument('users', 'contacts', id, subId, data.toMap());
    return;
  }
}
