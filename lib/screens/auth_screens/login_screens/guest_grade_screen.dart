import 'package:salah_online_platform/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/layout/home_layout.dart';
import 'package:salah_online_platform/models/user_model.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_cubit.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/auth_buttons.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/option_card.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

class GuestGradeScreen extends StatefulWidget {
  const GuestGradeScreen({super.key});

  @override
  State<GuestGradeScreen> createState() => _GuestGradeScreenState();
}

class _GuestGradeScreenState extends State<GuestGradeScreen> {
  StudyGrade? _grade;
  bool _isLoading = false;

  Future<void> _continueAsGuest({
    required PlatformCubit cubit,
    required bool isAr,
  }) async {
    FocusScope.of(context).unfocus();

    if (_grade == null) {
      AppStatusDialog.show(
        context: context,
        status: AppDialogStatus.warning,
        title: isAr ? 'تنبيه' : 'Notice',
        message:
            isAr ? 'برجاء اختيار الصف الدراسي' : 'Please select your grade',
        isAr: isAr,
      );
      return;
    }

    setState(() => _isLoading = true);

    final guestUser = UserModel(
      ar_fname: isAr ? 'ضيف' : 'Guest',
      ar_sname: '',
      ar_thname: '',
      fname: 'Guest',
      sname: '',
      thname: '',
      code: Constants.guest,
      grade: _grade!.name,
      phoneNum: '',
      parentPhoneNum: '',
      img: Constants.img,
      balance: 0,
      password: '',
      purchasedVideos: {},
      purchasedPdfs: {},
      stdQuizes: {},
      groupId: '',
      groupName: 'Online',
      enabled: true,
      isActive: true,
      pushToken: '',
      gender: '',
      createdAt: DateTime.now(),
    );

    await Constants.userBox.put('user', guestUser);
    cubit.isShowDelAccount();
    if (!mounted) return;

    Components.pushAndRemoveAll(
      context: context,
      name: Components.homeRouteName,
      widget: HomeLayout(
        cubit: cubit,
        isFirstTime: true,
        pageController: PageController(initialPage: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PlatformCubit.get(context);
    final primaryColor = AppColors.appPurblePrimaryColor;
    final isAr = cubit.isAr;
    final fontFamily = isAr ? 'Cairo' : 'Roboto';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: isAr ? 'الدخول كضيف' : 'Continue as guest',
              primaryColor: primaryColor,
              fontFamily: fontFamily,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Image.asset(
                      'assets/white_logo.png',
                      width: 150.0,
                      height: 150.0,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isAr ? 'اختر صفك الدراسي' : 'Choose your grade',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff1a1a1a),
                        fontFamily: fontFamily,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAr
                          ? 'اختر صفك لتصفّح المحتوى المتاح كضيف'
                          : 'Pick your grade to browse the available content as a guest',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.6),
                        fontFamily: fontFamily,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OptionCard(
                            label: isAr
                                ? 'الصف الثاني\nالثانوي'
                                : 'Second grade\nsecondary',
                            icon: Icons.school_rounded,
                            selected: _grade == StudyGrade.second,
                            primaryColor: primaryColor,
                            fontFamily: fontFamily,
                            onTap: () =>
                                setState(() => _grade = StudyGrade.second),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OptionCard(
                            label: isAr
                                ? 'الصف الثالث\nالثانوي'
                                : 'Third grade\nsecondary',
                            icon: Icons.school_outlined,
                            selected: _grade == StudyGrade.third,
                            primaryColor: primaryColor,
                            fontFamily: fontFamily,
                            onTap: () =>
                                setState(() => _grade = StudyGrade.third),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    AuthPrimaryButton(
                      onPressed: () =>
                          _continueAsGuest(cubit: cubit, isAr: isAr),
                      isLoading: _isLoading,
                      text: isAr ? 'الدخول كضيف' : 'Continue as guest',
                      loadingText: isAr ? 'جاري الدخول' : 'Entering',
                      icon: Icons.person_outline_rounded,
                      fontFamily: fontFamily,
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final Color primaryColor;
  final String fontFamily;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.primaryColor,
    required this.fontFamily,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            color: primaryColor,
            onTap: onBack,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xff1a1a1a),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
