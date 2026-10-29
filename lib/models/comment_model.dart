import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String? comment;
  DateTime? date;

  CommentModel({required this.comment, required this.date});

  // تحويل من Firestore (Map -> Object)
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      comment: map['comment'] ?? '',
      date:
          (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(), // تجنب null
    );
  }

  // تحويل إلى Firestore (Object -> Map)
  Map<String, dynamic> toMap() {
    return {
      'comment': comment ?? '',
      'date': date,
    };
  }
}
