import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceModel {
  // Common Fields (Present in all states)
  final double amount; // Parsed safely from String
  final String chapterId;
  final DateTime createdAt;
  final String currency;
  final String grade;
  final String title;

  final String intentKey;
  final String invoiceKey;
  final String lectureId;
  final String status; // "pending", "paid", "failed"
  final String userId;

  // Paid/Failed Shared Fields
  final String? paymentMethod; // e.g., "Card" or "كارت بنكي"
  final String? referenceNumber; // String or null
  String? redirectTo;
  String? fawryCode;
  DateTime? expireDate;

  // Paid Specific Fields
  final DateTime? paidAt;

  // Failed Specific Fields
  final DateTime? failedAt;
  final String? failureReason;
  final String? gatewayCode;

  InvoiceModel({
    required this.amount,
    required this.chapterId,
    required this.createdAt,
    required this.currency,
    required this.grade,
    required this.title,
    this.redirectTo,
    this.fawryCode,
    this.expireDate,
    required this.intentKey,
    required this.invoiceKey,
    required this.lectureId,
    required this.status,
    required this.userId,
    this.paymentMethod,
    this.referenceNumber,
    this.paidAt,
    this.failedAt,
    this.failureReason,
    this.gatewayCode,
  });

  // Factory constructor to handle all 3 variations
  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      // Common Fields
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      chapterId: json['chapterId'] as String? ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      currency: json['currency'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      title: json['title'] as String? ?? '',
      redirectTo: json['redirectTo'] as String? ?? '',
      fawryCode: json['fawryCode'] as String? ?? '',
      expireDate: json['expireDate'] is Timestamp
          ? (json['expireDate'] as Timestamp).toDate()
          : null,
      intentKey: json['intentKey'] as String? ?? '',
      invoiceKey: json['invoiceKey'] as String? ?? '',
      lectureId: json['lectureId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      userId: json['userId'] as String? ?? '',

      // Nullable Optional Fields (Safely parsed if present)
      paymentMethod: json['paymentMethod'] as String?,
      referenceNumber: json['referenceNumber'] as String?,

      paidAt: json['paidAt'] is Timestamp
          ? (json['paidAt'] as Timestamp).toDate()
          : null,

      failedAt: json['failedAt'] is Timestamp
          ? (json['failedAt'] as Timestamp).toDate()
          : null,

      failureReason: json['failureReason'] as String?,
      gatewayCode: json['gatewayCode'] as String?,
    );
  }

  // Handy helpers to easily check the status in your UI
  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
}
