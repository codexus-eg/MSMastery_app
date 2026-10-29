// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/models/question_bank_model.dart';
import 'package:salah_online_platform/screens/questions_bank/questionbank_questions_screen.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

import '../../bloc/platformCubit.dart';
import '../../bloc/platformStates.dart';
import '../../constants/colors.dart';
import '../../constants/components.dart';
import '../../constants/constants.dart';
import '../../constants/styles.dart';
import '../../constants/widgets.dart';
import '../../generated/l10n.dart';

class StartQuestionbankScreen extends StatelessWidget {
  StartQuestionbankScreen({
    super.key,
    required this.chapters,
    required this.num,
    required this.fill,
    required this.questionBankModel,
  });
  bool isLoading = false;
  Map<String?, List<String?>> chapters = {};
  int num = 0;
  int fill = 0;
  late QuestionBankModel questionBankModel;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformQuizGetQuestionBankLoadingState) {
          isLoading = true;
        }
        if (state is PlatformQuizGetQuestionBankFailState) {
          isLoading = false;
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err
                .substring(state.err.indexOf(']') + 2, state.err.length),
          );
        }
        if (state is PlatformQuizGetQuestionBankSuccessState) {
          isLoading = false;

          Components.push(
            context: context,
            widget: QuestionbankQuestionsScreen(
              cubit: PlatformCubit.get(context),
            ),
          );
        }
      },
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
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
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Components.setBgColor(cubit.isDarkMode),
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: cubit.isDarkMode
                                ? AppColors.darkBorder
                                : AppColors.lightBborder,
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DefaultImage(
                                imgUrl: Constants.questionBank,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 6,
                              ),
                              Center(
                                child: Text(
                                  questionBankModel.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.title2Style,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                S.of(context).content,
                                style: AppTextStyles.title2Style.copyWith(
                                  color:
                                      Components.setBgColor(cubit.isDarkMode),
                                  fontSize: 18.0,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              SizedBox(
                                height: 120.0,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: chapters.entries
                                        .map((e) => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .only(start: 12.0),
                                                  child: Text(
                                                    e.key!,
                                                    style: AppTextStyles
                                                        .body2Style,
                                                  ),
                                                ),
                                                Column(
                                                  children: e.value
                                                      .map(
                                                        (e) => Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .only(
                                                            start: 22.0,
                                                            top: 4.0,
                                                          ),
                                                          child: Text(
                                                            e!,
                                                            style: AppTextStyles
                                                                .body2Style
                                                                .copyWith(
                                                                    fontSize:
                                                                        14.0),
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.timer_sharp,
                                    color:
                                        Components.setBgColor(cubit.isDarkMode),
                                    size: 32,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    '${questionBankModel.duration} ${S.of(context).mins}',
                                    style: AppTextStyles.body2Style,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.help_outline,
                                    color:
                                        Components.setBgColor(cubit.isDarkMode),
                                    size: 32,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    '${questionBankModel.questionsNum.toString()} ${S.of(context).questionss}',
                                    style: AppTextStyles.body2Style,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
                                child: DefaultWaitedButton(
                                  isLoading: isLoading,
                                  isDarkMode: cubit.isDarkMode,
                                  width: double.infinity,
                                  onPressed: () async {
                                    bool isConnected =
                                        await Components.checkConnection();
                                    if (isConnected) {
                                      //TODO genearte questions
                                      cubit.generateQuestions(
                                        questionBankModel.title,
                                        questionBankModel.questionsNum,
                                        chapters,
                                        num,
                                        fill,
                                      );
                                    } else {
                                      AppStatusDialog.show(
                                        context: context,
                                        status: AppDialogStatus.error,
                                        message: S.of(context).no_internet,
                                        title: 'مفيش نت',
                                      );
                                    }
                                  },
                                  txt: S.of(context).start,
                                ),
                              ),
                            ],
                          ),
                        ),
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
