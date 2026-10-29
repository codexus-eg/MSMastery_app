class PaymentModel {
  String? status;
  List<PaymentData>? paymentData;

  PaymentModel({this.status, this.paymentData});

  PaymentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      paymentData = <PaymentData>[];
      json['data'].forEach((v) {
        paymentData!.add(PaymentData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (paymentData != null) {
      data['data'] = paymentData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/// Parsed result of the Fawaterk `invoiceInitPay` endpoint.
///
/// Depending on the chosen payment method the gateway returns one of:
///  * Card / Visa / mobile-wallet → `status: success` with a [redirectTo] url
///    nested under `data.payment_data` (open the checkout in a webview).
///  * Fawry / reference-code → `status: pending` with the Fawry
///    [fawryCode] (`referenceNumber`), the [expireDate] (`expirationTime`) and
///    a human-readable [reference] (e.g. `TR-457`) returned at the top level.
class PaymentInitResult {
  final String? status;
  final int? invoiceId;
  final String? orderId;
  final String? redirectTo;

  final String? fawryCode;

  final String? expireDate;

  PaymentInitResult({
    this.status,
    this.invoiceId,
    this.orderId,
    this.redirectTo,
    this.fawryCode,
    this.expireDate,
  });

  bool get isSuccess => status == 'success' || status == 'pending';

  bool get isReferenceCode => fawryCode != null && fawryCode!.isNotEmpty;
  bool get isRedirect =>
      !isReferenceCode && redirectTo != null && redirectTo!.isNotEmpty;

  factory PaymentInitResult.fromJson(Map<String, dynamic> json) {
    final paymentData = json['payment_data'] ?? {};

    final fawryCode = paymentData['fawryCode'];
    final expireDate = paymentData['expireDate'];

    return PaymentInitResult(
      status: json['status']?.toString(),
      invoiceId: json['invoice_id'],
      orderId: json['orderId'],
      redirectTo: paymentData['redirectTo'],
      fawryCode: fawryCode,
      expireDate: expireDate,
    );
  }
}

class PaymentData {
  int? paymentId;
  String? nameAr;
  String? nameEn;
  String? arSubTitle;
  String? enSubTitle;
  bool? redirectOption;
  PaymentData(
      {this.paymentId,
      this.nameAr,
      this.nameEn,
      this.arSubTitle,
      this.enSubTitle,
      this.redirectOption});

  PaymentData.fromJson(Map<String, dynamic> json) {
    paymentId = json['paymentId'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
    arSubTitle = json['arSubTitle'];
    enSubTitle = json['enSubTitle'];
    redirectOption = json['redirectOption'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['paymentId'] = paymentId;
    data['redirectOption'] = redirectOption;
    data['name_ar'] = nameAr;
    data['name_en'] = nameEn;
    data['arSubTitle'] = arSubTitle;
    data['enSubTitle'] = enSubTitle;

    return data;
  }
}
