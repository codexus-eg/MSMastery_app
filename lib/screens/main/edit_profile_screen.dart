// ignore_for_file: non_constant_identifier_names, must_be_immutable, use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/constants/styles.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/models/user_model.dart';

import '../../constants/widgets.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key}) {
    UserModel um = Constants.userBox.get('user');
    fNameController.text = um.fname ?? '';
    sNameController.text = um.sname ?? '';
    thNameController.text = um.thname ?? '';
    ar_fNameController.text = um.ar_fname ?? '';
    ar_sNameController.text = um.ar_sname ?? '';
    ar_thNameController.text = um.ar_thname ?? '';
  }

  late UserModel um;
  TextEditingController fNameController = TextEditingController();

  TextEditingController sNameController = TextEditingController();

  TextEditingController thNameController = TextEditingController();

  TextEditingController ar_fNameController = TextEditingController();

  TextEditingController ar_sNameController = TextEditingController();

  TextEditingController ar_thNameController = TextEditingController();

  var formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformUplaodUpdatedDataSuccessState) {
          isLoading = false;

          PlatformCubit.get(context).userImage = null;
          Navigator.pop(context);
        }
        if (state is PlatformPickImageFromGalleryFailState) {
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err,
          );
        }
        if (state is PlatformUplaodUpdatedDataLoadingState ||
            state is PlatformUplaodImageLoadingState) {
          isLoading = true;
        }
        if (state is PlatformUplaodUpdatedDataFailState) {
          isLoading = false;
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err
                .substring(state.err.indexOf(']') + 2, state.err.length),
          );
        }
      },
      builder: (context, state) {
        um = Constants.userBox.get('user');

        var cubit = PlatformCubit.get(context);

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }

            if (changed(cubit)) {
              AppStatusDialog.show(
                context: context,
                status: AppDialogStatus.warning,
                title: S.of(context).discard_changes,
                message: "Are you sure you want to discard changes?",
                primaryActionText: S.of(context).discard,
                onPrimaryAction: () {
                  cubit.userImage = null;
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              );
            } else {
              Navigator.pop(context);
            }
          },
          child: Form(
            key: formKey,
            child: Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultBackBtn(
                          txt: S.of(context).edit_profile,
                          textStyle: AppTextStyles.title1Style,
                          onTap: () {
                            if (changed(cubit)) {
                              AppStatusDialog.show(
                                context: context,
                                status: AppDialogStatus.warning,
                                title: S.of(context).discard_changes,
                                message:
                                    "Are you sure you want to discard changes?",
                                primaryActionText: S.of(context).discard,
                                onPrimaryAction: () {
                                  cubit.userImage = null;
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          }),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: InkWell(
                                  onTap: () async {
                                    debugPrint('User Image Presses');
                                    File? file = await cubit
                                        .pickImageFromGallery(context);
                                    if (file != null) {
                                      cubit.userImage = file;
                                      debugPrint(cubit.userImage!.path);
                                    }
                                  },
                                  child: Stack(
                                    alignment: AlignmentDirectional.bottomEnd,
                                    children: [
                                      CircleAvatar(
                                        radius: 70.0,
                                        backgroundImage: cubit.userImage == null
                                            ? CachedNetworkImageProvider(
                                                um.img ?? '',
                                              ) as ImageProvider
                                            : FileImage(cubit.userImage!),
                                        backgroundColor: Colors.white,
                                      ),
                                      const CircleAvatar(
                                        radius: 18.0,
                                        backgroundColor: Colors.black45,
                                        child: Icon(
                                          Icons.edit,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 15,
                              ),
                              /*
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!cubit.showDelAcc)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              S.of(context).name,
                                              style:
                                                  AppTextStyles.title2Style,
                                            ),
                                            const SizedBox(width: 2.0),
                                            Text(
                                              '(${S.of(context).in_english})',
                                              style: AppTextStyles.body2Style
                                                  .copyWith(
                                                      color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2.0),
                                        Row(
                                          textDirection: cubit.isAr
                                              ? TextDirection.ltr
                                              : TextDirection.ltr,
                                          children: [
                                            Expanded(
                                              child: DefaultTextField11(
                                                errStr: 'First Name',
                                                label: 'First',
                                                textInputAction: cubit.isAr
                                                    ? TextInputAction.previous
                                                    : TextInputAction.next,
                                                type: TextInputType.name,
                                                controller: fNameController,
                                              ),
                                            ),
                                            const SizedBox(width: 4.0),
                                            Expanded(
                                              child: DefaultTextField11(
                                                label: 'Second',
                                                errStr: 'Second Name',
                                                textInputAction: cubit.isAr
                                                    ? TextInputAction.previous
                                                    : TextInputAction.next,
                                                type: TextInputType.name,
                                                controller: sNameController,
                                              ),
                                            ),
                                            const SizedBox(width: 4.0),
                                            Expanded(
                                              child: DefaultTextField11(
                                                label: 'Third',
                                                textInputAction:
                                                    TextInputAction.done,
                                                errStr: 'Third Name',
                                                type: TextInputType.name,
                                                controller: thNameController,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 12.0),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        S.of(context).name,
                                        style: AppTextStyles.title2Style,
                                      ),
                                      const SizedBox(width: 2.0),
                                      Text(
                                        '(${S.of(context).in_arabic})',
                                        style: AppTextStyles.body2Style
                                            .copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2.0),
                                  Row(
                                    textDirection: cubit.isAr
                                        ? TextDirection.ltr
                                        : TextDirection.ltr,
                                    children: [
                                      Expanded(
                                        child: DefaultTextField11(
                                          type: TextInputType.name,
                                          label: 'الثالث',
                                          textInputAction:
                                              TextInputAction.done,
                                          errStr: 'الأسم الثالث',
                                          controller: ar_thNameController,
                                        ),
                                      ),
                                      const SizedBox(width: 4.0),
                                      Expanded(
                                        child: DefaultTextField11(
                                          type: TextInputType.name,
                                          label: 'الثاني',
                                          errStr: 'الأسم الثاني',
                                          textInputAction: cubit.isAr
                                              ? TextInputAction.next
                                              : TextInputAction.previous,
                                          controller: ar_sNameController,
                                        ),
                                      ),
                                      const SizedBox(width: 4.0),
                                      Expanded(
                                        child: DefaultTextField11(
                                          type: TextInputType.name,
                                          label: 'الأول',
                                          errStr: 'الأسم الأول',
                                          textInputAction: cubit.isAr
                                              ? TextInputAction.next
                                              : TextInputAction.previous,
                                          controller: ar_fNameController,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            */
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 5,
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
                                          bool isConnected = await Components
                                              .checkConnection();
                                          if (isConnected) {
                                            if (changed(cubit)) {
                                              cubit.uplaodUpdatedUserData(
                                                ar_fname:
                                                    ar_fNameController.text,
                                                ar_sname:
                                                    ar_sNameController.text,
                                                ar_thname:
                                                    ar_thNameController.text,
                                                fname: fNameController.text,
                                                sname: sNameController.text,
                                                thname: thNameController.text,
                                                img: await cubit.uplaodImage(
                                                  file: cubit.userImage,
                                                  img: um.img!,
                                                ),
                                              );
                                            } else {
                                              AppStatusDialog.show(
                                                context: context,
                                                status: AppDialogStatus.warning,
                                                title: 'انت معدلتش حاجة',
                                                message:
                                                    "You didn't change anything",
                                              );
                                            }
                                          } else {
                                            AppStatusDialog.show(
                                              context: context,
                                              status: AppDialogStatus.error,
                                              title: 'مفيش نت',
                                              message:
                                                  S.of(context).no_internet,
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
                                        if (changed(cubit)) {
                                          AppStatusDialog.show(
                                            context: context,
                                            status: AppDialogStatus.warning,
                                            title:
                                                S.of(context).discard_changes,
                                            message:
                                                "Are you sure you want to discard changes?",
                                            primaryActionText:
                                                S.of(context).discard,
                                            onPrimaryAction: () {
                                              cubit.userImage = null;
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            },
                                          );
                                        } else {
                                          Navigator.pop(context);
                                        }
                                      },
                                      color: cubit.isDarkMode
                                          ? AppColors.darkBorder
                                          : AppColors.lightBborder,
                                      isDarkMode: cubit.isDarkMode,
                                      child: Text(
                                        S.of(context).cancel,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.body2Style
                                            .copyWith(fontSize: 14.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool changed(PlatformCubit cubit) {
    UserModel um = Constants.userBox.get('user');
    return cubit.userImage != null ||
        fNameController.text != um.fname ||
        sNameController.text != um.sname ||
        thNameController.text != um.thname ||
        ar_fNameController.text != um.ar_fname ||
        ar_sNameController.text != um.ar_sname ||
        ar_thNameController.text != um.ar_thname;
  }
}
