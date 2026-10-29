class QuestionOptionModel {
  String? title;
  String? imgUrl;

  QuestionOptionModel({
    this.title,
    this.imgUrl,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      title: json['title'] as String?,
      imgUrl: json['imgUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imgUrl': imgUrl,
    };
  }
}
