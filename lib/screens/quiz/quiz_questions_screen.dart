// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../constants/styles.dart';
import '../../constants/widgets.dart';
import '../../generated/l10n.dart';
import '../../network/local/shared_pref_helper.dart';

class QuizQuestionsScreen extends StatefulWidget {
  QuizQuestionsScreen({
    super.key,
    required this.cubit,
    this.price,
    this.thumbnail,
    this.title,
    this.chapId,
    this.lecId,
    // this.minDegree,
    this.dep,
  });

  String? thumbnail;
  int? price;
  String? title;
  String? chapId;
  bool? dep;
  PlatformCubit cubit;
  String? lecId;
  // int? minDegree;

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  var pageController = PageController(initialPage: 0);
  bool isComplete = false;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.cubit.writtenAnswsMap.clear();

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
    widget.cubit.writtenAnswsMap.clear();
    await Constants.noScreenshot.screenshotOn();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformAddStdPointsLoadingState) {
          isLoading = true;
        }
        if (state is PlatformAddStdPointsFailState) {
          isLoading = false;
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            message: state.err
                .substring(state.err.indexOf(']') + 2, state.err.length),
            title: 'خلي بالك',
          );
        }
        if (state is PlatformAddStdPointsSuccessState) {
          isLoading = false;
          widget.cubit.isAr = SharedPrefHelper.getData('isAr') ?? true;
          widget.cubit.rebuild();

          if (widget.lecId != null) {
            Navigator.popUntil(
              context,
              (route) => route.settings.name == 'lectureDetails',
            );
          } else {
            widget.cubit.getAvaExams();
            Navigator.popUntil(
              context,
              (route) =>
                  route.settings.name == Components.homeRouteName ||
                  route.isFirst,
            );
            // widget.cubit.navigateToHomeTab(2);
          }
        }
      },
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        final isDark = cubit.isDarkMode;
        final int total = cubit.quizQuestions.length;
        final int answered = _answeredCount(cubit);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              return;
            }

            AppStatusDialog.show(
              context: context,
              status: AppDialogStatus.warning,
              message: SharedPrefHelper.getData('isAr') ?? true
                  ? 'هل أنت متأكد من الخروج؟'
                  : 'Are You Sure to Exit?',
              title: 'خلي بالك',
              primaryActionText: S.of(context).exit,
              onPrimaryAction: () {
                Navigator.pop(context);
                Navigator.pop(context);

                widget.cubit.isAr = SharedPrefHelper.getData('isAr') ?? true;
                widget.cubit.rebuild();
              },
            );
          },
          child: Scaffold(
            backgroundColor:
                isDark ? AppColors.darkBgColor : AppColors.lightBgColor,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, cubit, total, answered),
                  _buildQuestionNavigator(context, cubit),
                  const SizedBox(height: 4.0),
                  Expanded(
                    child: PageView.builder(
                      itemCount: total,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (value) {
                        FocusScope.of(context).unfocus();
                        setState(() => currentIndex = value);
                        cubit.changeIsLast(value == total - 1);
                        cubit.changeIsStart(value == 0);
                      },
                      controller: pageController,
                      itemBuilder: (context, index) => BuildQuizItem(
                        cubit: cubit,
                        isQuestionbank: false,
                        questionModel: cubit.quizQuestions[index],
                        queIdx: index,
                        length: total,
                      ),
                    ),
                  ),
                  _buildNavBar(context, cubit),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────── Header ─────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    PlatformCubit cubit,
    int total,
    int answered,
  ) {
    final isDark = cubit.isDarkMode;
    final double progress = total == 0 ? 0 : answered / total;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28.0),
          bottomRight: Radius.circular(28.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 16.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.title != null && widget.title!.trim().isNotEmpty)
                      Text(
                        widget.title!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title2Style.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                    const SizedBox(height: 2.0),
                    Text(
                      '${currentIndex + 1} ${S.of(context).of_} $total ${S.of(context).questionss}',
                      style: AppTextStyles.body2Style.copyWith(
                        color: Colors.grey,
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTimer(cubit),
            ],
          ),
          const SizedBox(height: 14.0),
          // Progress bar with answered count.
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0, end: progress),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 8.0,
                      backgroundColor: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBborder,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.appPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                '$answered/$total',
                style: AppTextStyles.body2Style.copyWith(
                  color: AppColors.appPrimaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(PlatformCubit cubit) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SlideCountdown(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.appPrimaryColor,
              AppColors.appSecondaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.0),
        ),
        duration: Duration(minutes: PlatformCubit.quizModel!.duration),
        onDone: () {
          cubit.addStdPoints(
            isComplete: true,
            lecId: widget.lecId,
          );
        },
        icon: const Padding(
          padding: EdgeInsets.only(right: 6),
          child: Icon(
            Icons.timer_outlined,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  // ──────────────────────── Question navigator ────────────────────────
  Widget _buildQuestionNavigator(BuildContext context, PlatformCubit cubit) {
    final isDark = cubit.isDarkMode;
    return SizedBox(
      height: 56.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemBuilder: (context, index) {
          final bool answered = !checkMissingAnswersWithIndex(cubit, index);
          final bool isCurrent = index == currentIndex;

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 600),
                curve: Curves.fastEaseInToSlowEaseOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 42.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: answered
                    ? LinearGradient(
                        colors: [
                          AppColors.appPrimaryColor,
                          AppColors.appSecondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: answered ? null : (isDark ? Colors.black : Colors.white),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.appPrimaryColor
                      : (answered
                          ? Colors.transparent
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBborder)),
                  width: isCurrent ? 2.4 : 1.2,
                ),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: answered
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black),
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        itemCount: cubit.quizQuestions.length,
      ),
    );
  }

  // ─────────────────────────── Bottom nav bar ───────────────────────────
  Widget _buildNavBar(BuildContext context, PlatformCubit cubit) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      decoration: BoxDecoration(
        color: cubit.isDarkMode ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28.0),
          topRight: Radius.circular(28.0),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: cubit.isDarkMode ? 0.4 : 0.08),
            blurRadius: 16.0,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!cubit.isStart)
            _SquareNavButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                FocusScope.of(context).unfocus();
                pageController.previousPage(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.fastEaseInToSlowEaseOut,
                );
              },
            ),
          if (!cubit.isStart) const SizedBox(width: 10.0),
          Expanded(
            child: _GradientButton(
              label: cubit.isLast ? S.of(context).complete : S.of(context).next,
              icon: cubit.isLast
                  ? Icons.check_rounded
                  : Icons.arrow_forward_ios_rounded,
              onTap: () => _onPrimaryAction(context, cubit),
            ),
          ),
        ],
      ),
    );
  }

  void _onPrimaryAction(BuildContext context, PlatformCubit cubit) {
    FocusScope.of(context).unfocus();
    if (cubit.isLast) {
      if (checkMissingAnswers(cubit)) {
        AppStatusDialog.show(
          context: context,
          status: AppDialogStatus.info,
          message: S.of(context).sure_complete,
          title: 'بقولك ايه',
          primaryActionText: S.of(context).complete,
          onPrimaryAction: () {
            Navigator.pop(context); // Dismiss dialog first
            cubit.addStdPoints(
              isComplete: true,
              lecId: widget.lecId,
            );
          },
        );
      } else {
        AppStatusDialog.show(
          context: context,
          status: AppDialogStatus.success,
          message: S.of(context).you_complete_success,
          title: 'تم بنجاح',
          primaryActionText: S.of(context).complete,
          onPrimaryAction: () {
            Navigator.pop(context); // Dismiss dialog first
            cubit.addStdPoints(
              isComplete: true,
              lecId: widget.lecId,
            );
          },
        );
        debugPrint('complete!');
        debugPrint(cubit.getResult().toString());
      }
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    }
  }

  int _answeredCount(PlatformCubit cubit) {
    int count = 0;
    for (int i = 0; i < cubit.quizQuestions.length; i++) {
      if (!checkMissingAnswersWithIndex(cubit, i)) count++;
    }
    return count;
  }

  bool checkMissingAnswers(PlatformCubit cubit) {
    for (var question in cubit.quizQuestions) {
      final qId = question.id;

      // If it's a multiple-choice question
      if (question.options != null && question.options!.isNotEmpty) {
        final ans = cubit.stdQuizAnsws[qId];
        if (ans == null || ans.toString().isEmpty) {
          return true; // Missing MCQ answer
        }
      }

      // If it's a written question
      else {
        final written = cubit.writtenAnswsMap[qId];
        if (written == null ||
            (written.text.trim().isEmpty && written.imagesUrl.isEmpty)) {
          return true; // Missing written answer
        }
      }
    }

    return false; // All questions answered
  }

  bool checkMissingAnswersWithIndex(PlatformCubit cubit, int index) {
    var question = cubit.quizQuestions[index];
    final qId = question.id;

    // If it's a multiple-choice question
    if (question.options != null && question.options!.isNotEmpty) {
      final ans = cubit.stdQuizAnsws[qId];
      if (ans == null || ans.toString().isEmpty) {
        return true; // Missing MCQ answer
      }
    }

    // If it's a written question
    else {
      final written = cubit.writtenAnswsMap[qId];
      if (written == null ||
          (written.text.trim().isEmpty && written.imagesUrl.isEmpty)) {
        return true; // Missing written answer
      }
    }

    return false; // All questions answered
  }
}

// ───────────────────────────── Buttons ─────────────────────────────
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Ink(
          height: 54.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.appPrimaryColor,
                AppColors.appSecondaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.appPrimaryColor.withValues(alpha: 0.35),
                blurRadius: 12.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8.0),
                Icon(icon, color: Colors.white, size: 18.0),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareNavButton extends StatelessWidget {
  const _SquareNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cubit = PlatformCubit.get(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Container(
          height: 54.0,
          width: 54.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cubit.isDarkMode
                ? AppColors.darkBorder
                : AppColors.lightBborder,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Icon(
            icon,
            color: AppColors.appPrimaryColor,
            size: 20.0,
          ),
        ),
      ),
    );
  }
}
