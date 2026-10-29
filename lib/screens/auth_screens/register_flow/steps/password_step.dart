import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_cubit.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_states.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/auth_buttons.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/auth_text_field.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

class PasswordStep extends StatefulWidget {
  final Color primaryColor;
  final String fontFamily;
  final bool isAr;
  final VoidCallback onFinish;

  const PasswordStep({
    super.key,
    required this.primaryColor,
    required this.fontFamily,
    required this.isAr,
    required this.onFinish,
  });

  @override
  State<PasswordStep> createState() => _PasswordStepState();
}

class _PasswordStepState extends State<PasswordStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final c = context.read<RegisterCubit>();
    _passwordController = TextEditingController(text: c.password);
    _confirmController = TextEditingController(text: c.confirmPassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Strength: 0-4
  int _strength(String pw) {
    int score = 0;
    if (pw.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pw)) score++;
    if (RegExp(r'[0-9]').hasMatch(pw)) score++;
    if (RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/?]').hasMatch(pw)) {
      score++;
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listenWhen: (_, s) =>
          s is RegisterSubmitSuccess || s is RegisterSubmitFail,
      listener: (context, state) {
        if (state is RegisterSubmitSuccess) {
          widget.onFinish();
        } else if (state is RegisterSubmitFail) {
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
          s is RegisterFieldChanged ||
          s is RegisterSubmitLoading ||
          s is RegisterSubmitSuccess ||
          s is RegisterSubmitFail ||
          s is RegisterInitial,
      builder: (context, state) {
        final cubit = context.read<RegisterCubit>();
        final isLoading = state is RegisterSubmitLoading;
        final strength = _strength(_passwordController.text);

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isAr ? 'كلمة المرور' : 'Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1a1a1a),
                  fontFamily: widget.fontFamily,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isAr
                    ? 'اختر كلمة مرور قوية لحماية حسابك'
                    : 'Choose a strong password to protect your account',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.6),
                  fontFamily: widget.fontFamily,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              AuthTextField(
                controller: _passwordController,
                label: widget.isAr ? 'كلمة المرور' : 'Password',
                icon: Icons.lock_rounded,
                primaryColor: widget.primaryColor,
                fontFamily: widget.fontFamily,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                obscureText: _obscurePassword,
                onChanged: (v) {
                  cubit.setPassword(v);
                  setState(() {});
                },
                suffixIcon: IconButton(
                  splashRadius: 22,
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: widget.primaryColor.withValues(alpha: 0.8),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) {
                  final value = v ?? '';
                  if (value.isEmpty) {
                    return widget.isAr ? 'ادخل كلمة المرور' : 'Enter password';
                  }
                  if (value.length < 8) {
                    return widget.isAr
                        ? 'يجب ألا تقل عن 8 أحرف'
                        : 'Must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _StrengthBar(
                strength: strength,
                primaryColor: widget.primaryColor,
                fontFamily: widget.fontFamily,
                isAr: widget.isAr,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _confirmController,
                label: widget.isAr ? 'تأكيد كلمة المرور' : 'Confirm password',
                icon: Icons.lock_outline_rounded,
                primaryColor: widget.primaryColor,
                fontFamily: widget.fontFamily,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                obscureText: _obscureConfirm,
                onChanged: cubit.setConfirmPassword,
                suffixIcon: IconButton(
                  splashRadius: 22,
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: widget.primaryColor.withValues(alpha: 0.8),
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) {
                  final value = v ?? '';
                  if (value.isEmpty) {
                    return widget.isAr ? 'أكد كلمة المرور' : 'Confirm password';
                  }
                  if (value != _passwordController.text) {
                    return widget.isAr
                        ? 'كلمتا المرور غير متطابقتين'
                        : 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _Hints(
                password: _passwordController.text,
                primaryColor: widget.primaryColor,
                fontFamily: widget.fontFamily,
                isAr: widget.isAr,
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (!_formKey.currentState!.validate()) return;
                  cubit.submitRegistration();
                },
                isLoading: isLoading,
                text: widget.isAr ? 'إنشاء الحساب' : 'Create account',
                loadingText: widget.isAr ? 'جاري الانشاء...' : 'Creating...',
                icon: Icons.check_circle_rounded,
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

class _StrengthBar extends StatelessWidget {
  final int strength;
  final Color primaryColor;
  final String fontFamily;
  final bool isAr;

  const _StrengthBar({
    required this.strength,
    required this.primaryColor,
    required this.fontFamily,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.amber,
      Colors.lightGreen,
      Colors.green,
    ];
    final labels = isAr
        ? ['ضعيفة جدًا', 'ضعيفة', 'متوسطة', 'قوية', 'قوية جدًا']
        : ['Very weak', 'Weak', 'Medium', 'Strong', 'Very strong'];
    final color = colors[strength.clamp(0, 4)];
    final label = labels[strength.clamp(0, 4)];

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              final isOn = i < strength;
              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: i == 3 ? 0 : 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          isOn ? color : Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Hints extends StatelessWidget {
  final String password;
  final Color primaryColor;
  final String fontFamily;
  final bool isAr;

  const _Hints({
    required this.password,
    required this.primaryColor,
    required this.fontFamily,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final rules = <_Rule>[
      _Rule(
        check: password.length >= 8,
        label: isAr ? '٨ أحرف على الأقل' : 'At least 8 characters',
      ),
      _Rule(
        check: RegExp(r'[A-Z]').hasMatch(password),
        label:
            isAr ? 'حرف كبير واحد على الأقل' : 'At least one uppercase letter',
      ),
      _Rule(
        check: RegExp(r'[0-9]').hasMatch(password),
        label: isAr ? 'رقم واحد على الأقل' : 'At least one number',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rules.map((r) {
          final color =
              r.check ? Colors.green : Colors.black.withValues(alpha: 0.45);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(
                  r.check
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.label,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 13,
                      color: color,
                      fontWeight: r.check ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Rule {
  final bool check;
  final String label;
  _Rule({required this.check, required this.label});
}
