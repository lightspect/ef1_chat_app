import 'package:chat_app_ef1/Model/userModel.dart';

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
  List<ContactModel> usersList;

  GroupModel({
    this.groupId = "",
    this.groupName = "",
    this.groupPhoto = "",
    this.createdAt = "",
    this.createdBy = "",
    this.recentMessageContent = "",
    this.recentMessageSender = "",
    this.recentMessageTime = "",
    this.type = 0,
    this.membersList,
    this.usersList,
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

  Members({this.userId = "", this.isActive = false, this.role = 0});

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
