import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salah_online_platform/models/comment_model.dart';

class PostModel {
  String id;
  String text;
  String? imageUrl;
  DateTime date;
  Map<String, DateTime> likes;
  Map<String, List<CommentModel>> comments; // دعم تعليقات متعددة لكل مستخدم

  PostModel({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.date,
    required this.likes,
    required this.comments,
  });

  // تحويل من Firestore (Map -> Object)
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'],
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      date: (map['date'] as Timestamp).toDate(),
      likes: (map['likes'] as Map<String, dynamic>? ?? {}).map((key, value) {
        if (value is bool) {
          return MapEntry(key, DateTime.now()); // لو bool نحوله لتاريخ افتراضي
        } else if (value is Timestamp) {
          return MapEntry(
              key, value.toDate()); // لو كان Firestore Timestamp نحوله
        }
        return MapEntry(
            key, DateTime.now()); // أي قيمة غير متوقعة نحط تاريخ افتراضي
      }),
      comments: (map['comments'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              (value as List<dynamic>)
                  .map((e) => CommentModel.fromMap(e))
                  .toList(),
            ),
          ) ??
          {},
    );
  }

  // تحويل إلى Firestore (Object -> Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
      'date': Timestamp.fromDate(date),
      'likes': likes,
      'comments': comments.map(
        (key, value) => MapEntry(key, value.map((e) => e.toMap()).toList()),
      ),
    };
  }
}
