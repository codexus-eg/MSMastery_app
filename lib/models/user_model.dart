// ignore_for_file: non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:salah_online_platform/models/std_quiz_model.dart';
import 'package:salah_online_platform/models/user_purchased_chapter_model.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String? fname;
  @HiveField(1)
  String? sname;
  @HiveField(2)
  String? thname;
  @HiveField(3)
  String? ar_fname;
  @HiveField(4)
  String? ar_sname;
  @HiveField(5)
  String? ar_thname;
  @HiveField(6)
  String? code;
  @HiveField(7)
  String? phoneNum;
  @HiveField(8)
  String? img;
  @HiveField(9)
  int? balance;
  @HiveField(10)
  String? grade;
  @HiveField(11)
  String? password;
  @HiveField(12, defaultValue: {})
  Map<String, UserPurchasedChapterModel>? purchasedVideos;
  @HiveField(13, defaultValue: {})
  Map<String, Map<String, List<String>>>? purchasedPdfs;
  @HiveField(14, defaultValue: {})
  Map<String, StdQuizModel>? stdQuizes;
  @HiveField(15)
  String? groupName;
  @HiveField(16)
  String? groupId;
  @HiveField(17)
  bool? enabled;
  @HiveField(18)
  String? pushToken;
  @HiveField(19)
  String? parentPhoneNum;
  @HiveField(20)
  bool? isActive;
  String? government;
  String? area;
  @HiveField(23)
  String? gender;
  List<DeviceModel>? devices;
  DateTime? createdAt;
  @HiveField(24)
  String? walletBalanceStatus;
  @HiveField(25)
  DateTime? lastwalletBalanceTransaction;

  UserModel({
    required this.ar_fname,
    required this.ar_sname,
    required this.ar_thname,
    required this.code,
    required this.fname,
    required this.grade,
    required this.phoneNum,
    required this.sname,
    required this.thname,
    required this.img,
    required this.balance,
    required this.password,
    required this.purchasedVideos,
    required this.parentPhoneNum,
    required this.purchasedPdfs,
    required this.stdQuizes,
    required this.groupId,
    required this.groupName,
    required this.enabled,
    required this.isActive,
    required this.pushToken,
    this.government,
    this.area,
    this.gender,
    this.devices,
    this.createdAt,
    this.walletBalanceStatus,
    this.lastwalletBalanceTransaction,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    ar_fname = json['ar_fname'];
    ar_sname = json['ar_sname'];
    ar_thname = json['ar_thname'];
    code = json['code'];
    fname = json['fname'];
    grade = json['grade'];

    phoneNum = json['phoneNum'];
    sname = json['sname'];
    enabled = json['enabled'] ?? true;

    isActive = json['isActive'] ?? true;
    parentPhoneNum = json['parentPhoneNum'];
    createdAt = json['createdAt'] != null
        ? (json['createdAt'] as Timestamp).toDate()
        : null;
    img = json['img'];
    thname = json['thname'];
    balance = json['balance'];
    password = json['password'];
    groupId = json['groupId'];
    pushToken = json['pushToken'] ?? '';
    groupName = json['groupName'];
    gender = json['gender'];
    government = json['government'];
    area = json['area'];
    walletBalanceStatus = json['walletBalanceStatus'];
    lastwalletBalanceTransaction = json['lastwalletBalanceTransaction'] != null
        ? (json['lastwalletBalanceTransaction'] as Timestamp).toDate()
        : null;
    Map<String, UserPurchasedChapterModel> purchasedVideos = {};
    if (json['purchased_videos'] != null) {
      json['purchased_videos'].forEach((chapterKey, chapterValue) {
        purchasedVideos[chapterKey] = UserPurchasedChapterModel.fromJson(
            chapterValue as Map<String, dynamic>);
      });
    }
    this.purchasedVideos = purchasedVideos;

    Map<String, Map<String, List<String>>> purchasedPdfs = {};

    if (json['purchased_pdfs'] != null) {
      json['purchased_pdfs'].forEach((chapterKey, chapterValue) {
        Map<String, List<String>> lectures = {};
        (chapterValue as Map<String, dynamic>)
            .forEach((lectureKey, lectureValue) {
          List<dynamic> list = lectureValue as List<dynamic>;
          lectures[lectureKey] = list.map((item) => item as String).toList();
        });
        purchasedPdfs[chapterKey] = lectures;
      });
    }
    this.purchasedPdfs = purchasedPdfs;

    if (json['stdQuizes'] != null) {
      stdQuizes = <String, StdQuizModel>{};
      json['stdQuizes'].forEach((k, v) {
        stdQuizes![k] = StdQuizModel.fromJson(v);
      });
    }
    if (json['devices'] != null) {
      devices = <DeviceModel>[];
      json['devices'].forEach((v) {
        devices!.add(DeviceModel.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['ar_fname'] = ar_fname;
    data['enabled'] = enabled ?? true;
    data['pushToken'] = pushToken ?? '';
    data['parentPhoneNum'] = parentPhoneNum;
    data['ar_sname'] = ar_sname;
    data['ar_thname'] = ar_thname;
    data['code'] = code;
    data['password'] = password;

    data['fname'] = fname;
    data['sname'] = sname;
    data['isActive'] = isActive;
    data['thname'] = thname;
    data['balance'] = balance;
    data['grade'] = grade;
    data['img'] = img;
    data['createdAt'] = createdAt;
    data['phoneNum'] = phoneNum;
    data['walletBalanceStatus'] = walletBalanceStatus;
    data['lastwalletBalanceTransaction'] = lastwalletBalanceTransaction;
    // Handle purchased_videos map structure
    if (purchasedVideos != null) {
      data['purchased_videos'] = purchasedVideos!.map((key, value) {
        return MapEntry(
          key,
          value.toMap(),
        );
      });
    }
    if (purchasedPdfs != null) {
      data['purchased_pdfs'] = purchasedPdfs!.map((key, innerMap) {
        return MapEntry(key, innerMap.map((innerKey, pdfList) {
          return MapEntry(
              innerKey, pdfList); // The List<String> remains the same
        }));
      });
    }
    // Handle stdQuizes if not null
    if (stdQuizes != null) {
      data['stdQuizes'] = stdQuizes!.map((k, v) => MapEntry(k, v.toJson()));
    }

    data['groupName'] = groupName;
    data['groupId'] = groupId;
    data['government'] = government;
    data['area'] = area;
    data['attendance'] = {};
    data['gender'] = gender;
    data['devices'] = devices?.map((e) => e.toJson()).toList() ?? [];
    return data;
  }
}

class DeviceModel {
  final String id;
  final String type; // mobile or pc

  DeviceModel({
    required this.id,
    required this.type,
  });

  /// تحويل من JSON لـ Model
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
    );
  }

  /// تحويل من Model لـ JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
    };
  }
}
