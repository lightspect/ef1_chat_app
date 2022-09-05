import 'package:chat_app_ef1/data/datasource/server/message_datasource.dart';
import 'package:chat_app_ef1/domain/entities/messages_model.dart';
import 'package:chat_app_ef1/domain/repositories/message_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageRepositoryImp implements MessageRepository {
  @override
  Future<DocumentReference<Object?>> addMessage(
      MessagesModel data, String? id) async {
    return await MessageDatasource.addMessage(data, id);
  }

  @override
  Future<List<MessagesModel>?> fetchMessages(String id) async {
    return await MessageDatasource.fetchMessages(id);
  }

  @override
  Stream<QuerySnapshot<Object?>> fetchMessagesAsStream(String id) {
    return MessageDatasource.fetchMessagesAsStream(id);
  }

  @override
  Stream<QuerySnapshot<Object?>> fetchMessagesAsStreamPagination(
      String id, int limit) {
    return MessageDatasource.fetchMessagesAsStreamPagination(id, limit);
  }

  @override
  Future<MessagesModel> getMessageById(String id, String? subId) async {
    return await MessageDatasource.getMessageById(id, subId);
  }

  @override
  Future removeMessage(String id, String subId) async {
    await MessageDatasource.removeMessage(id, subId);
  }

  @override
  Future setMessage(MessagesModel data, String id, String subId) async {
    await MessageDatasource.setMessage(data, id, subId);
  }

  @override
  Future updateMessage(MessagesModel data, String id, String? subId) async {
    await MessageDatasource.updateMessage(data, id, subId);
  }
}
