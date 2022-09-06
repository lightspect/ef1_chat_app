import 'package:chat_app_ef1/domain/entities/messages_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class MessageRepository {
  Future<List<MessagesModel>?> fetchMessages(String id);

  Stream<List<MessagesModel>> fetchMessagesAsStreamPagination(
      String id, int limit);

  Future<MessagesModel> getMessageById(String id, String? subId);

  Future removeMessage(String id, String subId);

  Future updateMessage(MessagesModel data, String id, String? subId);

  Future<DocumentReference> addMessage(MessagesModel data, String? id);

  Future setMessage(MessagesModel data, String id, String subId);
}
