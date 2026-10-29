import 'package:cloud_firestore/cloud_firestore.dart';

class VideoDetailsModel {
  late String title;
  String? subTitle;

  late String chapId;
  late String lecId;
  late String thumbnail;
  late int price;
  late bool dep;
  int? prevPrice;
  late DateTime date;

  VideoDetailsModel({
    required this.chapId,
    required this.title,
    required this.price,
    this.subTitle,
    this.prevPrice,
    required this.lecId,
    required this.thumbnail,
    required this.date,
    required this.dep,
  });

  VideoDetailsModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    chapId = json['lecId'];
    lecId = json['id'];
    price = json['price'];
    subTitle = json['subTitle'];
    thumbnail = json['thumbnail'];
    dep = json['dep'] ?? false;
    prevPrice = json['prevPrice'];
    // Handle the conversion from Timestamp to DateTime
    if (json['date'] is Timestamp) {
      date = (json['date'] as Timestamp).toDate();
    } else {
      date = json['date'];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'id': lecId,
      'lecId': chapId,
      'thumbnail': thumbnail,
      'subTitle': subTitle,
      'price': price,
      'prevPrice': prevPrice,
      'date': date,
      'dep': dep,
    };
  }
}
