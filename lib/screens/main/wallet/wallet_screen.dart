// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/constants/payment_options.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/user_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool isLoading = false;

  var fkey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    var cubit = PlatformCubit.get(context);
    cubit.getCashPhoneNum();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
        listener: (context, state) async {
      if (state is PlatformCheckCodeLoadingState) {
        isLoading = true;
      }
      if (state is PlatformCheckCodeFailState) {
        isLoading = false;
        AppStatusDialog.show(
          context: context,
          status: AppDialogStatus.error,
          title: 'خلي بالك',
          message:
              state.err.substring(state.err.indexOf(']') + 2, state.err.length),
        );
      }
      if (state is PlatformCheckCodeSuccessState) {
        isLoading = false;
        Navigator.pop(context);
        AppStatusDialog.show(
          context: context,
          status: AppDialogStatus.success,
          title: 'تم بنجاح',
          message: S.of(context).rech_succ,
        );
      }
      if (state is PlatformCheckCodeAlreadyChargedState) {
        isLoading = false;

        AppStatusDialog.show(
          context: context,
          status: AppDialogStatus.success,
          title: 'تم بنجاح',
          message: S.of(context).rech_succ,
        );
      }

      if (state is PlatformApplyGeneralCodeToBalanceSuccessState) {
        isLoading = false;

        AppStatusDialog.show(
          context: context,
          status: AppDialogStatus.success,
          title: 'تم بنجاح',
          message: S.of(context).purchased_success,
        );
      }

      if (state is PlatformApplyGeneralCodeToBalanceFailState) {
        isLoading = false;
        AppStatusDialog.show(
          context: context,
          status: AppDialogStatus.error,
          title: 'خلي بالك',
          message:
              state.err.substring(state.err.indexOf(']') + 2, state.err.length),
        );
      }
    }, builder: (context, state) {
      var cubit = PlatformCubit.get(context);
      UserModel um = Constants.userBox.get('user');

      final primaryColor = Components.setBgColor(cubit.isDarkMode);
      final secondaryColor = cubit.isDarkMode
          ? AppColors.appPrimaryColor
          : AppColors.appSecondaryColor;
      final bgColor =
          cubit.isDarkMode ? AppColors.darkBgColor : const Color(0xfff5f7fb);
      final isPending =
          Constants.userBox.get('user')?.walletBalanceStatus == 'pending';
      return Form(
        key: fkey,
        child: Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  DefaultBackBtn(
                    txt: S.of(context).wallet,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBalanceCard(
                            context: context,
                            balance: um.balance,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            cubit: cubit,
                          ),
                          const SizedBox(height: 36.0),
                          _buildSectionHeader(
                            context: context,
                            cubit: cubit,
                            icon: Icons.savings_rounded,
                            title: S.of(context).recharge_wallet_section,
                            subtitle: S.of(context).recharge_wallet_hint,
                          ),
                          if (isPending)
                            Widgets.buildPendingBanner(cubit.isDarkMode),
                          const SizedBox(height: 16.0),
                          _buildAddBalanceButton(
                            context: context,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            cubit: cubit,
                            isPending: isPending,
                          ),
                          const SizedBox(height: 32.0),
                          _buildSectionHeader(
                            context: context,
                            cubit: cubit,
                            icon: Icons.support_agent_rounded,
                            title: S.of(context).need_help_section,
                            subtitle: S.of(context).need_help_hint,
                          ),
                          const SizedBox(height: 16.0),
                          _buildWhatsAppButton(
                            context: context,
                            cashPhoneNum: cubit.cashPhoneNum,
                            cubit: cubit,
                          ),
                          const SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBalanceCard({
    required BuildContext context,
    required dynamic balance,
    required Color primaryColor,
    required Color secondaryColor,
    required PlatformCubit cubit,
  }) {
    final textColor = Components.setTextColor(cubit.isDarkMode);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, secondaryColor],
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: textColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      S.of(context).are_available_now,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: textColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$balance',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        S.of(context).egp,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppButton({
    required BuildContext context,
    required String cashPhoneNum,
    required PlatformCubit cubit,
  }) {
    const whatsappColor = Color(0xff25D366);
    const whatsappDark = Color(0xff128C7E);

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [whatsappColor, whatsappDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: whatsappColor.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: cashPhoneNum.isEmpty
              ? null
              : () async {
                  await launchUrl(
                    Uri.parse('https://wa.me/$cashPhoneNum'),
                  );
                },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  S.of(context).contact_us_cash,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Recharge flow
  // ===========================================================================

  Widget _buildSectionHeader({
    required BuildContext context,
    required PlatformCubit cubit,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final primaryColor = Components.setBgColor(cubit.isDarkMode);
    final titleColor =
        cubit.isDarkMode ? Colors.white : const Color(0xff1a1a1a);
    final subtitleColor = cubit.isDarkMode
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.55);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddBalanceButton({
    required BuildContext context,
    required Color primaryColor,
    required Color secondaryColor,
    required PlatformCubit cubit,
    required bool isPending,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (Constants.userBox.get('user').code == 'guest') {
              Constants.showLoginDialog(
                isDarkMode: cubit.isDarkMode,
                context: context,
              );
              return;
            }
            _startRecharge(cubit);
          },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isPending ? Icons.refresh_rounded : Icons.add_card_rounded,
                    color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  isPending
                      ? S.of(context).complete_payment
                      : S.of(context).add_to_wallet,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Step 1: choose how to recharge — code or online payment.
  void _startRecharge(PlatformCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AnimatedPaymentBottomSheetContent(
          isDarkMode: cubit.isDarkMode,
          isAr: cubit.isAr,
          isShowOnlinePayment: cubit.isWalletShowOnlinePayment,
          price: 0,
          itemName: 'إضافة رصيد',
          codeClicked: ({required code}) async {
            await cubit.checkCode(code: code, context: context);
          },
          showAmountSheet: true,
          onlineClicked: ({int? amount}) async {
            Navigator.pop(context);
            await cubit.applyGeneralCodeToBalance(
                value: amount!, isOnline: true);
          },
        ),
      ),
      backgroundColor: Colors.transparent,
      enableDrag: true,
      showDragHandle: false,
    );
  }
}
