class PurchaseExamModel {
  DateTime? date;
  String? stdCode;
  String? quizId;

  // Constructor
  PurchaseExamModel({
    required this.date,
    required this.stdCode,
    required this.quizId,
  });

  // Method to convert the instance back to JSON
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['date'] = date;
    data['stdCode'] = stdCode;
    data['quizId'] = quizId;

    return data;
  }
}
