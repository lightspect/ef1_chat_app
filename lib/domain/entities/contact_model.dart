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
