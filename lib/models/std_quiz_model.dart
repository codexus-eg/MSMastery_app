import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'std_quiz_model.g.dart';

@HiveType(typeId: 3)
class StdQuizModel extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String title;
  @HiveField(2)
  late DateTime dateTime;
  @HiveField(3)
  late int questionNums;
  @HiveField(4)
  late double degree;
  @HiveField(5, defaultValue: {})
  late Map<String, dynamic> userAnsIdx;
  @HiveField(6)
  late int fullMark; // 👈 هنخليها int مش nullable ونتعامل في الكونستركتور

  @HiveField(7)
  late int triesNum;

  @HiveField(8)
  DateTime? submitTime;
  @HiveField(9)
  String? status;
  @HiveField(10)
  DateTime? purchaseDateTime;

  StdQuizModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.questionNums,
    required this.triesNum,
    required this.fullMark,
    required this.degree,
    required this.userAnsIdx,
    this.submitTime,
    this.status,
    this.purchaseDateTime,
  });

  factory StdQuizModel.fromJson(Map<String, dynamic> json) {
    return StdQuizModel(
      id: json['id'] ?? '',
      triesNum: json['triesNum'] ?? 1,
      title: json['title'] ?? '',
      dateTime: json['dateTime'] != null
          ? (json['dateTime'] as Timestamp?)!.toDate()
          : DateTime.now(),
      questionNums: json['questionsNum'] ?? 0,
      degree: (json['degree'] as num?)?.toDouble() ?? 0.0,
      userAnsIdx: json['userAnsIdx'] ?? {},
      fullMark: json['fullMark'] ?? 0,
      submitTime: (json['submitTime'] as Timestamp?)?.toDate(),
      status: json['status'],
      purchaseDateTime: (json['purchaseDateTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'triesNum': triesNum,
      'dateTime': dateTime,
      'questionsNum': questionNums,
      'degree': degree,
      'userAnsIdx': userAnsIdx,
      'fullMark': fullMark,
      'submitTime': submitTime,
      'status': status,
      'purchaseDateTime': purchaseDateTime,
    };
  }

  StdQuizModel copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    int? questionNums,
    int? triesNum,
    int? fullMark,
    double? degree,
    Map<String, dynamic>? userAnsIdx,
    DateTime? submitTime,
    String? status,
    DateTime? purchaseDateTime,
  }) {
    return StdQuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      questionNums: questionNums ?? this.questionNums,
      triesNum: triesNum ?? this.triesNum,
      fullMark: fullMark ?? this.fullMark,
      degree: degree ?? this.degree,
      userAnsIdx: userAnsIdx ?? this.userAnsIdx,
      submitTime: submitTime,
      status: status,
      purchaseDateTime: purchaseDateTime,
    );
  }
}
