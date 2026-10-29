// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/screens/auth_screens/login_screens/guest_grade_screen.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/register_flow_page.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/constants/styles.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/layout/home_layout.dart';
import 'package:salah_online_platform/screens/main/error_screen.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  var fKey = GlobalKey<FormState>();

  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool isLoading = false;
  bool isGuestLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    PlatformCubit.get(context).getIsShowRegister();
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformLoginLoadingState) {
          isLoading = true;
        }
        if (state is PlatformLoginFailState) {
          isLoading = false;

          final cubit = PlatformCubit.get(context);
          final mapped = _mapLoginError(state);
          bool showRegister = cubit.isShowRegister &&
              !cubit.showDelAcc &&
              state.type == LoginErrorType.userNotFound;
          AppStatusDialog.show(
            context: context,
            status: mapped.status,
            title: mapped.title,
            message: state.err,
            primaryActionText: mapped.primaryText,
            secondaryActionText: showRegister ? mapped.secondaryText : null,
            onSecondaryAction: showRegister
                ? () {
                    Navigator.of(context).pop();
                    Components.push(
                      context: context,
                      widget: const RegisterFlowPage(),
                    );
                  }
                : null,
            isAr: cubit.isAr,
          );
        }

        if (state is PlatformLoginSuccessState) {
          isLoading = false;
          if (state.enabled && state.active) {
            Components.pushAndRemoveAll(
              context: context,
              name: Components.homeRouteName,
              widget: HomeLayout(
                cubit: PlatformCubit.get(context),
                isFirstTime: true,
                pageController: PageController(initialPage: 0),
              ),
            );
          } else {
            Components.pushReplacement(
              context: context,
              widget: ErrorScreen(
                cubit: PlatformCubit.get(context),
                status: !state.enabled
                    ? Constants.accountBlocked
                    : Constants.accountPending,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        final primaryColor = Components.setBgColor(cubit.isDarkMode);
        final fontFamily = cubit.isAr ? 'Cairo' : 'Roboto';

        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Form(
              key: fKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            // Logo with subtle background
                            Image.asset(
                              'assets/white_logo.png',
                              width: 200.0,
                              height: 200.0,
                            ),
                            Text(
                              S.of(context).welcome_back,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff1a1a1a),
                                fontFamily: fontFamily,
                              ),
                            ),
                            Text(
                              S.of(context).login_subtitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff0b0807)
                                    .withValues(alpha: 0.5),
                                fontFamily: fontFamily,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Phone field
                            _buildTextField(
                              controller: phoneController,
                              focusNode: _phoneFocus,
                              label: S.of(context).phone_num,
                              icon: Icons.phone_rounded,
                              primaryColor: primaryColor,
                              fontFamily: fontFamily,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => FocusScope.of(context)
                                  .requestFocus(_passwordFocus),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return S.of(context).phone_num;
                                }
                                if (v.trim().length < 8) {
                                  return S.of(context).phone_num;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Password field
                            _buildTextField(
                              controller: passwordController,
                              focusNode: _passwordFocus,
                              label: S.of(context).password,
                              icon: Icons.lock_rounded,
                              primaryColor: primaryColor,
                              fontFamily: fontFamily,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                splashRadius: 22,
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: primaryColor.withValues(alpha: 0.8),
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return S.of(context).password;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            _buildPrimaryButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                if (fKey.currentState!.validate()) {
                                  bool isConnected =
                                      await Components.checkConnection();
                                  if (isConnected) {
                                    if (!isLoading && !isGuestLoading) {
                                      cubit.platformLogin(
                                        password: passwordController.text,
                                        phoneNum: phoneController.text,
                                      );
                                    }
                                  } else {
                                    AppStatusDialog.show(
                                      context: context,
                                      status: AppDialogStatus.warning,
                                      title: 'لا يوجد اتصال',
                                      message: S.of(context).no_internet,
                                      isAr: cubit.isAr,
                                    );
                                  }
                                }
                              },
                              isLoading: isLoading || isGuestLoading,
                              text: S.of(context).login,
                              icon: Icons.login_rounded,
                              primaryColor: primaryColor,
                            ),

                            const SizedBox(height: 18),
                            // Register Link
                            if (cubit.isShowRegister)
                              Center(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            '${S.of(context).donot_have_acc} ',
                                        style:
                                            AppTextStyles.body2Style.copyWith(
                                          fontFamily: fontFamily,
                                          color: Colors.black
                                              .withValues(alpha: 0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Components.push(
                                              context: context,
                                              widget: const RegisterFlowPage(),
                                            );
                                          },
                                        text: S.of(context).create_acc,
                                        style:
                                            AppTextStyles.body2Style.copyWith(
                                          fontFamily: fontFamily,
                                          color: primaryColor,
                                          fontSize: 13,
                                          decoration: TextDecoration.none,
                                          decorationColor: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Divider with Guest Button
                            if (cubit.isShowGuest)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: Colors.black
                                              .withValues(alpha: 0.08),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(
                                          S.of(context).or_divider,
                                          style: TextStyle(
                                            color: Colors.black
                                                .withValues(alpha: 0.5),
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: Colors.black
                                              .withValues(alpha: 0.08),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildSecondaryButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const GuestGradeScreen(),
                                        ),
                                      );
                                    },
                                    text: S.of(context).login_guest,
                                    icon: Icons.person_outline_rounded,
                                    primaryColor: primaryColor,
                                  ),
                                ],
                              ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  _LoginErrorView _mapLoginError(PlatformLoginFailState state) {
    switch (state.type) {
      case LoginErrorType.userNotFound:
        return _LoginErrorView(
          status: AppDialogStatus.error,
          title: 'الحساب غير موجود',
          primaryText: 'حاول مرة أخرى',
          secondaryText: 'إنشاء حساب',
        );
      case LoginErrorType.deviceLimit:
        return _LoginErrorView(
          status: AppDialogStatus.warning,
          title: 'جهاز غير مسموح',
          primaryText: 'حسناً',
        );
      case LoginErrorType.noInternet:
        return _LoginErrorView(
          status: AppDialogStatus.warning,
          title: 'لا يوجد اتصال',
          primaryText: 'إعادة المحاولة',
        );
      case LoginErrorType.invalidCredentials:
        return _LoginErrorView(
          status: AppDialogStatus.error,
          title: 'بيانات غير صحيحة',
          primaryText: 'حاول مرة أخرى',
        );
      case LoginErrorType.unknown:
        return _LoginErrorView(
          status: AppDialogStatus.error,
          title: 'حدث خطأ ما',
          primaryText: 'حسناً',
        );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required Color primaryColor,
    required String fontFamily,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    const borderRadius = 14.0;
    final fillColor = Colors.white;
    final hintColor = Colors.black.withValues(alpha: 0.45);

    OutlineInputBorder buildBorder(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Material(
      elevation: 3.0,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(borderRadius),
      color: fillColor,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        cursorColor: primaryColor,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: 15,
          color: const Color(0xff1a1a1a),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: fontFamily,
            color: hintColor,
            fontSize: 14,
          ),
          floatingLabelStyle: TextStyle(
            fontFamily: fontFamily,
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: buildBorder(Colors.black.withValues(alpha: 0.08), 1),
          enabledBorder: buildBorder(Colors.black.withValues(alpha: 0.08), 1),
          focusedBorder: buildBorder(primaryColor, 1.6),
          errorBorder: buildBorder(Colors.redAccent.shade200, 1),
          focusedErrorBorder: buildBorder(Colors.redAccent, 1.6),
          errorStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required bool isLoading,
    required String text,
    required IconData icon,
    required Color primaryColor,
  }) {
    return SizedBox(
        width: double.infinity,
        height: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [primaryColor.withValues(alpha: 0.5), primaryColor],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: .35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading ? null : onPressed,
              child: Center(
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            S.of(context).loading,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            text,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ));
  }

  Widget _buildSecondaryButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required Color primaryColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginErrorView {
  final AppDialogStatus status;
  final String title;
  final String primaryText;
  final String? secondaryText;

  _LoginErrorView({
    required this.status,
    required this.title,
    required this.primaryText,
    this.secondaryText,
  });
}
