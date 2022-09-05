import 'package:chat_app_ef1/domain/entities/contact_model.dart';
import 'package:chat_app_ef1/domain/repositories/contact_repository.dart';

class ContactUseCase {
  ContactRepository? repository;

  ContactUseCase({required this.repository});

  Future<List<ContactModel?>?> fetchContacts(String id) async {
    return await repository?.fetchContacts(id);
  }

  Future<ContactModel?> getContactById(String id, String? subId) async {
    return await repository?.getContactById(id, subId);
  }

  Future removeContact(String id, String? subId) async {
    await repository?.removeContact(id, subId);
  }

  Future updateContact(ContactModel data, String id, String? subId) async {
    await repository?.updateContact(data, id, subId);
  }

  Future updateContactField(
      Map<String, dynamic> data, String id, String subId) async {
    await repository?.updateContactField(data, id, subId);
  }

  Future addContact(ContactModel data, String id) async {
    await repository?.addContact(data, id);
  }

  Future setContact(ContactModel data, String id, String? subId) async {
    await repository?.setContact(data, id, subId);
  }
}
