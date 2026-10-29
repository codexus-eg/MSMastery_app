import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_cubit.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_states.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/steps/address_step.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/steps/otp_step.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/steps/password_step.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/steps/personal_step.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/steps/phone_step.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/step_indicator.dart';
import 'package:salah_online_platform/screens/main/error_screen.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

class RegisterFlowPage extends StatelessWidget {
  const RegisterFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterCubit>(
      create: (_) => RegisterCubit(),
      child: const _RegisterFlowView(),
    );
  }
}

class _RegisterFlowView extends StatefulWidget {
  const _RegisterFlowView();

  @override
  State<_RegisterFlowView> createState() => _RegisterFlowViewState();
}

class _RegisterFlowViewState extends State<_RegisterFlowView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<bool> _handleBack(
      BuildContext context, RegisterCubit cubit, bool isAr) async {
    if (cubit.currentStep == RegisterStep.phone) {
      Navigator.of(context).pop();
      return false;
    }
    final prevIndex = cubit.currentStep.index - 1;
    cubit.goTo(RegisterStep.values[prevIndex]);
    _animateTo(prevIndex);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final platform = PlatformCubit.get(context);
    final primaryColor = Components.setBgColor(platform.isDarkMode);
    final fontFamily = platform.isAr ? 'Cairo' : 'Roboto';
    final isAr = platform.isAr;

    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (_, s) => s is RegisterStepChanged || s is RegisterInitial,
      builder: (context, _) {
        final cubit = context.read<RegisterCubit>();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await _handleBack(context, cubit, isAr);
          },
          child: Scaffold(
            backgroundColor: const Color(0xfffafbfd),
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    onBack: () => _handleBack(context, cubit, isAr),
                    title: isAr ? 'إنشاء حساب' : 'Create account',
                    primaryColor: primaryColor,
                    fontFamily: fontFamily,
                    currentStep: cubit.currentStep.index,
                    totalSteps: RegisterStep.values.length,
                    isAr: isAr,
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _StepWrapper(
                          child: PhoneStep(
                            primaryColor: primaryColor,
                            fontFamily: fontFamily,
                            isAr: isAr,
                            onNext: () {
                              cubit.goTo(RegisterStep.otp);
                              _animateTo(RegisterStep.otp.index);
                            },
                          ),
                        ),
                        _StepWrapper(
                          child: OtpStep(
                            primaryColor: primaryColor,
                            fontFamily: fontFamily,
                            isAr: isAr,
                            onNext: () {
                              cubit.goTo(RegisterStep.personal);
                              _animateTo(RegisterStep.personal.index);
                            },
                            onEditPhone: () {
                              cubit.goTo(RegisterStep.phone);
                              _animateTo(RegisterStep.phone.index);
                            },
                          ),
                        ),
                        _StepWrapper(
                          child: PersonalStep(
                            primaryColor: primaryColor,
                            fontFamily: fontFamily,
                            isAr: isAr,
                            onNext: () {
                              cubit.goTo(RegisterStep.address);
                              _animateTo(RegisterStep.address.index);
                            },
                          ),
                        ),
                        _StepWrapper(
                          child: AddressStep(
                            primaryColor: primaryColor,
                            fontFamily: fontFamily,
                            isAr: isAr,
                            onNext: () {
                              cubit.goTo(RegisterStep.password);
                              _animateTo(RegisterStep.password.index);
                            },
                          ),
                        ),
                        _StepWrapper(
                          child: PasswordStep(
                            primaryColor: primaryColor,
                            fontFamily: fontFamily,
                            isAr: isAr,
                            onFinish: () {
                              AppStatusDialog.show(
                                context: context,
                                status: AppDialogStatus.success,
                                barrierDismissible: false,
                                title: isAr
                                    ? 'تم انشاء الحساب'
                                    : 'Account created',
                                message: isAr
                                    ? 'تم انشاء حسابك بنجاح, سيتم تفعيل حسابك قريباً'
                                    : 'Your account was created successfully, it will be activated soon',
                                primaryActionText: isAr ? 'حسناً' : 'OK',
                                onPrimaryAction: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => ErrorScreen(
                                        status: Constants.accountPending,
                                        cubit: context.read<PlatformCubit>(),
                                      ),
                                    ),
                                  );
                                },
                                isAr: isAr,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StepWrapper extends StatelessWidget {
  final Widget child;
  const _StepWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: child,
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final String title;
  final Color primaryColor;
  final String fontFamily;
  final int currentStep;
  final int totalSteps;
  final bool isAr;

  const _TopBar({
    required this.onBack,
    required this.title,
    required this.primaryColor,
    required this.fontFamily,
    required this.currentStep,
    required this.totalSteps,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: StepProgressIndicator(
              totalSteps: totalSteps,
              currentStep: currentStep,
              primaryColor: primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr
                      ? 'خطوة ${currentStep + 1} من $totalSteps'
                      : 'Step ${currentStep + 1} of $totalSteps',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
