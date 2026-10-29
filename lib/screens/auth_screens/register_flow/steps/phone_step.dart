import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_cubit.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_states.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/auth_buttons.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/auth_text_field.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

class PhoneStep extends StatefulWidget {
  final Color primaryColor;
  final String fontFamily;
  final bool isAr;
  final VoidCallback onNext;

  const PhoneStep({
    super.key,
    required this.primaryColor,
    required this.fontFamily,
    required this.isAr,
    required this.onNext,
  });

  @override
  State<PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<PhoneStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _phoneController =
        TextEditingController(text: context.read<RegisterCubit>().phoneNum);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listenWhen: (_, s) =>
          s is RegisterSendOtpSuccess || s is RegisterSendOtpFail,
      listener: (context, state) {
        if (state is RegisterSendOtpSuccess) {
          widget.onNext();
        } else if (state is RegisterSendOtpFail) {
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: widget.isAr ? 'حدث خطأ' : 'Error',
            message: state.error,
            isAr: widget.isAr,
          );
        }
      },
      buildWhen: (_, s) =>
          s is RegisterSendOtpLoading ||
          s is RegisterSendOtpSuccess ||
          s is RegisterSendOtpFail ||
          s is RegisterInitial,
      builder: (context, state) {
        final cubit = context.read<RegisterCubit>();
        final isLoading = state is RegisterSendOtpLoading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                title: widget.isAr ? 'رقم الهاتف' : 'Phone Number',
                subtitle: widget.isAr
                    ? 'ادخل رقم هاتفك لاستلام رمز التحقق'
                    : 'Enter your phone number to receive a verification code',
                fontFamily: widget.fontFamily,
              ),
              const SizedBox(height: 24),
              Directionality(
                textDirection: TextDirection.ltr,
                child: AuthTextField(
                  controller: _phoneController,
                  focusNode: _focus,
                  label: widget.isAr ? 'رقم الهاتف' : 'Phone number',
                  icon: Icons.phone_rounded,
                  primaryColor: widget.primaryColor,
                  fontFamily: widget.fontFamily,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  maxLength: 11,
                  onChanged: cubit.setPhone,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) {
                      return widget.isAr
                          ? 'ادخل رقم الهاتف'
                          : 'Enter your phone number';
                    }
                    if (value.length != 11 || !value.startsWith('01')) {
                      return widget.isAr
                          ? 'رقم هاتف غير صحيح'
                          : 'Invalid phone number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Colors.black.withValues(alpha: 0.55),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.isAr
                            ? 'هيتم ارسال كود التحقق علي واتساب'
                            : 'A verification code will be sent via WhatsApp',
                        style: TextStyle(
                          fontFamily: widget.fontFamily,
                          color: Colors.black.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              AuthPrimaryButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (_formKey.currentState!.validate()) {
                    cubit.sendOtp();
                  }
                },
                isLoading: isLoading,
                text: widget.isAr ? 'ارسال الكود' : 'Send code',
                loadingText: widget.isAr ? 'جاري الارسال...' : 'Sending...',
                icon: Icons.send_rounded,
                fontFamily: widget.fontFamily,
                primaryColor: widget.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final String fontFamily;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xff1a1a1a),
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withValues(alpha: 0.6),
            fontFamily: fontFamily,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
