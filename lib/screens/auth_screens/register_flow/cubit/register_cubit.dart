import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/models/otp_model.dart';
import 'package:salah_online_platform/models/user_model.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_states.dart';
import 'package:salah_online_platform/services/notification_service.dart';

enum RegisterStep {
  phone,
  otp,
  personal,
  address,
  password,
}

enum Gender { male, female }

enum StudyGrade { second, third }

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterInitial());

  static RegisterCubit get(BuildContext context) =>
      BlocProvider.of<RegisterCubit>(context);

  RegisterStep currentStep = RegisterStep.phone;

  String phoneNum = '';
  String otp = '';

  String firstName = '';
  String secondName = '';
  String thirdName = '';
  Gender? gender;
  String parentPhoneNum = '';
  StudyGrade? grade;

  String government = '';
  String area = '';

  String password = '';
  String confirmPassword = '';

  int otpResendSeconds = 0;

  void goTo(RegisterStep step) {
    currentStep = step;
    emit(RegisterStepChanged(step));
  }

  void nextStep() {
    final next = RegisterStep.values[
        (currentStep.index + 1).clamp(0, RegisterStep.values.length - 1)];
    goTo(next);
  }

  void prevStep() {
    final prev = RegisterStep.values[
        (currentStep.index - 1).clamp(0, RegisterStep.values.length - 1)];
    goTo(prev);
  }

  void setPhone(String v) {
    phoneNum = v.trim();
    emit(const RegisterFieldChanged());
  }

  void setOtp(String v) {
    otp = v.trim();
    emit(const RegisterFieldChanged());
  }

  void setFirstName(String v) {
    firstName = v.trim();
    emit(const RegisterFieldChanged());
  }

  void setSecondName(String v) {
    secondName = v.trim();
    emit(const RegisterFieldChanged());
  }

  void setThirdName(String v) {
    thirdName = v.trim();
    emit(const RegisterFieldChanged());
  }

  void setGender(Gender v) {
    gender = v;
    emit(const RegisterFieldChanged());
  }

  void setParentPhone(String v) {
    parentPhoneNum = v.trim();
    emit(const RegisterFieldChanged());
  }

  void setGrade(StudyGrade v) {
    grade = v;
    emit(const RegisterFieldChanged());
  }

  void setGovernment(String v) {
    government = v;
    emit(const RegisterFieldChanged());
  }

  void setArea(String v) {
    area = v;
    emit(const RegisterFieldChanged());
  }

  void setPassword(String v) {
    password = v;
    emit(const RegisterFieldChanged());
  }

  void setConfirmPassword(String v) {
    confirmPassword = v;
    emit(const RegisterFieldChanged());
  }

  static const int _maxOtpPerHour = 3;
  static const List<String> _grades = ['second', 'third'];

  Future<void> sendOtp() async {
    final mobile = phoneNum.trim();
    emit(const RegisterSendOtpLoading());

    final isConnected = await Components.checkConnection();
    if (!isConnected) {
      emit(const RegisterSendOtpFail('لا يوجد اتصال بالانترنت'));
      return;
    }

    try {
      final exists = await _isPhoneRegistered(mobile);
      if (exists) {
        emit(const RegisterSendOtpFail(
            'هذا الرقم مسجل من قبل، حاول تسجيل الدخول.'));
        return;
      }

      final remaining = await _otpsRemainingThisHour(mobile);
      if (remaining <= 0) {
        emit(const RegisterSendOtpFail(
            'لقد تجاوزت الحد المسموح به (3 محاولات في الساعة). حاول مرة أخرى بعد ساعة.'));
        return;
      }

      final code = (Random().nextInt(900000) + 100000).toString();
      await FirebaseFirestore.instance.collection('otp').doc(code).set(
            OtpModel(
              code: code,
              date: DateTime.now(),
              phoneNum: mobile,
            ).toJson(),
          );

      await _sendOtpMessage(mobile: mobile, code: code);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('socket') ||
          msg.contains('network') ||
          msg.contains('connection') ||
          msg.contains('unavailable')) {
        emit(const RegisterSendOtpFail(
            'تعذر الاتصال بالخادم، تحقق من اتصالك بالإنترنت وحاول مرة أخرى.'));
      } else {
        emit(const RegisterSendOtpFail(
            'حدث خطأ غير متوقع، حاول مرة أخرى بعد قليل.'));
      }
    }
  }

  Future<bool> _isPhoneRegistered(String mobile) async {
    for (final grade in _grades) {
      final snap = await FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(grade)
          .where('phoneNum', isEqualTo: mobile)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) return true;
    }
    return false;
  }

  Future<int> _otpsRemainingThisHour(String mobile) async {
    final snap = await FirebaseFirestore.instance
        .collection('otp')
        .where('phoneNum', isEqualTo: mobile)
        .get();

    final now = DateTime.now();
    int recent = 0;
    for (final doc in snap.docs) {
      final ts = doc.data()['date'];
      if (ts is Timestamp && now.difference(ts.toDate()).inMinutes < 60) {
        recent++;
      }
    }
    return _maxOtpPerHour - recent;
  }

  Future<void> _sendOtpMessage({
    required String mobile,
    required String code,
  }) async {
    final response = await Constants.sendOtpMsg(
      phone: mobile,
      code: code,
    );
    if (response == null || response.statusCode != 200) {
      emit(const RegisterSendOtpFail('حدث خطأ غير متوقع, حاول مرة اخرى'));
    } else {
      otpResendSeconds = 30;
      emit(const RegisterSendOtpSuccess());
    }
  }

  Future<void> verifyOtp() async {
    emit(const RegisterVerifyOtpLoading());
    final doc = FirebaseFirestore.instance.collection('otp').doc(otp);
    final snap = await doc.get();
    if (snap.exists) {
      final data = snap.data()!;
      if (data['phoneNum'] == phoneNum) {
        final now = DateTime.now();
        if (now.difference(data['date'].toDate()).inMinutes < 10) {
          emit(const RegisterVerifyOtpSuccess());
          await doc.delete();
        } else {
          emit(const RegisterVerifyOtpFail('الكود منتهي الصلاحية'));
        }
      } else {
        emit(const RegisterVerifyOtpFail('الكود غير صحيح'));
      }
    } else {
      emit(const RegisterVerifyOtpFail('الكود غير صحيح'));
    }
  }

