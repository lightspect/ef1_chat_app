class MessagesModel {
  String messageId;
  String messageContent;
  String sentBy;
  String sentAt;
  int type;
  int contentType;
  String replyTo;

  MessagesModel({
    this.messageId = "",
    this.messageContent = "",
    this.sentBy = "",
    this.sentAt = "",
    this.type = 0,
    this.contentType = 0,
    this.replyTo = "",
  });

  factory MessagesModel.fromMap(Map data, String id) {
    data = data ?? {};
    return MessagesModel(
      messageId: id,
      messageContent: data['messageContent'] ?? '',
      sentAt: data['sentAt'] ?? '',
      sentBy: data['sentBy'] ?? '',
      type: data['type'] ?? 1,
      contentType: data['contentType'] ?? 1,
      replyTo: data['replyTo'] ?? '',
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
      'replyTo': replyTo,
    };
  }
}
