import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  late String title;
  String? subTitle;
  bool? isChapter;
  int? price;
  int? prevPrice;

  bool? isRev;
  String? verType;
  bool? isExtBook;
  late String chapId;
  late String thumbnail;
  late DateTime date;

  VideoModel({
    required this.title,
    required this.chapId,
    required this.thumbnail,
    required this.date,
    this.subTitle,
    this.isRev,
    this.price,
    this.prevPrice,
    this.verType,
    this.isExtBook,
    this.isChapter,
  });

  VideoModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    chapId = json['id'];
    subTitle = json['subTitle'];
    isRev = json['isRev'] ?? false;
    verType = json['verType'] ?? '';
    isExtBook = json['isExtBook'] ?? false;
    isChapter = json['isChapter'] ?? false;
    thumbnail = json['thumbnail'];
    price = json['price'];
    prevPrice = json['prevPrice'];

    if (json['date'] is Timestamp) {
      date = (json['date'] as Timestamp).toDate();
    } else {
      date = json['date'];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'id': chapId,
      'subTitle': subTitle,
      'isRev': isRev,
      'verType': verType,
      'thumbnail': thumbnail,
      'date': date,
      'isExtBook': isExtBook,
      'price': price,
      'prevPrice': prevPrice,
      'isChapter': isChapter,
    };
  }
}
