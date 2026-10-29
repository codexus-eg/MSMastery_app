// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/constants/styles.dart';
import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/models/payment_model.dart';
import 'package:salah_online_platform/screens/main/payment_webview_screen.dart';
import 'package:salah_online_platform/screens/qrscanner/qr_scanner_screen.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

class AnimatedPaymentBottomSheetContent extends StatefulWidget {
  bool isDarkMode;
  bool isAr;
  void Function({required String code}) codeClicked;

  void Function()? walletClicked;
  void Function({int? amount}) onlineClicked;
  int price;
  String itemName;
  String? lecId;
  String? chapId;
  String? quizId;
  bool? showAmountSheet;
  bool isShowOnlinePayment;
  AnimatedPaymentBottomSheetContent({
    super.key,
    required this.isDarkMode,
    required this.isAr,
    required this.codeClicked,
    required this.isShowOnlinePayment,
    this.walletClicked,
    required this.onlineClicked,
    required this.price,
    required this.itemName,
    this.lecId,
    this.quizId,
    this.chapId,
    this.showAmountSheet,
  });

  @override
  State<AnimatedPaymentBottomSheetContent> createState() =>
      _AnimatedPaymentBottomSheetContentState();
}

class _AnimatedPaymentBottomSheetContentState
    extends State<AnimatedPaymentBottomSheetContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  TextEditingController f3digitsController = TextEditingController();

  TextEditingController s3digitsController = TextEditingController();

  TextEditingController l3digitsController = TextEditingController();

  var fkey = GlobalKey<FormState>();

  String? selectedType;
  final List<PaymentOption> paymentOptions = [];

  @override
  void initState() {
    super.initState();
    if (widget.walletClicked != null) {
      paymentOptions.add(
        PaymentOption(
          icon: Icons.account_balance_wallet_rounded,
          label: S.current.use_wallet_value,
          subtitle:
              '${S.current.wallet_balance}: ${Constants.userBox.get('user').balance} ${S.current.egp}',
          color: const Color(0xFF6C5CE7),
          value: 'wallet',
        ),
      );
    }

    if (widget.isShowOnlinePayment) {
      paymentOptions.add(
        PaymentOption(
          icon: Icons.credit_card_rounded,
          label: S.current.online_payment,
          subtitle: S.current.pay_online_desc,
          color: const Color(0xFF0984E3),
          value: 'online',
        ),
      );
    }
    paymentOptions.add(
      PaymentOption(
        icon: Icons.pin_rounded,
        label: S.current.enter_lecture_code,
        subtitle: S.current.buy_with_code,
        color: const Color(0xFF00B894),
        value: 'pin',
      ),
    );
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28.0),
                        topRight: Radius.circular(28.0),
                      ),
                      color: widget.isDarkMode
                          ? AppColors.darkBgColor
                          : AppColors.lightBgColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(S.of(context).lecture_payment_options,
                              style: AppTextStyles.title1Style),
                        ),
                        const SizedBox(height: 16),
                        ...paymentOptions
                            .map((option) => _buildPaymentCard(option)),

                        const SizedBox(height: 16),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (child, animation) =>
                              SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1,
                            child: child,
                          ),
                          child: selectedType == 'pin'
                              ? Form(
                                  key: fkey,
                                  child: Column(
                                    key: const ValueKey('pin_fields'),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        S.of(context).enter_code,
                                        style: AppTextStyles.title2Style,
                                      ),
                                      const SizedBox(height: 8.0),
                                      // Scan QR button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 46,
                                        child: OutlinedButton.icon(
                                          onPressed: _scanLectureQr,
                                          icon: Icon(
                                            Icons.qr_code_scanner_rounded,
                                            size: 20,
                                            color: Components.setBgColor(
                                                widget.isDarkMode),
                                          ),
                                          label: Text(
                                            S.of(context).scan_qr,
                                            style: AppTextStyles.title2Style
                                                .copyWith(
                                              fontSize: 14,
                                              color: Components.setBgColor(
                                                  widget.isDarkMode),
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: Components.setBgColor(
                                                  widget.isDarkMode),
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      // "or enter manually" divider
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: widget.isDarkMode
                                                  ? AppColors.darkBorder
                                                  : AppColors.lightBborder,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                              S.of(context).enter_code_manually,
                                              style: AppTextStyles.body2Style
                                                  .copyWith(fontSize: 11),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: widget.isDarkMode
                                                  ? AppColors.darkBorder
                                                  : AppColors.lightBborder,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        textDirection: TextDirection.ltr,
                                        children: [
                                          Expanded(
                                            child: DefaultTextField11(
                                              errStr: 'First Three Digits',
                                              label: '123',
                                              textAlign: TextAlign.center,
                                              type: TextInputType.name,
                                              onChanged: (p0) {
                                                if (_handleCodePaste(p0)) {
                                                  return;
                                                }
                                                if (p0.length == 3) {
                                                  widget.isAr
                                                      ? FocusScope.of(context)
                                                          .previousFocus()
                                                      : FocusScope.of(context)
                                                          .nextFocus();
                                                }
                                              },
                                              controller: f3digitsController,
                                            ),
                                          ),
                                          const SizedBox(width: 4.0),
                                          Expanded(
                                            child: DefaultTextField11(
                                              type: TextInputType.name,
                                              label: '456',
                                              textAlign: TextAlign.center,
                                              onChanged: (p0) {
                                                if (_handleCodePaste(p0)) {
                                                  return;
                                                }
                                                if (p0.length == 3) {
                                                  widget.isAr
                                                      ? FocusScope.of(context)
                                                          .previousFocus()
                                                      : FocusScope.of(context)
                                                          .nextFocus();
                                                }
                                              },
                                              errStr: 'Second Three Digits',
                                              controller: s3digitsController,
                                            ),
                                          ),
                                          const SizedBox(width: 4.0),
                                          Expanded(
                                            child: DefaultTextField11(
                                              type: TextInputType.name,
                                              label: '789',
                                              textAlign: TextAlign.center,
                                              onChanged: (p0) {
                                                if (_handleCodePaste(p0)) {
                                                  return;
                                                }
                                                if (p0.length == 3) {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                }
                                              },
                                              errStr: 'Last Three Digits',
                                              controller: l3digitsController,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                )
                              :
                              /*
                         selectedType == 'online'
                            ? _buildOnlineInfo()
                            
                            : 
                            */

                              const SizedBox.shrink(key: ValueKey('no_pin')),
                        ),

                        // Go Button
                        Center(
                          child: BlocBuilder<PlatformCubit, PlatformStates>(
                            builder: (context, state) {
                              final isLoading = state
                                      is PlatformBuyLecturesLoadingState ||
                                  state is PlatformCheckCodeLoadingState ||
                                  state is PlatformCheckQuizLoadingState ||
                                  state is PlatformBuyQuizWalletLoadingState ||
                                  state
                                      is PlatformCheckPurchaseQuizCodeLoadingState;
                              return DefaultWaitedButton(
                                isLoading: isLoading,
                                txt: selectedType == 'online'
                                    ? S.of(context).proceed_to_payment
                                    : S.of(context).buy,
                                onPressed: () async {
                                  if (!isLoading) {
                                    if (selectedType == null) {
                                      AppStatusDialog.show(
                                        context: context,
                                        status: AppDialogStatus.error,
                                        title: 'خلي بالك',
                                        message:
                                            S.of(context).choose_payment_method,
                                      );
                                      return;
                                    }
                                    if (selectedType == 'pin') {
                                      if (fkey.currentState!.validate()) {
                                        FocusScope.of(context).unfocus();
                                        widget.codeClicked(
                                            code:
                                                '${f3digitsController.text} ${s3digitsController.text} ${l3digitsController.text}');
                                      }
                                    } else if (selectedType == 'online') {
                                      _startOnlinePayment();
                                    } else {
                                      AppStatusDialog.show(
                                        context: context,
                                        status: AppDialogStatus.info,
                                        title: (widget.chapId == null &&
                                                widget.lecId == null)
                                            ? S.of(context).buy_exam
                                            : S.of(context).buy_lec,
                                        message:
                                            '${S.of(context).sure_buy} ${widget.price} ${S.of(context).egp}${S.of(context).question_mark}',
                                        primaryActionText: S.of(context).buy,
                                        onPrimaryAction: () {
                                          if (!isLoading) {
                                            Navigator.pop(context);
                                            widget.walletClicked!();
                                          }
                                        },
                                      );
                                    }
                                  }
                                },
                                isDarkMode: widget.isDarkMode,
                                width: MediaQuery.of(context).size.width * 0.5,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles pasting a full code into any of the three digit fields.
  /// Spreads the pasted digits across the three fields (3/3/3).
  /// Returns true if it consumed the value as a paste.
  bool _handleCodePaste(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 3) return false;
    final controllers = [
      f3digitsController,
      s3digitsController,
      l3digitsController,
    ];
    for (int i = 0; i < controllers.length; i++) {
      final start = i * 3;
      final end = (start + 3) <= digits.length ? start + 3 : digits.length;
      final part = start >= digits.length ? '' : digits.substring(start, end);
      controllers[i].value = TextEditingValue(
        text: part,
        selection: TextSelection.collapsed(offset: part.length),
      );
    }
    FocusScope.of(context).unfocus();
    return true;
  }

  Future<void> _scanLectureQr() async {
    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => QRViewExample()),
    );
    if (!mounted) return;
    if (scanned != null && scanned.trim().isNotEmpty) {
      f3digitsController.text = scanned.substring(0, 3);
      s3digitsController.text = scanned.substring(4, 7);
      l3digitsController.text = scanned.substring(8, 11);
      // widget.codeClicked(code: scanned.trim());
    }
  }

  Widget _buildPaymentCard(PaymentOption option) {
    final isSelected = selectedType == option.value;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          selectedType = option.value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: isSelected
              ? option.color.withValues(alpha: widget.isDarkMode ? 0.18 : 0.08)
              : (widget.isDarkMode ? Colors.black : Colors.white),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected
                ? option.color
                : (widget.isDarkMode
                    ? AppColors.darkBorder
                    : AppColors.lightBborder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Leading icon badge
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: option.color.withValues(alpha: isSelected ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                option.icon,
                size: 24.0,
                color: option.color,
              ),
            ),
            const SizedBox(width: 14.0),
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option.label,
                    style: AppTextStyles.title2Style.copyWith(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (option.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      option.subtitle,
                      style: AppTextStyles.body2Style.copyWith(
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            // Trailing selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? option.color : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? option.color
                      : (widget.isDarkMode
                          ? AppColors.darkBorder
                          : AppColors.lightBborder),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Step 1 of the online payment flow:
  /// fetch the available Fawaterk methods, drop installment ("تقسيط") ones,
  /// then let the user pick a method.
  Future<void> _startOnlinePayment() async {
    PlatformCubit cubit = PlatformCubit.get(context);

    // 1. If true, wait for the user to pick and submit an amount first
    if (widget.showAmountSheet == true) {
      final selectedAmount = await _openAmountSheet(cubit);

      // If the user dismissed the bottom sheet without submitting, stop execution
      if (selectedAmount == null) return;

      widget.price = selectedAmount;
    }
    debugPrint(widget.price.toString());
    // 2. Now show loading and fetch payment methods
    _showLoadingDialog();
    final methods = await cubit.fetchPaymentMethods();

    if (!mounted) return;
    Navigator.pop(context); // close loading

    if (methods == null) {
      _showPaymentError();
      return;
    }

    if (methods.isEmpty) {
      AppStatusDialog.show(
        context: context,
        status: AppDialogStatus.warning,
        title: S.of(context).online_payment,
        message: S.of(context).no_payment_methods,
      );
      return;
    }

    final amount = widget.price == 1111 ? 0 : widget.price;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => PaymentMethodsSheet(
        methods: methods,
        isDarkMode: cubit.isDarkMode,
        isAr: cubit.isAr,
        onSelect: (method) {
          Navigator.pop(sheetContext);
          _processPayment(
            cubit,
            method.paymentId ?? 2,
            method.redirectOption ?? false,
            amount,
          );
        },
      ),
    );
  }

// 3. Updated to return a Future and pass the value back via Navigator.pop
  Future<int?> _openAmountSheet(PlatformCubit cubit) async {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: RechargeAmountSheet(
          isDarkMode: cubit.isDarkMode,
          onSubmit: (amount) {
            // Pass the chosen amount back through the Navigator pop
            Navigator.pop(sheetContext, amount);
          },
        ),
      ),
    );
  }

  /// Step 2: initialise the invoice for the chosen [method] and route the user
  /// to the matching experience (webview for redirects, code screen for Fawry).
  Future<void> _processPayment(
    PlatformCubit cubit,
    int paymentId,
    bool redirectOption,
    int amount,
  ) async {
    _showLoadingDialog();
    final result = await cubit.sendPaymentRequest(
      paymentId: paymentId,
      amount: amount,
      redirectOption: redirectOption,
      itemName: widget.showAmountSheet == true
          ? 'إضافة $amount جنيه رصيد'
          : widget.itemName,
      lecId: widget.lecId,
      chapId: widget.chapId,
      quizId: widget.quizId,
    );
    if (!mounted) return;
    Navigator.pop(context); // close loading

    if (result == null) {
      _showPaymentError();
      return;
    }

    if (result.isRedirect) {
      // Card / Visa / installments → open the gateway checkout in a webview.
      final PaymentResult? res = await Navigator.push<PaymentResult>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebviewScreen(url: result.redirectTo!),
        ),
      );
      if (!mounted) return;
      _handlePaymentResult(cubit, res, amount);
    } else if (result.isReferenceCode) {
      // Fawry & reference-code methods → show the code to pay at an outlet.
      _showFawryCode(cubit, result);
    } else {
      _showPaymentError();
    }
  }

  /// Reacts to the hosted-checkout outcome returned by [PaymentWebviewScreen].
  void _handlePaymentResult(
      PlatformCubit cubit, PaymentResult? res, int amount) {
    switch (res) {
      case PaymentResult.success:
        // Payment already captured by the gateway → unlock without charging the
        // wallet (price: 0). The bloc listener shows the success dialog.

        widget.onlineClicked(amount: amount);
        break;
      case PaymentResult.pending:
        AppStatusDialog.show(
          context: context,
          status: AppDialogStatus.info,
          title: S.of(context).online_payment,
          message: S.of(context).payment_pending,
        );
        break;
      case PaymentResult.fail:
        _showPaymentError();
        cubit.resetLocalData(
          status: 'failed',
          lecId: widget.lecId,
          chapId: widget.chapId,
          quizId: widget.quizId,
          itemName: widget.itemName,
        );
        break;
      case PaymentResult.cancelled:
      case null:
        // User backed out of the checkout — stay silent.
        break;
    }
  }

  void _showFawryCode(PlatformCubit cubit, PaymentInitResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FawryCodeSheet(
        isDarkMode: cubit.isDarkMode,
        code: result.fawryCode!,
        expireDate: result.expireDate,
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(
          color: Components.setBgColor(
            PlatformCubit.get(context).isDarkMode,
          ),
        ),
      ),
    );
  }

  void _showPaymentError() {
    AppStatusDialog.show(
      context: context,
      status: AppDialogStatus.error,
      title: S.of(context).online_payment,
      message: S.of(context).payment_failed,
    );
  }
}

class PaymentOption {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final String value;

  PaymentOption({
    required this.icon,
    required this.label,
    this.subtitle = '',
    required this.color,
    required this.value,
  });
}

/// Modern bottom sheet that shows the Fawry reference code with a copy action.
class FawryCodeSheet extends StatefulWidget {
  const FawryCodeSheet({
    super.key,
    required this.isDarkMode,
    required this.code,
    this.expireDate,
  });

  final bool isDarkMode;
  final String code;
  final String? expireDate;

  @override
  State<FawryCodeSheet> createState() => _FawryCodeSheetState();
}

class _FawryCodeSheetState extends State<FawryCodeSheet> {
  bool _copied = false;
  static const Color _fawryColor = Color(0xFFFFA000);

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).code_copied),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _fawryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            widget.isDarkMode ? AppColors.darkBgColor : AppColors.lightBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 12.0,
        bottom: 20.0 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20.0),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _fawryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.storefront_rounded,
                color: _fawryColor, size: 32),
          ),
          const SizedBox(height: 12.0),
          Text(
            S.of(context).fawry_payment,
            style: AppTextStyles.title1Style,
          ),
          const SizedBox(height: 8.0),
          Text(S.of(context).fawry_instructions,
              textAlign: TextAlign.center, style: AppTextStyles.body2Style),
          const SizedBox(height: 20.0),
          // Code box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16),
            decoration: BoxDecoration(
              color: _fawryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: _fawryColor.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Text(S.of(context).fawry_code, style: AppTextStyles.body2Style),
                const SizedBox(height: 6.0),
                Text(
                  widget.code,
                  style: AppTextStyles.title1Style.copyWith(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                  ),
                ),
              ],
            ),
          ),
          /*
          if 
          (widget.reference != null && widget.reference!.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.confirmation_number_outlined, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${S.of(context).reference_number}: ${widget.reference}',
                  style: AppTextStyles.body2Style,
                ),
              ],
            ),
          ],
          */
          if (widget.expireDate != null && widget.expireDate!.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text('${S.of(context).expires_at}: ',
                    style: AppTextStyles.body2Style),
                Text(
                  ' ${widget.expireDate}',
                  style: AppTextStyles.body2Style,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ],
          const SizedBox(height: 20.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _copyCode,
              icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded),
              label: Text(
                _copied ? S.of(context).code_copied : S.of(context).copy_code,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _fawryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              S.of(context).okay,
              style: AppTextStyles.body1Style
                  .copyWith(color: AppColors.appPurblePrimaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern bottom sheet that lists the available payment methods.
class PaymentMethodsSheet extends StatelessWidget {
  const PaymentMethodsSheet({
    super.key,
    required this.methods,
    required this.isDarkMode,
    required this.isAr,
    required this.onSelect,
  });

  final List<PaymentData> methods;
  final bool isDarkMode;
  final bool isAr;
  final void Function(PaymentData method) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgColor : AppColors.lightBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: EdgeInsets.only(
        top: 12.0,
        bottom: 16.0 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            S.of(context).choose_payment_method,
            style: AppTextStyles.title1Style,
          ),
          const SizedBox(height: 16.0),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: methods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10.0),
              itemBuilder: (context, index) {
                final method = methods[index];
                final visual = _MethodVisual.fromName(method.nameEn);
                final name = (isAr ? method.nameAr : method.nameEn) ??
                    method.nameEn ??
                    '';
                final subTitle =
                    (isAr ? method.arSubTitle : method.enSubTitle) ??
                        method.enSubTitle ??
                        '';
                return InkWell(
                  borderRadius: BorderRadius.circular(16.0),
                  onTap: () => onSelect(method),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 14.0),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: isDarkMode
                            ? AppColors.darkBorder
                            : AppColors.lightBborder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: visual.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child:
                              Icon(visual.icon, color: visual.color, size: 24),
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTextStyles.title2Style.copyWith(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                subTitle,
                                style: AppTextStyles.body2Style.copyWith(
                                  fontSize: 12.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual (icon + brand-ish color) for a Fawaterk payment method, derived from
/// its English name so the list looks consistent without remote SVG logos.
class _MethodVisual {
  final IconData icon;
  final Color color;
  const _MethodVisual(this.icon, this.color);

  factory _MethodVisual.fromName(String? nameEn) {
    final n = (nameEn ?? '').toLowerCase();
    if (n.contains('fawry')) {
      return const _MethodVisual(Icons.receipt_long_rounded, Color(0xFFFFA000));
    }
    if (n.contains('wallet')) {
      return const _MethodVisual(
          Icons.account_balance_wallet_rounded, Color(0xFF6C5CE7));
    }
    if (n.contains('valu')) {
      return const _MethodVisual(Icons.payments_rounded, Color(0xFFE84393));
    }
    if (n.contains('basata')) {
      return const _MethodVisual(Icons.receipt_long_rounded, Color(0xFF00B894));
    }
    if (n.contains('souhoola')) {
      return const _MethodVisual(
          Icons.account_balance_rounded, Color(0xFF6336E8));
    }
    // Card / Visa / Mastercard / NBE / default
    return const _MethodVisual(Icons.credit_card_rounded, Color(0xFF0984E3));
  }
}

/// Lets the student choose a recharge amount (presets + custom).
class RechargeAmountSheet extends StatefulWidget {
  const RechargeAmountSheet({
    super.key,
    required this.isDarkMode,
    required this.onSubmit,
  });

  final bool isDarkMode;
  final void Function(int amount) onSubmit;

  @override
  State<RechargeAmountSheet> createState() => _RechargeAmountSheetState();
}

class _RechargeAmountSheetState extends State<RechargeAmountSheet> {
  static const List<int> _presets = [50, 100, 150, 200, 300, 500];
  final TextEditingController _customController = TextEditingController();
  int? _selected;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  int? get _amount {
    final custom = int.tryParse(_customController.text.trim());
    if (custom != null && custom > 0) return custom;
    return _selected;
  }

  @override
  Widget build(BuildContext context) {
    final sheetColor =
        widget.isDarkMode ? AppColors.darkBgColor : AppColors.lightBgColor;

    final titleColor =
        widget.isDarkMode ? Colors.white : const Color(0xff1a1a1a);
    final primaryColor = Components.setBgColor(widget.isDarkMode);

    return Container(
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _dragHandle(widget.isDarkMode)),
          const SizedBox(height: 16),
          Text(
            S.of(context).choose_amount,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presets.map((value) {
              final isSelected = _selected == value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selected = value;
                    _customController.text = value.toString();
                  });
                  FocusScope.of(context).unfocus();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.12)
                        : (widget.isDarkMode ? Colors.black : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : (widget.isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.lightBborder),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    '$value ${S.of(context).egp}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? primaryColor : titleColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          DefaultTextField11(
            type: TextInputType.number,
            label: S.of(context).enter_amount,
            errStr: S.of(context).enter_amount,
            controller: _customController,
            onChanged: (_) => setState(() => _selected = null),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            suffixIcon: SizedBox(
              width: 30.0,
              height: 30.0,
              child: Center(
                child: Text(
                  S.of(context).egp,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _PrimaryButton(
            isDarkMode: widget.isDarkMode,
            label: S.of(context).proceed_to_payment,
            icon: Icons.arrow_forward_rounded,
            onTap: () {
              final amount = _amount;
              if (amount == null || amount < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).invalid_amount),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              widget.onSubmit(amount);
            },
          ),
        ],
      ),
    );
  }
}

/// Shared full-width primary action button used by the recharge sheets.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.isDarkMode,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final bool isDarkMode;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Components.setBgColor(isDarkMode);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
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
}

Widget _dragHandle(bool isDarkMode) {
  return Container(
    width: 44,
    height: 4,
    decoration: BoxDecoration(
      color: isDarkMode
          ? Colors.white.withValues(alpha: 0.18)
          : Colors.black.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
