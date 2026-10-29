// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/screens/auth_screens/login_screens/login_page.dart';
import 'package:salah_online_platform/screens/main/lectures_screen.dart';
import 'package:salah_online_platform/screens/main/home_screen.dart';
import 'package:salah_online_platform/screens/main/profile_screen.dart';
import 'package:no_screenshot/no_screenshot.dart';

import '../network/local/shared_pref_helper.dart';
import '../screens/main/quiz_screen.dart';

class Constants {
  static List<Widget> screensList = [
    const HomeScreen(),
    const LecturesScreen(),
    QuizScreen(),
    ProfileScreen(),
  ];
  static String otpMsg({required String code}) {
    String msg = '''
رمز التحقق الخاص بك هو $code،
يرجى إدخاله لتأكيد رقم الهاتف.
''';

    return msg;
  }

  static Future<http.Response?> sendOtpMsg({
    required String phone,
    required String code,
  }) async {
    String railwayUrl = "https://whatsappdashboard-production.up.railway.app";

    try {
      final response = await http.post(
        Uri.parse("$railwayUrl/send-otp"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "to": '+2$phone',
          "phoneNumberId": "1079265581929142",
          "language": "ar",
          "code": code,
        }),
      );

      return response;
    } catch (e) {
      debugPrint("❌ Network Error: $e");
      return null;
    }
  }

  static final noScreenshot = NoScreenshot.instance;

  static String guest = 'guest';
  static Map<String, FaIconData> icons = {
    'wts': FontAwesomeIcons.whatsapp,
    'fb': FontAwesomeIcons.facebook,
    'ytp': FontAwesomeIcons.youtube,
    'tel': FontAwesomeIcons.telegram,
    'tik': FontAwesomeIcons.tiktok,
    'insta': FontAwesomeIcons.instagram,
  };

  static late Box userBox;
  static String doubletoInt(double value) {
    String formatted = (value % 1 == 0)
        ? value.toInt().toString() // لو رقم صحيح
        : value.toString(); // لو فيه كسور

    return formatted;
  }

  static void showLoginDialog({
    required BuildContext context,
    required bool isDarkMode,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isDarkMode ? AppColors.darkBorder : AppColors.lightBborder,
          title: Text(
            S.of(context).login_req,
          ),
          content: Text(
            S.of(context).must_login_access,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                S.of(context).cancel,
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                await Constants.userBox.delete('user');
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                  (route) => false,
                );
              },
              child: Text(
                S.of(context).login,
                style: TextStyle(color: Components.setBgColor(isDarkMode)),
              ),
            ),
          ],
        );
      },
    );
  }

  static String firstOnBoarding =
      'https://firebasestorage.googleapis.com/v0/b/koraiemonlineplatform.appspot.com/o/app_images%2Fon_board%2Fphoto_2024-10-17_21-33-06.png?alt=media&token=7885ccab-8644-42b4-a437-3d57463a5d73';
  static String getStatred =
      'https://firebasestorage.googleapis.com/v0/b/koraiemonlineplatform.appspot.com/o/app_images%2Fon_board%2Fphoto_2024-10-17_21-33-05.png?alt=media&token=5b5dada8-a9f0-4cf1-a0a0-9ba23626b6e9';

  static String koraiemPhoto =
      'https://firebasestorage.googleapis.com/v0/b/koraiemonlineplatform.appspot.com/o/app_images%2Fon_board%2F541bf65446f74c2599b7a9453fce4314.jpg?alt=media&token=1b38b355-9fc6-46ef-9659-ecd7e8900384';

  static String questionBank =
      'https://firebasestorage.googleapis.com/v0/b/koraiemonlineplatform.appspot.com/o/app_images%2Fon_board%2Fquestions_bank%20(2).png?alt=media&token=1e71a497-3be6-446b-aaea-9339f9e7502a';

  static String lectures =
      'https://firebasestorage.googleapis.com/v0/b/sagedonlineplatform.appspot.com/o/app_images%2Fon_board%2Flectures.png?alt=media&token=e0590979-9784-4815-acf3-8cecef128a4b';

  static String questions =
      'https://firebasestorage.googleapis.com/v0/b/sagedonlineplatform.appspot.com/o/app_images%2Fon_board%2Fquestions.png?alt=media&token=1eb873b0-b18d-4619-9dcc-c1828ca239f3';

  static String requests =
      'https://firebasestorage.googleapis.com/v0/b/sagedonlineplatform.appspot.com/o/app_images%2Fon_board%2Frequests.png?alt=media&token=6872fe54-a80a-4d75-ab77-a694270708f6';

  static String attendence =
      'https://firebasestorage.googleapis.com/v0/b/sagedonlineplatform.appspot.com/o/app_images%2Fon_board%2Fattendance.png?alt=media&token=9aed8626-379f-40c8-a628-f6c052aae889';

  static String noQuiz =
      'https://firebasestorage.googleapis.com/v0/b/amin-platform.firebasestorage.app/o/app_images%2Fno_quiz.png?alt=media&token=d8511573-4c76-4ce7-b668-52191248fe2a';
  static String quizTime =
      'https://firebasestorage.googleapis.com/v0/b/amin-platform.firebasestorage.app/o/app_images%2Fquiz_time.png?alt=media&token=d8511573-4c76-4ce7-b668-52191248fe2a';
  static String img =
      'https://firebasestorage.googleapis.com/v0/b/salahplatform.firebasestorage.app/o/user_images%2Fuser.png?alt=media&token=671f6f72-efe5-4e5e-8f08-59479986f815';

  static String teacherImg =
      'https://firebasestorage.googleapis.com/v0/b/salahplatform.firebasestorage.app/o/app_images%2FteacherImg.png?alt=media&token=67eb9088-db88-4776-b845-5c4a5c994078';

  static String wallpaberDark = SharedPrefHelper.getData('isPurple') ?? false
      ? wallpaberPurbleDark
      : wallpaberBlueDark;

  static String wallpaberLight = SharedPrefHelper.getData('isPurple') ?? false
      ? wallpaberPurbleLight
      : wallpaberBlueLight;
  static String wallpaberPurbleDark = 'assets/images/bg/wallpaber_dark.png';
  static String wallpaberPurbleLight = 'assets/images/bg/wallpaber_light.png';
  static String wallpaberBlueDark = 'assets/images/bg/wallpaber_dark.png';
  static String wallpaberBlueLight = 'assets/images/bg/wallpaber_light.png';

  static String accountBlocked = 'blocked';
  static String accountPending = 'pending';

  static const List<String> governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الشرقية',
    'الدقهلية',
    'القليوبية',
    'البحيرة',
    'المنوفية',
    'الغربية',
    'كفر الشيخ',
    'دمياط',
    'بورسعيد',
    'الإسماعيلية',
    'السويس',
    'الفيوم',
    'بني سويف',
    'المنيا',
    'أسيوط',
    'سوهاج',
    'قنا',
    'الأقصر',
    'أسوان',
    'البحر الأحمر',
    'الوادي الجديد',
    'مطروح',
    'شمال سيناء',
    'جنوب سيناء',
  ];

  static String devCode = '327459595';

  static IconData mathIcon(String name) {
    if (name.contains('تفاضل') || name.contains('تكامل')) {
      return Icons.functions_rounded;
    } else if (name.contains('استاتيكا') || name.contains('ديناميكا')) {
      return Icons.speed_rounded;
    } else if (name.contains('هندسة')) {
      return Icons.architecture_rounded;
    } else {
      return Icons.calculate_rounded;
    }
  }
}
