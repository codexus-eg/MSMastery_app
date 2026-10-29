// ignore_for_file: strict_top_level_inference, non_constant_identifier_names, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:salah_online_platform/models/comment_model.dart';
import 'package:salah_online_platform/models/comment_std_data.dart';
import 'package:salah_online_platform/models/invoice_model.dart';
import 'package:salah_online_platform/models/like_std_data.dart';
import 'package:salah_online_platform/models/payment_model.dart';
import 'package:salah_online_platform/models/posts_model.dart';
import 'package:salah_online_platform/models/purchased_exam_model.dart';
import 'package:salah_online_platform/models/purchases_widget_data.dart';
import 'package:salah_online_platform/models/user_purchased_chapter_model.dart';
import 'package:salah_online_platform/models/watches_video_model.dart';
import 'package:salah_online_platform/models/written_answs_model.dart';

import 'package:path_provider/path_provider.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/models/attende_model.dart';
import 'package:salah_online_platform/models/purchased_vid_model.dart';
import 'package:salah_online_platform/models/social_media_model.dart';
import 'package:salah_online_platform/models/std_quiz_model.dart';
import 'package:salah_online_platform/models/user_model.dart';
import 'package:salah_online_platform/models/user_purchase_model.dart';
import 'package:salah_online_platform/models/video_details_model.dart';
import 'package:salah_online_platform/network/local/shared_pref_helper.dart';
import 'package:salah_online_platform/services/notification_service.dart';

import '../models/ChatModel.dart';
import '../models/RequsetsModel.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/viedo_model.dart';

class _LocalLectureSortWrapper {
  final String chapId;
  final String lecId;
  int? stdWatches;
  int? avaWatches;
  final DateTime purchaseDate;

  _LocalLectureSortWrapper({
    required this.chapId,
    required this.lecId,
    this.stdWatches,
    this.avaWatches,
    required this.purchaseDate,
  });
}

class PlatformCubit extends Cubit<PlatformStates> {
  PlatformCubit() : super(PaltformAppInitialState()) {
    isShowDelAccount();
    // حدّث الـ pushToken في Firestore تلقائيًا عند تجديده من FCM.
    NotificationService.onTokenRefreshCallback = updateCurrentUserPushToken;
  }

  /// تحديث الـ pushToken للطالب الحالي في Firestore عند تجديده.
  Future<void> updateCurrentUserPushToken(String token) async {
    if (Platform.isWindows) return;
    final UserModel? sm = Constants.userBox.get('user');
    if (sm == null || sm.code == null || sm.grade == null) return;
    if (sm.code == Constants.guest) return;
    try {
      await FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(sm.grade!)
          .doc(sm.code)
          .update({'pushToken': token});
    } catch (e) {
      debugPrint('Failed to update refreshed pushToken: $e');
    }
  }

  static PlatformCubit get(BuildContext context) => BlocProvider.of(context);
  var scaffoldKey = GlobalKey<ScaffoldState>();

  bool isSecure = true;
  void changePassSecure() {
    isSecure = !isSecure;

    emit(PaltformChangePasswordSecureState());
  }

  bool isGuest() {
    UserModel sm = Constants.userBox.get('user');
    return sm.code == Constants.guest;
  }

  bool isQuestionBank = false;
  void changeQuestionBank() {
    isQuestionBank = !isQuestionBank;
    emit(PlatformChangeQuestionBankState());
  }

  List<QuestionModel> questionbankQuestions = [];
  late Map<String, int?> stdQuestionbankAnsws;

  Future<void> generateQuestions(
    String title,
    int questionsnum,
    Map<String?, List<String?>> chapters,
    int num,
    int fill,
  ) async {
    emit(PlatformQuizGetQuestionBankLoadingState());
    questionbankQuestions = [];
    UserModel um = Constants.userBox.get('user');

    for (int i = 0; i < chapters.length; i++) {
      String? key = chapters.entries.elementAt(i).key;
      List<String?> value = chapters.entries.elementAt(i).value;

      List<String> nonNullValues = value.whereType<String>().toList();

      for (int k = 0; k < nonNullValues.length; k++) {
        try {
          QuerySnapshot questionSnapshot = await FirebaseFirestore.instance
              .collection('data')
              .doc('questions_bank')
              .collection(um.grade!)
              .doc(key)
              .collection('content')
              .doc(nonNullValues[k])
              .collection('questions')
              .get();

          if (questionSnapshot.docs.isNotEmpty) {
            List<DocumentSnapshot> docs = questionSnapshot.docs;

            // Shuffle the list to randomize order
            docs.shuffle();

            // Add the first `num` or `(num + (number - fill))` random questions
            for (int j = 0;
                ((i == chapters.length - 1 && k == nonNullValues.length - 1)
                    ? j <
                        (j < docs.length
                            ? (num + ((number - (num * fill))).abs())
                            : docs.length)
                    : j < (j < docs.length ? num : docs.length));
                j++) {
              questionbankQuestions.add(QuestionModel.fromJson(
                  docs[j].data() as Map<String, dynamic>));
            }
            docs = [];
          }
        } catch (onError) {
          debugPrint(onError.toString());
          emit(PlatformQuizGetQuestionBankFailState(onError.toString()));
        }
      }
    }
    // TODO add to add std points
    // emit(PlatformQuizGetQuestionBankSuccessState(questionbankQuestions));
    questionbankQuestions.shuffle();
    stdQuestionbankAnsws = {};
    addStdQuestionbankPoints(
      isComplete: false,
      chapters: chapters,
    );
  }

  Future<void> addStdQuestionbankPoints({
    required bool isComplete,
    Map<String?, List<String?>>? chapters,
  }) async {
    emit(PlatformAddStdQuestionbankPointsLoadingState());

    try {
      UserModel um = Constants.userBox.get('user');
      int idx = (um.stdQuizes?.values
                  .where((element) => element.id.startsWith('qb'))
                  .length ??
              0) +
          1;

      String targetId = isComplete ? 'qb ${idx - 1}' : 'qb $idx';
      // 1. Ensure map is initialized
      um.stdQuizes ??= {};
      final existingQuiz = um.stdQuizes![targetId];
      final now = DateTime.now();

      // 2. Prepare user answers map safely
      Map<String, dynamic> userAnsIdx =
          Map<String, dynamic>.from(stdQuestionbankAnsws);

      StdQuizModel updatedQuizModel;

      // 3. Create or Update model safely without risking null pointer crashes
      if (existingQuiz != null && existingQuiz.id.isNotEmpty) {
        updatedQuizModel = existingQuiz.copyWith(
          dateTime: isComplete ? existingQuiz.dateTime : now,
          degree: isComplete ? getQuestionbankResult() : 0,
          triesNum: 1,
          userAnsIdx: userAnsIdx,
          submitTime: isComplete ? now : null,
        );
      } else {
        // If completely new, get status/purchase date from payment phase defaults if any
        updatedQuizModel = StdQuizModel(
          id: targetId,
          title: isComplete ? 'Exam ${idx - 1}' : 'Exam $idx',
          dateTime: now,
          questionNums: questionbankQuestions.length,
          fullMark: questionbankQuestions.length,
          degree: isComplete ? getQuestionbankResult() : 0,
          triesNum: 1,
          userAnsIdx: userAnsIdx,
          submitTime: isComplete ? now : null,
          status: existingQuiz?.status,
          purchaseDateTime: existingQuiz?.purchaseDateTime,
        );

        DocumentReference<Map<String, dynamic>> doc = FirebaseFirestore.instance
            .collection('data')
            .doc('students')
            .collection(um.grade!)
            .doc(um.code)
            .collection('questionbank')
            .doc('qb $idx');
        doc.set({"chapters": chapters}).then((value) {
          for (int i = 0; i < questionbankQuestions.length; i++) {
            String paddedIndex = i.toString().padLeft(4, '0');
            doc
                .collection('questions')
                .doc(paddedIndex)
                .set(questionbankQuestions[i].toMap())
                .then((value) {})
                .catchError((onError) {
              emit(PlatformQuizGetQuestionBankFailState(onError.toString()));
              debugPrint(onError.toString());
            });
          }
        }).catchError((onError) {
          emit(PlatformQuizGetQuestionBankFailState(onError.toString()));
        });
      }

      // 4. Update the local copy
      um.stdQuizes![targetId] = updatedQuizModel;

      // 5. Sequence saves securely using async/await
      await um.save();

      await FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(um.grade!)
          .doc(um.code)
          .update({
        'stdQuizes.$targetId': updatedQuizModel.toJson(),
      });

      // 6. Emit corresponding final state
      if (isComplete) {
        emit(PlatformAddStdQuestionbankPointsSuccessState());
      } else {
        emit(PlatformQuizGetQuestionBankSuccessState(questionbankQuestions));
      }
    } catch (onError) {
      debugPrint(
          "Error inside addStdQuestionbankPoints: ${onError.toString()}");
      emit(PlatformAddStdQuestionbankPointsFailState(' ${onError.toString()}'));
    }
  }

  double getQuestionbankResult() {
    double score = 0;
    for (int i = 0; i < questionbankQuestions.length; i++) {
      if (stdQuestionbankAnsws[questionbankQuestions[i].id] ==
          questionbankQuestions[i].ansIdx) {
        score++;
      }
    }
    return score;
  }

  Map<String, Map<String, List<QuestionModel>>> questionbankFreeQuestions = {};
  // Store last documents for pagination
  final Map<String, DocumentSnapshot?> _lastDocuments = {};
  // Track if there are more questions to load
  Map<String, bool> hasMoreQuestions = {};
  static const int _questionsLimit = 5;

  Future<void> getQuestionbankFreeQuestions({
    required Map<String?, List<String?>> chapters,
  }) async {
    questionbankFreeQuestions.clear();
    _lastDocuments.clear();
    hasMoreQuestions.clear();
    emit(PlatformQuizGetFreeQuestionBankLoadingState());

    if (chapters.isEmpty) {
      emit(PlatformQuizGetFreeQuestionBankSuccessState(
          questionbankFreeQuestions));
      return;
    }

    try {
      UserModel um = Constants.userBox.get('user');

      final List<Future<void>> requests = [];

      for (final entry in chapters.entries) {
        final chapterId = entry.key;
        final lessonIds = entry.value;

        if (chapterId == null || lessonIds.isEmpty) continue;

        questionbankFreeQuestions[chapterId] = {};

        for (final lessonId in lessonIds) {
          if (lessonId == null) continue;

          questionbankFreeQuestions[chapterId]!.putIfAbsent(lessonId, () => []);
          final lectureKey = '${chapterId}_$lessonId';

          requests.add(
            FirebaseFirestore.instance
                .collection('data')
                .doc('questions_bank')
                .collection(um.grade!)
                .doc(chapterId)
                .collection('content')
                .doc(lessonId)
                .collection('questions')
                .limit(_questionsLimit)
                .get()
                .then((snapshot) {
              for (final doc in snapshot.docs) {
                questionbankFreeQuestions[chapterId]![lessonId]!
                    .add(QuestionModel.fromJson(doc.data()));
              }
              // Shuffle the questions
              questionbankFreeQuestions[chapterId]![lessonId]!.shuffle();
              // Store last document for pagination
              if (snapshot.docs.isNotEmpty) {
                _lastDocuments[lectureKey] = snapshot.docs.last;
                hasMoreQuestions[lectureKey] =
                    snapshot.docs.length == _questionsLimit;
              } else {
                hasMoreQuestions[lectureKey] = false;
              }
            }),
          );
        }
      }

      await Future.wait(requests);

      emit(
        PlatformQuizGetFreeQuestionBankSuccessState(
          questionbankFreeQuestions,
        ),
      );
    } catch (e, stack) {
      debugPrint('Error: $e');
      debugPrint(stack.toString());
      emit(
        PlatformQuizGetFreeQuestionBankFailState(e.toString()),
      );
    }
  }

  Future<void> loadMoreQuestionbankFreeQuestions({
    required String chapterId,
    required String lessonId,
  }) async {
    final lectureKey = '${chapterId}_$lessonId';

    // Check if there are more questions to load
    if (hasMoreQuestions[lectureKey] != true) {
      return;
    }

    // Check if we have a last document to start after
    final lastDoc = _lastDocuments[lectureKey];
    if (lastDoc == null) {
      return;
    }

    emit(PlatformLoadMoreFreeQuestionBankLoadingState(lectureKey));

    try {
      UserModel um = Constants.userBox.get('user');

      final snapshot = await FirebaseFirestore.instance
          .collection('data')
          .doc('questions_bank')
          .collection(um.grade!)
          .doc(chapterId)
          .collection('content')
          .doc(lessonId)
          .collection('questions')
          .startAfterDocument(lastDoc)
          .limit(_questionsLimit)
          .get();

      // Get new questions and shuffle only them
      final newQuestions = <QuestionModel>[];
      for (final doc in snapshot.docs) {
        newQuestions.add(QuestionModel.fromJson(doc.data()));
      }
      newQuestions.shuffle();

      // Add shuffled new questions to the existing list
      questionbankFreeQuestions[chapterId]?[lessonId]?.addAll(newQuestions);

      // Update last document for next pagination
      if (snapshot.docs.isNotEmpty) {
        _lastDocuments[lectureKey] = snapshot.docs.last;
        hasMoreQuestions[lectureKey] = snapshot.docs.length == _questionsLimit;
      } else {
        hasMoreQuestions[lectureKey] = false;
      }

      emit(PlatformLoadMoreFreeQuestionBankSuccessState(
        lectureKey,
        hasMoreQuestions[lectureKey] ?? false,
      ));
    } catch (e, stack) {
      debugPrint('Error loading more questions: $e');
      debugPrint(stack.toString());
      emit(PlatformLoadMoreFreeQuestionBankFailState(e.toString()));
    }
  }

  List<QuizModel> avaExams = [];
  Future<void> getAvaExams() async {
    emit(PlatformGetAvaExamsLoadingState());
    try {
      UserModel um = Constants.userBox.get('user');
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('data')
          .doc('quizes')
          .collection(um.grade!)
          .where('isShamel', isEqualTo: true)
          .where('isValid', isEqualTo: true)
          .get();

      avaExams = snapshot.docs
          .where((doc) {
            final data = doc.data();

            if (data['type'] != null) {
              final isOnlineStudent =
                  (um.groupName?.isEmpty ?? true) || um.groupName == 'Online';

              if (isOnlineStudent) {
                // الطالب أونلاين يشوف online و both
                if (data['type'] != 'both' && data['type'] != 'online') {
                  return false;
                }
              } else {
                // الطالب سنتر يشوف center و both
                if (data['type'] != 'both' && data['type'] == 'online') {
                  return false;
                }
              }
            }
            final lecId = data['lecId'];
            final id = data['id'] ?? doc.id;
            if (lecId != null && lecId.toString().isNotEmpty) return false;
            if (um.stdQuizes?[id] != null) return false;
            final validUntil = data['validUntil'];
            if (validUntil != null) {
              final validDate = (validUntil as Timestamp).toDate();
              if (validDate.isBefore(DateTime.now())) return false;
            }
            return true;
          })
          .map((doc) => QuizModel.fromJson(doc.data()))
          .toList();

      emit(PlatformGetAvaExamsSuccessState());
    } catch (onError) {
      debugPrint(onError.toString());
      emit(PlatformGetAvaExamsFailState(onError.toString()));
    }
  }

  int examTypeIndex = 0;
  void changeExamType(int index) {
    debugPrint(index.toString());
    examTypeIndex = index;

    if (index == 0) {
      getAvaExams();
    }
    emit(PlatformChangeLecturesExamsState());
  }

  int number = 10;
  void incrementQuestionsNum() {
    if (number < 60) {
      number += 10;
      emit(PlatformChangeQuestionsNumsState());
    }
  }

  void decrementQuestionsNum() {
    if (number > 10) {
      number -= 10;
      emit(PlatformChangeQuestionsNumsState());
    }
  }

  bool isOldPassSecure = true;
  void changeOldPassSecure() {
    isOldPassSecure = !isOldPassSecure;
    emit(PaltformChangeOldPasswordSecureState());
  }

  bool isNewPassSecure = true;
  void changeNewPassSecure() {
    isNewPassSecure = !isNewPassSecure;
    emit(PaltformChangeNewPasswordSecureState());
  }

