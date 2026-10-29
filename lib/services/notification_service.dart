import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/models/user_model.dart';
import 'package:salah_online_platform/screens/main/chat_screen.dart';
import 'package:salah_online_platform/screens/main/lectures_details_details_screen.dart';
import 'package:salah_online_platform/screens/main/posts/posts_screen.dart';

import '../firebase_options.dart';

/// مفتاح التنقل العام لاستخدامه عند الضغط على الإشعار.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// قناة الإشعارات عالية الأهمية (Android 8.0+).
/// لاحظ: نفس الـ id يُستخدم في الـ AndroidManifest كقناة افتراضية
/// لإشعارات FCM التي تصل والتطبيق مغلق/في الخلفية.
const AndroidNotificationChannel kHighImportanceChannel =
    AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// معالج الرسائل في الخلفية / والتطبيق مغلق تمامًا.
///
/// يجب أن تكون دالة من المستوى الأعلى ومُعلّمة بـ [pragma] حتى لا يحذفها
/// الـ tree-shaking في وضع الـ release (تعمل في isolate منفصل).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // لازم تهيئة Firebase داخل الـ isolate المنفصل قبل أي استخدام.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Background/terminated message received: ${message.messageId}');

  // إذا كانت الرسالة تحتوي على notification payload فإن نظام التشغيل
  // (Android/iOS) يعرض الإشعار تلقائيًا في الخلفية/الإغلاق، لذلك لا نعرضه
  // مرة أخرى يدويًا حتى لا يتكرر الإشعار.
  // نعرض يدويًا فقط في حالة رسائل البيانات (data-only) على Android.
  if (Platform.isAndroid &&
      message.notification == null &&
      message.data.isNotEmpty) {
    await NotificationService._ensureLocalNotificationsInitialized();
    await NotificationService._showLocalNotification(message);
  }
}

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _localInitialized = false;

  /// رسالة الإشعار التي فُتح بها التطبيق من حالة الإغلاق التام (terminated).
  /// تنتظر شاشة البداية (Splash) لتفتح الشاشة المطلوبة بعد التوجيه للـ Home.
  static RemoteMessage? _pendingInitialMessage;

  /// تُرجِع الرسالة المعلّقة (إن وُجدت) وتمسحها حتى لا تُستهلك مرتين.
  static RemoteMessage? consumePendingInitialMessage() {
    final RemoteMessage? message = _pendingInitialMessage;
    _pendingInitialMessage = null;
    return message;
  }

  /// نقطة دخول عامة للتنقّل بناءً على رسالة إشعار (تستدعيها شاشة البداية).
  static void handleNotificationNavigation(RemoteMessage message) =>
      _handleMessageOpened(message);

  /// التهيئة الكاملة — تُستدعى مرة واحدة عند بدء التطبيق (بعد Firebase.initializeApp).
  static Future<void> initialize() async {
    // 1) سجّل معالج الخلفية أولًا.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2) هيّئ الإشعارات المحلية + أنشئ القناة.
    await _ensureLocalNotificationsInitialized();

    // 3) اطلب الأذونات (iOS + Android 13+).
    await _requestPermissions();

    // 4) على iOS: اترك النظام يعرض الإشعار في المقدمة (alert/badge/sound).
    //    هذا يتجنب تعارض الـ UNUserNotificationCenter delegate مع
    //    firebase_messaging، فلا نعرض إشعارًا محليًا على iOS.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5) رسائل المقدمة → على Android نعرضها كإشعار محلي (لأن النظام لا يعرضها
    //    تلقائيًا في المقدمة). على iOS يعرضها النظام عبر الخطوة (4).
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (Platform.isAndroid &&
          (message.notification != null || message.data.isNotEmpty)) {
        _showLocalNotification(message);
      }
    });

    // 6) الضغط على الإشعار والتطبيق في الخلفية (وليس مغلقًا) → تنقّل فورًا
    //    لأن التطبيق يعمل بالفعل ولا يمرّ على شاشة البداية (Splash).
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // 7) الضغط على الإشعار والتطبيق كان مغلقًا تمامًا (terminated):
    //    لا ننتقل الآن — نخزّن الرسالة كـ "معلّقة" حتى تنتهي شاشة البداية من
    //    التوجيه إلى HomeLayout ثم تفتح الشاشة المطلوبة فوقها (حتى يعود زر الرجوع
    //    إلى الـ Home بدلاً من أن تستبدلها شاشة البداية).
    _pendingInitialMessage = await _messaging.getInitialMessage();

    // 8) راقب تحديث الـ token وحدّثه في Firestore.
    _messaging.onTokenRefresh.listen(updateTokenInFirestore);
  }

  /// طلب أذونات الإشعارات.
  static Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android 13+ يتطلب طلب إذن POST_NOTIFICATIONS صراحةً.
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// تهيئة plugin الإشعارات المحلية + إنشاء القناة (يُستدعى في الـ isolate
  /// الرئيسي وكذلك في isolate الخلفية عند الحاجة).
  static Future<void> _ensureLocalNotificationsInitialized() async {
    if (_localInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
      onDidReceiveBackgroundNotificationResponse:
          _onLocalNotificationBackgroundTap,
    );

    // أنشئ القناة على Android (لإشعارات النظام التلقائية أيضًا).
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(kHighImportanceChannel);

    _localInitialized = true;
  }

  /// عرض إشعار محلي من رسالة FCM (يُستخدم للمقدمة وللبيانات فقط).
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    final String title =
        notification?.title ?? message.data['title'] ?? 'إشعار جديد';
    final String body = notification?.body ?? message.data['body'] ?? '';
    final String? imageUrl = notification?.android?.imageUrl ??
        notification?.apple?.imageUrl ??
        message.data['image'];

    // حمّل الصورة (إن وُجدت) لعرض إشعار بصورة كبيرة.
    final Uint8List? imageBytes = await _downloadImage(imageUrl);

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      kHighImportanceChannel.id,
      kHighImportanceChannel.name,
      channelDescription: kHighImportanceChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      // الأيقونة الصغيرة (status bar) يجب أن تكون silhouette أبيض شفاف،
      // وإلا تظهر مربعًا أبيض. نستخدم ic_notification المخصصة.
      icon: '@drawable/ic_notification',

      color: AppColors.appPrimaryColor,
      // الأيقونة الكبيرة الملوّنة (شعار التطبيق) تظهر بجانب الإشعار.
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: imageBytes != null
          ? BigPictureStyleInformation(
              ByteArrayAndroidBitmap(imageBytes),
              hideExpandedLargeIcon: true,
              contentTitle: title,
              summaryText: body,
            )
          : null,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
      payload: _encodePayload(message),
    );
  }

  /// تنزيل صورة الإشعار بأمان (يرجع null عند الفشل).
  static Future<Uint8List?> _downloadImage(String? url) async {
    if (url == null || url.isEmpty) return null;
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint('Failed to download notification image: $e');
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // إدارة الـ Token
  // ---------------------------------------------------------------------------

  /// ينتظر توفّر الـ APNs token على iOS/macOS قبل تنفيذ أي عملية FCM
  /// (getToken / subscribeToTopic ...) لأنها تفشل بخطأ
  /// [firebase_messaging/apns-token-not-set] إن استُدعيت قبل وصول الـ token.
  /// يرجع true إن كان جاهزًا (أو على منصّة لا تحتاجه)، وإلا false.
  static Future<bool> ensureApnsToken({int maxRetries = 2}) async {
    if (!(Platform.isIOS || Platform.isMacOS)) return true;
    try {
      String? apnsToken = await _messaging.getAPNSToken();
      int retries = 0;
      while (apnsToken == null && retries < maxRetries) {
        await Future.delayed(const Duration(seconds: 1));
        apnsToken = await _messaging.getAPNSToken();
        retries++;
      }
      if (apnsToken == null) {
        debugPrint(
            'APNs token غير متوفّر بعد — سيُؤجَّل حفظ الـ token/الاشتراك بالمواضيع.');
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('ensureApnsToken error: $e');
      return false;
    }
  }

  /// جلب الـ FCM token الحالي.
  static Future<String?> getToken() async {
    try {
      // على iOS لا يتوفّر الـ FCM token قبل أن يصل الـ APNs token من النظام،
      // وإلا فإن getToken() يرجع null. لذلك ننتظر توفّره أولًا مع إعادة محاولة.
      if (!await ensureApnsToken()) return null;
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      return null;
    }
  }

  /// حفظ الـ pushToken لطالب محدّد في Firestore (يُستخدم عند تسجيل الدخول/الإنشاء).
  /// يرجع الـ token الذي تم حفظه (أو null إن لم يتوفّر).
  static Future<String?> saveTokenForUser({
    required String grade,
    required String code,
    String? currentToken,
  }) async {
    if (Platform.isWindows) return null;
    final String? newToken = await getToken();
    if (newToken == null || newToken.isEmpty) return null;
    if (newToken == currentToken) return newToken;
    try {
      await FirebaseFirestore.instance
          .collection('data')
          .doc('students')
          .collection(grade)
          .doc(code)
          .update({'pushToken': newToken});
    } catch (e) {
      debugPrint('Failed to save pushToken for $code: $e');
    }
    return newToken;
  }

  /// تحديث الـ token الخاص بالطالب الحالي في Firestore.
  /// يستخدمه listener تحديث الـ token تلقائيًا.
  static void Function(String token)? onTokenRefreshCallback;

  static Future<void> updateTokenInFirestore(String token) async {
    debugPrint('FCM token refreshed: $token');
    onTokenRefreshCallback?.call(token);
  }

  // ---------------------------------------------------------------------------
  // التعامل مع الضغط على الإشعار
  // ---------------------------------------------------------------------------

  static void _onLocalNotificationTap(NotificationResponse response) {
    final RemoteMessage? message = _decodePayload(response.payload);
    if (message != null) {
      _handleMessageOpened(message);
    }
  }

  @pragma('vm:entry-point')
  static void _onLocalNotificationBackgroundTap(NotificationResponse response) {
    // عند الضغط على إشعار محلي والتطبيق مغلق — يُفتح التطبيق ويُعالَج التنقل
    // عبر getInitialMessage في initialize().
    debugPrint('Local notification tapped (background): ${response.payload}');
  }

  /// نقطة موحّدة لمعالجة فتح الإشعار — أضف منطق التنقل حسب بيانات الرسالة هنا.
  static void _handleMessageOpened(RemoteMessage message) {
    debugPrint('Notification opened with data: ${message.data}');
    final data = message.data;
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    switch (data['type']) {
      case 'lecture':
        // تأكد من توفّر البيانات المطلوبة قبل التنقّل.
        if (data['chapId'] == null || data['lecId'] == null) return;
        navigator.push(MaterialPageRoute(
          builder: (context) => LectureDetailsDetailsScreen(
            price: int.tryParse(data['price'] ?? '') ?? 0,
            thumbnail: data['thumbnail'] ?? '',
            title: data['title'] ?? '',
            chapId: data['chapId']!,
            lecId: data['lecId']!,
            dep: data['dep'] == 'true',
          ),
        ));
        break;
      case 'exam':
        PlatformCubit.get(navigator.context).navigateToHomeTab(2);
        break;
      case 'request':
        navigator.push(MaterialPageRoute(
          builder: (context) => ChatScreen(
            requestId: data['id'],
            requestTitle: data['title'],
            requestState: data['state'],
            token: data['token'],
          ),
        ));
        break;
      case 'post':
        navigator.push(MaterialPageRoute(
          builder: (context) => PostsScreen(),
        ));
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // ترميز/فك ترميز الـ payload (نخزّن الـ data فقط).
  // ---------------------------------------------------------------------------

  static String _encodePayload(RemoteMessage message) {
    final Map<String, dynamic> data = {
      'title': message.notification?.title,
      'body': message.notification?.body,
      ...message.data,
    };
    return data.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}=${e.value}')
        .join('&');
  }

  static RemoteMessage? _decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    final Map<String, String> data = {};
    for (final part in payload.split('&')) {
      final idx = part.indexOf('=');
      if (idx > 0) {
        data[part.substring(0, idx)] = part.substring(idx + 1);
      }
    }
    return RemoteMessage(data: data);
  }

  static Future<void> manageUserTopics({String? oldGroupId}) async {
    if (Platform.isWindows) return;

    // على iOS يفشل subscribeToTopic بخطأ [firebase_messaging/apns-token-not-set]
    // إن استُدعي قبل وصول الـ APNs token. ننتظر توفّره أولًا، وإن لم يصل نتجاوز
    // (سيُعاد ضبط المواضيع لاحقًا عبر setLocalData عند توفّر الـ token).
    if (!await NotificationService.ensureApnsToken()) {
      debugPrint('manageUserTopics: APNs token not ready yet — skipping.');
      return;
    }

    try {
      UserModel um = Constants.userBox.get('user');

      String enhGroupId = um.groupId!.isEmpty ? 'online' : um.groupId!;
      debugPrint('enhGroupId: $enhGroupId');

      if (oldGroupId != null) {
        String enhOldGroupId = oldGroupId.isEmpty ? 'online' : oldGroupId;

        //remove previous group's topic
        if (enhOldGroupId != enhGroupId) {
          debugPrint('unsubscribeFromTopic ${um.grade}_$enhOldGroupId');
          debugPrint(
              'unsubscribeFromTopic ${um.grade}_${enhOldGroupId == 'online' ? 'online' : 'center'}_lectures');

          await FirebaseMessaging.instance
              .unsubscribeFromTopic('${um.grade}_$enhOldGroupId');
          await FirebaseMessaging.instance.unsubscribeFromTopic(
              '${um.grade}_${enhOldGroupId == 'online' ? 'online' : 'center'}_lectures');
        }
      }

      //add new group's topic
      await FirebaseMessaging.instance.subscribeToTopic(um.grade!);
      await FirebaseMessaging.instance
          .subscribeToTopic('${um.grade}_$enhGroupId');
      await FirebaseMessaging.instance.subscribeToTopic(
          '${um.grade}_${enhGroupId == 'online' ? 'online' : 'center'}_lectures');
      debugPrint('added');
    } catch (e) {
      debugPrint('manageUserTopics error: $e');
    }
  }

  /// إلغاء الاشتراك في مواضيع المستخدم (يُستدعى عند تسجيل الخروج).
  ///
  /// يستقبل [grade] و[groupId] كوسيطات بدلًا من قراءتهما من [Constants.userBox]
  /// لأن نموذج المستخدم يُحذف فورًا عند تسجيل الخروج؛ فلو قرأناه هنا (بعد انتظار
  /// APNs token) لوجدناه null. المُستدعي يُمرّر القيم قبل الحذف ولا ينتظر انتهاء
  /// هذه الدالة (fire-and-forget) حتى لا يتأخّر تسجيل الخروج.
  static Future<void> removeUserTopics({
    required String? grade,
    required String? groupId,
  }) async {
    if (Platform.isWindows) return;
    if (grade == null || grade.isEmpty) return;
    if (!await NotificationService.ensureApnsToken()) {
      debugPrint('removeUserTopics: APNs token not ready yet — skipping.');
      return;
    }

    try {
      String enhGroupId =
          (groupId == null || groupId.isEmpty) ? 'online' : groupId;

      await FirebaseMessaging.instance.unsubscribeFromTopic(grade);
      await FirebaseMessaging.instance
          .unsubscribeFromTopic('${grade}_$enhGroupId');
      await FirebaseMessaging.instance.unsubscribeFromTopic(
          '${grade}_${enhGroupId == 'online' ? 'online' : 'center'}_lectures');
    } catch (e) {
      debugPrint('removeUserTopics error: $e');
    }
  }

  static Future<void> sendToTopic({
    required String topic,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? dataPayload,
  }) async {
    // 1. Get your OAuth2 access token
    final accessToken = await Components.getAccessToken();

    final String url =
        'https://fcm.googleapis.com/v1/projects/salahplatform/messages:send';

    // 3. Construct the request body using "topic" instead of "token"
    final Map<String, dynamic> requestBody = {
      "message": {
        "topic": topic, // This targets the topic
        "notification": {
          "title": title,
          "body": body,
          if (imageUrl != null && imageUrl.isNotEmpty) "image": imageUrl,
        },
        // Ensure data is sent even if null (as an empty map)
        "data": dataPayload ?? {},
      }
    };

    // 4. Send the POST request
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
        debugPrint('Successfully sent message to topic: $topic');
      } else {
        debugPrint(
            'Failed to send to topic. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending topic notification: $e');
    }
  }
}
