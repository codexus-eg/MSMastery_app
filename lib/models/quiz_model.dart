import 'package:cloud_firestore/cloud_firestore.dart';

class QuizModel {
  String id;
  String title;
  int duration;
  int questionsNum;
  int fullMark;
  bool isValid;
  bool isRand;
  DateTime? validUntil;
  int? price;
  bool showDegree;

  QuizModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.questionsNum,
    required this.fullMark,
    required this.isRand,
    required this.isValid,
    required this.showDegree,
    this.validUntil,
    this.price,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'],
      title: json['title'],
      duration: json['duration'],
      questionsNum: json['questionsNum'],
      fullMark: json['fullMark'] ?? json['questionsNum'],
      isValid: json['isValid'],
      isRand: json['isRand'] ?? true,
      showDegree: json['showDegree'] ?? true,
      validUntil: json['validUntil'] != null
          ? (json['validUntil'] as Timestamp).toDate()
          : null,
      price: json['price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'fullMark': fullMark,
      'questionsNum': questionsNum,
      'isValid': isValid,
      'isRand': isRand,
      'validUntil': validUntil,
      'price': price,
      'showDegree': showDegree,
    };
  }
}