  double sliderVal = 10;
  void changeSlider(double val) {
    sliderVal = val;
    emit(PlatformChangeSliderState());
  }

/*
// Student Register
  void platformStudentSignup({
    required ar_fname,
    required ar_sname,
    required ar_thname,
    required fname,
    required grade,
    required phoneNum,
    required sname,
    required thname,
    required password,
  }) {
    emit(PlatformCreateUserLoadingState());
    FirebaseFirestore.instance
        .collection('data')
        .doc('year')
        .get()
        .then((value) {
      String stdIndex =
          '${Random.secure().nextInt(10).toString()}${Random.secure().nextInt(10).toString()}${Random.secure().nextInt(10).toString()}${Random.secure().nextInt(10).toString()}${Random.secure().nextInt(10).toString()}';

      String stdCode =
          '${Components.getGradeNum(grade)}${value.data()!['year']}$stdIndex';

      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: '$stdCode@gmail.com', password: password)
          .then((value) {
        FirebaseFirestore.instance
            .collection('data')
            .doc('init_balance')
            .get()
            .then((value) {
          createStudent(
            userModel: UserModel(
              parentPhoneNum: '',
              ar_fname: ar_fname,
              ar_sname: ar_sname,
              ar_thname: ar_thname,
              code: stdCode,
              fname: fname,
              grade: grade,
              enabled: true,
              pushToken: '',
              phoneNum: phoneNum,
              sname: sname,
              thname: thname,
              img: Constants.img,
              balance: value.data()!['value'],
              password: password,
              purchasedVideos: {},
              purchasedPdfs: {},
              stdQuizes: [],
              groupId: '3E0YUrRnB9zLdhPgH0Mf',
              groupName: 'لطفي',
              attendance: {},
            ),
          );
        }).catchError((onError) {
          emit(PlatformCreateUserFailState(onError.toString()));
        });
      }).catchError((onError) {
        debugPrint(onError.toString());
        emit(PlatformCreateUserFailState(onError.toString()));
      });
    }).catchError((onError) {
      emit(PlatformCreateUserFailState(onError.toString()));
    });
  }
*/
  Future<String> getPhoneNum(String s) async {
    DocumentSnapshot<Map<String, dynamic>> phone =
        await FirebaseFirestore.instance.collection('phoneNums').doc(s).get();
    return phone.data()!['phone'];
  }

