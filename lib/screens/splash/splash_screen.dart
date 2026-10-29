// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:upgrader/upgrader.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/layout/home_layout.dart';
import 'package:salah_online_platform/models/user_model.dart';
import 'package:salah_online_platform/services/notification_service.dart';
import 'package:salah_online_platform/screens/auth_screens/login_screens/login_page.dart';
import 'package:salah_online_platform/screens/main/error_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({
    super.key,
    required this.cubit,
  });

  PlatformCubit cubit;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // final _updater = ShorebirdUpdater();
  final bool _isUpdating = false;

  late final AnimationController _logoController;
  late final Animation<double> _logoFade;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _logoController.forward();

    /*
    if (Platform.isWindows) {
      _checkForUpdate();
    } else {
      */
    _initializeApp();
    //   }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

/*
  Future<void> _checkForUpdate() async {
    try {
      final status = await _updater.checkForUpdate(track: UpdateTrack.stable);

      if (status == UpdateStatus.outdated) {
        // فيه تحديث
        setState(() => _isUpdating = true);

        try {
          await _updater.update(track: UpdateTrack.stable);

          // بعد التحديث مباشرة نعمل Restart
          Restart.restartApp();
        } catch (e) {
          debugPrint('Error in update(): $e');
          _initializeApp();
        }
      } else {
        // الحالة: upToDate أو غير مدعوم
        _initializeApp();
      }
    } catch (e) {
      debugPrint('Error in checkForUpdate: $e');
      _initializeApp();
    }
  }
*/
  Future<void> _initializeApp() async {
    Future.delayed(const Duration(milliseconds: 3800)).then((value) {
      if (Constants.userBox.isEmpty) {
        Components.pushReplacement(
          context: context,
          widget: UpgradeAlert(
            barrierDismissible: false,
            showIgnore: false,
            showLater: false,
            child: LoginPage(),
          ),
        );
      } else {
        UserModel sm = Constants.userBox.get('user');

        if (sm.img == null || sm.img!.isEmpty) {
          Components.pushReplacement(
            context: context,
            widget: UpgradeAlert(
              barrierDismissible: false,
              showIgnore: false,
              showLater: false,
              child: LoginPage(),
            ),
          );
        } else {
          if ((sm.enabled == null || sm.enabled == true) &&
              (sm.isActive == null || sm.isActive == true)) {
            Components.pushAndRemoveAll(
              context: context,
              name: Components.homeRouteName,
              widget: UpgradeAlert(
                barrierDismissible: false,
                showIgnore: false,
                showLater: false,
                child: HomeLayout(
                  cubit: widget.cubit,
                  isFirstTime: true,
                  pageController: PageController(initialPage: 0),
                ),
              ),
            );

            // إذا فُتح التطبيق من إشعار (والتطبيق كان مغلقًا) — افتح الشاشة
            // المطلوبة فوق HomeLayout بعد التوجيه إليه، حتى يعود زر الرجوع للـ Home.
            final pending = NotificationService.consumePendingInitialMessage();
            if (pending != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                NotificationService.handleNotificationNavigation(pending);
              });
            }
          } else {
            Components.pushReplacement(
              context: context,
              widget: UpgradeAlert(
                barrierDismissible: false,
                showIgnore: false,
                showLater: false,
                child: ErrorScreen(
                  cubit: widget.cubit,
                  status: sm.enabled == false
                      ? Constants.accountBlocked
                      : Constants.accountPending,
                ),
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isUpdating) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Updating..."),
              SizedBox(height: 16),
              CircularProgressIndicator(
                color: AppColors.appPurblePrimaryColor,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: BlocBuilder<PlatformCubit, PlatformStates>(
        builder: (context, state) {
          return Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Center(
                child: Image(
                  image: AssetImage(
                    PlatformCubit.get(context).isDarkMode
                        ? 'assets/splash/logo_dark.gif'
                        : 'assets/splash/logo_light.gif',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Opacity(
                  opacity: 0.6,
                  child: Image(
                    width: 105.0,
                    height: 105.0,
                    fit: BoxFit.contain,
                    image: AssetImage(
                      PlatformCubit.get(context).isDarkMode
                          ? 'assets/splash/cod_logo_light.png'
                          : 'assets/splash/cod_logo_black.png',
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
