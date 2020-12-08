class MessagesModel {
  String messageId;
  String messageContent;
  String sentBy;
  String sentAt;
  int type;
  int contentType;
  List<String> reaction;

  MessagesModel(
      {this.messageId,
      this.messageContent,
      this.sentBy,
      this.sentAt,
      this.type,
      this.contentType,
      this.reaction});

  factory MessagesModel.fromMap(Map data, String id) {
    data = data ?? {};
    return MessagesModel(
      messageId: id,
      messageContent: data['messageContent'] ?? '',
      sentAt: data['sentAt'] ?? '',
      sentBy: data['sentBy'] ?? '',
      type: data['type'] ?? 1,
      contentType: data['contentType'] ?? 1,
      reaction: data['reaction'] != null ? data['reaction'].toList() : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'messageContent': messageContent,
      'sentAt': sentAt,
      'sentBy': sentBy,
      'type': type,
      'contentType': contentType,
      'reaction': reaction,
    };
  }
}

class ReactionModel {
  String userId;
  int reaction;

  ReactionModel({this.userId, this.reaction});

  factory ReactionModel.fromMap(Map data) {
    data = data ?? {};
    return ReactionModel(
      userId: data['userId'] ?? '',
      reaction: data['reaction'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'reaction': reaction,
    };
  }
}