  List<SocialMediaModel> socialMedia = [];
  void getSocialMedia() {
    socialMedia.clear();
    FirebaseFirestore.instance.collection('socialMedia').get().then((onValue) {
      for (var social in onValue.docs) {
        if (social.data()['linkUrl'] == null ||
            social.data()['linkUrl'].isEmpty) {
          continue;
        }
        socialMedia.add(SocialMediaModel.fromJson(social.data()));
      }
      emit(PlatfomrRefreshState());
    }).catchError((onError) {
      debugPrint(onError.toString());
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

  void platformLogin({
    required String password,
    required String phoneNum,
  }) async {
    emit(PlatformLoginLoadingState());

    try {
      /*
      // 1️⃣ تسجيل الدخول بالبريد وكلمة المرور
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: '$code@gmail.com',
        password: password,
      );
*/

      DocumentReference<Map<String, dynamic>>? docRef;
      List<String> grades = ['first', 'second', 'third'];
      for (var grade in grades) {
        var data = await FirebaseFirestore.instance
            .collection('data')
            .doc('students')
            .collection(grade)
            .where('phoneNum', isEqualTo: phoneNum)
            .get();
        if (data.docs.isNotEmpty) {
          var code = data.docs.first.id;
          docRef = FirebaseFirestore.instance
              .collection('data')
              .doc('students')
              .collection(Components.getGrade(code[0]))
              .doc(code);
          break;
        }
      }
      if (docRef == null) {
        emit(PlatformLoginFailState(
          'رقم الهاتف غير مسجل لدينا، تأكد من الرقم أو سجّل حساب جديد.',
          type: LoginErrorType.userNotFound,
        ));
        return;
      }
      var snapshot = await docRef.get();
      Map<String, dynamic> userData = snapshot.data()!;

      if (password != userData['password']) {
        emit(PlatformLoginFailState(
          'كلمة المرور غير صحيحة.',
          type: LoginErrorType.invalidCredentials,
        ));
        return;
      }
      if (userData['code'] != Constants.devCode) {
        // 2️⃣ تحديد نوع الجهاز ومعرفه
        String deviceType = _getDeviceType();
        String deviceId = await _getDeviceId();

        List devices = userData['devices'] ?? [];

        // 4️⃣ التحقق من الحد المسموح
        bool typeExists = devices.any((d) => d['type'] == deviceType);
        bool sameDeviceExists = devices.any((d) => d['id'] == deviceId);

        if (!sameDeviceExists && typeExists) {
          emit(PlatformLoginFailState(
            'لا يمكنك تسجيل الدخول من ${deviceType == 'mobile' ? 'موبايل' : 'كمبيوتر'} آخر، حسابك مرتبط بجهاز مختلف.',
            type: LoginErrorType.deviceLimit,
          ));
          return;
        }

        // 5️⃣ لو الجهاز جديد → أضفه
        if (!sameDeviceExists) {
          devices.add({'type': deviceType, 'id': deviceId});
          await docRef.update({'devices': devices});
        }
      }
      String? oldGroupId = Constants.userBox.get('user')?.groupName;
      // 6️⃣ تخزين بيانات المستخدم محليًا
      await Constants.userBox.put('user', UserModel.fromJson(userData));
      NotificationService.manageUserTopics(oldGroupId: oldGroupId);
      isShowDelAccount();

      emit(
        PlatformLoginSuccessState(
          enabled: UserModel.fromJson(userData).enabled ?? true,
          active: UserModel.fromJson(userData).isActive ?? true,
        ),
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      debugPrint(msg);
      emit(PlatformLoginFailState(msg));
    }
  }

/*
// login
  void platformLogin({
    required String password,
    required String code,
  }) {
    emit(PlatformLoginLoadingState());
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: '$code@gmail.com',
      password: password,
    )
        .then((value) {
      FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(Components.getGrade(code[0]))
          .doc(code)
          .get()
          .then((value) {
        debugPrint(value.data().toString());
        Constants.userBox
            .put('user', UserModel.fromJson(value.data()!))
            .then((valuee) {
          isShowDelAccount();
          emit(
            PlatformLoginSuccessState(
              enabled: UserModel.fromJson(value.data()!).enabled ?? true,
              active: UserModel.fromJson(value.data()!).isActive ?? true,
            ),
          );
        }).catchError((onError) {
          debugPrint('ahmed ${onError.toString()}');
          emit(PlatformLoginFailState(' ${onError.toString()}'));
        });
      }).catchError((onError) {
        debugPrint('ahmed2 ${onError.toString()}');
        emit(PlatformLoginFailState(onError.toString()));
      });
    }).catchError((onError) {
      debugPrint('ahmed3 ${onError.toString()}');
      emit(PlatformLoginFailState(onError.toString()));
    });
  }
*/
  Future<void> setUserDataLocally() async {
    emit(PlatformGetUserDataLoadingState());
    UserModel um = Constants.userBox.get('user');
    FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(um.grade!)
        .doc(um.code)
        .get()
        .then((value) async {
      debugPrint(value.data().toString());

      if (value.exists && value.data() != null) {
        Map<String, dynamic> userData = value.data()!;
        if (userData['enabled'] == false) {
          Constants.userBox.put(
            'user',
            UserModel.fromJson(userData),
          );
          emit(PlatformAccountBlockedState());
          return;
        }

        if (!Platform.isWindows) {
          // احفظ الـ pushToken بشكل صحيح لـ Android و iOS (يتعامل مع APNs على iOS).
          final String? newPushToken =
              await NotificationService.saveTokenForUser(
            grade: um.grade!,
            code: um.code!,
            currentToken: userData['pushToken'],
          );
          if (newPushToken != null) {
            userData['pushToken'] = newPushToken;
          }
        }
        // قم بتحديث البيانات محليًا
        String? oldGroupId = Constants.userBox.get('user')?.groupId;
        // 6️⃣ تخزين بيانات المستخدم محليًا

        Constants.userBox
            .put('user', UserModel.fromJson(userData))
            .then((_) async {
          NotificationService.manageUserTopics(oldGroupId: oldGroupId);
          await getPurchasedVideosList();
          emit(PlatformGetUserDataSuccessState());
        }).catchError((onError) {
          debugPrint('Error updating local data: ${onError.toString()}');
          emit(PlatformGetUserDataFailState(' ${onError.toString()}'));
        });
      } else {
        await Constants.userBox.delete('user').then((onValue) {
          emit(PlatformDeleteAccountSuccessState());
        });
      }
    }).catchError((onError) {
      debugPrint('Firestore error: ${onError.toString()}');
      emit(PlatformGetUserDataFailState(onError.toString()));
    });
  }
/*
  void setVideosData() async {
    CollectionReference<Map<String, dynamic>> col = FirebaseFirestore.instance
        .collection('data')
        .doc('videos')
        .collection('third')
        .doc('nhkIGQJklA4qkWU1CTFX')
        .collection('lectures');

    QuerySnapshot<Map<String, dynamic>> videosCol = await col.get();

    for (var vid in videosCol.docs) {
      col.doc(vid.id).update({
        'hide': true,
        'dep': false,
      });
    }
    debugPrint('Doneeee');
  }
  */
/*
  void resetStdVideos() async {
    CollectionReference<Map<String, dynamic>> stdCol = FirebaseFirestore
        .instance
        .collection('data')
        .doc('students')
        .collection('second');
    QuerySnapshot<Map<String, dynamic>> stds = await stdCol.get();

    for (var std in stds.docs) {
      DocumentSnapshot<Map<String, dynamic>> get =
          await stdCol.doc(std.id).get();
      if (get.data()!['balance'] >= 2) {
        stdCol.doc(std.id).update({'balance': FieldValue.increment(-2)});
      } else {
        stdCol.doc(std.id).update({'balance': 0});
      }
    }

    debugPrint('Doneee');
  }
*/

//logout

  void platformLogout() async {
    emit(PlatformLogoutLoadingState());

    // اقرأ قيم المواضيع قبل حذف المستخدم، لأن removeUserTopics ينتظر APNs token
    // ولو قرأ المستخدم من الـ box بعد الحذف لوجده null. لا ننتظر انتهاء إلغاء
    // الاشتراك (fire-and-forget) حتى لا يتأخّر تسجيل الخروج.
    final UserModel? um = Constants.userBox.get('user');
    NotificationService.removeUserTopics(
      grade: um?.grade,
      groupId: um?.groupId,
    );

    // FirebaseAuth.instance.signOut().then((value) {
    Constants.userBox.delete('user').then((value) {
      emit(PlatformLogoutSuccessState());
    }).catchError((onError) {
      emit(PlatformLogoutFailState(' ${onError.toString()}'));
    });
    /*
    }).catchError((onError) {
      emit(PlatformLogoutFailState(onError.toString()));
    });
    */
  }

  void setLocalData() {
    UserModel sm = Constants.userBox.get('user');
    FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(sm.grade!)
        .doc(sm.code)
        .get()
        .then((onValue) async {
      if (onValue.exists) {
        Map<String, dynamic> userData = onValue.data()!;
        if (userData['enabled'] == false) {
          emit(PlatformAccountBlockedState());
          Constants.userBox.put('user', UserModel.fromJson(userData));
          return;
        }
        if (userData['isActive'] == false) {
          emit(PlatformAccountPendingState());
          Constants.userBox.put('user', UserModel.fromJson(userData));
          return;
        }
        if (!Platform.isWindows) {
          // احفظ الـ pushToken بشكل صحيح لـ Android و iOS (يتعامل مع APNs على iOS).
          final String? newPushToken =
              await NotificationService.saveTokenForUser(
            grade: sm.grade!,
            code: sm.code!,
            currentToken: userData['pushToken'],
          );
          if (newPushToken != null) {
            userData['pushToken'] = newPushToken;
          }
        }
        String? oldGroupId = Constants.userBox.get('user')?.groupId;
        // 6️⃣ تخزين بيانات المستخدم محليًا
        await Constants.userBox.put('user', UserModel.fromJson(userData));
        NotificationService.manageUserTopics(oldGroupId: oldGroupId);
        await getPurchasedVideosList();
        debugPrint('Account Exist!');
      } else {
        await Constants.userBox.delete('user').then((onValue) {
          emit(PlatformDeleteAccountSuccessState());
        });
        debugPrint('Account Deleted!');
      }
      emit(PlatfomrRefreshState());
    }).catchError((onError) {
      debugPrint(onError.toString());
    });
  }

  Future<void> setErrScreenData() async {
    UserModel sm = Constants.userBox.get('user');
    await FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(sm.grade!)
        .doc(sm.code)
        .get()
        .then((onValue) async {
      if (onValue.exists) {
        Map<String, dynamic> userData = onValue.data()!;
        String? oldGroupId = Constants.userBox.get('user')?.groupId;
        await Constants.userBox.put('user', UserModel.fromJson(userData));
        if (userData['enabled'] == true && userData['isActive'] == true) {
          emit(PlatformAccountNotBlockedAndPendingState());

          NotificationService.manageUserTopics(oldGroupId: oldGroupId);
          return;
        }
      } else {
        await Constants.userBox.delete('user').then((onValue) {
          emit(PlatformDeleteAccountSuccessState());
        });
        debugPrint('Account Deleted!');
      }
      emit(PlatfomrRefreshState());
    }).catchError((onError) {
      debugPrint(onError.toString());
    });
  }

/*
// codes
  void getStdPurchasedVideos() {
    UserModel um = Constants.userBox.get('user');
    FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(um.grade!)
        .doc(um.code)
        .get()
        .then((value) {
      Map<String, Map<String, List<String>>> purchasedPdfs = {};
      Map<String, Map<String, List<UserPurchasedModel>>> purchasedVideos = {};
      if (value.data()!['purchased_videos'] != null) {
        value.data()!['purchased_videos'].forEach((chapterKey, chapterValue) {
          Map<String, List<UserPurchasedModel>> lectures = {};
          (chapterValue as Map<String, dynamic>)
              .forEach((lectureKey, lectureValue) {
            List<dynamic> list = lectureValue as List<dynamic>;
            lectures[lectureKey] = list
                .map((item) =>
                    UserPurchasedModel.fromJson(item as Map<String, dynamic>))
                .toList();
          });
          purchasedVideos[chapterKey] = lectures;
        });
      }

      if (value.data()!['purchased_pdfs'] != null) {
        value.data()!['purchased_pdfs'].forEach((chapterKey, chapterValue) {
          Map<String, List<String>> lectures = {};
          (chapterValue as Map<String, dynamic>)
              .forEach((lectureKey, lectureValue) {
            List<dynamic> list = lectureValue as List<dynamic>;
            lectures[lectureKey] = list.map((item) => item as String).toList();
          });
          purchasedPdfs[chapterKey] = lectures;
        });
      }
      um.purchasedPdfs = purchasedPdfs;
      um.purchasedVideos = purchasedVideos;
      um.save().then((value) {
        emit(PlatformGetPurchasedVideosSuccessState());
      }).catchError((onError) {
        debugPrint(onError.toString());
      });
    }).catchError((onError) {
      debugPrint(onError.toString());
    });
  }
*/
  bool showDelAcc = true;
  void isShowDelAccount() {
    if (Constants.userBox.isNotEmpty) {
      UserModel um = Constants.userBox.get('user');
      showDelAcc = (um.code == Constants.devCode);
      //  getStdPurchasedVideos();
      emit(PlatformGetIsDelAccShowSuccessState());
    }

/*
    FirebaseFirestore.instance
        .collection('data')
        .doc('isDelAcc')
        .get()
        .then((value) {
      showDelAcc = value.data()!['isDelAccShown'];
      emit(PlatformGetIsDelAccShowSuccessState());
    }).catchError((onError) {
      debugPrint(onError.toString());
    });
    */
  }

  void deleteAccount() {
    /*
    final user = FirebaseAuth.instance.currentUser;
    user!.delete().then((value) {
      */
    Constants.userBox.delete('user').then((value) {
      emit(PlatformDeleteAccountSuccessState());
    }).catchError((onError) {
      emit(PlatformDeleteAccountFailState(' ${onError.toString()}'));
    });
    /*
    }).catchError((onError) {
      emit(PlatformDeleteAccountFailState(onError.toString()));
    });
    */
  }

  Future<void> checkPurchaseQuizCode({
    required String code,
    required String quizId,
    context,
  }) async {
    emit(PlatformCheckPurchaseQuizCodeLoadingState());
    final um = Constants.userBox.get('user');

    try {
      final codeDoc =
          await FirebaseFirestore.instance.collection('codes').doc(code).get();

      if (!codeDoc.exists) {
        emit(PlatformCheckPurchaseQuizCodeFailState(
            ' ${S.current.enter_valid_code}'));
        return;
      }

      final data = codeDoc.data()!;
      final stdCode = data['stdCode'];

      if (stdCode != null && stdCode.toString().isNotEmpty) {
        if (stdCode == um.code) {
          emit(PlatformCheckPurchaseQuizCodeFailState(
              ' ${S.current.u_charge_code}'));
        } else {
          emit(PlatformCheckPurchaseQuizCodeFailState(
              ' ${S.current.code_used}'));
        }
        return;
      }

      final codeChapId = data['chapId'];
      final codeLecId = data['lecId'];
      final codeValue = data['value'];

      if (codeChapId != null && codeLecId != null) {
        emit(PlatformCheckPurchaseQuizCodeFailState(
            ' ده كود شحن حصة مش امتحان!'));
        return;
      }

      if (codeValue != null) {
        emit(PlatformCheckPurchaseQuizCodeFailState(
            ' ده كود شحن محفظة مش امتحان!'));
        return;
      }

      final quizCode = data['quizCode'];

      if (quizCode == null || quizCode.toString().isEmpty) {
        emit(PlatformCheckPurchaseQuizCodeFailState(
            ' ${S.current.enter_valid_code}'));
        return;
      }

      if (quizId != quizCode) {
        emit(PlatformCheckPurchaseQuizCodeFailState(
            ' ${S.current.code_not_for_quiz}'));
        return;
      }
      await redeemExamCode(quizId: quizId);

      // ✅ Save code usage
      await FirebaseFirestore.instance.collection('codes').doc(code).update({
        'stdCode': um.code,
        'date': DateTime.now(),
      });
      emit(PlatformCheckPurchaseQuizCodeSuccessState());
    } catch (e) {
      emit(PlatformCheckPurchaseQuizCodeFailState(e.toString()));
    }
  }

  Future<void> redeemExamCode({required String quizId, int? price}) async {
    UserModel user = Constants.userBox.get('user');
    await FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(user.grade!)
        .doc(user.code!)
        .update({
      'balance': FieldValue.increment(-(price ?? 0)),
      'stdQuizes.$quizId.status': 'paid',
      'stdQuizes.$quizId.purchaseDateTime': DateTime.now(),
    });
    user.stdQuizes?[quizId] = StdQuizModel(
      id: '',
      title: '',
      dateTime: DateTime.now(),
      questionNums: 0,
      triesNum: 0,
      fullMark: 0,
      degree: 0,
      userAnsIdx: {},
      purchaseDateTime: DateTime.now(),
      status: 'paid',
    );
    await FirebaseFirestore.instance
        .collection('data')
        .doc('purchases')
        .collection(user.grade!)
        .doc()
        .set(PurchaseExamModel(
          date: DateTime.now(),
          stdCode: user.code,
          quizId: quizId,
        ).toMap());
    user.balance = (user.balance ?? 0) - (price ?? 0);
    await user.save();
    debugPrint('stdQuiz: ${user.stdQuizes?[quizId]?.toJson().toString()}');
    emit(PlatfomrRefreshState());
  }

  Future<void> checkChapterCode({
    required String code,
    String? chapId,
    context,
  }) async {
    emit(PlatformCheckCodeLoadingState());
    final um = Constants.userBox.get('user');

    try {
      final codeDoc =
          await FirebaseFirestore.instance.collection('codes').doc(code).get();

      if (!codeDoc.exists) {
        emit(PlatformCheckCodeFailState(' ${S.current.enter_valid_code}'));
        return;
      }

      final data = codeDoc.data()!;
      final stdCode = data['stdCode'];

      if (stdCode != null && stdCode.toString().isNotEmpty) {
        if (stdCode == um.code) {
          emit(PlatformCheckCodeFailState(' ${S.current.u_charge_code}'));
        } else {
          emit(PlatformCheckCodeFailState(' ${S.current.code_used}'));
        }
        return;
      }

      final codeChapId = data['chapId'];
      final codeLecId = data['lecId'];

      // Wallet code - Add to balance
      if (codeChapId == null) {
        // General
        if (chapId == null) {
          await applyGeneralCodeToBalance(value: data['value']);
        } else {
          emit(PlatformCheckCodeFailState(' ده كود شحن محفظة مش حصة!'));

          return;
        }
      }
      // Lecture code - Validate and Purchase
      else {
        // General
        if (chapId == null) {
          emit(PlatformCheckCodeFailState(' ده كود شحن حصة مش محفظة!'));
          return;
        } else {
          // Lecture
          if (chapId == codeChapId && codeLecId == null) {
            final success = await _validateChapterCode(chapId, um.grade!);
            if (!success) {
              emit(
                  PlatformCheckCodeFailState(' ${S.current.enter_valid_code}'));
              return;
            }

            await _purchaseChapterWithCode(
              chapId: chapId,
              um: um,
            );
          } else {
            emit(PlatformCheckCodeFailState(' ${S.current.code_not_for_chap}'));
            return;
          }
        }
      }

      // ✅ Save code usage
      await FirebaseFirestore.instance.collection('codes').doc(code).update({
        'stdCode': um.code,
        'date': DateTime.now(),
      });
      emit(PlatformCheckCodeSuccessState(videoDetailsModel: videoDetailsModel));
    } catch (e) {
      emit(PlatformCheckCodeFailState(e.toString()));
    }
  }

  Future<bool> _validateChapterCode(
    String chapId,
    String grade,
  ) async {
    final chapterRef = FirebaseFirestore.instance
        .collection('data')
        .doc('videos')
        .collection(grade)
        .doc(chapId);

    final chapterSnap = await chapterRef.get();
    if (!chapterSnap.exists) return false;
    if (chapterSnap.data()?['hide'] == true) return false;

    return true;
  }

  Future<void> _purchaseChapterWithCode({
    required String chapId,
    required UserModel um,
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    // 1. Safe nested Map initialization
    if (!um.purchasedVideos!.containsKey(chapId)) {
      um.purchasedVideos![chapId] = UserPurchasedChapterModel(
        lectures: {},
        status: 'paid',
        purchaseDateTime: DateTime.now(),
      );
    }
    // Firebase Database Payload
    final studentRef = FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(um.grade!)
        .doc(um.code);

    batch.update(studentRef, {
      'purchased_videos.$chapId.status': 'paid',
      'purchased_videos.$chapId.purchaseDateTime': DateTime.now(),
    });

    final purchaseRef = FirebaseFirestore.instance
        .collection('data')
        .doc('purchases')
        .collection(um.grade!)
        .doc();

    batch.set(
      purchaseRef,
      PurchaseVideoModel(
        date: DateTime.now(),
        stdCode: um.code,
        chapId: chapId,
      ).toMap(),
    );

    // 5. Commit Cloud Database changes then write to local storage
    await batch.commit();
    await um.save();
  }

  Future<void> checkCode({
    required String code,
    String? lecId,
    String? chapId,
    context,
  }) async {
    emit(PlatformCheckCodeLoadingState());
    videoDetailsModel = null;
    final um = Constants.userBox.get('user');

    try {
      final codeDoc =
          await FirebaseFirestore.instance.collection('codes').doc(code).get();

      if (!codeDoc.exists) {
        emit(PlatformCheckCodeFailState(' ${S.current.enter_valid_code}'));
        return;
      }

      final data = codeDoc.data()!;
      final stdCode = data['stdCode'];

      if (stdCode != null && stdCode.toString().isNotEmpty) {
        if (stdCode == um.code) {
          emit(PlatformCheckCodeFailState(' ${S.current.u_charge_code}'));
        } else {
          emit(PlatformCheckCodeFailState(' ${S.current.code_used}'));
        }
        return;
      }

      final codeChapId = data['chapId'];
      final codeLecId = data['lecId'];

      // Wallet code - Add to balance
      if (codeChapId == null && codeLecId == null) {
        // General
        if (chapId == null && lecId == null) {
          await applyGeneralCodeToBalance(value: data['value']);
        } else {
          emit(PlatformCheckCodeFailState(' ده كود شحن محفظة مش حصة!'));

          return;
        }
      }
      // Lecture code - Validate and Purchase
      else {
        // General
        if (chapId == null && lecId == null) {
          emit(PlatformCheckCodeFailState(' ده كود شحن حصة مش محفظة!'));
          return;
        } else {
          // Lecture
          if (chapId == codeChapId && lecId == codeLecId) {
            final success =
                await _validateLectureCode(chapId!, lecId!, um.grade!);
            if (!success) {
              emit(
                  PlatformCheckCodeFailState(' ${S.current.enter_valid_code}'));
              return;
            }

            await _purchaseLectureWithCode(
              chapId: chapId,
              lecId: lecId,
              um: um,
            );
          } else {
            emit(PlatformCheckCodeFailState(' ${S.current.code_not_for_lec}'));
            return;
          }
        }
      }

      // ✅ Save code usage
      await FirebaseFirestore.instance.collection('codes').doc(code).update({
        'stdCode': um.code,
        'date': DateTime.now(),
      });
      emit(PlatformCheckCodeSuccessState(videoDetailsModel: videoDetailsModel));
    } catch (e) {
      emit(PlatformCheckCodeFailState(e.toString()));
    }
  }

  VideoDetailsModel? videoDetailsModel;

  Future<void> applyGeneralCodeToBalance({
    required int value,
    bool? isOnline,
  }) async {
    try {
      UserModel user = Constants.userBox.get('user');
      await FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(user.grade!)
          .doc(user.code!)
          .update({
        'balance': FieldValue.increment(value),
        'walletBalanceStatus': 'paid',
        'lastwalletBalanceTransaction': DateTime.now(),
      });

      user.balance = (user.balance ?? 0) + value;
      user.walletBalanceStatus = 'paid';
      user.lastwalletBalanceTransaction = DateTime.now();
      await user.save();
      if (isOnline ?? false) {
        emit(PlatformApplyGeneralCodeToBalanceSuccessState());
      } else {
        emit(PlatfomrRefreshState());
      }
    } catch (e) {
      debugPrint("apply general code to balance fail : ${e.toString()}");
      if (isOnline ?? false) {
        emit(PlatformApplyGeneralCodeToBalanceFailState(e.toString()));
      }
    }
  }

  Future<bool> _validateLectureCode(
    String chapId,
    String lecId,
    String grade,
  ) async {
    final chapterRef = FirebaseFirestore.instance
        .collection('data')
        .doc('videos')
        .collection(grade)
        .doc(chapId);

    final chapterSnap = await chapterRef.get();
    if (!chapterSnap.exists) return false;
    if (chapterSnap.data()?['hide'] == true) return false;

    final lectureRef = chapterRef.collection('lectures').doc(lecId);
    final lectureSnap = await lectureRef.get();
    if (!lectureSnap.exists) return false;

    if (lectureSnap.data()?['hide'] == true) return false;

    final dataSnap = await lectureRef.collection('data').get();
    if (dataSnap.docs.isEmpty) return false;
    videoDetailsModel = VideoDetailsModel.fromJson(lectureSnap.data()!);

    return true;
  }

  Future<void> _purchaseLectureWithCode({
    required String chapId,
    required String lecId,
    required UserModel um,
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    // 1. Safe nested Map initialization
    if (!um.purchasedVideos!.containsKey(chapId)) {
      um.purchasedVideos![chapId] = UserPurchasedChapterModel(lectures: {});
    }
    um.purchasedVideos![chapId]!.lectures ??= {};

    if (!um.purchasedVideos![chapId]!.lectures!.containsKey(lecId)) {
      um.purchasedVideos![chapId]!.lectures![lecId] =
          UserPurchasedLectureModel(videos: {});
    }
    um.purchasedVideos![chapId]!.lectures![lecId]!.videos ??= {};

    Map<String, UserPurchasedModel> videosMap =
        um.purchasedVideos![chapId]!.lectures![lecId]!.videos!;

    // 2. Fetch all missing lecture videos from Firestore FIRST (Single Fetch)
    // This handles the case where the local map is empty because it's a first-time purchase
    if (videosMap.isEmpty) {
      // videosMap =  await _fetchLectureVideosFromNetwork(um.grade!, chapId, lecId);
      //   um.purchasedVideos?[chapId]!.lectures![lecId]!.videos = videosMap;
      um.purchasedVideos?[chapId]!.lectures![lecId]!.videos = {};
    }

    // 3. Parallel Network Requests Optimization (No serial waiting loops!)
    List<Future<void>> updateTasks = [];

    for (var entry in videosMap.entries) {
      final vidId = entry.key;
      final video = entry.value;

      // Launch all network operations simultaneously
      updateTasks.add(
        getAvaWatches(chapId: chapId, lecId: lecId, vidId: vidId).then((extra) {
          video.avaWatches = (video.avaWatches ?? 4) + extra;
        }),
      );
    }

    // Wait for all async operations to finish in parallel
    await Future.wait(updateTasks);

    // 4. Firebase Database Payload
    final studentRef = FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(um.grade!)
        .doc(um.code);

    batch.update(studentRef, {
      'purchased_videos.$chapId.lectures.$lecId.purchaseDateTime':
          DateTime.now(),
      // Clear any leftover "pending" flag from an abandoned online attempt.
      'purchased_videos.$chapId.lectures.$lecId.status': 'paid',
      'purchased_videos.$chapId.lectures.$lecId.videos':
          videosMap.map((key, value) => MapEntry(key, value.toMap())),
    });

    final purchaseRef = FirebaseFirestore.instance
        .collection('data')
        .doc('purchases')
        .collection(um.grade!)
        .doc();

    batch.set(
      purchaseRef,
      PurchaseVideoModel(
        date: DateTime.now(),
        stdCode: um.code,
        chapId: chapId,
        lecId: lecId,
      ).toMap(),
    );

    // 5. Commit Cloud Database changes then write to local storage
    um.purchasedVideos![chapId]!.lectures![lecId]!.status = 'paid';
    await batch.commit();
    await um.save();
  }

/*
  /// Helper to fetch fallback base video structure if the student is purchasing this for the first time
  Future<Map<String, UserPurchasedModel>> _fetchLectureVideosFromNetwork(
    String grade,
    String chapId,
    String lecId,
  ) async {
    Map<String, UserPurchasedModel> fallbackMap = {};
    try {
      QuerySnapshot<Map<String, dynamic>> videosDocs = await FirebaseFirestore
          .instance
          .collection('data')
          .doc('videos')
          .collection(grade)
          .doc(chapId)
          .collection('lectures')
          .doc(lecId)
          .collection('data')
          .get();

      for (var doc in videosDocs.docs) {
        fallbackMap[doc.id] = UserPurchasedModel(
          vidId: doc.id,
          stdWatches: 0,
          avaWatches: doc.data()['avaWatches'] ?? 4,
          dateTime: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint("Failed to fetch initial lecture videos: $e");
    }
    return fallbackMap;
  }
*/
  Future<int> getAvaWatches({
    required String chapId,
    required String lecId,
    required String vidId,
  }) async {
    UserModel um = Constants.userBox.get('user');
    DocumentSnapshot<Map<String, dynamic>> vid = await FirebaseFirestore
        .instance
        .collection('data')
        .doc('videos')
        .collection(um.grade!)
        .doc(chapId)
        .collection('lectures')
        .doc(lecId)
        .collection('data')
        .doc(vidId)
        .get();

    if (!vid.exists || vid.data() == null) return 4;
    return vid.data()!['avaWatches'] ?? 4;
  }

/*
  Future<void> _purchaseLectureWithCode({
    required String chapId,
    required String lecId,
    required UserModel um,
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    // Init maps if needed
    um.purchasedVideos ??= {};
    um.purchasedVideos![chapId]?.lectures ??= {};
    um.purchasedVideos![chapId]!.lectures![lecId]?.videos ??= {};

    // Loop to update avaWatches
    for (var video
        in um.purchasedVideos![chapId]!.lectures![lecId]!.videos!.values) {
      final extra = await getAvaWatches(
        chapId: chapId,
        lecId: lecId,
        vidId: video.key,
      );

      video.avaWatches = (video.avaWatches ?? 4) + extra;
    }

    // Firebase: update student
    final studentRef = FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(um.grade!)
        .doc(um.code);

    batch.update(studentRef, {
      'purchased_videos.$chapId.lectures.$lecId.videos': um
          .purchasedVideos![chapId]!.lectures![lecId]!.videos!
          .map((key, value) => MapEntry(key, value.toMap())),
    });

    // Firebase: log purchase
    final purchaseRef = FirebaseFirestore.instance
        .collection('data')
        .doc('purchases')
        .collection(um.grade!)
        .doc();

    batch.set(
        purchaseRef,
        PurchaseVideoModel(
          date: DateTime.now(),
          stdCode: um.code,
          chapId: chapId,
          lecId: lecId,
        ).toMap());

    // Save locally after Firebase completes
    await batch.commit();
    await um.save();
  }

  Future<int> getAvaWatches({
    required String chapId,
    required String lecId,
    required String vidId,
  }) async {
    UserModel um = Constants.userBox.get('user');
    DocumentSnapshot<Map<String, dynamic>> vid = await FirebaseFirestore
        .instance
        .collection('data')
        .doc('videos')
        .collection(um.grade!)
        .doc(chapId)
        .collection('lectures')
        .doc(lecId)
        .collection('data')
        .doc(vidId)
        .get();

    return vid.data()!['avaWatches'] ?? 4;
  }
*/
  List<String> bannersList = [];

  Future<void> getBanners() async {
    emit(PlatformGetBannersLoadingState());
    try {
      var snapshot =
          await FirebaseFirestore.instance.collection('banners').get();

      bannersList = snapshot.docs
          .map((doc) => (doc.data()['imgUrl'] ?? '').toString())
          .where((url) => url.isNotEmpty)
          .toList();

      emit(PlatformGetBannersSuccessState());
    } catch (error) {
      debugPrint('getBanners error: $error');
      emit(PlatformGetBannersFailState(error.toString()));
    }
  }

  List<VideoModel> videoList = [];

  Future<void> getVideos() async {
    videoList = [];
    emit(PlatformGetVideosLoadingState());
    UserModel um = Constants.userBox.get('user');

    try {
      var videosSnapshot = await FirebaseFirestore.instance
          .collection('data')
          .doc('videos')
          .collection(um.grade ?? '')
          .orderBy('date', descending: true)
          .get();

      for (var doc in videosSnapshot.docs) {
        final data = doc.data();

        // لو الفيديو مخفي
        if (data['hide'] == true) {
          debugPrint('Ahmedddd');
          continue;
        }
        if (doc.data()['type'] != null) {
          // لو الطالب أونلاين (Online أو فاضي)
          final isOnlineStudent =
              (um.groupName?.isEmpty ?? true) || um.groupName == 'Online';

          if (isOnlineStudent) {
            // الطالب أونلاين يشوف online و both
            if (data['type'] != 'both' && data['type'] != 'online') {
              continue;
            }
          } else {
            // الطالب سنتر يشوف center و both
            if (data['type'] != 'both' && data['type'] == 'online') {
              continue;
            }
          }
        }

        videoList.add(VideoModel.fromJson(data));
      }

      debugPrint(videoList.length.toString());

//
      await getRecentLectures(um);
      emit(PlatformGetVideosSuccessState());
    } catch (error) {
      debugPrint(error.toString());
      emit(PlatformGetVideosFailState(error.toString()));
    }
  }

  List<VideoDetailsModel> recentVideosList = [];
  Future<void> getRecentLectures(UserModel um) async {
    recentVideosList = [];
    emit(PlatformGetRecentVideosLoadingState());

    try {
      for (var video in videoList) {
        debugPrint(video.chapId);
        var lecturesSnapshot = await FirebaseFirestore.instance
            .collection('data')
            .doc('videos')
            .collection(um.grade!)
            .doc(video.chapId)
            .collection('lectures')
            .orderBy('date', descending: true)
            .get();
        for (var doc in lecturesSnapshot.docs) {
          if (doc.data()['hide'] ?? false) {
            continue;
          }
          debugPrint(doc.data().toString());
          recentVideosList.add(VideoDetailsModel.fromJson(doc.data()));
        }
      }
      // await getPurchasedVideosList();
      recentVideosList.sort((a, b) => b.date.compareTo(a.date));
      //  debugPrint(recentVideosList.first.toString());

      emit(PlatformGetRecentVideosSuccessState());
    } catch (error) {
      debugPrint(error.toString());
      emit(PlatformGetRecentVideosFailState(error.toString()));
    }
  }

  List<VideoDetailsModel> myVideos = [];

  Future<void> getMyVideos() async {
    myVideos = [];
    UserModel um = Constants.userBox.get('user');

    if (um.purchasedVideos!.isEmpty) {
      debugPrint('No purchased videos found.');
      return;
    }

    // 1. Gather all purchased lectures locally across all chapters
    List<_LocalLectureSortWrapper> localLectures = [];

    for (String chapId in um.purchasedVideos!.keys) {
      final chapter = um.purchasedVideos![chapId];
      if (chapter?.lectures == null) continue;

      for (String lecId in chapter!.lectures!.keys) {
        final lectureData = chapter.lectures![lecId];
        if (lectureData?.status == 'pending') continue;
        localLectures.add(
          _LocalLectureSortWrapper(
            chapId: chapId,
            lecId: lecId,
            // Fallback to epoch if date is missing
            purchaseDate: lectureData?.purchaseDateTime ?? DateTime.now(),
          ),
        );
      }
    }

    // 2. Sort them locally right away!
    // Change to b.purchaseDate.compareTo(a.purchaseDate) for Newest First
    localLectures.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

    // 3. Fire parallel Firestore requests based on the already sorted list
    List<Future<void>> fetchTasks = [];

    // We use a thread-safe map or ordered placeholder to maintain the sort order after async operations complete
    List<VideoDetailsModel?> orderedResults =
        List.filled(localLectures.length, null);

    for (int i = 0; i < localLectures.length; i++) {
      final target = localLectures[i];

      fetchTasks.add(FirebaseFirestore.instance
          .collection('data')
          .doc('videos')
          .collection(um.grade!)
          .doc(target.chapId)
          .collection('lectures')
          .doc(target.lecId)
          .get()
          .then((lectureDoc) {
        if (lectureDoc.exists && lectureDoc.data() != null) {
          final data = lectureDoc.data()!;

          // Skip if hidden
          if (data['hide'] ?? false) return;

          // Insert directly into its pre-sorted index slot!
          orderedResults[i] = VideoDetailsModel.fromJson(data);
        }
      }).catchError((error) {
        debugPrint('Error fetching metadata for ${target.lecId}: $error');
      }));
    }

    try {
      // Wait for all cloud data to populate concurrently
      await Future.wait(fetchTasks);

      // 4. Filter out any null entries (from hidden videos or failed fetches)
      myVideos = orderedResults.whereType<VideoDetailsModel>().toList();
      debugPrint(myVideos.first.title);
      emit(PlatformGetMyLecturesDataSuccessState());
    } catch (error) {
      debugPrint('Error populating video data details: $error');
    }
  }

/*
  Future<void> getMyVideos() async {
    myVideos = [];
    UserModel um = Constants.userBox.get('user');

    if (um.purchasedVideos == null || um.purchasedVideos!.isEmpty) {
      debugPrint('No purchased videos found.');
      return;
    }

    for (String chapId in um.purchasedVideos!.keys) {
      DocumentReference<Map<String, dynamic>> doc = FirebaseFirestore.instance
          .collection('data')
          .doc('videos')
          .collection(um.grade!)
          .doc(chapId);

      try {
        for (String lecId in um.purchasedVideos![chapId]!.lectures!.keys) {
          // Check if there's at least one video that matches the condition
          DocumentSnapshot<Map<String, dynamic>> lectureDoc =
              await doc.collection('lectures').doc(lecId).get();
          if (lectureDoc.exists) {
            if (lectureDoc.data()?['hide'] ?? false) {
              continue;
            }
            myVideos.add(VideoDetailsModel.fromJson(lectureDoc.data()!));
          }
        }
        emit(PlatformGetMyLecturesDataSuccessState());
      } catch (error) {
        debugPrint(error.toString());
      }
    }

    debugPrint(myVideos.toString());
  }
*/
// old myVideos
/*
  List<VideoDetailsModel> myVideos = [];
  Future<void> getMyVideos() async {
    myVideos = [];
    UserModel um = Constants.userBox.get('user');

    if (um.purchasedVideos != null && um.purchasedVideos!.isNotEmpty) {
      um.purchasedVideos!.forEach((key, purchasedVideos) {
        for (UserPurchasedModel video in purchasedVideos) {
          FirebaseFirestore.instance
              .collection('data')
              .doc('videos')
              .collection(um.grade!)
              .doc(key)
              .collection('lectures')
              .doc(video.vidId)
              .get()
              .then((value) {
            myVideos.add(VideoDetailsModel.fromJson(value.data()!));
            emit(PlatformGetMyLecturesDataSuccessState());
          }).catchError((onError) {
            debugPrint(onError.toString());
          });
        }
      });
      debugPrint(myVideos);
    } else {
      debugPrint('No purchased videos found.');
    }
  }
*/

  List<VideoDetailsModel> videoDetailsList = [];
  Future<void> getVideoDetails({
    required String chapId,
  }) async {
    videoDetailsList = [];
    emit(PlatformGetVideoDetailsLoadingState());
    UserModel um = Constants.userBox.get('user');
    try {
      var lecturesSnapshot = await FirebaseFirestore.instance
          .collection('data')
          .doc('videos')
          .collection(um.grade!)
          .doc(chapId)
          .collection('lectures')
          .orderBy('date', descending: true)
          .get();

      for (var doc in lecturesSnapshot.docs) {
        if (doc.data()['hide'] ?? false) {
          continue;
        }
        if (doc.data()['type'] != null) {
          final isOnlineStudent =
              (um.groupName?.isEmpty ?? true) || um.groupName == 'Online';

          if (isOnlineStudent) {
            // الطالب أونلاين يشوف online و both
            if (doc.data()['type'] != 'both' &&
                doc.data()['type'] != 'online') {
              continue;
            }
          } else {
            // الطالب سنتر يشوف center و both
            if (doc.data()['type'] != 'both' &&
                doc.data()['type'] == 'online') {
              continue;
            }
          }
        }
        videoDetailsList.add(VideoDetailsModel.fromJson(doc.data()));
      }

      emit(PlatformGetVideoDetailsSuccessState(videoDetailsList));
    } catch (error) {
      debugPrint(error.toString());
      emit(PlatformGetVideoDetailsFailState(error.toString()));
    }
  }

  List<Map<String, dynamic>> lectureData = [];
  Future<void> getLectureData({
    required String chapId,
    required String lecId,
  }) async {
    List<WatchesVideoModel> vidds = [];
    emit(PlatformGetLecturesDataLoadingState());

    UserModel um = Constants.userBox.get('user');
    FirebaseFirestore.instance
        .collection('data')
        .doc('videos')
        .collection(um.grade!)
        .doc(chapId)
        .collection('lectures')
        .doc(lecId)
        .collection('data')
        .orderBy('index')
        .get()
        .then((value) {
      lectureData = [];
      for (var doc in value.docs) {
        if (doc.data()['visType'] != null) {
          // لو الطالب أونلاين (Online أو فاضي)
          final isOnlineStudent =
              (um.groupName?.isEmpty ?? true) || um.groupName == 'Online';

          if (isOnlineStudent) {
            // الطالب أونلاين يشوف online و both
            if (doc.data()['visType'] != 'both' &&
                doc.data()['visType'] != 'online') {
              continue;
            }
          } else {
            // الطالب سنتر يشوف center و both
            if (doc.data()['visType'] != 'both' &&
                doc.data()['visType'] == 'online') {
              debugPrint('skip:  ${doc.data()['title']}');
              continue;
            }
          }
        }
        lectureData.add(doc.data());
        if (doc.data()['type'] == 'video') {
          vidds.add(WatchesVideoModel.fromMap(doc.data()));
        }
      }

      debugPrint('Lecture data: $lectureData');
      emit(PlatformGetLecturesDataSuccessState(lectureData, vidds));
    }).catchError((onError) {
      debugPrint(onError.toString());
      emit(PlatformGetLecturesDataFailState(onError.toString()));
    });
  }

  Map<String, AttendeModel> stdAttendanceList = {};
  int loan = 0;

  Future<void> getAttendance() async {
    emit(PlatformGetAttendenceDataLoadingState());
    UserModel um = Constants.userBox.get('user');

    try {
      // 1. Fetch the student's main attendance document
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('data')
              .doc('students')
              .collection(um.grade!)
              .doc(um.code)
              .get();

      if (documentSnapshot.exists &&
          documentSnapshot.data()!.containsKey('attendance')) {
        loan = documentSnapshot.data()!['loan'] ?? 0;
        Map<String, dynamic> data = documentSnapshot.data()!['attendance'];

        // Convert to MapEntry list
        List<MapEntry<String, AttendeModel>> sortedEntries = data.entries.map(
          (entry) {
            return MapEntry(entry.key, AttendeModel.fromJson(entry.value));
          },
        ).toList();

        // Sort by date (descending)
        sortedEntries.sort(
          (a, b) => b.value.date.compareTo(a.value.date),
        );

        stdAttendanceList = Map.fromEntries(sortedEntries);
        debugPrint('stdAttendanceList: ${stdAttendanceList.length}');

        // 2. Identify UNIQUE groups needed to prevent redundant queries
        Set<String> uniqueGroups = {};
        for (var model in stdAttendanceList.values) {
          uniqueGroups.add(model.groupName ?? um.groupName!);
        }

        // 3. Fetch all required group documents CONCURRENTLY and cache them in memory
        Map<String, List<dynamic>> groupLecturesCache = {};

        await Future.wait(uniqueGroups.map((groupName) async {
          var groupDoc = await FirebaseFirestore.instance
              .collection('Attendance')
              .doc(um.grade)
              .collection("Groups")
              .where('Name', isEqualTo: groupName)
              .get();

          if (groupDoc.docs.isNotEmpty) {
            var docData = groupDoc.docs.first.data();
            if (docData.containsKey('lectures')) {
              groupLecturesCache[groupName] =
                  docData['lectures'] as List<dynamic>;
            }
          }
        }));

        // 4. Update stdAttendanceList in a single pass using the in-memory cache
        for (var entry in stdAttendanceList.entries) {
          var lecName = entry.key;
          var model = entry.value;
          var groupName = model.groupName ?? um.groupName;

          var cachedLectures = groupLecturesCache[groupName];

          if (cachedLectures != null) {
            var targetLecture = cachedLectures.firstWhere(
              (lec) => lec['lecName'] == lecName,
              orElse: () => null,
            );

            if (targetLecture != null) {
              stdAttendanceList[lecName] = model.copyWith(
                fullExamDegree: targetLecture['fullMark'],
                fullHWDegree: targetLecture['hwDegree'],
                amount: targetLecture['amount'],
              );
            }
          }
        }

        emit(PlatformGetAttendanceDataSuccessState());
      } else {
        emit(PlatformGetAttendanceDataFailState(
            'Document or attendance data does not exist'));
      }
    } catch (onError) {
      emit(PlatformGetAttendanceDataFailState(onError.toString()));
      debugPrint(onError.toString());
    }
  }

  Future<void> buyQuizWallet({
    required String quizId,
    required int price,
  }) async {
    try {
      emit(PlatformBuyQuizWalletLoadingState());
      UserModel um = Constants.userBox.get('user');
      if (price > (um.balance ?? 0)) {
        emit(PlatformBuyQuizWalletFailState(S.current.no_balance_avl));
        return;
      }
      await redeemExamCode(quizId: quizId, price: price);
      emit(PlatformBuyQuizWalletSuccessState());
    } catch (e) {
      debugPrint(e.toString());
      emit(PlatformBuyQuizWalletFailState(e.toString()));
    }
  }

  void buyChapter({
    required int price,
    required String chapId,
    required bool pop,
  }) async {
    emit(PlatformBuyLecturesLoadingState());
    UserModel um = Constants.userBox.get('user');

    // 2. Guest Mode handling
    if (isGuest()) {
      await um.save();
      emit(PlatformBuyChaptersSuccessState(pop: pop));
      return;
    }

    // 3. Balance verification
    if (price > (um.balance ?? 0)) {
      emit(PlatformBuyLecturesFailState(S.current.no_balance_avl));
      return;
    }

    // 4. Firebase Operations utilizing WriteBatch
    WriteBatch batch = FirebaseFirestore.instance.batch();

    PurchaseVideoModel purchaseVideoModel = PurchaseVideoModel(
      date: DateTime.now(),
      stdCode: um.code,
      chapId: chapId,
    );

    // Deduct balance on Firestore
    DocumentReference studentRef = FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(um.grade!)
        .doc(um.code!);

    batch.update(studentRef, {'balance': FieldValue.increment(-price)});

    // Generate new entry in purchases log
    DocumentReference purchaseRef = FirebaseFirestore.instance
        .collection('data')
        .doc('purchases')
        .collection(um.grade!)
        .doc();

    batch.set(purchaseRef, purchaseVideoModel.toMap());

    // Update purchased_videos structure on Firestore using dot notation
    batch.update(
      studentRef,
      {
        'purchased_videos.$chapId.purchaseDateTime': DateTime.now(),
        'purchased_videos.$chapId.status': 'paid',
      },
    );

    try {
      // Commit to cloud database first
      await batch.commit();

      // 5. Finalize local state modifications on success
      um.purchasedVideos![chapId] = UserPurchasedChapterModel(
        lectures: {},
        status: 'paid',
        purchaseDateTime: DateTime.now(),
      );
      um.balance = (um.balance ?? 0) - price;

      await um.save();

      emit(PlatformBuyChaptersSuccessState(pop: pop));
    } catch (error) {
      debugPrint('Error during purchase execution: $error');
      emit(PlatformBuyLecturesFailState(error.toString()));
    }
  }

  void buyLectures({
    required int price,
    required String lecId,
    required String chapId,
    bool? isChapPaid,
    required List<WatchesVideoModel> newVids,
    required bool pop,
  }) async {
    emit(PlatformBuyLecturesLoadingState());
    UserModel um = Constants.userBox.get('user');

    // 2. Guest Mode handling
    if (isGuest()) {
      await um.save();
      emit(PlatformBuyLecturesSuccessState(pop: pop));
      return;
    }

    // 3. Balance verification
    if (price > (um.balance ?? 0)) {
      emit(PlatformBuyLecturesFailState(S.current.no_balance_avl));
      return;
    }

    // 4. Firebase Operations utilizing WriteBatch
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Deduct balance on Firestore
    DocumentReference studentRef = FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(um.grade!)
        .doc(um.code!);

    batch.update(studentRef, {'balance': FieldValue.increment(-price)});
    if (isChapPaid != true) {
      // Generate new entry in purchases log
      DocumentReference purchaseRef = FirebaseFirestore.instance
          .collection('data')
          .doc('purchases')
          .collection(um.grade!)
          .doc();
      PurchaseVideoModel purchaseVideoModel = PurchaseVideoModel(
        date: DateTime.now(),
        stdCode: um.code,
        chapId: chapId,
        lecId: lecId,
      );

      batch.set(purchaseRef, purchaseVideoModel.toMap());
    }
    // 1. Process local updates & merge new videos safely
    Map<String, UserPurchasedModel> updatedVideos =
        _mergeAndGetVideos(um, chapId, lecId, newVids);

    // Update purchased_videos structure on Firestore using dot notation
    batch.update(
      studentRef,
      {
        'purchased_videos.$chapId.lectures.$lecId.purchaseDateTime':
            DateTime.now(),
        // Clear any leftover "pending" flag from an abandoned online attempt.
        'purchased_videos.$chapId.lectures.$lecId.status': 'paid',
        'purchased_videos.$chapId.lectures.$lecId.videos':
            updatedVideos.map((key, value) => MapEntry(key, value.toMap()))
      },
    );

    try {
      // Commit to cloud database first
      await batch.commit();

      // 5. Finalize local state modifications on success
      um.purchasedVideos![chapId]!.lectures![lecId]!.purchaseDateTime =
          DateTime.now(); // Assumes your model has a date property
      um.purchasedVideos![chapId]!.lectures![lecId]!.status = 'paid';
      um.purchasedVideos![chapId]!.lectures![lecId]!.videos = updatedVideos;
      um.balance = (um.balance ?? 0) - price;

      await um.save();

      emit(PlatformBuyLecturesSuccessState(pop: pop));
    } catch (error) {
      debugPrint('Error during purchase execution: $error');
      emit(PlatformBuyLecturesFailState(error.toString()));
    }
  }

  /// Helper method to initialize nested structures safely, merge videos, and prevent duplicate logic.
  Map<String, UserPurchasedModel> _mergeAndGetVideos(
    UserModel um,
    String chapId,
    String lecId,
    List<WatchesVideoModel> newVids,
  ) {
    // Step A: Ensure the root Chapter model exists in the map
    if (!um.purchasedVideos!.containsKey(chapId)) {
      um.purchasedVideos![chapId] = UserPurchasedChapterModel(lectures: {});
    }

    // Step B: Ensure the Lectures map is initialized
    um.purchasedVideos![chapId]!.lectures ??= {};

    // Step C: Ensure the specific Lecture model exists in the map
    if (!um.purchasedVideos![chapId]!.lectures!.containsKey(lecId)) {
      um.purchasedVideos![chapId]!.lectures![lecId] = UserPurchasedLectureModel(
        videos: {},
        status: 'paid',
        purchaseDateTime: DateTime.now(),
      );
    }

    // Step D: Ensure the Videos map inside the lecture is initialized
    um.purchasedVideos![chapId]!.lectures![lecId]!.videos ??= {};

    // Extract reference to working videos map
    Map<String, UserPurchasedModel> currentVideos =
        um.purchasedVideos![chapId]!.lectures![lecId]!.videos!;

    // Step E: Loop and merge/add new videos
    for (var vid in newVids) {
      if (vid.vidId == null) continue;

      if (currentVideos.containsKey(vid.vidId)) {
        // Use copyWith if your model supports it to preserve immutable integrity,
        // or modify the reference field safely as done here:
        final existingVid = currentVideos[vid.vidId]!;
        existingVid.avaWatches =
            (existingVid.avaWatches ?? 0) + (vid.avaWatches ?? 4);
      } else {
        currentVideos[vid.vidId!] = UserPurchasedModel(
          vidId: vid.vidId,
          stdWatches: 0,
          avaWatches: vid.avaWatches ?? 4,
          dateTime: DateTime.now(),
        );
      }
    }

    return currentVideos;
  }

  void addPdf({
    required String chapId,
    required String lecId,
    required String pdfId,
  }) async {
    emit(PlatformaddPdfLoadingState());

    UserModel um = Constants.userBox.get('user');
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Initialize purchased videos if null
    um.purchasedPdfs ??= {};
    um.purchasedPdfs![chapId] ??= {};
    um.purchasedPdfs![chapId]![lecId] ??= [];

    um.purchasedPdfs![chapId]![lecId]!.add(pdfId);

    // Prepare to update purchased videos in Firestore
    batch.update(
      FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(um.grade!)
          .doc(um.code),
      {
        'purchased_pdfs': um.purchasedPdfs!.map((chapterKey, lectures) {
          return MapEntry(chapterKey, lectures.map((lecKey, purchases) {
            return MapEntry(
                lecKey, purchases.map((purchase) => purchase).toList());
          }));
        }),
      },
    );

    try {
      // Commit the batch
      await batch.commit();

      // Save updated user model
      await um.save();

      emit(PlatformaddPdfSuccessState());
    } catch (error) {
      debugPrint('Error during purchase: $error');
      emit(PlatformBuyLecturesFailState(error.toString()));
    }
  }

  bool checkVideoPurchased({
    required String vidId,
    required String lecId,
    required String chapId,
    // required int avaWatch,
  }) {
    UserModel um = Constants.userBox.get('user');

    // Check if the video has been purchased in the specified chapter and lecture
    UserPurchasedLectureModel? userPurchasedLectureModel =
        um.purchasedVideos?[chapId]?.lectures?[lecId];
    if (userPurchasedLectureModel != null &&
        userPurchasedLectureModel.status == 'paid') {
      UserPurchasedModel? userPurchasedModel =
          userPurchasedLectureModel.videos?[vidId];
      if (userPurchasedModel != null) {
        if ((userPurchasedModel.avaWatches ?? 4) >
            (userPurchasedModel.stdWatches ?? 0)) {
          return true;
        } else {
          return false;
        }
      } else {
        return true;
      }
    } else {
      return false;
    }
    /*
    return um.purchasedVideos?[chapId]?[lecId] != null &&
        um.purchasedVideos![chapId]![lecId]!.any((element) =>
            element.vidId == vidId &&
            (element.stdWatches != element.avaWatches));
            */
  }

  bool checkPackagePurchased({
    required List<WatchesVideoModel> vidds,
    required String lecId,
    required String chapId,
  }) {
    UserModel? um = Constants.userBox.get('user');

    // التحقق من أن المستخدم ليس null وأن البيانات موجودة
    if (um == null || um.purchasedVideos == null) return false;

    var purchasedLecVideos =
        um.purchasedVideos![chapId]?.lectures?[lecId]?.videos;
    if (purchasedLecVideos == null) return false;

    if (um.purchasedVideos![chapId]?.lectures?[lecId]?.status != 'paid') {
      return false;
    }
    // التحقق مما إذا كانت القائمة موجودة
    if (purchasedLecVideos.isEmpty) return true;

    // التأكد من أن عدد الفيديوهات مطابق
    if (vidds.length > purchasedLecVideos.length) return true;

    // التحقق من كل فيديو في vidds
    for (var video in vidds) {
      // البحث عن الفيديو المطابق في purchasedLecVideos
      var purchasedVideo = purchasedLecVideos[video.vidId];

      // إذا لم يتم العثور على الفيديو في purchasedLecVideos
      if (purchasedVideo == null) {
        return true;
      }

      // مقارنة avaWatches القادم من vidds مع stdWatches القادم من purchasedLecVideos
      if ((purchasedVideo.avaWatches ?? 4) > (purchasedVideo.stdWatches ?? 0)) {
        return true; // إذا كان عدد المشاهدات المستهلكة وصل للحد الأقصى، نرجع false
      }
    }

    return false; // إذا نجحت كل التحققّات، نرجع true
  }

  bool checkPurchased({required String lecId, required String chapId}) {
    UserModel um = Constants.userBox.get('user');

    // Check if the purchasedVideos map contains the chapter ID and then the lecture ID
    return um.purchasedVideos?[chapId]?.lectures?[lecId] != null &&
        um.purchasedVideos?[chapId]?.lectures?[lecId]?.status == 'paid';
  }

  bool checkChapterPurchased({required String chapId}) {
    UserModel um = Constants.userBox.get('user');

    // Check if the purchasedVideos map contains the chapter ID.
    return um.purchasedVideos?[chapId] != null &&
        um.purchasedVideos![chapId]?.status == 'paid';
  }

  /// Whether the given lecture is currently waiting for an online payment to be
  /// confirmed (the student started an online/Fawry flow but didn't finish it).
  bool isLecturePending({required String chapId, required String lecId}) {
    UserModel um = Constants.userBox.get('user');
    return um.purchasedVideos?[chapId]?.lectures?[lecId]?.status == 'pending';
  }

  /// Whether the given chapter is currently waiting for an online payment.
  bool isChapPending({required String chapId}) {
    UserModel um = Constants.userBox.get('user');
    return um.purchasedVideos?[chapId]?.status == 'pending';
  }

/*
  /// Flags a lecture (or a whole chapter when [lecId] is null) as `pending`
  /// right after an online invoice is created, so the student sees an
  /// "awaiting payment" hint and can resume or start a fresh payment later.
  ///
  /// The flag is written both to Firestore and to the local Hive copy. A
  /// successful wallet/code/online purchase later overwrites it with `paid`.
  Future<void> markPaymentPending({
    required String chapId,
    String? lecId,
  }) async {
    if (isGuest()) return;
    UserModel um = Constants.userBox.get('user');

    try {
      final studentRef = FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(um.grade!)
          .doc(um.code);

      // Ensure the nested local structure exists before flipping the status.
      um.purchasedVideos ??= {};
      if (lecId == null) {
        um.purchasedVideos![chapId] ??= UserPurchasedChapterModel(lectures: {});
        // Don't override an already-paid chapter.
        if (um.purchasedVideos![chapId]!.status == 'paid') return;
        um.purchasedVideos![chapId]!.status = 'pending';
        um.purchasedVideos![chapId]!.purchaseDateTime = DateTime.now();

        await studentRef.update({
          'purchased_videos.$chapId.status': 'pending',
          'purchased_videos.$chapId.purchaseDateTime': DateTime.now(),
        });
      } else {
        um.purchasedVideos![chapId] ??= UserPurchasedChapterModel(lectures: {});
        um.purchasedVideos![chapId]!.lectures ??= {};
        um.purchasedVideos![chapId]!.lectures![lecId] ??=
            UserPurchasedLectureModel(videos: {});
        if (um.purchasedVideos![chapId]!.lectures![lecId]!.status == 'paid') {
          return;
        }
        um.purchasedVideos![chapId]!.lectures![lecId]!.status = 'pending';
        um.purchasedVideos![chapId]!.lectures![lecId]!.purchaseDateTime =
            DateTime.now();

        await studentRef.update({
          'purchased_videos.$chapId.lectures.$lecId.status': 'pending',
          'purchased_videos.$chapId.lectures.$lecId.purchaseDateTime':
              DateTime.now(),
        });
      }

      await um.save();
      emit(PlatfomrRefreshState());
    } catch (error) {
      debugPrint('markPaymentPending error: $error');
    }
  }
*/
  void watchVideo({
    required String vidId,
    required bool valid,
    required int avaWatches,
    required String lecId,
    required String chapId,
  }) {
    emit(PlatformRemoveLecturesLoadingState());
    UserModel um = Constants.userBox.get('user');

    // 1. Safe deep lookups to prevent null-pointer crashes
    final chapter = um.purchasedVideos?[chapId];
    if (chapter == null || chapter.lectures == null) {
      emit(PlatformRemoveLecturesFailState(
          'Chapter or Lectures structure not found'));
      return;
    }

    final lecture = chapter.lectures![lecId];
    if (lecture == null) {
      emit(PlatformRemoveLecturesFailState('Lecture not found'));
      return;
    }

    // Ensure the videos map inside the lecture is initialized
    lecture.videos ??= {};
    Map<String, UserPurchasedModel> videosMap = lecture.videos!;

    // 2. Core watch verification and progression logic
    UserPurchasedModel updatedVideo;

    if (videosMap.containsKey(vidId)) {
      final existingVideo = videosMap[vidId]!;

      // Stop if the video has already been watched and the state is invalid
      if ((existingVideo.stdWatches ?? 0) != 0 && !valid) {
        emit(PlatformRemoveLecturesFailState(
            'Invalid state: cannot watch video'));
        return;
      }

      // Increment watch counts safely
      existingVideo.stdWatches = (existingVideo.stdWatches ?? 0) + 1;
      existingVideo.dateTime = DateTime.now();
      updatedVideo = existingVideo;
    } else {
      // If it's a completely new video record, create a new model instance
      updatedVideo = UserPurchasedModel(
        vidId: vidId,
        stdWatches: 1,
        avaWatches: avaWatches,
        dateTime: DateTime.now(),
      );
      videosMap[vidId] = updatedVideo;
    }

    // 3. Update local UI list state cleanly if tracking it concurrently
    int lecIdx =
        purchasedVideosList.indexWhere((element) => element.lectureId == lecId);
    if (lecIdx != -1) {
      purchasedVideosList[lecIdx].stdWatches += 1;
    }

    // 4. Sequence database persistence: Local Hive first, then sync to Firestore
    um.save().then((_) {
      FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(um.grade!)
          .doc(um.code!)
          .update({
        'purchased_videos.$chapId.lectures.$lecId.videos.$vidId':
            updatedVideo.toMap(),
      }).then((_) {
        emit(PlatformRemoveLecturesSuccessState());
      }).catchError((error) {
        debugPrint('Firestore Update Error: $error');
        emit(PlatformRemoveLecturesFailState(error.toString()));
      });
    }).catchError((error) {
      debugPrint('Hive Save Error: $error');
      emit(PlatformRemoveLecturesFailState(
          'Error saving user model locally: ${error.toString()}'));
    });
  }

/*
  void watchVideo({
    required String vidId,
    required bool valid,
    required int avaWatches,
    required String lecId,
    required String chapId,
  }) {
    emit(PlatformRemoveLecturesLoadingState());
    UserModel um = Constants.userBox.get('user');

    // Check if the chapter and lecture exist in purchased videos
    if (um.purchasedVideos?[chapId]?.lectures?[lecId] != null) {
      Map<String, UserPurchasedModel>? purchases =
          um.purchasedVideos![chapId]!.lectures![lecId]!.videos;

      if (purchases![vidId] != null) {
        UserPurchasedModel? video = purchases[vidId];
        if ((video?.stdWatches ?? 0) != 0 && !valid) return;

        video?.stdWatches = ((video.stdWatches)! + 1);
        video?.dateTime = DateTime.now();
      } else {
        um.purchasedVideos![chapId]!.lectures![lecId]!.videos![vidId] =
            UserPurchasedModel(
          vidId: vidId,
          stdWatches: 1,
          avaWatches: avaWatches,
          dateTime: DateTime.now(),
        );
      }
      int lecIdx = purchasedVideosList
          .indexWhere((element) => element.lectureId == lecId);
      if (lecIdx != -1) {
        purchasedVideosList[lecIdx].stdWatches += 1;
      }

      // Save updated user model and Firestore in sequence
      um.save().then((_) {
        FirebaseFirestore.instance
            .collection('data')
            .doc('students')
            .collection(um.grade!)
            .doc(um.code!)
            .update({
          'purchased_videos.$chapId.lectures.$lecId.videos.$vidId': um
              .purchasedVideos![chapId]!.lectures![lecId]!.videos![vidId]!
              .toMap(),
        }).then((_) {
          emit(PlatformRemoveLecturesSuccessState());
        }).catchError((error) {
          emit(PlatformRemoveLecturesFailState(error.toString()));
        });
      }).catchError((error) {
        emit(PlatformRemoveLecturesFailState(
            'Error saving user model: ${error.toString()}'));
      });
    } else {
      emit(PlatformRemoveLecturesFailState('Lecture not found'));
    }
  }
*/
  int curIdx = 0;
  void changeBottomIndex(int idx) {
    curIdx = idx;
    emit(PaltformChangeIndexState());
  }

  /// مرجع لـ PageController الخاص بـ HomeLayout (يُسجَّل في initState).
  /// يُستخدم للتنقّل بين تبويبات الـ Home برمجيًا (مثلاً من الإشعارات).
  PageController? homePageController;

  /// الانتقال إلى تبويب معيّن في HomeLayout (0=home ... 3=quizzes ... 4=profile).
  /// يعيد المحاولة حتى يصبح الـ PageView جاهزًا (مفيد عند فتح التطبيق من إشعار).
  void navigateToHomeTab(int index, {int attempt = 0}) {
    changeBottomIndex(index);
    if (homePageController != null && homePageController!.hasClients) {
      homePageController!.jumpToPage(index);
    } else if (attempt < 20) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigateToHomeTab(index, attempt: attempt + 1);
      });
    }
  }

  bool isDarkMode = SharedPrefHelper.getData('isDarkMode') ?? false;
  void changeDarkMode() {
    isDarkMode = !isDarkMode;
    if (isPurple) {
      if (isDarkMode) {
        Constants.wallpaberDark = Constants.wallpaberPurbleDark;
      } else {
        Constants.wallpaberLight = Constants.wallpaberPurbleLight;
      }
    } else {
      if (isDarkMode) {
        Constants.wallpaberDark = Constants.wallpaberBlueDark;
      } else {
        Constants.wallpaberLight = Constants.wallpaberBlueLight;
      }
    }
    SharedPrefHelper.saveData(key: 'isDarkMode', value: isDarkMode)
        .then((value) {
      emit(PlatformChangeModeState());
    }).catchError((onError) {
      debugPrint('Error change mode');
    });
  }

  bool isPurple = SharedPrefHelper.getData('isPurple') ?? false;

  void changeAppColor() {
    isPurple = !isPurple;
    if (isPurple) {
      AppColors.appPrimaryColor = AppColors.appPurblePrimaryColor;
      AppColors.appSecondaryColor = AppColors.appPurbleSecondaryColor;
      if (isDarkMode) {
        Constants.wallpaberDark = Constants.wallpaberPurbleDark;
      } else {
        Constants.wallpaberLight = Constants.wallpaberPurbleLight;
      }
    } else {
      AppColors.appPrimaryColor = AppColors.appBluePrimaryColor;
      AppColors.appSecondaryColor = AppColors.appBlueSecondaryColor;
      if (isDarkMode) {
        Constants.wallpaberDark = Constants.wallpaberBlueDark;
      } else {
        Constants.wallpaberLight = Constants.wallpaberBlueLight;
      }
    }
    SharedPrefHelper.saveData(key: 'isPurple', value: isPurple).then((value) {
      emit(PlatformChangeAppColorState());
    }).catchError((onError) {
      debugPrint('Error change mode');
    });
  }

  Future<String> getLink(String platform) async {
    DocumentSnapshot<Map<String, dynamic>> ds = await FirebaseFirestore.instance
        .collection('social_links')
        .doc('${platform}_link')
        .get();

    return ds.data()!['link'].toString();
  }

  bool isAr = SharedPrefHelper.getData('isAr') ?? true;
  void changeLang() {
    isAr = !isAr;
    SharedPrefHelper.saveData(key: 'isAr', value: isAr).then((value) {
      emit(PlatformChangeLanguageState());
    }).catchError((onError) {
      debugPrint('Error change lang');
    });
  }

  void rebuild() {
    emit(PlatformRebuildStateState());
  }

// edit profile

  File? userImage;

  Future<File?>? pickImageFromGallery(context) async {
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = (await file.readAsBytes()).lengthInBytes;
      final kb = bytes / 1024;
      if ((kb / 1024) <= 1.5) {
        emit(PlatformPickImageFromGallerySuccessState());
        return File(file.path);
      } else {
        emit(PlatformPickImageFromGalleryFailState(
            S.of(context).choose_less_img));
        return null;
      }
    }
    emit(PlatformPickImageFromGalleryFailState(S.of(context).no_img_selc));
    return null;
  }

  Future<String> uplaodImage({
    required File? file,
    String? childName,
    required String img,
  }) async {
    emit(PlatformUplaodImageLoadingState());
    if (file != null) {
      Reference ref = FirebaseStorage.instance.ref().child(
          '${childName ?? 'user_images'}/${Uri.file(file.path).pathSegments.last}');
      TaskSnapshot snapShot = await ref.putFile(file);
      String downloadUrl = await snapShot.ref.getDownloadURL();

      if (!img.contains('user.png')) {
        await FirebaseStorage.instance.refFromURL(img).delete();
      }
      return downloadUrl;
    }
    emit(PlatformUplaodImageFailState());
    return '';
  }

  void updatePassword({
    required String oldPass,
    required String newPass,
  }) {
    emit(PlatformUpdatePasswordLoadingState());
    // final user = FirebaseAuth.instance.currentUser;
    UserModel um = Constants.userBox.get('user');

    try {
      /*
      // Re-authenticate the user
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPass,
      );
      user.reauthenticateWithCredential(credential).then((value) {
        user.updatePassword(newPass).then((value) {
          */
      FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(um.grade!)
          .doc(um.code)
          .update({'password': newPass}).then((value) {
        um.password = newPass;
        um.save().then((value) {
          emit(PlatformUpdatePasswordSuccessState());
        }).catchError((onError) {
          emit(PlatformUpdatePasswordFailState(' ${onError.toString()}'));
        });
      }).catchError((onError) {
        emit(PlatformUpdatePasswordFailState(onError.toString()));
      });
      /*
        }).catchError((onError) {
          emit(PlatformUpdatePasswordFailState(onError.toString()));
        });
        
      }).catchError((onError) {
        emit(PlatformUpdatePasswordFailState(onError.toString()));
      });
      */
    } catch (e) {
      emit(PlatformUpdatePasswordFailState(e.toString()));
    }
  }

  void uplaodUpdatedUserData({
    required ar_fname,
    required ar_sname,
    required ar_thname,
    required fname,
    required sname,
    required String img,
    required thname,
  }) {
    emit(PlatformUplaodUpdatedDataLoadingState());
    UserModel um = Constants.userBox.get('user');
    FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(um.grade!)
        .doc(um.code)
        .update({
      "ar_fname": ar_fname,
      "ar_sname": ar_sname,
      "ar_thname": ar_thname,
      "fname": fname,
      "sname": sname,
      "thname": thname,
      "img": img.isEmpty ? um.img : img,
    }).then((value) {
      um.ar_fname = ar_fname;
      um.ar_sname = ar_sname;
      um.ar_thname = ar_thname;
      um.fname = fname;
      um.sname = sname;
      um.thname = thname;
      um.img = img.isEmpty ? um.img : img;
      um.save().then((value) {
        emit(PlatformUplaodUpdatedDataSuccessState());
      }).catchError((onError) {
        emit(PlatformUplaodUpdatedDataFailState(' ${onError.toString()}'));
      });
    }).catchError((onError) {
      emit(PlatformUplaodUpdatedDataFailState(onError.toString()));
    });
  }

  // quizes
  Future<int> getMinDegree({
    required String quizId,
  }) async {
    String handleQuizId =
        quizId.contains(',') ? quizId.split(',').last : quizId;
    debugPrint(quizId.split(',').last);

    final quizDoc = await FirebaseFirestore.instance
        .collection('data')
        .doc('quizes')
        .collection(Components.getGrade(handleQuizId[0]))
        .doc(handleQuizId)
        .get();
    final doc = await FirebaseFirestore.instance
        .collection('data')
        .doc('videos')
        .collection(Components.getGrade(handleQuizId[0]))
        .doc(quizDoc.data()?['chapId'])
        .collection('lectures')
        .doc(quizDoc.data()?['lecId'])
        .collection('data')
        .doc(quizDoc.data()?['quizId'])
        .get();

    return doc.data()?['minDegree'] ?? 0;
  }

  Future<bool> getShowDegree({required String quizId}) async {
    String handleQuizId =
        quizId.contains(',') ? quizId.split(',').last : quizId;
    final doc = await FirebaseFirestore.instance
        .collection('data')
        .doc('quizes')
        .collection(Components.getGrade(handleQuizId[0]))
        .doc(handleQuizId)
        .get();

    return doc.data()?['showDegree'] ?? true;
  }

  void checkQuiz({
    required String quizCode,
    context,
    String? title,
    String? vidId,
    int? minDegree,
  }) {
    emit(PlatformCheckQuizLoadingState());
    UserModel um = Constants.userBox.get('user');
    FirebaseFirestore.instance
        .collection('data')
        .doc('quizes')
        .collection(um.grade!)
        .doc(quizCode)
        .get()
        .then((value) {
      if (value.data() != null) {
        FirebaseFirestore.instance
            .collection('data')
            .doc('quizes')
            .collection(um.grade!)
            .doc(quizCode)
            .get()
            .then((value) {
          if (value.data()!['isValid']) {
            //  debugPrint(vidId);
            //
            if (vidId != null) {
              getQuestionData(
                  quizCode: quizCode, vidId: vidId, minDegree: minDegree);
            } else {
              bool isinList = um.stdQuizes?[quizCode] != null &&
                  um.stdQuizes![quizCode]!.id.isNotEmpty;
              if (isinList) {
                emit(
                  PlatformCheckQuizFailState(' You Answered this Quiz Before'),
                );
              } else {
                if (value.data()?['validUntil'] != null) {
                  if ((value.data()?['validUntil'] as Timestamp)
                      .toDate()
                      .isAfter(DateTime.now())) {
                    getQuestionData(quizCode: quizCode);
                  } else {
                    emit(PlatformCheckQuizFailState(
                        ' ${S.current.exam_expired}'));
                  }
                } else {
                  getQuestionData(quizCode: quizCode);
                }
              }
            }
          } else {
            emit(PlatformCheckQuizFailState(' Not Valid Code'));
          }
        }).catchError((onError) {
          emit(PlatformCheckQuizFailState(onError.toString()));
        });
      } else {
        emit(PlatformCheckQuizFailState(' Not Valid Code'));
      }
    }).catchError((onError) {
      emit(PlatformCheckQuizFailState(onError.toString()));
    });
  }

  // quiz
  static QuizModel? quizModel;
  void setQuizModel(QuizModel quiz) {
    quizModel = quiz;
  }

  void getQuestionData({
    required String quizCode,
    String? vidId,
    int? minDegree,
  }) {
    UserModel um = Constants.userBox.get('user');
    FirebaseFirestore.instance
        .collection('data')
        .doc('quizes')
        .collection(um.grade!)
        .doc(quizCode)
        .get()
        .then((value) {
      setQuizModel(QuizModel.fromJson(value.data()!));
      debugPrint(vidId);
      if (vidId != null) {
        emit(PlatformCheckLectureQuizSuccessState(vidId, minDegree));
      } else {
        emit(PlatformCheckQuizSuccessState(title: quizModel?.title ?? ''));
      }
    }).catchError((onError) {
      debugPrint(onError.toString());
      emit(PlatformCheckQuizFailState(onError.toString()));
    });
  }

  List<QuestionModel> quizQuestions = [];
  late Map<String, dynamic> stdQuizAnsws;
  void getQuestions({
    required String quizCode,
    required bool isInQuizScreen,
    String? lecId,
  }) {
    quizQuestions = [];
    emit(PlatformQuizGetQuizesLoadingState());
    UserModel um = Constants.userBox.get('user');
    FirebaseFirestore.instance
        .collection('data')
        .doc('quizes')
        .collection(um.grade!)
        .doc(quizCode)
        .collection('questions')
        .get()
        .then((value) {
      debugPrint(value.docs.length.toString());
      for (int i = 0; i < value.docs.length; i++) {
        quizQuestions.add(QuestionModel.fromJson(value.docs[i].data()));
      }

      if (isInQuizScreen) {
        emit(PlatformQuizGetQuizesSuccessState(quizQuestions));
      } else {
        stdQuizAnsws = {};
        writtenAnswsMap = {};
        if (quizModel!.isRand) {
          quizQuestions.shuffle();
          debugPrint('shuffled');
        } else {
          quizQuestions.sort((a, b) {
            if (a.index != null && b.index != null) {
              return a.index!.compareTo(b.index!);
            }
            return a.date.compareTo(b.date);
          });
          debugPrint('sorted');
        }
        addStdPoints(isComplete: false, lecId: lecId);
      }
    }).catchError((onError) {
      debugPrint(onError.toString());
      emit(PlatformQuizGetQuizesFailState(onError.toString()));
    });
  }

  List<QuestionModel> questionbankAnswsQuestions = [];
  void getQuestionbankQuestions({
    required String id,
  }) {
    questionbankAnswsQuestions = [];
    emit(PlatformQuizGetQuestionBankLoadingState());
    UserModel um = Constants.userBox.get('user');
    FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(um.grade!)
        .doc(um.code)
        .collection('questionbank')
        .doc(id)
        .collection('questions')
        .orderBy(FieldPath.documentId)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        questionbankAnswsQuestions.add(QuestionModel.fromJson(doc.data()));
      }

      emit(PlatformQuizGetQuestionBankSuccessState(questionbankAnswsQuestions));
    }).catchError((onError) {
      debugPrint('Error: $onError');
      emit(PlatformQuizGetQuestionBankFailState(onError.toString()));
    });
  }

  void getAnswsChapters(String id) {
    UserModel um = Constants.userBox.get('user');
    FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(um.grade!)
        .doc(um.code)
        .collection('questionbank')
        .doc(id)
        .get()
        .then((snapshot) {
      // Directly cast the data to the desired type
      Map<String?, List<String?>>? chaptersMap =
          (snapshot.data()?['chapters'] as Map<String?, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<String?>.from(value)),
      );

      emit(PlatformQuizGetQuestionBankChaptersSuccessState(chaptersMap ?? {}));
    }).catchError((onError) {});
  }

  void selectAnswer(String queId, int ansIdx) {
    stdQuizAnsws[queId] = ansIdx;
    emit(PlatformQuizSelectAnswerState());
  }

  void selectQuestionbankAnswer(String queId, int ansIdx) {
    stdQuestionbankAnsws[queId] = ansIdx;
    emit(PlatformQuestionbankSelectAnswerState());
  }

  bool isLast = false;
  void changeIsLast(bool isLastt) {
    isLast = isLastt;
    emit(PlatformQuizCheckIsLastState());
  }

  bool isStart = true;
  void changeIsStart(bool isStartt) {
    isStart = isStartt;
    emit(PlatformQuizCheckIsStartState());
  }

  double getResult() {
    double score = 0;
    for (int i = 0; i < quizQuestions.length; i++) {
      if (stdQuizAnsws[quizQuestions[i].id] is int &&
          stdQuizAnsws[quizQuestions[i].id] == quizQuestions[i].ansIdx) {
        score += quizQuestions[i].degree;
      }
    }
    return score;
  }

  Future<void> addStdPoints({
    required bool isComplete,
    String? lecId,
  }) async {
    emit(PlatformAddStdPointsLoadingState());

    try {
      UserModel um = Constants.userBox.get('user');
      String targetId =
          lecId == null ? quizModel!.id : '$lecId,${quizModel!.id}';

      // 1. Ensure map is initialized
      um.stdQuizes ??= {};
      final existingQuiz = um.stdQuizes![targetId];
      final now = DateTime.now();

      // 2. Prepare user answers map safely
      Map<String, dynamic> userAnsIdx = Map<String, dynamic>.from(stdQuizAnsws);
      writtenAnswsMap.forEach((questionId, model) {
        final combinedValue = [model.text, ...model.imagesUrl].join(',');
        userAnsIdx[questionId] = combinedValue;
      });

      StdQuizModel updatedQuizModel;

      // 3. Create or Update model safely without risking null pointer crashes
      if (existingQuiz != null && existingQuiz.id.isNotEmpty) {
        int triesNum = existingQuiz.triesNum;

        updatedQuizModel = existingQuiz.copyWith(
          dateTime: isComplete ? existingQuiz.dateTime : now,
          degree: isComplete ? getResult() : 0,
          triesNum: isComplete ? triesNum : triesNum + 1,
          userAnsIdx: userAnsIdx,
          submitTime: isComplete ? now : null,
        );
      } else {
        // If completely new, get status/purchase date from payment phase defaults if any
        updatedQuizModel = StdQuizModel(
          id: targetId,
          title: quizModel!.title,
          dateTime: now,
          fullMark: quizModel!.fullMark,
          questionNums: quizModel!.questionsNum,
          degree: isComplete ? getResult() : 0,
          triesNum: 1,
          userAnsIdx: userAnsIdx,
          submitTime: isComplete ? now : null,
          status: existingQuiz?.status,
          purchaseDateTime: existingQuiz?.purchaseDateTime,
        );
      }

      // 4. Update the local copy
      um.stdQuizes![targetId] = updatedQuizModel;

      // 5. Sequence saves securely using async/await
      await um.save();

      await FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(um.grade!)
          .doc(um.code)
          .update({
        'stdQuizes.$targetId': updatedQuizModel.toJson(),
      });

      // 6. Emit corresponding final state
      if (isComplete) {
        emit(PlatformAddStdPointsSuccessState());
      } else {
        emit(PlatformQuizGetQuizesSuccessState(quizQuestions));
      }
    } catch (onError) {
      debugPrint("Error inside addStdPoints: ${onError.toString()}");
      emit(PlatformAddStdPointsFailState(onError.toString()));
    }
  }

