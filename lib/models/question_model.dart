import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salah_online_platform/models/question_options_model.dart';

class QuestionModel {
  late String title;
  late String id;
  int? index;
  late DateTime date;
  String? imgUrl;
  List<QuestionOptionModel>? options;
  int? ansIdx;
  late int degree;

  QuestionModel({
    required this.title,
    required this.id,
    this.options,
    required this.date,
    this.imgUrl,
    this.index,
    required this.degree,
    this.ansIdx,
  });

  QuestionModel.fromJson(Map<String, dynamic> data) {
    title = data['title'];
    id = data['id'];
    index = data['index'];
    date = (data['date'] as Timestamp).toDate();
    imgUrl = data['imgUrl'];
    ansIdx = data['ansIdx'];
    degree = data['degree'] ?? 1;
    if (data['options'] != null) {
      options = <QuestionOptionModel>[];
      data['options'].forEach((v) {
        options!.add(QuestionOptionModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['id'] = id;
    data['index'] = index;
    data['date'] = date;
    data['ansIdx'] = ansIdx;
    data['degree'] = degree;
    data['imgUrl'] = imgUrl;
    data['options'] = options?.map((v) => v.toMap()).toList();
    return data;
  }
}
