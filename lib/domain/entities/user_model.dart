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
