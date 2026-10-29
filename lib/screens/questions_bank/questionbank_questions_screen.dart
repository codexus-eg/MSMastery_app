// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../constants/widgets.dart';
import '../../generated/l10n.dart';
import '../../network/local/shared_pref_helper.dart';

class QuestionbankQuestionsScreen extends StatefulWidget {
  QuestionbankQuestionsScreen({
    super.key,
    required this.cubit,
  });
  PlatformCubit cubit;

  @override
  State<QuestionbankQuestionsScreen> createState() =>
      _QuestionbankQuestionsScreenState();
}

class _QuestionbankQuestionsScreenState
    extends State<QuestionbankQuestionsScreen> {
  var pageController = PageController(initialPage: 0);
  bool isComplete = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Constants.noScreenshot.screenshotOff();
    });
    if (!widget.cubit.isAr) {
      widget.cubit.isAr = true;
      widget.cubit.rebuild();
    }
    widget.cubit.changeIsLast(false);
    widget.cubit.changeIsStart(true);
  }

  late Color color = Components.setBgColor(widget.cubit.isDarkMode);
  bool isLoading = false;
  @override
  void dispose() async {
    super.dispose();
    await Constants.noScreenshot.screenshotOn();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformAddStdQuestionbankPointsLoadingState) {
          isLoading = true;
        }
        if (state is PlatformAddStdQuestionbankPointsFailState) {
          isLoading = false;
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err
                .substring(state.err.indexOf(']') + 2, state.err.length),
          );
        }
        if (state is PlatformAddStdQuestionbankPointsSuccessState) {
          isLoading = false;
          widget.cubit.isAr = SharedPrefHelper.getData('isAr') ?? true;
          widget.cubit.rebuild();

          Navigator.popUntil(
            context,
            (route) =>
                route.settings.name == Components.homeRouteName ||
                route.isFirst,
          );
        }
      },
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }

            AppStatusDialog.show(
              message: SharedPrefHelper.getData('isAr') ?? true
                  ? 'هل أنت متأكد من الخروج؟'
                  : 'Are You Sure to Exit?',
              context: context,
              status: AppDialogStatus.warning,
              title: 'خلي بالك',
              primaryActionText:
                  SharedPrefHelper.getData('isAr') ?? true ? 'خروج' : 'Exit',
              onPrimaryAction: () {
                Navigator.pop(context);
                Navigator.pop(context);

                widget.cubit.isAr = SharedPrefHelper.getData('isAr') ?? true;
                widget.cubit.rebuild();
              },
            );
          },
          child: Scaffold(
            backgroundColor: cubit.isDarkMode
                ? AppColors.darkBorder
                : AppColors.lightBborder,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 11,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => SizedBox(
                          width: 50.0, // Adjust the width as needed
                          child: OutlinedButton(
                            onPressed: () {
                              pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 750),
                                curve: Curves.fastEaseInToSlowEaseOut,
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                cubit.stdQuestionbankAnsws[cubit
                                            .questionbankQuestions[index].id] !=
                                        null
                                    ? color
                                    : (cubit.isDarkMode
                                        ? AppColors.darkBorder
                                        : AppColors.lightBborder),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              padding: WidgetStateProperty.all(
                                  EdgeInsets.zero), // Adjust padding as needed
                            ),
                            child: Center(
                              // Center the text within the SizedBox
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: cubit.stdQuestionbankAnsws[cubit
                                              .questionbankQuestions[index]
                                              .id] !=
                                          null
                                      ? Colors.white
                                      : cubit.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 6.0),
                        itemCount: cubit.questionbankQuestions.length,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 16.0),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: SlideCountdown(
                            decoration: BoxDecoration(
                              color: Components.setBgColor(cubit.isDarkMode),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            duration: Duration(
                              minutes: cubit.questionbankQuestions.length * 3,
                            ),
                            onDone: () {
                              cubit.addStdQuestionbankPoints(
                                isComplete: true,
                              );
                            },
                            icon: const Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.alarm,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: PageView.builder(
                      itemCount: cubit.questionbankQuestions.length,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (value) {
                        cubit.changeIsLast(
                            value == cubit.questionbankQuestions.length - 1);
                        cubit.changeIsStart(value == 0);
                      },
                      controller: pageController,
                      itemBuilder: (context, index) => BuildQuizItem(
                        cubit: cubit,
                        questionModel: cubit.questionbankQuestions[index],
                        queIdx: index,
                        isQuestionbank: true,
                        length: cubit.questionbankQuestions.length,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 16.0,
                      end: 16.0,
                      bottom: 8.0,
                      top: 8.0,
                    ),
                    child: Row(
                      children: [
                        if (!cubit.isStart)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                pageController.previousPage(
                                  duration: const Duration(milliseconds: 750),
                                  curve: Curves.fastEaseInToSlowEaseOut,
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(color),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (!cubit.isStart) const SizedBox(width: 6.0),
                        Expanded(
                          flex: 4,
                          child: OutlinedButton(
                            onPressed: () {
                              if (cubit.isLast) {
                                // if want to get result and ignore unsolved questions.   => print(cubit.getResult());

                                if (cubit.stdQuestionbankAnsws.length !=
                                    cubit.questionbankQuestions.length) {
                                  AppStatusDialog.show(
                                    context: context,
                                    status: AppDialogStatus.warning,
                                    title: 'بقولك ايه',
                                    message: S.of(context).sure_complete,
                                    primaryActionText: S.of(context).complete,
                                    onPrimaryAction: () {
                                      cubit.addStdQuestionbankPoints(
                                        isComplete: true,
                                      );
                                    },
                                  );
                                } else {
                                  AppStatusDialog.show(
                                    context: context,
                                    status: AppDialogStatus.success,
                                    title: 'الله ينور والله',
                                    message: S.of(context).you_complete_success,
                                    primaryActionText: S.of(context).complete,
                                    onPrimaryAction: () {
                                      cubit.addStdQuestionbankPoints(
                                        isComplete: true,
                                      );
                                    },
                                  );
                                  debugPrint('complete!');
                                  debugPrint(
                                      cubit.getQuestionbankResult().toString());
                                }
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 750),
                                  curve: Curves.fastEaseInToSlowEaseOut,
                                );
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(color),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                            child: Text(
                              cubit.isLast
                                  ? S.of(context).complete
                                  : S.of(context).next,
                              style: const TextStyle(color: Colors.white),
                            ),
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