/*
  void addStdQuestionbankPoints({
    required bool isComplete,
    Map<String?, List<String?>>? chapters,
  }) {
    emit(PlatformAddStdQuestionbankPointsLoadingState());
    UserModel um = Constants.userBox.get('user');
    int idx = 1;

    for (var e in um.stdQuizes!) {
      if (e.id.startsWith('qb')) {
        idx++;
      }
    }

    StdQuizModel stdQuizModel = StdQuizModel(
      id: isComplete ? 'qb ${idx - 1}' : 'qb $idx',
      title: isComplete ? 'Exam ${idx - 1}' : 'Exam $idx',
      dateTime: DateTime.now(),
      fullMark: questionbankQuestions.length,
      questionNums: questionbankQuestions.length,
      degree: isComplete ? getQuestionbankResult() : 0,
      triesNum: 1,
      userAnsIdx: stdQuestionbankAnsws,
      //  isGetMinDegree: true,
    );
    debugPrint(stdQuizModel.id);

    if (isComplete) {
      // 

      int index = um.stdQuizes!.indexOf(
          um.stdQuizes!.firstWhere((element) => element.id == stdQuizModel.id));
      debugPrint('wahba $index');

      um.stdQuizes![index] = stdQuizModel;
    } else {
      DocumentReference<Map<String, dynamic>> doc = FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(um.grade!)
          .doc(um.code)
          .collection('questionbank')
          .doc('qb $idx');
      doc.set({"chapters": chapters}).then((value) {
        for (int i = 0; i < questionbankQuestions.length; i++) {
          String paddedIndex = i.toString().padLeft(4, '0');
          doc
              .collection('questions')
              .doc(paddedIndex)
              .set(questionbankQuestions[i].toMap())
              .then((value) {})
              .catchError((onError) {
            emit(PlatformQuizGetQuestionBankFailState(onError.toString()));
            debugPrint(onError.toString());
          });
        }
        um.stdQuizes!.add(stdQuizModel);
      }).catchError((onError) {
        emit(PlatformQuizGetQuestionBankFailState(onError.toString()));
      });
    }
    um.save().then((value) {
      FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(um.grade!)
          .doc(um.code)
          .update({
        'stdQuizes': um.stdQuizes!.map((quiz) => quiz.toJson()).toList()
      }).then((value) {
        if (isComplete) {
          emit(PlatformAddStdQuestionbankPointsSuccessState());
        } else {
          emit(PlatformQuizGetQuestionBankSuccessState(questionbankQuestions));
        }
      }).catchError((onError) {
        emit(PlatformAddStdQuestionbankPointsFailState(onError.toString()));
      });
    }).catchError((onError) {
      emit(PlatformAddStdQuestionbankPointsFailState(' ${onError.toString()}'));
    });
  }
*/
  Map<String, WrittenAnswsModel> writtenAnswsMap = {};

  void deleteQuiz() {
    FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection('third')
        .doc('32640640')
        .update({'stdQuizes': []});
    debugPrint('quiz deleted');
  }

