class RequsetsModel {
  final String senderId;
  final String receiverId;
  final String request;
  final String state;
  final id;
  final List<dynamic> imageurl;
  final String date;
  final String grade;
  final String? token;
  final String title;
  RequsetsModel({
    required this.senderId,
    required this.receiverId,
    required this.request,
    required this.state,
    required this.id,
    required this.imageurl,
    required this.date,
    required this.grade,
    required this.token,
    required this.title,
  });

  factory RequsetsModel.fromJson(Map<String, dynamic> json) {
    return RequsetsModel(
        senderId: json['sender_id'],
        receiverId: json['receiver_id'],
        request: json['message'],
        state: json['state'],
        imageurl: json['imageurl'],
        token: json['secToken'] ?? '',
        id: json['id'],
        date: json['date'],
        grade: json['grade'],
        title: json['title']);
  }
  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': request,
      'state': state,
      'id': id,
      'stdToken': token ?? '',
      'imageurl': imageurl,
      'date': date,
      'grade': grade,
      'title': title,
    };
  }
}
