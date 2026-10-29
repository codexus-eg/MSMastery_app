import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_cubit.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_states.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/auth_buttons.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

class OtpStep extends StatefulWidget {
  final Color primaryColor;
  final String fontFamily;
  final bool isAr;
  final VoidCallback onNext;
  final VoidCallback onEditPhone;

  const OtpStep({
    super.key,
    required this.primaryColor,
    required this.fontFamily,
    required this.isAr,
    required this.onNext,
    required this.onEditPhone,
  });

  @override
  State<OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<OtpStep> {
  static const int _otpLength = 6;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  Timer? _timer;
  int _remaining = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remaining = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 0) {
        t.cancel();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    // Multiple characters arriving at once means a paste (or SMS autofill).
    if (value.length > 1) {
      _fillFromPaste(value);
      return;
    }
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    context.read<RegisterCubit>().setOtp(_otp);
    setState(() {});
  }

  void _fillFromPaste(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    for (int i = 0; i < _otpLength; i++) {
      final ch = i < digits.length ? digits[i] : '';
      _controllers[i].value = TextEditingValue(
        text: ch,
        selection: TextSelection.collapsed(offset: ch.length),
      );
    }
    final focusIndex =
        digits.length >= _otpLength ? _otpLength - 1 : digits.length;
    _focusNodes[focusIndex].requestFocus();
    context.read<RegisterCubit>().setOtp(_otp);
    setState(() {});
  }

  void _resend() {
    if (_remaining > 0) return;
    _startTimer();
    context.read<RegisterCubit>().sendOtp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listenWhen: (_, s) =>
          s is RegisterVerifyOtpSuccess || s is RegisterVerifyOtpFail,
      listener: (context, state) {
        if (state is RegisterVerifyOtpSuccess) {
          widget.onNext();
        } else if (state is RegisterVerifyOtpFail) {
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: widget.isAr ? 'كود غير صحيح' : 'Wrong code',
            message: state.error,
            isAr: widget.isAr,
          );
        }
      },
      buildWhen: (_, s) =>
          s is RegisterVerifyOtpLoading ||
          s is RegisterVerifyOtpSuccess ||
          s is RegisterVerifyOtpFail ||
          s is RegisterInitial,
      builder: (context, state) {
        final cubit = context.read<RegisterCubit>();
        final isLoading = state is RegisterVerifyOtpLoading;
        final isComplete = _otp.length == _otpLength;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isAr ? 'تأكيد رقم الهاتف' : 'Verify your phone',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xff1a1a1a),
                fontFamily: widget.fontFamily,
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.6),
                  fontFamily: widget.fontFamily,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: widget.isAr
                        ? 'أدخل الكود المرسل علي '
                        : 'Enter the code sent to ',
                  ),
                  TextSpan(
                    text: cubit.phoneNum,
                    style: TextStyle(
                      color: widget.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: '  '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: widget.onEditPhone,
                      child: Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: widget.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (i) {
                  return _OtpBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    primaryColor: widget.primaryColor,
                    fontFamily: widget.fontFamily,
                    onChanged: (v) => _onChanged(i, v),
                  );
                }),
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: _remaining > 0
                  ? Text(
                      widget.isAr
                          ? 'إعادة إرسال الكود خلال 00:${_remaining.toString().padLeft(2, '0')}'
                          : 'Resend in 00:${_remaining.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontFamily: widget.fontFamily,
                        color: Colors.black.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                    )
                  : TextButton(
                      onPressed: _resend,
                      child: Text(
                        widget.isAr ? 'إعادة إرسال الكود' : 'Resend code',
                        style: TextStyle(
                          color: widget.primaryColor,
                          fontFamily: widget.fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 14),
            AuthPrimaryButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (!isComplete) {
                  AppStatusDialog.show(
                    context: context,
                    status: AppDialogStatus.warning,
                    title: widget.isAr ? 'الكود غير مكتمل' : 'Incomplete code',
                    message: widget.isAr
                        ? 'برجاء ادخال الكود كامل'
                        : 'Please enter the full code',
                    isAr: widget.isAr,
                  );
                  return;
                }
                cubit.verifyOtp();
              },
              isLoading: isLoading,
              text: widget.isAr ? 'تأكيد' : 'Verify',
              loadingText: widget.isAr ? 'جاري التحقق...' : 'Verifying...',
              icon: Icons.verified_rounded,
              fontFamily: widget.fontFamily,
              primaryColor: widget.primaryColor,
            ),
          ],
        );
      },
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color primaryColor;
  final String fontFamily;
  final void Function(String) onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.primaryColor,
    required this.fontFamily,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        cursorColor: primaryColor,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: onChanged,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xff1a1a1a),
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasValue
                  ? primaryColor.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 1.6),
          ),
        ),
      ),
    );
  }
}