// 🟢 Save written text
  void saveWrittenAnswer(String questionId, String text) {
    // if map doesn't have entry yet → create one
    if (writtenAnswsMap[questionId] == null) {
      writtenAnswsMap[questionId] = WrittenAnswsModel(text, []);
    } else {
      writtenAnswsMap[questionId]!.text = text;
    }

    emit(WrittenAnswerUpdated());
  }

// 🟢 Add image URL after upload
  void addWrittenImage(String questionId, String url) {
    // if map doesn't have entry yet → create one
    if (writtenAnswsMap[questionId] == null) {
      writtenAnswsMap[questionId] = WrittenAnswsModel('', [url]);
    } else {
      writtenAnswsMap[questionId]!.imagesUrl.add(url);
    }

    emit(WrittenAnswerUpdated());
  }

  // 🟢 Remove image
  void removeWrittenImage(String questionId, String url) {
    writtenAnswsMap[questionId]?.imagesUrl.remove(url);
    emit(WrittenAnswerUpdated());
  }

  // 🟢 Upload progress states
  void setUploading(bool isUploading) {
    emit(WrittenAnswerUploading(isUploading));
  }

  Future<void> saveStdToExcel() async {
    String grade = 'second';
    final CollectionReference usersCollection = FirebaseFirestore.instance
        .collection('data')
        .doc('students')
        .collection(grade);

    // Fetch all documents in the collection
    QuerySnapshot snapshot = await usersCollection.get();

    // Map to store unique phone numbers with corresponding name and age
    Map<String, Map<String, dynamic>> uniqueUsersMap = {};

    for (var doc in snapshot.docs) {
      String phoneNumber = doc['phoneNum'] as String;
      String name =
          '${doc['ar_fname'] ?? ''} ${doc['ar_sname'] ?? ''} ${doc['ar_thname'] ?? ''}';
      String groupName = doc['groupName'] as String;

      // If the phone number is not already in the map, add it
      if (!uniqueUsersMap.containsKey(phoneNumber)) {
        debugPrint('Ahmedd');
        uniqueUsersMap[phoneNumber] = {
          'phoneNumber': phoneNumber,
          'name': name,
          'groupName': groupName,
        };
      }
    }

    // Convert the map values to a list
    List<Map<String, dynamic>> uniqueUsersList = uniqueUsersMap.values.toList();

    // Create an Excel document
    var excel = Excel.createExcel();
    Sheet sheetObject = excel[grade];

    // Add header row
    sheetObject.appendRow([
      TextCellValue('Name'),
      TextCellValue('Phone Number'),
      TextCellValue('Group Name'),
    ]);

    // Add data rows
    for (var user in uniqueUsersList) {
      sheetObject.appendRow([
        TextCellValue(user['name']),
        TextCellValue(user['phoneNumber']),
        TextCellValue(user['groupName']),
      ]);
    }

    // Save the file locally
    Directory? directory = await getDownloadsDirectory();
    String filePath = '${directory!.path}/${grade}Students.xlsx';
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    debugPrint('Excel file saved at: $filePath');
  }

  // Requests (Wahba)

  List<RequsetsModel> requests1 = [];
  List<RequsetsModel> filterRequests1 = [];

  List<RequsetsModel> grade3 = [];
  List<RequsetsModel> requests3 = [];
  List<ChatModel> messages = [];

  static bool student = true;
  int choice = 0;
  int? code;

  TextEditingController requestController = TextEditingController();
  TextEditingController chatController = TextEditingController();
  TextEditingController createLectureAttendanceController =
      TextEditingController();

  Future<void> addRequest(
    List<String> imagaeUrl, {
    required String? senderId,
    required String request,
    required String State,
    required String stdToken,
    required String title,
  }) async {
    emit(AddRequestLoadingState());
    UserModel? um = Constants.userBox.get('user');
    String? grade = um!.grade;
    String id = FirebaseFirestore.instance
        .collection('Requests')
        .doc(grade)
        .collection('data')
        .doc()
        .id;
    debugPrint(grade);
    try {
      await FirebaseFirestore.instance
          .collection('Requests')
          .doc(grade)
          .collection('data')
          .doc(id)
          .set({
        'message': request,
        'receiver_id': '0000',
        'sender_id': senderId,
        'state': State,
        'id': id,
        'stdToken': stdToken,
        'imageurl': imagaeUrl,
        'date': DateTime.now().toString(),
        'grade': grade,
        'title': title,
      });
      getRequests();
      emit(AddRequestSuccessState());
    } catch (error) {
      emit(AddRequestErrorState());
      debugPrint('error');
      debugPrint(error.toString());
    }
  }
