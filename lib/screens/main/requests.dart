// ignore_for_file: must_be_immutable, non_constant_identifier_names, library_private_types_in_public_api

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/styles.dart';
import 'package:salah_online_platform/services/notification_service.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/models/user_model.dart';

import '../../constants/colors.dart';
import '../../constants/widgets.dart';
import '../../generated/l10n.dart';
import '../../models/RequsetsModel.dart';
import 'chat_screen.dart';
import 'Overlay.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({
    super.key,
  });

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<FormState> formKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    PlatformCubit.get(context).getRequests();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is AddRequestSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request added successfully')),
          );
        } else if (state is AddRequestErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add request')),
          );
        }
      },
      builder: (context, state) {
        PlatformCubit cubb = PlatformCubit.get(context);

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }
            if (cubb.down) {
              cubb.changing(context);
            } else {
              Navigator.pop(context);
            }
          },
          child: Scaffold(
            key: scaffoldKey,
            body: Container(
              /*
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    cubb.isDarkMode
                        ? Constants.wallpaberDark
                        : Constants.wallpaberLight,
                  ),
                ),
              ),
              */
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultBackBtn(
                        txt: S.of(context).requests,
                        onTap: () {
                          if (cubb.down) {
                            cubb.changing(context);
                          }
                          Navigator.pop(context);
                        },
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ToggleSwitch(
                          initialLabelIndex: cubb.choice,
                          dividerColor:
                              cubb.isDarkMode ? Colors.white : Colors.black,
                          minWidth: 100.0,
                          minHeight: 35,
                          totalSwitches: 4,
                          cornerRadius: 20,
                          textDirectionRTL: cubb.isAr,
                          inactiveBgColor: cubb.isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.lightBborder,
                          activeBgColor: [
                            Components.setBgColor(cubb.isDarkMode)
                          ],
                          labels: const [
                            'All',
                            'Taken',
                            'Pending',
                            'Ended',
                          ],
                          onToggle: (index) {
                            cubb.choice = index!;
                            cubb.filteredRequests(cubb.choice);
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => cubb.getRequests(),
                          child: ConditionalBuilder(
                              condition: cubb.requests1.isEmpty ||
                                  cubb.filterRequests1.isEmpty,
                              builder: (context) => ListView(
                                    children: [
                                      Center(
                                        child: Text(
                                          S.of(context).no_requests_yet,
                                          style: AppTextStyles.title2Style,
                                        ),
                                      ),
                                    ],
                                  ),
                              fallback: (context) {
                                return ListView.separated(
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return BuildRequest(
                                      context,
                                      cubb.filterRequests1[index],
                                      cubb,
                                      index,
                                    );
                                  },
                                  itemCount: cubb.filterRequests1.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 10),
                                );
                              }),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Components.setBgColor(cubb.isDarkMode),
              onPressed: state is AddRequestLoadingState
                  ? null
                  : () async {
                      if (cubb.down) {
                        if (formKey.currentState!.validate()) {
                          List<String> url;
                          if (cubb.images.isNotEmpty) {
                            url = await cubb.uplaodImage2(files: cubb.images);
                          } else {
                            url = [];
                          }
                          // debugPrint(url);
                          UserModel? um = Constants.userBox.get('user');
                          await cubb.addRequest(
                            url,
                            request: cubb.requestController.text,
                            senderId: um!.code!,
                            State: 'pending',
                            title:
                                '${S.of(context).request} ${cubb.requests1.length + 1}',
                            stdToken: um.pushToken ?? '',
                          );
                          NotificationService.sendToTopic(
                            topic: 'req',
                            title: 'سؤال جديد',
                            body: cubb.requestController.text,
                          );
                          cubb.changing(context);
                        }
                      } else {
                        if (!cubb.isGuest()) {
                          scaffoldKey.currentState!.showBodyScrim(
                            true,
                            0.6,
                          );

                          scaffoldKey.currentState!.showBottomSheet(
                            enableDrag: false,
                            (context1) {
                              return BlocConsumer<PlatformCubit,
                                  PlatformStates>(
                                listener: (context, state) {},
                                builder: (context, state) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Components.setBgColor(
                                          cubb.isDarkMode),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          alignment:
                                              AlignmentDirectional.topStart,
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                  top: Radius.circular(
                                                    28.0,
                                                  ),
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: Text(
                                                  S.of(context).new_req,
                                                  style: AppTextStyles
                                                      .title1Style
                                                      .copyWith(
                                                    color:
                                                        Components.setTextColor(
                                                            cubb.isDarkMode),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .only(
                                                start: 8.0,
                                                top: 8.0,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  cubb.changing(context);
                                                },
                                                child: CircleAvatar(
                                                  backgroundColor: cubb
                                                          .isDarkMode
                                                      ? AppColors.darkBorder
                                                      : AppColors.lightBborder,
                                                  radius: 16.0,
                                                  child: Icon(
                                                    Icons.close,
                                                    color: cubb.isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(28.0),
                                              topRight: Radius.circular(28.0),
                                            ),
                                            color: cubb.isDarkMode
                                                ? AppColors.darkBgColor
                                                : AppColors.lightBgColor,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 65.0,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: ListView.separated(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context1, index) {
                                                          if (index ==
                                                              cubb.images
                                                                  .length) {
                                                            return GestureDetector(
                                                              onTap: () {
                                                                cubb.pick(
                                                                    ImageSource
                                                                        .gallery);
                                                              },
                                                              child: Container(
                                                                width: 50.0,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12.0),
                                                                  color: cubb
                                                                          .isDarkMode
                                                                      ? AppColors
                                                                          .darkBorder
                                                                      : AppColors
                                                                          .lightBborder,
                                                                ),
                                                                child:
                                                                    const Icon(
                                                                  Icons.add,
                                                                  size: 32.0,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          return ImagesIcons(
                                                            index,
                                                            cubb,
                                                            context1,
                                                            cubb.images[index]!,
                                                          );
                                                        },
                                                        separatorBuilder:
                                                            (context, index) =>
                                                                const SizedBox(
                                                                    width:
                                                                        12.0),
                                                        itemCount: cubb
                                                                .images.length +
                                                            1, // Add 1 to include the GestureDetector
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 12.0),
                                              Form(
                                                key: formKey,
                                                child: DefaultTextField11(
                                                  type: TextInputType.multiline,
                                                  textInputAction:
                                                      TextInputAction.newline,
                                                  controller:
                                                      cubb.requestController,
                                                  maxLines: 5,
                                                  errStr: S.of(context).new_req,
                                                  label: S
                                                      .of(context)
                                                      .enter_new_req,
                                                ),
                                              ),
                                              const SizedBox(height: 22.0),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            backgroundColor:
                                Components.setBgColor(cubb.isDarkMode),
                          );
                          cubb.changing(context);
                        } else {
                          Constants.showLoginDialog(
                            isDarkMode: cubb.isDarkMode,
                            context: context,
                          );
                        }
                      }
                    },
              child: state is AddRequestLoadingState
                  ? CircularProgressIndicator(
                      color: Components.setTextColor(cubb.isDarkMode),
                    )
                  : cubb.icon,
            ),
          ),
        );
      },
    );
  }
}

Widget ImagesIcons(index, PlatformCubit cubb, context, File file) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                FullScreenImageViewer.showFullImage2(context, file);
              },
              child: SizedBox(
                width: 50,
                height: 55,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: -15,
              start: -12,
              child: GestureDetector(
                onTap: () {
                  cubb.deleteImage(index);
                },
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      cubb.isDarkMode ? Colors.black : Colors.white,
                  child: const Icon(
                    Icons.cancel,
                    size: 26.0,
                    color: Colors.grey,
                  ),
                  // child: Text("$index"),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget ImagesIcons2(index, context, String imageurl, bool isDarkMode) {
  return GestureDetector(
    onTap: () {
      FullScreenImageViewer.showFullImage(context, imageurl);
    },
    child: Column(
      children: [
        SizedBox(
          width: 60.0,
          height: 60.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DefaultImage(
              imgUrl: imageurl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget BuildRequest(
  context,
  RequsetsModel request,
  PlatformCubit cubb,
  index,
) {
  return GestureDetector(
    onTap: () {
      if (request.state == "taken" || request.state == "ended") {
        PlatformCubit.student = true;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              requestTitle: request.title,
              requestId: request.id,
              requestState: request.state,
              token: request.token,
            ),
          ),
        );
      } else {
        requestOverlay2(
          request,
          context,
          '${S.of(context).request} ${index + 1}',
          cubb,
        );
        // cubb.AnyWay(context);
      }
    },
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        padding: const EdgeInsetsDirectional.only(
          top: 12.0,
          start: 8.0,
          end: 8.0,
        ),
        decoration: BoxDecoration(
          color: cubb.isDarkMode
              ? AppColors.darkBorder
              : AppColors.lightBborder, // Background color
          borderRadius:
              const BorderRadius.all(Radius.circular(20.0)), // Rounded corners
        ),
        child: Column(
          children: [
            Row(
              children: [
                request.imageurl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: CachedNetworkImage(
                          imageUrl: request.imageurl[0],
                          width: 50,
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          ),
                          height: 50,
                          fit: BoxFit.fill,
                        ))
                    : CircleAvatar(
                        backgroundColor: Colors.grey[100],
                        radius: 25,
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${S.of(context).request} ${index + 1}',
                        style: AppTextStyles.title2Style,
                      ),
                      Text(
                        maxLines: 2,
                        request.request,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body2Style.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                request.state == "taken"
                    ? const CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.green,
                      )
                    : request.state == "pending"
                        ? const CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.red,
                          )
                        : const Icon(
                            Icons.arrow_forward,
                            size: 30,
                          )
              ],
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.only(bottom: 6, end: 6, top: 15),
              child: Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: Text(
                  cubb.formatDate(request.date),
                  style: AppTextStyles.body2Style,
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
