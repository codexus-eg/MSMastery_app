import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'user_purchase_model.g.dart';

@HiveType(typeId: 2)
class UserPurchasedModel extends HiveObject {
  @HiveField(0)
  String? vidId;
  @HiveField(1)
  int? stdWatches;
  @HiveField(2)
  int? avaWatches;
  @HiveField(3)
  DateTime? dateTime;
  UserPurchasedModel({
    required this.vidId,
    required this.stdWatches,
    required this.avaWatches,
    required this.dateTime,
  });

  UserPurchasedModel.fromJson(Map<String, dynamic> json) {
    vidId = json['vid_id'];
    stdWatches = json['stdWatches'];
    avaWatches = json['avaWatches'] ?? 4;
    dateTime = json['dateTime'] != null
        ? (json['dateTime'] as Timestamp).toDate()
        : null;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vid_id'] = vidId;
    data['stdWatches'] = stdWatches;
    data['avaWatches'] = avaWatches;
    data['dateTime'] = dateTime;
    return data;
  }
}