/*
  List<RequsetsModel> recentRequests = [];
  void getRecentRequests() {
    for (int i = 0; i < requests1.length; i++) {
      while (recentRequests.length <= 2) {
        if (requests1[i].state != 'ended') {
          recentRequests.add(requests1[i]);
        }
      }
    }
  }
  */

  Future<void> getRequests() async {
    debugPrint('ahmed');
    UserModel? um = Constants.userBox.get('user');
    requests1 = [];
    FirebaseFirestore.instance
        .collection('Requests')
        //  change to um.grade
        .doc(um!.grade!)
        .collection('data')
        //  change to um.code
        .where('sender_id', isEqualTo: um.code)
        .orderBy("date", descending: true)
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        requests1.add(RequsetsModel.fromJson(value.docs[i].data()));
      }
      filterRequests1 = requests1;
      debugPrint('$filterRequests1 Ahmed');

      // debugPrint(requests1);
      filteredRequests(choice);
      emit(PlatformGetRequestsSuccessState());
      debugPrint('Done');
    }).catchError((error) {
      //  emit(PlatformGetRequestsFailState(error.toString()));
      debugPrint(error.toString());
    });
  }

  void createChat(RequsetsModel request) {
    FirebaseFirestore.instance
        .collection('Requests')
        .doc(request.grade)
        .collection('data')
        .doc(request.id)
        .collection("Chat")
        .doc()
        .set({
          'type': false,
          'message': request.request,
          'id': request.senderId,
          'time': DateTime.now().toString()
        })
        .then((value) => emit(States()))
        .catchError((error) {
          debugPrint(error);
        });
  }

  Future<void> addMessage(
      ReqId, String? message, String id, String type, String? imagaeUrl) {
    UserModel um = Constants.userBox.get('user');
    emit(AddMessageLoadingState());
    FirebaseFirestore.instance
        .collection('Requests')
        .doc(um.grade)
        .collection('data')
        .doc(ReqId)
        .collection("Chat")
        .doc()
        .set({
      'message': message,
      'id': id,
      'time': DateTime.now(),
      "imagaeUrl": imagaeUrl,
      'type': type
    }).then((value) {
      //   chatController.clear;
      //  img = null;
      //  swap();
      // getChat(model);
    }).catchError((error) {
      debugPrint(error);
    });
    return Future(() => null);
  }

  void getChat(String requestId) {
    messages = [];
    UserModel um = Constants.userBox.get('user');
    FirebaseFirestore.instance
        .collection('Requests')
        .doc(um.grade)
        .collection('data')
        .doc(requestId)
        .collection("Chat")
        .orderBy('time')
        .snapshots()
        .listen((snapshot) {
      messages = snapshot.docs
          .map((doc) => ChatModel.fromJson(doc.data()))
          .toList()
          .reversed
          .toList();

      emit(States());
    });
  }

  List<File?> images = [];

  void pick(ImageSource source) async {
    final picker = ImagePicker();
    emit(ImageLoadingState());

    await picker.pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        // return await file.readAsBytes();
        images.add(File(value.path));
        emit(PickImageState());
      }
    });
  }

  File? img;
  void pickChatImage(ImageSource source) async {
    final picker = ImagePicker();
    emit(ImageLoadingState());
    await picker.pickImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        // return await file.readAsBytes();
        img = File(value.path);
        emit(PickImageState2());
      }
      debugPrint("Image Picked");
    });
  }

  String chatImageUrl = "";
  Future<String> uploadChatimage({
    required File? file,
    String? id,
  }) async {
    emit(UploadChatImageState());
    String url = '$id/${Uri.file(file!.path)}';
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('$id/${Uri.file(file.path).pathSegments.last}');
    TaskSnapshot snapShot = await ref.putFile(file);
    String downloadURL = await snapShot.ref.getDownloadURL();
    url = downloadURL;
    debugPrint("Url is $url");
    return url;
  }

  Future<String>? url;

  Future<List<String>> uplaodImage2({
    required List<File?> files,
  }) async {
    emit(AddRequestLoadingState());
    UserModel? um = Constants.userBox.get('user');
    List<String> urls = [];
    for (int i = 0; i < files.length; i++) {
      Reference ref = FirebaseStorage.instance.ref().child(
          'requests/${um!.grade}/${um.code!}/${Uri.file(files[i]!.path).pathSegments.last}');
      TaskSnapshot snapShot = await ref.putFile(files[i]!);
      String downloadURL = await snapShot.ref.getDownloadURL();
      urls.add(downloadURL);
    }

    return urls;
  }

  void filteredRequests(int filter) {
    if (filter == 0) {
      choice = 0;
      filterRequests1 = requests1;
      emit(PlatformChangeRequestFilterState());
    } else if (filter == 1) {
      choice = 1;

      filterRequests1 = [];
      for (int i = 0; i < requests1.length; i++) {
        if (requests1[i].state == "taken") {
          filterRequests1.add(requests1[i]);
        }
      }
      emit(PlatformChangeRequestFilterState());
    } else if (filter == 2) {
      choice = 2;

      filterRequests1 = [];

      for (int i = 0; i < requests1.length; i++) {
        if (requests1[i].state == "pending") {
          filterRequests1.add(requests1[i]);
        }
      }
      emit(PlatformChangeRequestFilterState());
    } else if (filter == 3) {
      choice = 3;

      filterRequests1 = [];
      for (int i = 0; i < requests1.length; i++) {
        if (requests1[i].state == "ended") {
          filterRequests1.add(requests1[i]);
        }
      }

      emit(PlatformChangeRequestFilterState());
    }
    debugPrint("done swapping");
  }

  int len = 10;
  void deleteImage(index) {
    images.removeAt(index);

    emit(DeleteImage());
  }

  Icon icon = Icon(
    Icons.add,
    size: 32.0,
    color: Colors.white,
  );
  bool down = false;

  void changing(context) {
    if (down) {
      down = false;
      icon = Icon(
        Icons.add,
        size: 32.0,
        color: Components.setTextColor(isDarkMode),
      );

      emit(ChangeIcon1State());
      images = [];
      requestController.clear();
      Navigator.pop(context);
    } else {
      down = true;
      icon = Icon(
        Icons.check,
        size: 32.0,
        color: Components.setTextColor(isDarkMode),
      );
      emit(ChangeIcon2State());
    }
  }

  Icon icon2 = Icon(
    Icons.add,
    size: 32.0,
    color: Colors.white,
  );
  bool down2 = false;

  void changing2(context) {
    if (down2) {
      down2 = false;
      icon2 = Icon(
        Icons.add,
        size: 32.0,
        color: Components.setTextColor(isDarkMode),
      );

      emit(ChangeIcon21State());
      Navigator.pop(context);
    } else {
      down2 = true;
      icon2 = Icon(
        Icons.check,
        size: 32.0,
        color: Components.setTextColor(isDarkMode),
      );
      emit(ChangeIcon22State());
    }
  }

  void resetDown2() {
    if (down2) {
      down2 = false;
      icon2 = Icon(
        Icons.add,
        size: 32.0,
        color: Components.setTextColor(isDarkMode),
      );
      emit(ChangeIcon21State());
    }
  }

