// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';

import '../../../constants/colors.dart';
import '../../../constants/styles.dart';
import '../../../constants/widgets.dart';
import '../../../generated/l10n.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});
  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformUpdatePasswordLoadingState) {
          isLoading = true;
        }
        if (state is PlatformUpdatePasswordFailState) {
          isLoading = false;
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err
                .substring(state.err.indexOf(']') + 2, state.err.length),
          );
        }
        if (state is PlatformUpdatePasswordSuccessState) {
          isLoading = false;
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.success,
            title: 'تم بنجاح',
            message: S.of(context).pass_changes_success,
            onPrimaryAction: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          );
        }
      },
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        return Scaffold(
          body: Form(
            key: formKey,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultBackBtn(
                      txt: S.of(context).edit_pass,
                      textStyle: AppTextStyles.title1Style,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.of(context).old_password,
                                style: AppTextStyles.title2Style,
                              ),
                              const SizedBox(height: 4.0),
                              DefaultTextField11(
                                controller: oldPassController,
                                height: 16.0,
                                label: S.of(context).enter_your_old_password,
                                errStr: S.of(context).password,
                                type: TextInputType.visiblePassword,
                                isPassword: cubit.isOldPassSecure,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    cubit.changeOldPassSecure();
                                  },
                                  icon: Icon(
                                    cubit.isOldPassSecure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: cubit.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24.0),
                              Text(
                                S.of(context).new_password,
                                style: AppTextStyles.title2Style,
                              ),
                              const SizedBox(height: 4.0),
                              DefaultTextField11(
                                controller: newPassController,
                                height: 16.0,
                                label: S.of(context).enter_your_new_password,
                                errStr: S.of(context).password,
                                type: TextInputType.visiblePassword,
                                isPassword: cubit.isNewPassSecure,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    cubit.changeNewPassSecure();
                                  },
                                  icon: Icon(
                                    cubit.isNewPassSecure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: cubit.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DefaultWaitedButton(
                                  isLoading: isLoading,
                                  width: double.infinity,
                                  isDarkMode: cubit.isDarkMode,
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      bool isConnected =
                                          await Components.checkConnection();
                                      if (isConnected) {
                                        cubit.updatePassword(
                                          oldPass: oldPassController.text,
                                          newPass: newPassController.text,
                                        );
                                      } else {
                                        AppStatusDialog.show(
                                          context: context,
                                          status: AppDialogStatus.error,
                                          message: S.of(context).no_internet,
                                          title: cubit.isAr ? 'تنبيه' : 'Alert',
                                        );
                                      }
                                    }
                                  },
                                  txt: S.of(context).update,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                flex: 1,
                                child: DefaultButton(
                                  onPressed: () {
                                    if (oldPassController.text.isEmpty &&
                                        newPassController.text.isEmpty) {
                                      Components.pop(context: context);
                                    } else {
                                      AppStatusDialog.show(
                                        context: context,
                                        message: cubit.isAr
                                            ? 'هل أنت متأكد من الخروج؟'
                                            : 'Are You Sure to Exit?',
                                        status: AppDialogStatus.warning,
                                        title: 'تنبيه',
                                        primaryActionText:
                                            cubit.isAr ? 'خروج' : 'Exit',
                                        onPrimaryAction: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        secondaryActionText:
                                            cubit.isAr ? 'إلغاء' : 'Cancel',
                                        onSecondaryAction: () {
                                          Navigator.pop(context);
                                        },
                                        isAr: cubit.isAr,
                                      );
                                    }
                                  },
                                  color: cubit.isDarkMode
                                      ? AppColors.darkBorder
                                      : AppColors.lightBborder,
                                  isDarkMode: cubit.isDarkMode,
                                  child: Text(
                                    S.of(context).cancel,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.body2Style,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
