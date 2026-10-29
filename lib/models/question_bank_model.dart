class QuestionBankModel {
  late String title;
  late int duration;
  late int questionsNum;
  late Map<String?, List<String?>> chapters;

  QuestionBankModel({
    required this.title,
    required this.duration,
    required this.questionsNum,
    required this.chapters,
  });
}