/////////Change send icon
  bool isTyping = false;
  void ChangeSendIcon(String value) {
    isTyping = value.trim().isNotEmpty;

    emit(ChangeSendIconstate());
  }

/////////////////change img to null when sending message
  void swap() {
    img = null;
    emit(SwapState());
  }

  //////////////////////formate date
  String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd/hh:mm', 'en').format(dateTime);
  }

//////
  Map<String, List<String>> chapters = {};
  void getChapters() {
    chapters = {};
    emit(PlatformgetChaptersLoadingState());
    UserModel um = Constants.userBox.get('user');
    CollectionReference cr = FirebaseFirestore.instance
        .collection('data')
        .doc('questions_bank')
        .collection(um.grade!);

    cr.get().then((value) async {
      // Iterate over each chapter document
      for (int i = 0; i < value.docs.length; i++) {
        String chapterId = value.docs[i].id;
        // Initialize the list for the current chapter if not already initialized
        chapters.putIfAbsent(chapterId, () => []);

        // Fetch content sub-collection for the current chapter
        QuerySnapshot contentSnapshot =
            await cr.doc(chapterId).collection('content').get();

        // Iterate over each content document and add its ID to the chapter list
        for (int j = 0; j < contentSnapshot.docs.length; j++) {
          String contentId = contentSnapshot.docs[j].id;

          chapters[chapterId]!.add(contentId);
        }
      }
      emit(PlatformgetChaptersSuccessState());
    }).catchError((onError) {
      emit(PlatformgetChaptersFailState());
      debugPrint(onError.toString());
    });
  }

  void updateRequest2(String id, String newState) {
    UserModel um = Constants.userBox.get('user');
    FirebaseFirestore.instance
        .collection('Requests')
        .doc(um.grade)
        .collection('data')
        .doc(id)
        .update({"state": newState}).then((value) {
      debugPrint('wahba');
      // emit(PlatformUpdateRequestStatueState());
      getRequests();
    }).catchError((error) {
      debugPrint(error.toString());
      // emit(States());
    });
  }

  bool isExamTaken({required String lectureId, required quizCode}) {
    UserModel sm = Constants.userBox.get('user');
    return sm.stdQuizes?['$lectureId,$quizCode'] != null;
  }

  Future<void> sendNotification({
    required String userToken,
    required String title,
    required String body,
    String? imageUrl,
    required Map<String, String> dataPayload,
  }) async {
    var accessToken = await Components.getAccessToken();
    final String url =
        'https://fcm.googleapis.com/v1/projects/salahplatform/messages:send';

    final Map<String, dynamic> requestBody = {
      "message": {
        "token": userToken, // التوكن المستهدف
        "notification": {
          "title": title,
          "body": body,
          if (imageUrl != null && imageUrl.isNotEmpty) "image": imageUrl,
        },
        "data":
            dataPayload // هنا نضع الـ type والـ IDs التي يقرأها تطبيق الطالب
      }
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully!');
      } else {
        debugPrint('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  List<PostModel> posts = [];
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  bool isLoadingMore = false;
  int postsCount = SharedPrefHelper.getData('postsCount') ?? 0;
  Future<void> getPosts({bool loadMore = false}) async {
    if (isLoadingMore) return;
    isLoadingMore = true;

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('date', descending: true)
        .limit(15);

    if (loadMore && lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    query.get().then((value) {
      if (value.docs.isNotEmpty) {
        lastDocument = value.docs.last;

        if (loadMore) {
          posts.addAll(value.docs.map((e) => PostModel.fromMap(e.data())));
        } else {
          posts = value.docs.map((e) => PostModel.fromMap(e.data())).toList();
        }

        emit(PlatformGetPostsSuccessState());
      }
      isLoadingMore = false;
    }, onError: (error) {
      isLoadingMore = false;
      debugPrint(error.toString());
      emit(PlatformGetPostsFailState(error.toString()));
    });
  }

  Future<void> getPostsCount() async {
    await FirebaseFirestore.instance.collection('posts').get().then((value) {
      postsCount = value.docs.length;
    });
  }

  Future<void> removeLike({
    required String postId,
    required String code,
  }) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    await postRef.update({'likes.$code': FieldValue.delete()});
    emit(PlatformTogglePostLikeSuccessState());
  }

  Future<void> addLike({
    required String postId,
    required String code,
  }) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    await postRef.update({'likes.$code': DateTime.now()});
    emit(PlatformTogglePostLikeSuccessState());
  }

  Future<void> addComment({
    required String postId,
    required CommentModel cm,
    required String code,
  }) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    await postRef.update({
      'comments.$code': FieldValue.arrayUnion([
        cm.toMap(),
      ])
    });
    emit(PlatformTogglePostLikeSuccessState());
  }

  String commentVal = '';
  void changeCommentVal(String value) {
    commentVal = value;
    emit(PlatformChangeCommentValue());
  }

  Future<void> addPost() async {
    DocumentReference<Map<String, dynamic>> post =
        FirebaseFirestore.instance.collection('posts').doc();

    post.set(
      PostModel(
        id: post.id,
        comments: {},
        likes: {},
        text: 'تم الغاء حصة اليوم!',
        imageUrl:
            'https://firebasestorage.googleapis.com/v0/b/koraiemonlineplatform.appspot.com/o/notifications%2F2%2F1742098642976.jpg?alt=media&token=08cf212e-ff21-44e7-bd41-743ce5b331e9',
        date: DateTime.now(),
      ).toMap(),
    );
  }

  Map<String, CommentStdData> commentstds = {};

  Future<void> getCommentUsers(List<String> userIds) async {
    if (userIds.isEmpty) return;

    // استخدم 'where in' لو العدد ≤ 10 لتقليل عدد الاستعلامات
    if (userIds.length <= 10) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(Components.getGrade(userIds.first[0]))
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      commentstds = {
        for (var doc in querySnapshot.docs)
          doc.id: CommentStdData(
            imgUrl: doc.data()['img'] ?? '',
            name:
                '${doc.data()['ar_fname'] ?? ''} ${doc.data()['ar_sname'] ?? ''} ${doc.data()['ar_thname'] ?? ''}',
          ),
      };
    } else {
      // لو العدد أكثر من 10، استعلم كل مستخدم على حدة
      var futures = userIds.map((code) async {
        var std = await FirebaseFirestore.instance
            .collection('data')
            .doc('students')
            .collection(Components.getGrade(code[0]))
            .doc(code)
            .get();

        var data = std.data();
        if (data != null) {
          return MapEntry(
            code,
            CommentStdData(
              imgUrl: data['img'] ?? '',
              name:
                  '${data['ar_fname'] ?? ''} ${data['ar_sname'] ?? ''} ${data['ar_thname'] ?? ''}',
            ),
          );
        }
        return null; // تجاهل المستخدمين غير الموجودين
      });

      commentstds = Map.fromEntries((await Future.wait(futures))
          .whereType<MapEntry<String, CommentStdData>>());
    }
  }

  List<LikeStdData> likesUsers = [];

  Future<void> getLikesUsers(Map<String, DateTime> likes) async {
    if (likes.isEmpty) return;

    List<String> userIds = likes.keys.toList();

    if (userIds.length <= 10) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(Components.getGrade(userIds.first[0]))
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      likesUsers = querySnapshot.docs.map((doc) {
        var data = doc.data();
        return LikeStdData(
          imgUrl: data['img'] ?? '',
          name:
              '${data['ar_fname'] ?? ''} ${data['ar_sname'] ?? ''} ${data['ar_thname'] ?? ''}',
          date: likes[doc.id] ?? DateTime.now(), // استخدم تاريخ اللايك
        );
      }).toList();
    } else {
      var futures = userIds.map((code) async {
        var std = await FirebaseFirestore.instance
            .collection('data')
            .doc('students')
            .collection(Components.getGrade(code[0]))
            .doc(code)
            .get();

        var data = std.data();
        if (data != null) {
          return LikeStdData(
            imgUrl: data['img'] ?? '',
            name:
                '${data['ar_fname'] ?? ''} ${data['ar_sname'] ?? ''} ${data['ar_thname'] ?? ''}',
            date: likes[code] ?? DateTime.now(),
          );
        }
        return null;
      });

      likesUsers =
          (await Future.wait(futures)).whereType<LikeStdData>().toList();
    }

    // ترتيب البيانات بناءً على تاريخ اللايك من الأحدث إلى الأقدم
    likesUsers.sort((a, b) => b.date!.compareTo(a.date!));
  }

  List<PurchasesWidgetData> purchasedVideosList = [];
  Future<void> getPurchasedVideosList() async {
    UserModel um = Constants.userBox.get('user');

    if (um.purchasedVideos?.isEmpty ?? true) {
      purchasedVideosList = [];
      return;
    }

    // 1. Gather all active local purchases across chapters
    List<_LocalLectureSortWrapper> activePurchases = [];

    um.purchasedVideos?.forEach((chapId, chapterModel) {
      final lecturesMap = chapterModel.lectures;
      if (lecturesMap == null) return;

      lecturesMap.forEach((lecId, lectureModel) {
        int totalStdWatches = 0;
        int totalAvaWatches = 0;

        // Calculate watch totals safely from the internal nested map
        final videosMap = lectureModel.videos;
        if (videosMap != null) {
          for (var videoModel in videosMap.values) {
            totalStdWatches += videoModel.stdWatches ?? 0;
            totalAvaWatches += videoModel.avaWatches ?? 4;
          }
        }

        // Check if the student still has remaining watch counts left
        if (totalStdWatches < totalAvaWatches) {
          activePurchases.add(
            _LocalLectureSortWrapper(
                chapId: chapId,
                lecId: lecId,
                stdWatches: totalStdWatches,
                avaWatches: totalAvaWatches,
                purchaseDate: lectureModel.purchaseDateTime ?? DateTime.now()),
          );
        }
      });
    });

    // 2. Sort all eligible purchases by date (Newest First)
    activePurchases.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

    // 3. Take ONLY the latest 2 items to minimize Firestore reads
    final latestTwoPurchases = activePurchases.take(2).toList();
    if (latestTwoPurchases.isEmpty) {
      purchasedVideosList = [];
      return;
    }

    // 4. Fire parallel Firestore fetches for just those 2 specific lectures
    List<Future<void>> fetchTasks = [];
    List<PurchasesWidgetData?> orderedWidgets =
        List.filled(latestTwoPurchases.length, null);

    for (int i = 0; i < latestTwoPurchases.length; i++) {
      final purchase = latestTwoPurchases[i];

      fetchTasks.add(FirebaseFirestore.instance
          .collection('data')
          .doc('videos')
          .collection(um.grade!)
          .doc(purchase.chapId)
          .collection('lectures')
          .doc(purchase.lecId)
          .get()
          .then((lectureDoc) {
        if (lectureDoc.exists && lectureDoc.data() != null) {
          final data = lectureDoc.data()!;

          // Map incoming server properties to your UI widget class
          orderedWidgets[i] = PurchasesWidgetData(
            lectureImg: data['thumbnail'] ?? '',
            lectureTitle: data['title'] ?? 'No Title Available',
            lectureDep: data['dep'] ?? '',
            chapterId: purchase.chapId,
            lectureId: purchase.lecId,
            price: data['price'] ?? 0,
            stdWatches: purchase.stdWatches ?? 0,
            avaWatches: purchase.avaWatches ?? 0,
          );
        }
      }).catchError((error) {
        debugPrint(
            'Error fetching server metadata for lecture ${purchase.lecId}: $error');
      }));
    }

    try {
      // Resolve both network tasks at the same time
      await Future.wait(fetchTasks);

      // Filter out nulls in case a document was deleted or failed on the server
      purchasedVideosList =
          orderedWidgets.whereType<PurchasesWidgetData>().toList();

      emit(PlatformGetMyLecturesDataSuccessState());
    } catch (error) {
      debugPrint('Error building purchased widgets collection: $error');
    }
  }

