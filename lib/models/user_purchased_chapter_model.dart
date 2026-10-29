import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:salah_online_platform/models/user_purchase_model.dart';

part 'user_purchased_chapter_model.g.dart';

@HiveType(typeId: 4)
class UserPurchasedChapterModel extends HiveObject {
  @HiveField(0)
  Map<String, UserPurchasedLectureModel>? lectures;
  @HiveField(1)
  String? status;
  @HiveField(2)
  DateTime? purchaseDateTime;
  UserPurchasedChapterModel(
      {this.lectures, this.status, this.purchaseDateTime});

  UserPurchasedChapterModel.fromJson(Map<String, dynamic> json) {
    Map<String, UserPurchasedLectureModel> lecturesMap = {};
    if (json['lectures'] != null) {
      json['lectures'].forEach((lectureKey, lectureValue) {
        lecturesMap[lectureKey] = UserPurchasedLectureModel.fromJson(
            Map<String, dynamic>.from(lectureValue as Map));
      });
    }
    lectures = lecturesMap;
    status = json['status'];
    purchaseDateTime = json['purchaseDateTime'] != null
        ? (json['purchaseDateTime'] as Timestamp).toDate()
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      'lectures': lectures?.map((key, value) => MapEntry(key, value.toMap())),
      'status': status,
      'purchaseDateTime': purchaseDateTime,
    };
  }
}

@HiveType(typeId: 5)
class UserPurchasedLectureModel extends HiveObject {
  @HiveField(0)
  Map<String, UserPurchasedModel>? videos;
  @HiveField(1)
  String? status;
  @HiveField(2)
  DateTime? purchaseDateTime;
  UserPurchasedLectureModel({this.videos, this.status, this.purchaseDateTime});

  UserPurchasedLectureModel.fromJson(Map<String, dynamic> json) {
    Map<String, UserPurchasedModel> videosMap = {};
    if (json['videos'] != null) {
      json['videos'].forEach((videoKey, videoValue) {
        videosMap[videoKey] = UserPurchasedModel.fromJson(
            Map<String, dynamic>.from(videoValue as Map));
      });
    }
    videos = videosMap;
    status = json['status'];
    purchaseDateTime = json['purchaseDateTime'] != null
        ? (json['purchaseDateTime'] as Timestamp).toDate()
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      'videos': videos?.map((key, value) => MapEntry(key, value.toMap())),
      'status': status,
      'purchaseDateTime': purchaseDateTime,
    };
  }
}
