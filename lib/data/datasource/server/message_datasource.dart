import 'package:chat_app_ef1/core/helper/api.dart';
import 'package:chat_app_ef1/domain/entities/messages_model.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageDatasource {
  static Api? _api = locator<Api>();
  static List<MessagesModel>? messages;

  static Future<List<MessagesModel>?> fetchMessages(String id) async {
    var result = await _api!.getSubCollection('messages', id, 'messages');
    messages = result.docs
        .map((doc) =>
            MessagesModel.fromMap(doc.data() as Map<dynamic, dynamic>?, doc.id))
        .toList();
    return messages;
  }

  static Stream<List<MessagesModel>> fetchMessagesAsStreamPagination(
      String id, int limit) {
    var result = _api!.streamSubCollectionOrderByLimit(
        'messages', id, 'messages', 'sentAt', limit);
    Stream<List<MessagesModel>> streamList = result.map((event) => event.docs
        .map((e) =>
            MessagesModel.fromMap(e.data() as Map<dynamic, dynamic>, e.id))
        .toList());
    return streamList;
  }

  static Future<MessagesModel> getMessageById(String id, String? subId) async {
    var doc = await _api!.getSubDocumentById('messages', id, 'messages', subId);
    return MessagesModel.fromMap(doc.data() as Map<dynamic, dynamic>?, doc.id);
  }

  static Future removeMessage(String id, String subId) async {
    await _api!.removeSubDocument('messages', 'messages', id, subId);
    return;
  }

  static Future updateMessage(
      MessagesModel data, String id, String? subId) async {
    await _api!
        .updateSubDocument('messages', 'messages', id, subId, data.toMap());
    return;
  }

  static Future<DocumentReference> addMessage(
      MessagesModel data, String? id) async {
    return await _api!.addSubDocument('messages', 'messages', id, data.toMap());
  }

  static Future setMessage(MessagesModel data, String id, String subId) async {
    await _api!.setSubDocument('messages', 'messages', id, subId, data.toMap());
    return;
  }
}
