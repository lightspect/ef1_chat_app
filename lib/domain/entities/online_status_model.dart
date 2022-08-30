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
