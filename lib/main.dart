import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:salah_online_platform/screens/splash/splash_screen.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:ffi/ffi.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/models/std_quiz_model.dart';
import 'package:salah_online_platform/models/user_model.dart';
import 'package:salah_online_platform/models/user_purchased_chapter_model.dart';
import 'package:salah_online_platform/network/local/shared_pref_helper.dart';
import 'package:salah_online_platform/services/notification_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:window_size/window_size.dart';
import 'firebase_options.dart';

import 'models/user_purchase_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    setWindowTitle('بِالْعَرَبِيّ');

    // الحصول على معلومات الشاشة
    final display = await screenRetriever.getPrimaryDisplay();
    final screenWidth = display.size.width;
    final screenHeight = display.size.height;

    // تحديد حجم النافذة: العرض ثلث الشاشة، الطول طول الشاشة
    final windowWidth = screenWidth / 3;
    final windowHeight = screenHeight + 200.0;

    // تعيين حجم النافذة وموضعها
    setWindowFrame(Rect.fromLTWH(
      (screenWidth) / 2,
      0,
      //screenHeight / 7, // وضع النافذة في الأعلى
      windowWidth,
      windowHeight,
    ));

    // منع تغيير حجم النافذة
    setWindowMinSize(ui.Size(windowWidth, windowHeight));
    //  setWindowMaxSize(ui.Size(windowWidth + 100, windowHeight + 150));

    preventScreenRecording();
  }

  await SharedPrefHelper.initSharedPref();

  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(UserPurchasedModelAdapter());
  Hive.registerAdapter(StdQuizModelAdapter());
  Hive.registerAdapter(UserPurchasedChapterModelAdapter());
  Hive.registerAdapter(UserPurchasedLectureModelAdapter());

  try {
    Constants.userBox = await Hive.openBox<UserModel>('userBox');
  } catch (e) {
    debugPrint(
        "Failed to open Hive userBox, deleting from disk and retrying: $e");
    try {
      await Hive.deleteBoxFromDisk('userBox');
      Constants.userBox = await Hive.openBox<UserModel>('userBox');
    } catch (e2) {
      debugPrint("Failed to open Hive userBox after deletion: $e2");
      Constants.userBox = await Hive.openBox('userBox');
    }
  }
  timeago.setLocaleMessages('ar', timeago.ArMessages()); // Add french messages

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تهيئة إشعارات FCM الكاملة (المقدمة/الخلفية/التطبيق مغلق) على الموبايل فقط.
  if (!Platform.isWindows) {
    await NotificationService.initialize();
  }

  runApp(const MyApp());
}

typedef SetWindowDisplayAffinityC = Int32 Function(
    IntPtr hWnd, Uint32 dwAffinity);
typedef SetWindowDisplayAffinityDart = int Function(int hWnd, int dwAffinity);

void preventScreenRecording() {
  final user32 = DynamicLibrary.open('user32.dll');
  final findWindow = user32.lookupFunction<
      IntPtr Function(Pointer<Utf16>, Pointer<Utf16>),
      int Function(Pointer<Utf16>, Pointer<Utf16>)>('FindWindowW');
  final setWindowDisplayAffinity = user32.lookupFunction<
      SetWindowDisplayAffinityC,
      SetWindowDisplayAffinityDart>('SetWindowDisplayAffinity');

  final windowName = 'بِالْعَرَبِيّ'.toNativeUtf16();
  final hWnd = findWindow(nullptr, windowName);

  if (hWnd != 0) {
    const wdaExcludefromcapture = 0x00000011; // هذا يمنع التسجيل
    setWindowDisplayAffinity(hWnd, wdaExcludefromcapture);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlatformCubit(),
      child: BlocBuilder<PlatformCubit, PlatformStates>(
        builder: (context, state) {
          var cubit = PlatformCubit.get(context);

          return MaterialApp(
            navigatorKey: navigatorKey,
            locale: cubit.isAr ? const Locale('ar') : const Locale('en'),
            themeMode: cubit.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            debugShowCheckedModeBanner: false,
            home: SplashScreen(cubit: cubit),
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: cubit.isAr ? 'Cairo' : 'Roboto',
              colorSchemeSeed: AppColors.appPrimaryColor,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.white,
                  statusBarIconBrightness: Brightness.dark,
                ),
              ),
            ),
            darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
              scaffoldBackgroundColor: Colors.black,
              textTheme: Typography()
                  .white
                  .apply(fontFamily: cubit.isAr ? 'Cairo' : 'Roboto'),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.black,
                  statusBarIconBrightness: Brightness.light,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
