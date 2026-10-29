class PurchaseVideoModel {
  DateTime? date;
  String? stdCode;
  String? chapId;
  String? lecId;

  // Constructor
  PurchaseVideoModel({
    required this.date,
    required this.stdCode,
    required this.chapId,
    this.lecId,
  });

  // Method to convert the instance back to JSON
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['date'] = date;
    data['stdCode'] = stdCode;
    data['chapId'] = chapId;
    if (lecId != null) data['lecId'] = lecId;

    return data;
  }
}
