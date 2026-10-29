import 'package:cloud_firestore/cloud_firestore.dart';

class LikeStdData {
  String imgUrl;
  String name;
  DateTime? date;

  LikeStdData({
    required this.imgUrl,
    required this.name,
    required this.date,
  });

  // تحويل من Firestore (Map -> Object)
  factory LikeStdData.fromMap(Map<String, dynamic> map) {
    return LikeStdData(
      imgUrl: map['imgUrl'] ?? '', // تجنب الـ null
      name: map['name'] ?? '',
      date: map['date'] == null || map['date'] is bool
          ? DateTime.now()
          : (map['date'] as Timestamp).toDate(),
    );
  }

  // تحويل إلى Firestore (Object -> Map)
  Map<String, dynamic> toMap() {
    return {
      'imgUrl': imgUrl,
      'name': name,
    };
  }
}
