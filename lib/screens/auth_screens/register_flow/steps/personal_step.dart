import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_cubit.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/cubit/register_states.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/auth_buttons.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/auth_text_field.dart';
import 'package:salah_online_platform/screens/auth_screens/register_flow/widgets/option_card.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

class PersonalStep extends StatefulWidget {
  final Color primaryColor;
  final String fontFamily;
  final bool isAr;
  final VoidCallback onNext;

  const PersonalStep({
    super.key,
    required this.primaryColor,
    required this.fontFamily,
    required this.isAr,
    required this.onNext,
  });

  @override
  State<PersonalStep> createState() => _PersonalStepState();
}

class _PersonalStepState extends State<PersonalStep> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _secondNameController;
  late final TextEditingController _thirdNameController;
  late final TextEditingController _parentPhoneController;

  @override
  void initState() {
    super.initState();
    final c = context.read<RegisterCubit>();
    _firstNameController = TextEditingController(text: c.firstName);
    _secondNameController = TextEditingController(text: c.secondName);
    _thirdNameController = TextEditingController(text: c.thirdName);
    _parentPhoneController = TextEditingController(text: c.parentPhoneNum);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _thirdNameController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  String? _nameValidator(String? v, String fieldLabel) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) {
      return widget.isAr ? 'ادخل $fieldLabel' : 'Enter $fieldLabel';
    }
    if (value.length < 2) {
      return widget.isAr ? 'الاسم قصير جدًا' : 'Name is too short';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (_, s) => s is RegisterFieldChanged || s is RegisterInitial,
      builder: (context, state) {
        final cubit = context.read<RegisterCubit>();

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isAr ? 'بياناتك الشخصية' : 'Personal information',
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
                    ? 'املأ بياناتك للمتابعة'
                    : 'Fill in your information to continue',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.6),
                  fontFamily: widget.fontFamily,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _SectionLabel(
                text: widget.isAr ? 'الاسم بالكامل' : 'Full name',
                fontFamily: widget.fontFamily,
              ),
              const SizedBox(height: 10),
              AuthTextField(
                controller: _firstNameController,
                label: widget.isAr ? 'الاسم الأول' : 'First name',
                icon: Icons.person_rounded,
                primaryColor: widget.primaryColor,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[ء-ي]'))
                ],
                fontFamily: widget.fontFamily,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onChanged: cubit.setFirstName,
                validator: (v) => _nameValidator(
                    v, widget.isAr ? 'الاسم الأول' : 'first name'),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _secondNameController,
                label: widget.isAr ? 'الاسم الثاني' : 'Second name',
                icon: Icons.person_outline_rounded,
                primaryColor: widget.primaryColor,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[ء-ي]'))
                ],
                fontFamily: widget.fontFamily,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onChanged: cubit.setSecondName,
                validator: (v) => _nameValidator(
                    v, widget.isAr ? 'الاسم الثاني' : 'second name'),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _thirdNameController,
                label: widget.isAr ? 'الاسم الثالث' : 'Third name',
                icon: Icons.person_outline_rounded,
                primaryColor: widget.primaryColor,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[ء-ي]'))
                ],
                fontFamily: widget.fontFamily,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onChanged: cubit.setThirdName,
                validator: (v) => _nameValidator(
                    v, widget.isAr ? 'الاسم الثالث' : 'third name'),
              ),
              const SizedBox(height: 22),
              _SectionLabel(
                text: widget.isAr ? 'النوع' : 'Gender',
                fontFamily: widget.fontFamily,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OptionCard(
                      label: 'طالب',
                      icon: Icons.male_rounded,
                      selected: cubit.gender == Gender.male,
                      primaryColor: widget.primaryColor,
                      fontFamily: widget.fontFamily,
                      onTap: () {
                        setState(() {});
                        cubit.setGender(Gender.male);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OptionCard(
                      label: 'طالبة',
                      icon: Icons.female_rounded,
                      selected: cubit.gender == Gender.female,
                      primaryColor: widget.primaryColor,
                      fontFamily: widget.fontFamily,
                      onTap: () {
                        setState(() {});
                        cubit.setGender(Gender.female);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _SectionLabel(
                text: widget.isAr ? 'رقم ولي الأمر' : 'Parent phone',
                fontFamily: widget.fontFamily,
              ),
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: AuthTextField(
                  controller: _parentPhoneController,
                  label: widget.isAr ? 'رقم ولي الأمر' : 'Parent phone',
                  icon: Icons.support_agent_rounded,
                  primaryColor: widget.primaryColor,
                  fontFamily: widget.fontFamily,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  maxLength: 11,
                  onChanged: cubit.setParentPhone,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) {
                      return widget.isAr
                          ? 'ادخل رقم ولي الأمر'
                          : 'Enter parent phone';
                    }
                    if (value.length != 11 || !value.startsWith('01')) {
                      return widget.isAr
                          ? 'رقم غير صحيح'
                          : 'Invalid phone number';
                    }
                    if (value == cubit.phoneNum) {
                      return widget.isAr
                          ? 'لا يمكن أن يكون نفس رقم الطالب'
                          : 'Must differ from student phone';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 22),
              _SectionLabel(
                text: widget.isAr ? 'الصف الدراسي' : 'Grade',
                fontFamily: widget.fontFamily,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OptionCard(
                      label: widget.isAr ? 'الصف\nالثاني' : 'Second\ngrade',
                      icon: Icons.school_rounded,
                      selected: cubit.grade == StudyGrade.second,
                      primaryColor: widget.primaryColor,
                      fontFamily: widget.fontFamily,
                      onTap: () {
                        setState(() {});
                        cubit.setGrade(StudyGrade.second);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OptionCard(
                      label: widget.isAr ? 'الصف\nالثالث' : 'Third\ngrade',
                      icon: Icons.school_outlined,
                      selected: cubit.grade == StudyGrade.third,
                      primaryColor: widget.primaryColor,
                      fontFamily: widget.fontFamily,
                      onTap: () {
                        setState(() {});
                        cubit.setGrade(StudyGrade.third);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              AuthSecondaryButton(
                primaryColor: widget.primaryColor,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (!_formKey.currentState!.validate()) return;
                  if (cubit.gender == null) {
                    AppStatusDialog.show(
                      context: context,
                      status: AppDialogStatus.warning,
                      title: widget.isAr ? 'تنبيه' : 'Notice',
                      message: widget.isAr
                          ? 'برجاء اختيار النوع'
                          : 'Please select your gender',
                      isAr: widget.isAr,
                    );
                    return;
                  }
                  if (cubit.grade == null) {
                    AppStatusDialog.show(
                      context: context,
                      status: AppDialogStatus.warning,
                      title: widget.isAr ? 'تنبيه' : 'Notice',
                      message: widget.isAr
                          ? 'برجاء اختيار الصف الدراسي'
                          : 'Please select your grade',
                      isAr: widget.isAr,
                    );
                    return;
                  }
                  widget.onNext();
                },
                //  isLoading: false,
                text: widget.isAr ? 'التالي' : 'Next',
                // loadingText: '',
                icon: Icons.arrow_forward_rounded,
                fontFamily: widget.fontFamily,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final String fontFamily;

  const _SectionLabel({required this.text, required this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: const Color(0xff1a1a1a),
      ),
    );
  }
}
