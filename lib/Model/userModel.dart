class UserModel {
  String userId;
  String nickname;
  String photoUrl;
  String createdAt;
  String aboutMe;
  String chattingWith;
  String token;

  UserModel(
      {this.userId = "",
      this.nickname = "",
      this.photoUrl = "",
      this.createdAt = "",
      this.aboutMe = "",
      this.chattingWith = "",
      this.token = ""});

  factory UserModel.fromMap(Map data) {
    data = data ?? {};
    return UserModel(
        userId: data['id'] ?? '',
        nickname: data['nickname'] ?? '',
        photoUrl: data['photoUrl'] ?? '',
        createdAt: data['createdAt'] ?? '',
        aboutMe: data['aboutMe'] ?? '',
        chattingWith: data['chattingWith'] ?? '',
        token: data['token'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'nickname': nickname,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'aboutMe': aboutMe,
      'chattingWith': chattingWith,
      'token': token,
    };
  }
}

class ContactModel {
  String userId;
  String nickname;
  String photoUrl;

  ContactModel({this.userId, this.nickname, this.photoUrl});

  factory ContactModel.fromMap(Map data) {
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
