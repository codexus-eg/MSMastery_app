// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/styles.dart';
import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/screens/quiz/quiz_questions_screen.dart';

import '../../bloc/platformCubit.dart';
import '../../generated/l10n.dart';

class StartQuizScreen extends StatelessWidget {
  StartQuizScreen({
    super.key,
    this.lecId,
    this.minDegree,
    this.price,
    this.thumbnail,
    this.title,
    this.chapId,
    this.dep,
  });

  String? thumbnail;
  int? price;
  String? title;
  String? chapId;
  bool? dep;
  bool isLoading = false;
  String? lecId;
  int? minDegree;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformQuizGetQuizesLoadingState) {
          isLoading = true;
        }
        if (state is PlatformQuizGetQuizesFailState) {
          isLoading = false;
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err
                .substring(state.err.indexOf(']') + 2, state.err.length),
          );
        }
        if (state is PlatformQuizGetQuizesSuccessState) {
          isLoading = false;

          Components.push(
            context: context,
            widget: QuizQuestionsScreen(
              chapId: chapId,
              dep: dep,
              price: price,
              thumbnail: thumbnail,
              title: title,
              cubit: PlatformCubit.get(context),
              lecId: lecId,
            ),
          );
        }
      },
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        final quiz = PlatformCubit.quizModel!;
        final isDark = cubit.isDarkMode;
        final primary = Components.setBgColor(isDark);
        final hasMinDegree = minDegree != null && minDegree != 0;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultBackBtn(
                    txt: S.of(context).quiz,
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // ---------------- Hero header ----------------
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 32.0, horizontal: 20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28.0),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.appPrimaryColor,
                                  AppColors.appSecondaryColor,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.18),
                                  ),
                                  child: const Icon(
                                    Icons.assignment_rounded,
                                    color: Colors.white,
                                    size: 46,
                                  ),
                                ),
                                const SizedBox(height: 18.0),
                                Text(
                                  quiz.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.title2Style.copyWith(
                                    color: Colors.white,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          // ---------------- Stat cards ----------------
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _QuizStatCard(
                                    icon: Icons.timer_outlined,
                                    value: '${quiz.duration}',
                                    label: S.of(context).mins,
                                    isDarkMode: isDark,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: _QuizStatCard(
                                    icon: Icons.help_outline_rounded,
                                    value: '${quiz.questionsNum}',
                                    label: quiz.questionsNum <= 10
                                        ? S.of(context).question
                                        : S.of(context).questionss,
                                    isDarkMode: isDark,
                                  ),
                                ),
                                if (quiz.fullMark != quiz.questionsNum) ...[
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: _QuizStatCard(
                                      icon: Icons.star_rounded,
                                      value: '${quiz.fullMark}',
                                      label: S.of(context).fullMarkk,
                                      isDarkMode: isDark,
                                    ),
                                  ),
                                ],
                                if (hasMinDegree) ...[
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: _QuizStatCard(
                                      icon: Icons.flag_rounded,
                                      value: '$minDegree/${quiz.fullMark}',
                                      label: S.of(context).min_degree,
                                      isDarkMode: isDark,
                                      highlight: true,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // ---------------- Warning note ----------------
                          if (hasMinDegree) ...[
                            const SizedBox(height: 16.0),
                            Container(
                              padding: const EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                color: const Color(0xffe0922f)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: const Color(0xffe0922f)
                                      .withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xffe0922f),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      S.of(context).min_degree_warning,
                                      style: AppTextStyles.body2Style.copyWith(
                                        fontSize: 13.5,
                                        height: 1.4,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.85)
                                            : Colors.black
                                                .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // ---------------- Start button ----------------
                  DefaultWaitedButton(
                    isLoading: isLoading,
                    isDarkMode: isDark,
                    width: double.infinity,
                    onPressed: () async {
                      bool isConnected = await Components.checkConnection();
                      if (isConnected) {
                        cubit.getQuestions(
                          quizCode: quiz.id,
                          isInQuizScreen: false,
                          lecId: lecId,
                        );
                      } else {
                        AppStatusDialog.show(
                          context: context,
                          status: AppDialogStatus.error,
                          message: S.of(context).no_internet,
                          title: 'خلي بالك',
                        );
                      }
                    },
                    txt: S.of(context).start,
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

/// Compact stat card showing a quiz metric (icon, value, label).
class _QuizStatCard extends StatelessWidget {
  const _QuizStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDarkMode,
    this.highlight = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool isDarkMode;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final primary = Components.setBgColor(isDarkMode);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: highlight
            ? primary.withValues(alpha: isDarkMode ? 0.22 : 0.12)
            : (isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: primary.withValues(alpha: highlight ? 0.5 : 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primary, size: 26),
          const SizedBox(height: 8.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: AppTextStyles.title2Style.copyWith(
                fontSize: 18.0,
                color: primary,
              ),
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body2Style.copyWith(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
