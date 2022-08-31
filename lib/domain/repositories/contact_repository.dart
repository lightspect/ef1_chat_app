import 'package:chat_app_ef1/domain/entities/contact_model.dart';

abstract class ContactRepository {
  Future<List<ContactModel?>?> fetchContacts(String id);

  Future<ContactModel> getContactById(String id, String? subId);

  Future removeContact(String id, String? subId);

  Future updateContact(ContactModel data, String id, String? subId);

  Future updateContactField(Map<String, dynamic> data, String id, String subId);

  Future addContact(ContactModel data, String id);

  Future setContact(ContactModel data, String id, String? subId);
}
