class GroupModel {
  String? groupId;
  String? groupName;
  String? groupPhoto;
  String? createdAt;
  String? createdBy;
  String? recentMessageContent;
  String? recentMessageSender;
  String? recentMessageTime;
  int? type;
  List<dynamic>? members;

  GroupModel(
      {this.groupId,
      this.groupName,
      this.groupPhoto,
      this.createdAt,
      this.createdBy,
      this.recentMessageContent,
      this.recentMessageSender,
      this.recentMessageTime,
      this.type,
      this.members});

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupPhoto': groupPhoto,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'recentMessage': recentMessageContent,
      'recentMessageSender': recentMessageSender,
      'recentMessageTime': recentMessageTime,
      'type': type,
      'members': members
    };
  }

  factory GroupModel.fromMap(Map? data) {
    data = data ?? {};
    return GroupModel(
        groupId: data['groupId'] ?? '',
        groupName: data['groupName'] ?? '',
        groupPhoto: data['groupPhoto'] ?? '',
        createdAt: data['createdAt'] ?? '',
        createdBy: data['createdBy'] ?? '',
        recentMessageContent: data['recentMessage'] ?? '',
        recentMessageSender: data['recentMessageSender'] ?? '',
        recentMessageTime: data['recentMessageTime'] ?? '',
        type: data['type'] ?? 1,
        members: data['members'].toList() ?? []);
  }
}
