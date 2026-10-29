import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/models/boarding_model.dart';

class Components {
  static void pushReplacement(
      {required BuildContext context, required Widget widget}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
  }

  static Future<String?> getAccessToken() async {
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    try {
      // 1. Fetch the document from Firestore
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('data').doc('fcm').get();

      if (!doc.exists) {
        debugPrint("Error: Service account document not found in Firestore.");
        return null;
      }

      // 2. Extract the raw string from the document fields
      String? rawJsonString = doc.get('fcm') as String?;
      if (rawJsonString == null || rawJsonString.isEmpty) {
        debugPrint("Error: fcm field is empty.");
        return null;
      }

      // 3. Convert the String back into a Map<String, dynamic>
      Map<String, dynamic> serviceAccountJson = jsonDecode(rawJsonString);

      // 4. Use the decoded Map exactly like before
      http.Client client = await auth.clientViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

      auth.AccessCredentials credentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
              auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
              scopes,
              client);

      client.close();
      debugPrint("Access Token obtained successfully.");
      return credentials.accessToken.data;
    } catch (e) {
      debugPrint("Error getting access token from Firestore string: $e");
      return null;
    }
  }

  static void push({required BuildContext context, required Widget widget}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );
  }

  /// اسم الراوت الخاص بـ HomeLayout للرجوع إليه من أي شاشة.
  static const String homeRouteName = 'home';

  /// يفتح [widget] كأول شاشة في الـ stack ويمسح كل الشاشات السابقة،
  /// حتى لا تظل شاشة تسجيل الدخول أسفل الـ HomeLayout.
  static void pushAndRemoveAll({
    required BuildContext context,
    required Widget widget,
    String? name,
  }) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => widget,
        settings: RouteSettings(name: name),
      ),
      (route) => false,
    );
  }

  static void pop({required BuildContext context}) {
    Navigator.of(context).pop();
  }

  static List<BoardingModel> boardings = [
    BoardingModel(
      image: Constants.firstOnBoarding,
      title: 'أهلاَ بيك في منصة\nبِالْعَرَبِيّ',
      body: "#لن_يسبقك_أحد",
    ),
    BoardingModel(
      image: Constants.lectures,
      title: 'الحصص',
      body: 'تقدر تتفرج علي الحصص براحتك في اي وقت.',
    ),
    BoardingModel(
      image: Constants.requests,
      title: 'الاسئلة',
      body: 'تقدر تبعت سؤال للسكرتيرة وترد عليك.',
    ),
    BoardingModel(
      image: Constants.questions,
      title: 'الامتحانات',
      body: 'هتمتحن ف اي وقت عن طريق ادخال كود الامتحان.',
    ),
    BoardingModel(
      image: Constants.questionBank,
      title: 'بنك الاسئلة',
      body: 'حل اكبر كمية اسئلة من بنك الاسئلة.',
    ),
    BoardingModel(
      image: Constants.attendence,
      title: 'الحضور',
      body: 'تقدر تتابع حضورك وغيابك وتسجل حضورك بسهولة.',
    ),
    BoardingModel(
      image: Constants.getStatred,
      title: "يلا بينا!",
      body: 'يلا بينا نبدأ.',
    ),
  ];

  static Future<bool> checkConnection() async {
    var result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none); // يعني فيه اتصال بشبكة
  }

  static String getGrade(String num) {
    if (num == '1') {
      return 'first';
    } else if (num == '2') {
      return 'second';
    } else if (num == '3') {
      return 'third';
    } else {
      return 'sec';
    }
  }

  static Color setBgColor(bool isDarkMode) =>
      isDarkMode ? AppColors.appPrimaryColor : AppColors.appSecondaryColor;
  static Color setTextColor(bool isDarkMode) => Colors.white;

  static String getGradeNum(String grade) {
    if (grade == 'first') {
      return '1';
    } else if (grade == 'second') {
      return '2';
    } else {
      return '3';
    }
  }

  String calculateVideoDuration(Duration duration) {
    final totalHour = duration.inHours == 0 ? '' : '${duration.inHours}:';
    final totalMinute = duration.toString().split(':')[1];
    final totalSeconds = (duration - Duration(minutes: duration.inMinutes))
        .inSeconds
        .toString()
        .padLeft(2, '0');
    final String videoLength = '$totalHour$totalMinute:$totalSeconds';
    return videoLength;
  }

  static Color getColorFromPercentage(double percentage) {
    if (percentage >= 0.80) {
      return Colors.green;
    } else if (percentage <= 0.30) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  static IconData lectureDataIcon(String type) {
    if (type == 'video') {
      return Icons.video_collection;
    } else if (type == 'pdf') {
      return Icons.picture_as_pdf;
    } else {
      return Icons.quiz;
    }
  }

  static String getGradeName(String selectedGrade) {
    if (selectedGrade == 'first') {
      return 'الأول الثانوي';
    } else if (selectedGrade == 'second') {
      return 'الثاني الثانوي';
    } else if (selectedGrade == 'third') {
      return 'الثالث الثانوي';
    } else {
      return 'غير محدد';
    }
  }
}
