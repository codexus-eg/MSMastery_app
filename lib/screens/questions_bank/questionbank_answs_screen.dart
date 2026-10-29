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

import '../../constants/colors.dart';
import '../../constants/styles.dart';
import '../../constants/widgets.dart';
import '../../generated/l10n.dart';

class QuestionbankAnswersScreen extends StatefulWidget {
  QuestionbankAnswersScreen({
    super.key,
    required this.title,
    required this.id,
  });
  List<QuestionModel> questions = []; // get from firebase
  String title;
  String id;
  Map<String?, List<String?>> chapters = {};

  @override
  State<QuestionbankAnswersScreen> createState() =>
      _QuestionbankAnswersScreenState();
}

class _QuestionbankAnswersScreenState extends State<QuestionbankAnswersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
        ..getQuestionbankQuestions(id: widget.id)
        ..getAnswsChapters(widget.id),
      child: BlocConsumer<PlatformCubit, PlatformStates>(
        listener: (context, state) {
          if (state is PlatformQuizGetQuestionBankSuccessState) {
            widget.questions = state.questions;
          }
          if (state is PlatformQuizGetQuestionBankChaptersSuccessState) {
            widget.chapters = state.chapters;
          }
        },
        builder: (context, state) {
          var cubit = PlatformCubit.get(context);
          UserModel um = Constants.userBox.get('user');

          return Scaffold(
            backgroundColor: cubit.isDarkMode
                ? AppColors.darkBorder
                : AppColors.lightBborder,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultBackBtn(
                      txt: widget.title,
                    ),
                    SizedBox(
                      height: 120.0,
                      child: SingleChildScrollView(
                        child: Column(
                          children: widget.chapters.entries
                              .map((e) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                                start: 24.0),
                                        child: Text(
                                          e.key!,
                                          style: AppTextStyles.body1Style,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: e.value
                                            .map(
                                              (e) => Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .only(
                                                  start: 32.0,
                                                  top: 4.0,
                                                ),
                                                child: Text(
                                                  e!,
                                                  style:
                                                      AppTextStyles.body2Style,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      )
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) => BuildQuizAnsItem(
                          queIdx: index,
                          title: widget.questions[index].title,
                          queAnsIdx: widget.questions[index].ansIdx!,
                          stdAnsIdx: um.stdQuizes![widget.id]!
                              .userAnsIdx[widget.questions[index].id],
                          length: widget.questions.length,
                          questionModel: widget.questions[index],
                          isDarkMode: PlatformCubit.get(context).isDarkMode,
                        ),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16.0),
                        itemCount: widget.questions.length,
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
}

class BuildQuizAnsItem extends StatelessWidget {
  BuildQuizAnsItem({
    super.key,
    required this.queIdx,
    required this.length,
    required this.isDarkMode,
    required this.questionModel,
    required this.title,
    required this.stdAnsIdx,
    required this.queAnsIdx,
  });

  int length;
  int queIdx;
  late Color color = Components.setBgColor(isDarkMode);
  bool isDarkMode;
  String title;
  QuestionModel questionModel;
  int? stdAnsIdx;
  int queAnsIdx;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformCubit, PlatformStates>(
      builder: (context, state) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.black
                : Colors.white, // changes if dark mode or not
            borderRadius: BorderRadius.circular(12.0),
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
                          '${queIdx + 1} ${S.of(context).of_} $length ${S.of(context).questionss}',
                          style: AppTextStyles.body2Style.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          title,
                          style: AppTextStyles.title2Style,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
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
                    )
                  : const SizedBox(),
              const SizedBox(
                height: 12.0,
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: isDarkMode
                      ? AppColors.darkBorder
                      : AppColors.lightBborder,
                ),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, ansIdx) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: queAnsIdx != stdAnsIdx && queAnsIdx == ansIdx + 1
                          ? Colors.green.withValues(alpha: 0.25)
                          : null,
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsetsDirectional.only(start: 8.0),
                      title: (questionModel.options?[ansIdx].title == null)
                          ? const SizedBox()
                          : Text(
                              '${questionModel.options![ansIdx].title}',
                              style: AppTextStyles.body2Style,
                            ),
                      subtitle: (questionModel.options?[ansIdx].imgUrl == null)
                          ? const SizedBox()
                          : DefaultImage(
                              imgUrl: questionModel.options![ansIdx].imgUrl!,
                            ),
                      trailing: Radio<int>(
                        value: ansIdx + 1,
                        activeColor:
                            stdAnsIdx == queAnsIdx ? Colors.green : Colors.red,
                        groupValue: stdAnsIdx,
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                  itemCount: questionModel.options!.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
