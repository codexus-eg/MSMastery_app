class PurchasesWidgetData {
  String lectureImg;
  String lectureTitle;
  String? lectureSubTitle;
  int avaWatches;
  int stdWatches;

  String lectureId;

  String chapterId;

  bool lectureDep;

  int price;
  DateTime? dateTime;

  PurchasesWidgetData({
    required this.lectureImg,
    required this.lectureTitle,
    required this.avaWatches,
    this.lectureSubTitle,
    required this.stdWatches,
    required this.lectureId,
    required this.chapterId,
    required this.lectureDep,
    required this.price,
    this.dateTime,
  });

  PurchasesWidgetData copyWith({
    String? lecId,
    String? lectureImg,
    String? lectureId,
    String? chapterId,
    String? lectureTitle,
    String? lectureSubTitle,
    int? avaWatches,
    int? stdWatches,
    DateTime? dateTime,
  }) {
    return PurchasesWidgetData(
      lectureImg: lectureImg ?? this.lectureImg,
      lectureTitle: lectureTitle ?? this.lectureTitle,
      avaWatches: avaWatches ?? this.avaWatches,
      stdWatches: stdWatches ?? this.stdWatches,
      lectureId: lectureId ?? this.lectureId,
      chapterId: chapterId ?? this.chapterId,
      lectureSubTitle: lectureSubTitle ?? this.lectureSubTitle,
      lectureDep: lectureDep,
      price: price,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
