class UserModel {
  String userId;
  String? nickname;
  String? photoUrl;
  String createdAt;
  String aboutMe;
  String? token;
  Map<dynamic, dynamic>? offNotification;

  UserModel({
    this.userId = "",
    this.nickname = "",
    this.photoUrl = "",
    this.createdAt = "",
    this.aboutMe = "",
    this.token = "",
    this.offNotification,
  });

  factory UserModel.fromMap(Map? data) {
    data = data ?? {};
    return UserModel(
      userId: data['id'] ?? '',
      nickname: data['nickname'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: data['createdAt'] ?? '',
      aboutMe: data['aboutMe'] ?? '',
      token: data['token'] ?? '',
      offNotification: data['offNotification'] != null
          ? data['offNotification'].map((k, v) {
              return MapEntry(k.toString(), v.toString());
            })
          : {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'nickname': nickname,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'aboutMe': aboutMe,
      'token': token,
      'offNotification': offNotification
    };
  }
}

class ContactModel {
  String? userId;
  String? nickname;
  String? photoUrl;

  ContactModel({this.userId = "", this.nickname = "", this.photoUrl = ""});

  factory ContactModel.fromMap(Map? data) {
    data = data ?? {};
    return ContactModel(
      userId: data['id'] ?? '',
      nickname: data['nickname'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'nickname': nickname,
      'photoUrl': photoUrl,
    };
  }
}

class OnlineStatusModel {
  String userId;
  String? nickname;
  String? photoUrl;
  String status;
  String time;

  OnlineStatusModel(
      {this.userId = "",
      this.nickname = "",
      this.photoUrl = "",
      this.status = "",
      this.time = ""});

  factory OnlineStatusModel.fromMap(Map? data, String? id) {
    data = data ?? {};
    return OnlineStatusModel(
      userId: id!,
      status: data['state'] ?? "",
      time: data['last_changed'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'state': status,
      'last_changed': time,
    };
  }
}
