import 'package:chat_app_ef1/data/datasource/server/contact_datasource.dart';
import 'package:chat_app_ef1/domain/entities/contact_model.dart';
import 'package:chat_app_ef1/domain/repositories/contact_repository.dart';

class ContactRepositoryImp implements ContactRepository {
  @override
  Future addContact(ContactModel data, String id) async {
    ContactDatasource.addContact(data, id);
  }

  @override
  Future<List<ContactModel?>?> fetchContacts(String id) async {
    return await ContactDatasource.fetchContacts(id);
  }

  @override
  Future<ContactModel> getContactById(String id, String? subId) async {
    return await ContactDatasource.getContactById(id, subId);
  }

  @override
  Future removeContact(String id, String? subId) async {
    await ContactDatasource.removeContact(id, subId);
  }

  @override
  Future setContact(ContactModel data, String id, String? subId) async {
    await ContactDatasource.setContact(data, id, subId);
  }

  @override
  Future updateContact(ContactModel data, String id, String? subId) async {
    await ContactDatasource.updateContact(data, id, subId);
  }

  @override
  Future updateContactField(
      Map<String, dynamic> data, String id, String subId) async {
    await ContactDatasource.updateContactField(data, id, subId);
  }
}
