import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String? message;
  final String id;
  final DateTime time;
  String? imageUrl;
  String type;

  ChatModel({
    required this.message,
    required this.id,
    required this.time,
    required this.imageUrl,
    required this.type,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // معالجة الوقت سواء Timestamp أو String
    DateTime parsedTime;
    if (json['time'] is Timestamp) {
      parsedTime = (json['time'] as Timestamp).toDate();
    } else if (json['time'] is String) {
      parsedTime = DateTime.tryParse(json['time']) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    // معالجة النوع (bool أو string)
    String parsedType;
    if (json['type'] is bool) {
      parsedType = json['type'] ? 'img' : 'txt';
    } else {
      parsedType = json['type']?.toString() ?? 'txt';
    }

    return ChatModel(
      message: json['message'],
      id: json['id'],
      time: parsedTime,
      imageUrl: json['imagaeUrl'] ?? json['imageUrl'],
      type: parsedType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'id': id,
      'time': time,
      'imageUrl': imageUrl,
      'type': type,
    };
  }
}