// Student Register
  Future<void> submitRegistration() async {
    emit(const RegisterSubmitLoading());

    try {
      final yearDoc =
          await FirebaseFirestore.instance.collection('data').doc('year').get();

      final year = yearDoc.data()?['year'];

      final random = Random.secure();

      String stdCode = '';
      bool exists = true;

      // Limit attempts to avoid infinite loop
      for (int i = 0; i < 10 && exists; i++) {
        final stdIndex = List.generate(6, (_) => random.nextInt(10)).join();

        stdCode = '${Components.getGradeNum(grade!.name)}$year$stdIndex';

        final doc = await FirebaseFirestore.instance
            .collection('data')
            .doc('students')
            .collection(grade!.name)
            .doc(stdCode)
            .get();

        exists = doc.exists;
      }

      if (exists) {
        emit(const RegisterSubmitFail(
            'فشل إنشاء رمز الطالب المميز, حاول مرة اخرى'));
        return;
      }
      String deviceType = _getDeviceType();
      String deviceId = await _getDeviceId();

      await createStudent(
        userModel: UserModel(
          ar_fname: firstName,
          ar_sname: secondName,
          ar_thname: thirdName,
          fname: firstName,
          sname: secondName,

          thname: thirdName,
          createdAt: DateTime.now(),

          grade: grade!.name,
          phoneNum: phoneNum,
          parentPhoneNum: parentPhoneNum,
          isActive: false,
          government: government,
          area: area,
          gender: gender!.name,
          code: stdCode,
          groupId: '',
          groupName: 'Online',

          // Defaults
          enabled: true,
          devices: [DeviceModel(id: deviceId, type: deviceType)],

          pushToken: await NotificationService.getToken() ?? '',
          purchasedPdfs: {},
          purchasedVideos: {},
          stdQuizes: {},

          img: Constants.img,
          balance: 0,
          password: password,
        ),
      );
    } catch (e) {
      emit(RegisterSubmitFail(e.toString()));

      debugPrint(e.toString());
    }
  }

  Future<void> createStudent({
    required UserModel userModel,
  }) async {
    FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(userModel.grade!)
        .doc(userModel.code)
        .set(userModel.toMap())
        .then((value) {
      Constants.userBox.put('user', userModel);
      NotificationService.manageUserTopics();
      debugPrint('${userModel.phoneNum} Created!');
      NotificationService.sendToTopic(
        topic: 'sec',
        title: 'طلب تفعيل حساب جديد',
        body:
            '${userModel.ar_fname} ${userModel.ar_sname} ${userModel.ar_thname} - الصف ${Components.getGradeName(userModel.grade!)} في انتظار الموافقة.',
      );
      emit(const RegisterSubmitSuccess());
    }).catchError((onError) {
      debugPrint(onError.toString());
      emit(RegisterSubmitFail(onError.toString()));
    });
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var info = await deviceInfo.androidInfo;
      return info.id;
    } else if (Platform.isIOS) {
      var info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? '';
    } else {
      var info = await deviceInfo.windowsInfo;
      return info.deviceId;
    }
  }

  String _getDeviceType() {
    return (Platform.isAndroid || Platform.isIOS) ? 'mobile' : 'pc';
  }
}
