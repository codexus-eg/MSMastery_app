// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/models/question_model.dart';
import 'package:salah_online_platform/screens/main/Overlay.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../../constants/widgets.dart';
import '../../generated/l10n.dart';

class QuestionBankFreeQuestionsScreen extends StatefulWidget {
  QuestionBankFreeQuestionsScreen({
    super.key,
    required this.chapters,
  });

  Map<String?, List<String?>> chapters = {};
  Map<String?, Map<String, List<QuestionModel>>> questions =
      {}; // get from firebase

  @override
  State<QuestionBankFreeQuestionsScreen> createState() =>
      _QuestionBankFreeQuestionsScreenState();
}

class _QuestionBankFreeQuestionsScreenState
    extends State<QuestionBankFreeQuestionsScreen> {
  // Track expanded state for chapters and lectures
  final Set<String> _expandedChapters = {};
  final Set<String> _expandedLectures = {};

  // Track loading state for each lecture
  final Set<String> _loadingLectures = {};

  @override
  void initState() {
    super.initState();
    PlatformCubit.get(context)
        .getQuestionbankFreeQuestions(chapters: widget.chapters);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Constants.noScreenshot.screenshotOff();
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await Constants.noScreenshot.screenshotOn();
    PlatformCubit.get(context).questionbankFreeQuestions.clear();
    PlatformCubit.get(context).hasMoreQuestions.clear();
    widget.questions.clear();
    _expandedChapters.clear();
    _expandedLectures.clear();
    _loadingLectures.clear();
  }

  void _toggleChapter(String chapterName) {
    setState(() {
      if (_expandedChapters.contains(chapterName)) {
        _expandedChapters.remove(chapterName);
      } else {
        _expandedChapters.add(chapterName);
      }
    });
  }

  void _toggleLecture(String lectureKey) {
    setState(() {
      if (_expandedLectures.contains(lectureKey)) {
        _expandedLectures.remove(lectureKey);
      } else {
        _expandedLectures.add(lectureKey);
      }
    });
  }

  void _loadMoreQuestions(String chapterId, String lessonId) {
    final lectureKey = '${chapterId}_$lessonId';
    setState(() {
      _loadingLectures.add(lectureKey);
    });
    PlatformCubit.get(context).loadMoreQuestionbankFreeQuestions(
      chapterId: chapterId,
      lessonId: lessonId,
    );
  }

  int _getTotalQuestionsInChapter(
      Map<String, List<QuestionModel>> lecturesMap) {
    int total = 0;
    for (var questions in lecturesMap.values) {
      total += questions.length;
    }
    return total;
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 14,
          ),
          const SizedBox(width: 4.0),
          Text(
            label,
            style: AppTextStyles.body2Style.copyWith(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformQuizGetFreeQuestionBankSuccessState) {
          widget.questions = state.questionbankFreeQuestions;
          debugPrint(widget.questions.toString());
        } else if (state is PlatformQuizGetFreeQuestionBankFailState) {
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err,
          );
        } else if (state is PlatformLoadMoreFreeQuestionBankSuccessState) {
          setState(() {
            _loadingLectures.remove(state.lectureKey);
          });
        } else if (state is PlatformLoadMoreFreeQuestionBankFailState) {
          setState(() {
            _loadingLectures.clear();
          });
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err,
          );
        }
      },
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);

        return Scaffold(
          backgroundColor:
              cubit.isDarkMode ? AppColors.darkBorder : AppColors.lightBborder,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultBackBtn(),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: state is PlatformQuizGetFreeQuestionBankLoadingState
                        ? const Center(child: CircularProgressIndicator())
                        : widget.questions.isEmpty
                            ? Center(
                                child: Text(
                                  S.of(context).no_content_yet,
                                  style: AppTextStyles.title2Style,
                                ),
                              )
                            : Scrollbar(
                                thumbVisibility: true, // يظهر الشريط دايمًا
                                trackVisibility: true, // يظهر المسار كمان
                                interactive: true,

                                thickness: 6, // سمك الشريط
                                radius:
                                    const Radius.circular(20), // نعومة الأطراف
                                child: ListView.builder(
                                  itemCount: widget.questions.keys.length,
                                  itemBuilder: (context, chapterIndex) {
                                    final chapterName = widget.questions.keys
                                        .elementAt(chapterIndex);
                                    final lecturesMap =
                                        widget.questions[chapterName]!;
                                    final isChapterExpanded = _expandedChapters
                                        .contains(chapterName ?? '');
                                    final totalQuestions =
                                        _getTotalQuestionsInChapter(
                                            lecturesMap);

                                    return Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 16.0),
                                      decoration: BoxDecoration(
                                        color: cubit.isDarkMode
                                            ? Colors.black
                                                .withValues(alpha: 0.7)
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          // Chapter Header (Collapsible)
                                          InkWell(
                                            onTap: () => _toggleChapter(
                                                chapterName ?? ''),
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.appPrimaryColor,
                                                    AppColors.appPrimaryColor
                                                        .withValues(alpha: 0.8),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: isChapterExpanded
                                                    ? const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                16.0),
                                                        topRight:
                                                            Radius.circular(
                                                                16.0),
                                                      )
                                                    : BorderRadius.circular(
                                                        16.0),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                    child: const Icon(
                                                      Icons.menu_book_rounded,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12.0),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          chapterName ?? '',
                                                          style: AppTextStyles
                                                              .title2Style
                                                              .copyWith(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4.0),
                                                        Row(
                                                          children: [
                                                            _buildInfoChip(
                                                              icon: Icons
                                                                  .library_books,
                                                              label:
                                                                  '${lecturesMap.length} ${S.of(context).lecturess}',
                                                            ),
                                                            const SizedBox(
                                                                width: 8.0),
                                                            _buildInfoChip(
                                                              icon: Icons.quiz,
                                                              label:
                                                                  '$totalQuestions ${S.of(context).questionss}',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  AnimatedRotation(
                                                    turns: isChapterExpanded
                                                        ? 0.5
                                                        : 0,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.2),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Chapter Content (Lectures)
                                          AnimatedCrossFade(
                                            firstChild: const SizedBox.shrink(),
                                            secondChild: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                children: lecturesMap.entries
                                                    .map((lectureEntry) {
                                                  final lectureName =
                                                      lectureEntry.key;
                                                  final questions =
                                                      lectureEntry.value;
                                                  final lectureKey =
                                                      '${chapterName}_$lectureName';
                                                  final isLectureExpanded =
                                                      _expandedLectures
                                                          .contains(lectureKey);

                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 12.0),
                                                    decoration: BoxDecoration(
                                                      color: cubit.isDarkMode
                                                          ? AppColors.darkBorder
                                                          : AppColors
                                                              .lightBborder,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                      border: Border.all(
                                                        color: cubit.isDarkMode
                                                            ? Colors
                                                                .grey.shade800
                                                            : Colors
                                                                .grey.shade300,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        // Lecture Header (Collapsible)
                                                        InkWell(
                                                          onTap: () =>
                                                              _toggleLecture(
                                                                  lectureKey),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12.0),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  AppColors
                                                                      .appSecondaryColor,
                                                                  AppColors
                                                                      .appSecondaryColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.8),
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                              borderRadius:
                                                                  isLectureExpanded
                                                                      ? const BorderRadius
                                                                          .only(
                                                                          topLeft:
                                                                              Radius.circular(11.0),
                                                                          topRight:
                                                                              Radius.circular(11.0),
                                                                        )
                                                                      : BorderRadius
                                                                          .circular(
                                                                              11.0),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white
                                                                        .withValues(
                                                                            alpha:
                                                                                0.2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .play_lesson,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 20,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width:
                                                                        10.0),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        lectureName,
                                                                        style: AppTextStyles
                                                                            .body1Style
                                                                            .copyWith(
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              2.0),
                                                                      Text(
                                                                        '${questions.length} ${S.of(context).questionss}',
                                                                        style: AppTextStyles
                                                                            .body2Style
                                                                            .copyWith(
                                                                          color:
                                                                              Colors.white70,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                AnimatedRotation(
                                                                  turns:
                                                                      isLectureExpanded
                                                                          ? 0.5
                                                                          : 0,
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          300),
                                                                  child: Icon(
                                                                    Icons
                                                                        .keyboard_arrow_down,
                                                                    color: Colors
                                                                        .white
                                                                        .withValues(
                                                                            alpha:
                                                                                0.8),
                                                                    size: 22,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        // Questions List
                                                        AnimatedCrossFade(
                                                          firstChild:
                                                              const SizedBox
                                                                  .shrink(),
                                                          secondChild: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              children: [
                                                                ListView
                                                                    .separated(
                                                                  physics:
                                                                      const NeverScrollableScrollPhysics(),
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount:
                                                                      questions
                                                                          .length,
                                                                  separatorBuilder: (context,
                                                                          index) =>
                                                                      const SizedBox(
                                                                          height:
                                                                              8.0),
                                                                  itemBuilder:
                                                                      (context,
                                                                          questionIndex) {
                                                                    final question =
                                                                        questions[
                                                                            questionIndex];
                                                                    return BuildQuizAnsItem(
                                                                      queIdx:
                                                                          questionIndex,
                                                                      length: questions
                                                                          .length,
                                                                      isDarkMode:
                                                                          cubit
                                                                              .isDarkMode,
                                                                      questionModel:
                                                                          question,
                                                                      title: question
                                                                          .title,
                                                                      queAnsIdx:
                                                                          question
                                                                              .ansIdx!,
                                                                    );
                                                                  },
                                                                ),
                                                                // Load More Button
                                                                if (cubit.hasMoreQuestions[
                                                                        lectureKey] ==
                                                                    true)
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            12.0),
                                                                    child: _loadingLectures
                                                                            .contains(lectureKey)
                                                                        ? const Center(
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.all(12.0),
                                                                              child: CircularProgressIndicator(),
                                                                            ),
                                                                          )
                                                                        : InkWell(
                                                                            onTap: () =>
                                                                                _loadMoreQuestions(chapterName ?? '', lectureName),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                            child:
                                                                                Container(
                                                                              width: double.infinity,
                                                                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                                                                              decoration: BoxDecoration(
                                                                                gradient: LinearGradient(
                                                                                  colors: [
                                                                                    AppColors.appSecondaryColor.withValues(alpha: 0.8),
                                                                                    AppColors.appSecondaryColor,
                                                                                  ],
                                                                                  begin: Alignment.centerLeft,
                                                                                  end: Alignment.centerRight,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                              ),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  const Icon(
                                                                                    Icons.add_circle_outline,
                                                                                    color: Colors.white,
                                                                                    size: 20,
                                                                                  ),
                                                                                  const SizedBox(width: 8.0),
                                                                                  Text(
                                                                                    S.of(context).more_questions,
                                                                                    style: AppTextStyles.body1Style.copyWith(
                                                                                      color: Colors.white,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                          crossFadeState:
                                                              isLectureExpanded
                                                                  ? CrossFadeState
                                                                      .showSecond
                                                                  : CrossFadeState
                                                                      .showFirst,
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      300),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            crossFadeState: isChapterExpanded
                                                ? CrossFadeState.showSecond
                                                : CrossFadeState.showFirst,
                                            duration: const Duration(
                                                milliseconds: 300),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
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

class BuildQuizAnsItem extends StatefulWidget {
  const BuildQuizAnsItem({
    super.key,
    required this.queIdx,
    required this.length,
    required this.isDarkMode,
    required this.questionModel,
    required this.title,
    required this.queAnsIdx,
  });

  final int length;
  final int queIdx;
  final bool isDarkMode;
  final String title;
  final QuestionModel questionModel;
  final int queAnsIdx;

  @override
  State<BuildQuizAnsItem> createState() => _BuildQuizAnsItemState();
}

class _BuildQuizAnsItemState extends State<BuildQuizAnsItem> {
  bool _showAnswer = false;

  void _toggleShowAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Components.setBgColor(widget.isDarkMode);

    return BlocBuilder<PlatformCubit, PlatformStates>(
      builder: (context, state) => Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 3.5,
                  height: MediaQuery.of(context).size.height / 10,
                  decoration: BoxDecoration(
                    color: color,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.queIdx + 1} ${S.of(context).of_} ${widget.length} ${S.of(context).questionss}',
                        style: AppTextStyles.body2Style.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.title,
                        style: AppTextStyles.title2Style,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (widget.questionModel.imgUrl != null)
              GestureDetector(
                onTap: () {
                  FullScreenImageViewer.showFullImage(
                    context,
                    widget.questionModel.imgUrl,
                  );
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.questionModel.imgUrl!,
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
                    // Tap to zoom hint
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
              ),
            const SizedBox(height: 12.0),
            // Options List
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: widget.isDarkMode
                    ? AppColors.darkBorder
                    : AppColors.lightBborder,
              ),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.questionModel.options!.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 4.0),
                itemBuilder: (context, ansIdx) {
                  final isCorrectAnswer = widget.queAnsIdx == ansIdx + 1;
                  final showCorrect = _showAnswer && isCorrectAnswer;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: showCorrect
                          ? Colors.green.withValues(alpha: 0.2)
                          : null,
                      border: showCorrect
                          ? Border.all(color: Colors.green, width: 2)
                          : null,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsetsDirectional.only(
                        start: 12.0,
                        end: 8.0,
                      ),
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: showCorrect
                              ? Colors.green
                              : (widget.isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300),
                        ),
                        child: Center(
                          child: showCorrect
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : SizedBox(),
                        ),
                      ),
                      title: (widget.questionModel.options![ansIdx].title ==
                              null)
                          ? const SizedBox()
                          : Text(
                              '${widget.questionModel.options![ansIdx].title}',
                              style: AppTextStyles.body2Style.copyWith(
                                color:
                                    showCorrect ? Colors.green.shade700 : null,
                                fontWeight: showCorrect
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                      subtitle:
                          (widget.questionModel.options![ansIdx].imgUrl == null)
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: DefaultImage(
                                    imgUrl: widget
                                        .questionModel.options![ansIdx].imgUrl!,
                                  ),
                                ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12.0),
            // Show Answer Button
            InkWell(
              onTap: _toggleShowAnswer,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _showAnswer
                        ? [Colors.grey.shade600, Colors.grey.shade700]
                        : [
                            AppColors.appPrimaryColor,
                            AppColors.appPrimaryColor.withValues(alpha: 0.8),
                          ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showAnswer ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      _showAnswer
                          ? S.of(context).cancel
                          : S.of(context).show_result,
                      style: AppTextStyles.body1Style.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