/*
  Future<void> getPurchasedVideosList() async {
    UserModel um = Constants.userBox.get('user');

    final List<PurchasesWidgetData> result = [];

    um.purchasedVideos?.forEach((chapId, lectures) {
      lectures.forEach((lecId, videos) {
        VideoDetailsModel? recent;

        for (var video in recentVideosList) {
          if (video.lecId == lecId) {
            recent = video;
            break;
          }
        }

        if (recent != null) {
          int totalStdWatches = 0;
          int totalAvaWatches = 0;

          for (var video in videos) {
            totalStdWatches += video.stdWatches ?? 0;
            totalAvaWatches += video.avaWatches ?? 4;
          }

          if (totalStdWatches != totalAvaWatches) {
            result.add(
              PurchasesWidgetData(
                lectureImg: recent.thumbnail,
                lectureTitle: recent.title,
                lectureDep: recent.dep,
                chapterId: recent.chapId,
                lectureId: recent.lecId,
                price: recent.price,
                stdWatches: totalStdWatches,
                avaWatches: totalAvaWatches,
              ),
            );
          }
        }
      });
    });

    purchasedVideosList = result.take(2).toList();
  }
*/

  bool isShowRegister = false;
  bool isShowGuest = false;

  Future<void> getIsShowRegister() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('data')
          .doc('isShowRegister')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (Platform.isAndroid) {
          isShowRegister = data['isShowRegister2'] ?? false;
          isShowGuest = data['isShowGuest2'] ?? false;
        } else if (Platform.isIOS) {
          isShowRegister = data['isShowRegister3'] ?? false;
          isShowGuest = data['isShowGuest3'] ?? false;
        }
      }

      emit(PlatfomrRefreshState());
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  String cashPhoneNum = '';

  bool isWalletShowOnlinePayment = false;
  bool isExamShowOnlinePayment = false;
  bool isLectureShowOnlinePayment = false;

  void getIsShowOnlinePayment() {
    FirebaseFirestore.instance
        .collection('data')
        .doc('isShowOnlinePayment')
        .get()
        .then((value) {
      isWalletShowOnlinePayment =
          value.data()!['isWalletShowOnlinePayment'] ?? false;
      isExamShowOnlinePayment =
          value.data()!['isExamShowOnlinePayment'] ?? false;
      isLectureShowOnlinePayment =
          value.data()!['isLectureShowOnlinePayment'] ?? false;
      emit(PlatfomrRefreshState());
    }).catchError((error) {
      debugPrint("Error fetching isShowOnlinePayment: $error");
      isWalletShowOnlinePayment = false;
      isExamShowOnlinePayment = false;
      isLectureShowOnlinePayment = false;
    });
  }

  void getCashPhoneNum() {
    FirebaseFirestore.instance
        .collection('phoneNums')
        .doc('cash')
        .get()
        .then((value) {
      cashPhoneNum = value.data()!['phone'] ?? '';
      emit(PlatfomrRefreshState());
    }).catchError((error) {
      debugPrint("Error fetching cash phone number: $error");
      cashPhoneNum = '';
    });
  }

  // ===========================================================================
  // Fawaterk online payment
  // ===========================================================================

  /// Re-reads the current balance from Firestore into the local user box.
  /// Call after a successful online wallet recharge (the backend credits the
  /// balance on the gateway callback; this pulls the fresh value).
  Future<void> refreshBalance() async {
    try {
      final UserModel um = Constants.userBox.get('user');
      final doc = await FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(um.grade!)
          .doc(um.code!)
          .get();
      final bal = doc.data()?['balance'];
      if (bal is num) {
        um.balance = bal.toInt();
        await um.save();
      }
      emit(PlatfomrRefreshState());
    } catch (e) {
      debugPrint('refreshBalance error: $e');
    }
  }

  /// Fetches the list of available payment methods from Fawaterk.
  /// Returns `null` on any failure so the UI can show an error.
  Future<List<PaymentData>?> fetchPaymentMethods() async {
    const apiUrl =
        'https://kareempaymentbackend-production.up.railway.app/api/payments/methods';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      final responseData = json.decode(response.body);
      final paymentMethods = PaymentModel.fromJson(responseData);
      if (paymentMethods.status != 'success') return null;
      return paymentMethods.paymentData ?? [];
    } catch (error) {
      debugPrint('fetchPaymentMethods error: $error');
      return null;
    }
  }

  /// Initialises a Fawaterk invoice for the chosen [paymentId].
  ///
  /// Returns a [PaymentInitResult] holding either a redirect url (Card/Visa) or
  /// a Fawry reference code, or `null` if the request failed.
  Future<PaymentInitResult?> sendPaymentRequest({
    required int paymentId,
    required bool redirectOption,
    required num amount,
    required String itemName,
    String? lecId,
    String? chapId,
    String? quizId,
  }) async {
    debugPrint('$paymentId $amount $itemName');
    const apiUrl =
        'https://kareempaymentbackend-production.up.railway.app/api/payments/send';
    UserModel um = Constants.userBox.get('user');

    final requestData = {
      'payment_method_id': paymentId,
      'lectureId': lecId,
      'chapterId': chapId,
      'quizId': quizId,
      'userId': um.code,
      'title': itemName,
      'price': '$amount',
      'grade': um.grade,
      'customer': {
        'first_name': um.ar_fname,
        'last_name': '${um.ar_sname} ${um.ar_thname}',
        'phone': um.phoneNum
      },
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );
      final responseData = json.decode(response.body);
      debugPrint(json.encode(responseData));

      final result = PaymentInitResult.fromJson(responseData);
      debugPrint('resultttt: ${responseData.toString()}');
      if (result.isSuccess) {
        resetLocalData(
          status: 'pending',
          lecId: lecId,
          chapId: chapId,
          quizId: quizId,
          itemName: itemName,
        );
        return result;
      }
      return null;
    } catch (error) {
      debugPrint('sendPaymentRequest error: $error');
      return null;
    }
  }

  void resetLocalData({
    required String status,
    String? lecId,
    String? chapId,
    String? quizId,
    required String itemName,
  }) async {
    UserModel um = Constants.userBox.get('user');

    final now = DateTime.now();

    if (chapId != null) {
      // 1. Ensure the parent map exists
      um.purchasedVideos ??= {};

      // 2. Safely fetch or initialize the chapter object
      final chapter =
          um.purchasedVideos![chapId] ??= UserPurchasedChapterModel();

      if (lecId != null) {
        // 3. Ensure the nested lectures map exists
        chapter.lectures ??= {};

        // 4. Safely fetch or initialize the lecture object inside it
        final lecture =
            chapter.lectures![lecId] ??= UserPurchasedLectureModel();

        // 5. Update the lecture fields
        lecture.status = status;
        lecture.purchaseDateTime = now;
      } else {
        // 6. Chapter-Only Update
        chapter.status = status;
        chapter.purchaseDateTime = now;
      }
    } else if (quizId != null) {
      // Ensure quizzes map exists
      um.stdQuizes ??= {};

      // Direct initialization replaces redundant lookups
      um.stdQuizes![quizId] = StdQuizModel(
        id: '',
        title: itemName,
        dateTime: now, // Replaced duplicate DateTime.now() with cached 'now'
        fullMark: 0,
        questionNums: 0,
        degree: 0,
        triesNum: 1,
        userAnsIdx: {},
        submitTime: null,
        status: status,
        purchaseDateTime: now,
      );
    } else {
      // Wallet Only Update
      um.walletBalanceStatus = status;
      um.lastwalletBalanceTransaction = now;
    }

    await um.save();
    emit(PlatfomrRefreshState());
  }

  static const int invoicesPageSize = 5;
  List<InvoiceModel> allInvoices = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastInvoiceDoc;
  bool hasMoreInvoices = true;
  bool isLoadingMoreInvoices = false;

  Query<Map<String, dynamic>> _invoicesQuery() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: Constants.userBox.get('user').code)
        .orderBy('createdAt', descending: true)
        .limit(invoicesPageSize);
  }

  /// First page (also used for pull-to-refresh). Resets the cursor.
  Future<void> getAllInvoices() async {
    emit(PlatfromGetAllInvoicesLoadingState());
    _lastInvoiceDoc = null;
    hasMoreInvoices = true;
    isLoadingMoreInvoices = false;
    try {
      final value = await _invoicesQuery().get();
      allInvoices =
          value.docs.map((doc) => InvoiceModel.fromJson(doc.data())).toList();
      _lastInvoiceDoc = value.docs.isNotEmpty ? value.docs.last : null;
      hasMoreInvoices = value.docs.length == invoicesPageSize;
      emit(PlatfromGetAllInvoicesSuccessState());
    } catch (error) {
      debugPrint('Error fetching invoices: $error');
      emit(PlatfromGetAllInvoicesFailState(error.toString()));
    }
  }

  /// Loads the next page when the user scrolls to the bottom.
  Future<void> getMoreInvoices() async {
    if (isLoadingMoreInvoices || !hasMoreInvoices || _lastInvoiceDoc == null) {
      return;
    }
    isLoadingMoreInvoices = true;
    emit(PlatfromGetMoreInvoicesLoadingState());
    try {
      final value =
          await _invoicesQuery().startAfterDocument(_lastInvoiceDoc!).get();
      allInvoices
          .addAll(value.docs.map((doc) => InvoiceModel.fromJson(doc.data())));
      if (value.docs.isNotEmpty) _lastInvoiceDoc = value.docs.last;
      hasMoreInvoices = value.docs.length == invoicesPageSize;
      isLoadingMoreInvoices = false;
      emit(PlatfromGetMoreInvoicesSuccessState());
    } catch (error) {
      debugPrint('Error fetching more invoices: $error');
      isLoadingMoreInvoices = false;
      emit(PlatfromGetMoreInvoicesFailState(error.toString()));
    }
  }
}
