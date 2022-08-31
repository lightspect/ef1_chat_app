import 'package:chat_app_ef1/core/helper/api.dart';
import 'package:chat_app_ef1/domain/entities/messages_model.dart';
import 'package:chat_app_ef1/locator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageDatasource {
  Api? _api = locator<Api>();
  List<MessagesModel>? messages;

  Future<List<MessagesModel>?> fetchMessages(String id) async {
    var result = await _api!.getSubCollection('messages', id, 'messages');
    messages = result.docs
        .map((doc) =>
            MessagesModel.fromMap(doc.data() as Map<dynamic, dynamic>?, doc.id))
        .toList();
    return messages;
  }

  Stream<QuerySnapshot> fetchMessagesAsStream(String id) {
    return _api!.streamSubCollection('messages', id, 'messages');
  }

  Stream<QuerySnapshot> fetchMessagesAsStreamPagination(String id, int limit) {
    return _api!.streamSubCollectionOrderByLimit(
        'messages', id, 'messages', 'sentAt', limit);
  }

  Future<MessagesModel> getMessageById(String id, String? subId) async {
    var doc = await _api!.getSubDocumentById('messages', id, 'messages', subId);
    return MessagesModel.fromMap(doc.data() as Map<dynamic, dynamic>?, doc.id);
  }

  Future removeMessage(String id, String subId) async {
    await _api!.removeSubDocument('messages', 'messages', id, subId);
    return;
  }

  Future updateMessage(MessagesModel data, String id, String? subId) async {
    await _api!
        .updateSubDocument('messages', 'messages', id, subId, data.toMap());
    return;
  }

  Future<DocumentReference> addMessage(MessagesModel data, String? id) async {
    return await _api!.addSubDocument('messages', 'messages', id, data.toMap());
  }

  Future setMessage(MessagesModel data, String id, String subId) async {
    await _api!.setSubDocument('messages', 'messages', id, subId, data.toMap());
    return;
  }
}
