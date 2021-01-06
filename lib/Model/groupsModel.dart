class GroupModel {
  String groupId;
  String groupName;
  String groupPhoto;
  String createdAt;
  String createdBy;
  String recentMessageContent;
  String recentMessageSender;
  String recentMessageTime;
  int type;
  List<Members> membersList;

  GroupModel({
    this.groupId,
    this.groupName,
    this.groupPhoto,
    this.createdAt,
    this.createdBy,
    this.recentMessageContent,
    this.recentMessageSender,
    this.recentMessageTime,
    this.type,
    this.membersList,
  });

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
      'membersList': membersList
          .map<Map<String, dynamic>>((member) => member.toMap())
          .toList(),
    };
  }

  factory GroupModel.fromMap(Map data) {
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
      membersList: data['membersList'] != null
          ? data['membersList']
              .map<Members>((member) => Members.fromMap(member))
              .toList()
          : [],
    );
  }
}

class Members {
  String userId;
  bool isActive;
  int role;

  Members({this.userId, this.isActive, this.role});

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'isActive': isActive, 'role': role};
  }

  factory Members.fromMap(Map data) {
    data = data ?? {};
    return Members(
      userId: data['userId'] ?? '',
      isActive: data['isActive'] ?? false,
      role: data['role'] ?? 1,
    );
  }
}
