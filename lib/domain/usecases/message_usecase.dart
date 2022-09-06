import 'package:chat_app_ef1/domain/entities/messages_model.dart';
import 'package:chat_app_ef1/domain/repositories/message_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageUseCase {
  MessageRepository? repository;

  MessageUseCase({this.repository});

  Future<List<MessagesModel>?> fetchMessages(String id) async {
    return await repository?.fetchMessages(id);
  }

  Stream<List<MessagesModel>>? fetchMessagesAsStreamPagination(
      String id, int limit) {
    return repository?.fetchMessagesAsStreamPagination(id, limit);
  }

  Future<MessagesModel?> getMessageById(String id, String? subId) async {
    return repository?.getMessageById(id, subId);
  }

  Future removeMessage(String id, String subId) async {
    await repository?.removeMessage(id, subId);
  }

  Future updateMessage(MessagesModel data, String id, String? subId) async {
    await repository?.updateMessage(data, id, subId);
  }

  Future<DocumentReference?> addMessage(MessagesModel data, String? id) async {
    return await repository?.addMessage(data, id);
  }

  Future setMessage(MessagesModel data, String id, String subId) async {
    await repository?.setMessage(data, id, subId);
  }
}
