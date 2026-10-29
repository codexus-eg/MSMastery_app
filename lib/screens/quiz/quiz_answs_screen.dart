// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/models/question_model.dart';
import 'package:salah_online_platform/models/user_model.dart';
import 'package:salah_online_platform/screens/main/Overlay.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../../constants/widgets.dart';
import '../../generated/l10n.dart';

class QuizAnswersScreen extends StatefulWidget {
  QuizAnswersScreen({
    super.key,
    required this.title,
    required this.quizCode,
    this.lecId,
  });
  List<QuestionModel> questions = []; // get from firebase
  String title;
  String quizCode;
  String? lecId;

  @override
  State<QuizAnswersScreen> createState() => _QuizAnswersScreenState();
}

enum _AnsCategory { correct, wrong, missed, written }

class _QuizAnswersScreenState extends State<QuizAnswersScreen> {
  // null = show all; otherwise filter the list to one category.
  _AnsCategory? _filter;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('not work');
      await Constants.noScreenshot.screenshotOff();
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await Constants.noScreenshot.screenshotOn();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlatformCubit()
        ..getQuestions(
          quizCode: widget.quizCode.contains(',')
              ? widget.quizCode.split(',').last
              : widget.quizCode,
          isInQuizScreen: true,
        ),
      child: BlocConsumer<PlatformCubit, PlatformStates>(
        listener: (context, state) {
          if (state is PlatformQuizGetQuizesSuccessState) {
            widget.questions = state.questions;
          }
        },
        builder: (context, state) {
          var cubit = PlatformCubit.get(context);
          UserModel um = Constants.userBox.get('user');
          String quizId;
          if (widget.lecId != null) {
            quizId = '${widget.lecId},${widget.quizCode}';
          } else {
            quizId = widget.quizCode;
          }

          // 📊 Summary stats + filtered list
          int totalDegree = 0;
          double earnedDegree = 0;
          int correctCount = 0;
          int wrongCount = 0;
          int missedCount = 0;
          int writtenCount = 0;
          final List<int> visibleIndices = [];
          for (int i = 0; i < widget.questions.length; i++) {
            final q = widget.questions[i];
            totalDegree += q.degree;
            final ans = _stdAnsFor(um, quizId, i, q);
            final category = _categoryFor(q, ans);
            switch (category) {
              case _AnsCategory.correct:
                correctCount++;
                break;
              case _AnsCategory.wrong:
                wrongCount++;
                break;
              case _AnsCategory.missed:
                missedCount++;
                break;
              case _AnsCategory.written:
                writtenCount++;
                break;
            }

            // Earned degree (MCQ = full mark when correct, written = stored score).
            final bool isMcq = q.options != null && q.options!.isNotEmpty;
            if (isMcq) {
              if (ans != null && ans == q.ansIdx) earnedDegree += q.degree;
            } else {
              final parts = ans?.toString().split(',') ?? const [];
              final scoreVal =
                  parts.isEmpty ? null : double.tryParse(parts.last);
              if (scoreVal != null) earnedDegree += scoreVal;
            }

            if (_filter == null || _filter == category) {
              visibleIndices.add(i);
            }
          }

          return Scaffold(
            backgroundColor: cubit.isDarkMode
                ? AppColors.darkBgColor
                : AppColors.lightBgColor,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: DefaultBackBtn(
                        txt: widget.title,
                        textStyle: AppTextStyles.title2Style,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    if (widget.questions.isNotEmpty) ...[
                      _buildSummaryCard(
                        context,
                        isDark: cubit.isDarkMode,
                        totalQuestions: widget.questions.length,
                        correctCount: correctCount,
                        wrongCount: wrongCount,
                        missedCount: missedCount,
                        writtenCount: writtenCount,
                        earnedDegree: earnedDegree,
                        totalDegree: totalDegree,
                      ),
                      const SizedBox(height: 12.0),
                    ],
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, listIndex) {
                          final index = visibleIndices[listIndex];
                          return BuildQuizAnsItem(
                            queIdx: index,
                            title: widget.questions[index].title,
                            queAnsIdx: widget.questions[index].ansIdx,
                            questionDegree: widget.questions[index].degree,
                            stdAns: _stdAnsFor(
                                um, quizId, index, widget.questions[index]),
                            length: widget.questions.length,
                            questionModel: widget.questions[index],
                            isDarkMode: PlatformCubit.get(context).isDarkMode,
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16.0),
                        itemCount: visibleIndices.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Resolves the student's stored answer for a question (handles both the
  // legacy index-keyed map and the newer question-id-keyed map).
  dynamic _stdAnsFor(UserModel um, String quizId, int index, QuestionModel q) {
    final answ = um.stdQuizes?[quizId]?.userAnsIdx;
    if (answ == null || answ.isEmpty) return null;
    return answ.keys.first.length == 1 ? answ['$index'] : answ[q.id];
  }

  // Categorises a question. Written questions are their own category and are
  // never counted as right / wrong / missed.
  _AnsCategory _categoryFor(QuestionModel q, dynamic ans) {
    final bool isMcq = q.options != null && q.options!.isNotEmpty;
    if (!isMcq) return _AnsCategory.written;
    if (ans == null) return _AnsCategory.missed;
    if (ans == q.ansIdx) return _AnsCategory.correct;
    return _AnsCategory.wrong;
  }

  // 📊 Result summary: percentage ring, score, and tappable category filters.
  Widget _buildSummaryCard(
    BuildContext context, {
    required bool isDark,
    required int totalQuestions,
    required int correctCount,
    required int wrongCount,
    required int missedCount,
    required int writtenCount,
    required double earnedDegree,
    required int totalDegree,
  }) {
    final double pct = totalDegree > 0 ? (earnedDegree / totalDegree) : 0;
    final Color pctColor = Components.getColorFromPercentage(pct);
    String fmt(num n) =>
        n == n.toInt() ? n.toInt().toString() : n.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 14.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ⭕ Percentage ring
              CircularPercentIndicator(
                radius: 38.0,
                lineWidth: 9.0,
                animation: true,
                animationDuration: 800,
                circularStrokeCap: CircularStrokeCap.round,
                percent: pct,
                center: Text(
                  "${(pct * 100).round()}%",
                  style: AppTextStyles.body2Style.copyWith(
                    fontWeight: FontWeight.bold,
                    color: pctColor,
                  ),
                ),
                progressColor: pctColor,
                backgroundColor: pctColor.withValues(alpha: 0.15),
              ),

              const SizedBox(width: 18.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).your_result,
                      style: AppTextStyles.title2Style.copyWith(
                        fontSize: 18.0,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    _summaryStat(
                      icon: Icons.military_tech_rounded,
                      color: AppColors.appPrimaryColor,
                      text:
                          '${fmt(earnedDegree)} / $totalDegree ${S.of(context).degrees}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          // 🟢🔴🟠 Tappable category filters
          Row(
            children: [
              Expanded(
                child: _statTile(
                  count: correctCount,
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                  label: S.of(context).right,
                  category: _AnsCategory.correct,
                  isDark: isDark,
                ),
              ),
              if (wrongCount > 0) ...[
                const SizedBox(width: 8.0),
                Expanded(
                  child: _statTile(
                    count: wrongCount,
                    icon: Icons.cancel_rounded,
                    color: Colors.red,
                    label: S.of(context).wrong,
                    category: _AnsCategory.wrong,
                    isDark: isDark,
                  ),
                ),
              ],
              if (missedCount > 0) ...[
                const SizedBox(width: 8.0),
                Expanded(
                  child: _statTile(
                    count: missedCount,
                    icon: Icons.remove_circle_rounded,
                    color: Colors.orange,
                    label: S.of(context).missed,
                    category: _AnsCategory.missed,
                    isDark: isDark,
                  ),
                ),
              ], // 📝 Written tile — only when the exam has written questions.
              if (writtenCount > 0) ...[
                const SizedBox(width: 8.0),
                Expanded(
                  child: _statTile(
                    count: writtenCount,
                    icon: Icons.edit_note_rounded,
                    color: Colors.teal,
                    label: S.of(context).written,
                    category: _AnsCategory.written,
                    isDark: isDark,
                  ),
                ),
              ],
            ],
          ),
          if (_filter != null) ...[
            const SizedBox(height: 6.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _filter = null),
                icon: const Icon(Icons.close_rounded, size: 16.0),
                label: Text(S.of(context).clear_filter),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.appPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statTile({
    required int count,
    required IconData icon,
    required Color color,
    required String label,
    required _AnsCategory category,
    required bool isDark,
  }) {
    final bool active = _filter == category;
    return GestureDetector(
      onTap: count == 0
          ? null
          : () => setState(() => _filter = active ? null : category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: active ? color : color.withValues(alpha: 0.30),
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18.0, color: active ? Colors.white : color),
                const SizedBox(width: 6.0),
                Text(
                  '$count',
                  style: TextStyle(
                    color: active ? Colors.white : color,
                    fontWeight: FontWeight.w900,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2.0),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: FontWeight.w600,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryStat({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.0, color: color),
        const SizedBox(width: 8.0),
        Text(
          text,
          style: AppTextStyles.body2Style.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }
}

class BuildQuizAnsItem extends StatelessWidget {
  BuildQuizAnsItem({
    super.key,
    required this.queIdx,
    required this.length,
    required this.isDarkMode,
    required this.questionModel,
    required this.title,
    required this.stdAns,
    this.queAnsIdx,
    required this.questionDegree,
  });

  int length;
  int queIdx;
  late Color color = Components.setBgColor(isDarkMode);
  bool isDarkMode;
  String title;
  QuestionModel questionModel;
  dynamic stdAns;
  int? queAnsIdx;
  int questionDegree;
  final TextEditingController _ansController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformCubit, PlatformStates>(
      builder: (context, state) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.06),
                blurRadius: 14.0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟦 Header
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.appPrimaryColor,
                            AppColors.appSecondaryColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${queIdx + 1} ${S.of(context).of_} $length ${S.of(context).questionss}',
                                  style: AppTextStyles.body2Style.copyWith(
                                    color: Colors.grey,
                                    fontSize: 13.0,
                                  ),
                                ),
                              ),
                              if (questionModel.options != null &&
                                  questionModel.options!.isNotEmpty)
                                _statusPill(
                                  color: (stdAns != null && stdAns == queAnsIdx)
                                      ? Colors.green
                                      : Colors.red,
                                  icon: (stdAns != null && stdAns == queAnsIdx)
                                      ? Icons.check_rounded
                                      : Icons.close_rounded,
                                ),
                              const SizedBox(width: 6.0),
                              _statusPill(
                                color: AppColors.appPrimaryColor,
                                icon: Icons.military_tech_rounded,
                                label:
                                    '${questionModel.options == null ? (stdAns.toString().split(',').length == 1 || double.tryParse(stdAns.toString().split(',').last) == null ? 'N/A' : Constants.doubletoInt(double.parse(stdAns.toString().split(',').last))) : questionDegree} ${S.of(context).degree}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            title,
                            style: AppTextStyles.title2Style,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              questionModel.imgUrl != null
                  ? GestureDetector(
                      onTap: () {
                        FullScreenImageViewer.showFullImage(
                          context,
                          questionModel.imgUrl,
                        );
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl: questionModel.imgUrl!,
                              height: MediaQuery.of(context).size.height / 4,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.zoom_in,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    S.of(context).tap_to_zoom,
                                    style: AppTextStyles.body2Style.copyWith(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 12.0),
              if (questionModel.options != null &&
                  questionModel.options!.isNotEmpty)
                Column(
                  children: List.generate(
                    questionModel.options!.length,
                    (ansIdx) => _buildReviewOption(context, ansIdx),
                  ),
                ),
              if (questionModel.options == null ||
                  questionModel.options!.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          color: color,
                          size: 22.0,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          S.of(context).your_answer,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    if (stdAns != null &&
                        stdAns.toString().split(',').first.isNotEmpty)
                      // ✏️ Text Answer
                      TextField(
                        controller: _ansController
                          ..text = stdAns.toString().split(',').first,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: S.of(context).write_your_answer,
                          filled: true,
                          enabled: false,
                          fillColor: isDarkMode
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          stdAns.toString().split(',').skip(1).map((imgUrl) {
                        if (double.tryParse(imgUrl) != null) {
                          return const SizedBox();
                        }
                        return GestureDetector(
                          onTap: () {
                            FullScreenImageViewer.showFullImage(
                                context, imgUrl);
                          },
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: imgUrl,
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.zoom_in,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        S.of(context).tap_to_zoom,
                                        style:
                                            AppTextStyles.body2Style.copyWith(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔵 Small status pill (icon + optional label)
  Widget _statusPill({
    required Color color,
    required IconData icon,
    String? label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (label == null || label.isEmpty) ? 6.0 : 9.0,
        vertical: 5.0,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.0, color: color),
          if (label != null && label.isNotEmpty) ...[
            const SizedBox(width: 5.0),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ Modern review option card (green = correct, red = student's wrong pick)
  Widget _buildReviewOption(BuildContext context, int ansIdx) {
    final option = questionModel.options![ansIdx];
    final int value = ansIdx + 1;

    final bool isCorrectAns = value == queAnsIdx;
    final bool isStudentPick = stdAns != null && value == stdAns;

    final bool highlighted = isCorrectAns || isStudentPick;
    final Color stateColor = isCorrectAns ? Colors.green : Colors.red;

    final Color idleBg =
        isDarkMode ? AppColors.darkBgColor : AppColors.lightBgColor;
    final Color idleBorder = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: highlighted ? stateColor.withValues(alpha: 0.12) : idleBg,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: highlighted ? stateColor : idleBorder,
          width: highlighted ? 2.0 : 1.2,
        ),
      ),
      child: Row(
        children: [
          /*
          // 🔤 Letter / status badge
          Container(
              width: 34.0,
              height: 34.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: highlighted ? stateColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: highlighted ? stateColor : Colors.grey,
                  width: 1.6,
                ),
              ),
              child: highlighted
                  ? Icon(stateIcon, color: Colors.white, size: 20.0)
                  : SizedBox.shrink()),
          const SizedBox(width: 12.0),
        */
          // 📝 Option content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (option.title != null)
                  Text(
                    '${option.title}',
                    style: AppTextStyles.body2Style.copyWith(
                      fontWeight:
                          highlighted ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                if (option.imgUrl != null) ...[
                  if (option.title != null) const SizedBox(height: 8.0),
                  GestureDetector(
                    onTap: () {
                      FullScreenImageViewer.showFullImage(
                        context,
                        option.imgUrl,
                      );
                    },
                    child: DefaultImage(imgUrl: option.imgUrl!),
                  ),
                ],
              ],
            ),
          ),
          if (isStudentPick) ...[
            const SizedBox(width: 8.0),
            Text(
              S.of(context).your_answer.replaceAll(':', '').trim(),
              style: TextStyle(
                color: stateColor,
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
