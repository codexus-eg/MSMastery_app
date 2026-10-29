import 'package:cloud_firestore/cloud_firestore.dart';

class OtpModel {
  DateTime date;
  String phoneNum;
  String code;

  OtpModel({
    required this.code,
    required this.date,
    required this.phoneNum,
  });

  // Convert an OtpModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'phoneNum': phoneNum,
      'code': code,
    };
  }

  // Create an OtpModel from a JSON map
  factory OtpModel.fromJson(Map<String, dynamic> json) {
    return OtpModel(
      date: (json['date'] as Timestamp).toDate(),
      phoneNum: json['phoneNum'],
      code: json['code'],
    );
  }

  // Check if the OTP has expired
  bool isExpired() {
    return DateTime.now().isAfter(date.add(const Duration(minutes: 5)));
  }
}
