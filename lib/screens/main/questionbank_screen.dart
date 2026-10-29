// // ignore_for_file: must_be_immutable, use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:salah_online_platform/widgets/app_status_dialog.dart';
// import 'package:parent_child_checkbox/parent_child_checkbox.dart';
// import 'package:percent_indicator/percent_indicator.dart';

// import 'package:salah_online_platform/bloc/platform_cubit.dart';
// import 'package:salah_online_platform/bloc/platformStates.dart';
// import 'package:salah_online_platform/constants/components.dart';
// import 'package:salah_online_platform/generated/l10n.dart';
// import 'package:salah_online_platform/models/question_bank_model.dart';
// import 'package:salah_online_platform/screens/quiz/quiz_answs_screen.dart';

// import '../../constants/colors.dart';
// import '../../constants/constants.dart';
// import '../../constants/styles.dart';
// import '../../constants/widgets.dart';
// import '../../models/std_quiz_model.dart';
// import '../../models/user_model.dart';
// import '../questions_bank/start_questionbank_screen.dart';

// class QuestionbankScreen extends StatelessWidget {
//   QuestionbankScreen({super.key});

//   TextEditingController queNumsController = TextEditingController();
//   var scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<PlatformCubit, PlatformStates>(
//       listener: (context, state) {},
//       builder: (context, state) {
//         UserModel? um = Constants.userBox.get('user');

//         var cubit = PlatformCubit.get(context);
//         List<StdQuizModel>? filteredQuestions = um?.stdQuizes!
//             .where((question) => !question.id.contains(','))
//             .toList();
//         filteredQuestions!.sort((a, b) => b.dateTime.compareTo(a.dateTime));

//         return Scaffold(
//           key: scaffoldKey,
//           body: Container(
//             /*
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 fit: BoxFit.cover,
//                 image: AssetImage(
//                   cubit.isDarkMode
//                       ? Constants.wallpaberDark
//                       : Constants.wallpaberLight,
//                 ),
//               ),
//             ),
//             */
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       S.of(context).quizs,
//                       style: AppTextStyles.headStyle,
//                     ),
//                     const SizedBox(height: 12.0),
//                     Expanded(
//                       child: filteredQuestions.isEmpty
//                           ? Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   DefaultImage(
//                                     imgUrl: Constants.noQuiz,
//                                     width:
//                                         MediaQuery.of(context).size.width / 2,
//                                     height:
//                                         MediaQuery.of(context).size.height / 5,
//                                   ),
//                                   const SizedBox(height: 8.0),
//                                   Text(
//                                     S.of(context).no_quizes_yet,
//                                     style: const TextStyle(fontSize: 16.0),
//                                   ),
//                                   const SizedBox(height: 12.0),
//                                   Text(
//                                     S.of(context).press_to_add_quiz,
//                                     style: const TextStyle(fontSize: 22.0),
//                                   )
//                                 ],
//                               ),
//                             )
//                           : ListView.separated(
//                               itemBuilder: (context, index) => QuizTile(
//                                 isDarkMode: cubit.isDarkMode,
//                                 date: filteredQuestions[index].dateTime,
//                                 id: filteredQuestions[index].id,
//                                 grade: filteredQuestions[index].degree.toInt(),
//                                 questionNums: filteredQuestions[index]
//                                     .questionNums
//                                     .toInt(),
//                                 title:
//                                     filteredQuestions[index].title.toString(),
//                                 //  questions: um.stdQuizes![index].questions!,
//                               ),
//                               separatorBuilder: (context, index) =>
//                                   const SizedBox(height: 8.0),
//                               itemCount: filteredQuestions.length,
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () {
//               // cubit.addQuestion();

//               int empty = 0;
//               int fill = 0;
//               if (cubit.down2) {
//                 // check if not cahnge any thing.
//                 Map<String?, List<String?>> chapters =
//                     ParentChildCheckbox.selectedChildrens;
//                 chapters.forEach((key, value) {
//                   if (value.isEmpty) {
//                     empty++;
//                   } else {
//                     fill += value.length;
//                   }
//                 });
//                 if (empty == cubit.chapters.length) {
//                   AppStatusDialog.show(
//                     context: context,
//                     status: AppDialogStatus.warning,
//                     title: 'خلي بالك',
//                     message: 'انت مختارتش حاجة',
//                   );
//                 } else {
//                   if ((int.parse(queNumsController.text) ~/ fill) == 0) {
//                     AppStatusDialog.show(
//                       context: context,
//                       status: AppDialogStatus.warning,
//                       title: 'خلي بالك',
//                       message: 'لازم عدد الاسئلة يكون اكبر من عدد الحصص',
//                     );
//                     cubit.number += int.parse(queNumsController.text);
//                     queNumsController.text = cubit.number.toString();
//                   } else {
//                     chapters.removeWhere((key, value) => value.isEmpty);
//                     cubit.changing2(context);

//                     Components.push(
//                       context: context,
//                       widget: StartQuestionbankScreen(
//                         questionBankModel: QuestionBankModel(
//                           questionsNum: int.parse(queNumsController.text),
//                           duration: int.parse(queNumsController.text) * 3,
//                           title: '${S.of(context).quiz} 1',
//                           chapters: chapters,
//                         ),
//                         chapters: chapters,
//                         num: int.parse(queNumsController.text) ~/ fill,
//                         fill: fill,
//                       ),
//                     );
//                     debugPrint(chapters.toString());
//                   }
//                   //  go to start quiz screen
//                   // debugPrint(queNumsController.text);
//                   // debugPrint(
//                   //     (int.parse(queNumsController.text) ~/ fill).toString());
//                 }
//               } else {
//                 cubit.getChapters();
//                 //  change to 10
//                 queNumsController.text = '3';
//                 cubit.number = 3;
//                 scaffoldKey.currentState!.showBottomSheet(
//                   enableDrag: false,
//                   (context1) {
//                     return BlocConsumer<PlatformCubit, PlatformStates>(
//                       listener: (context, state) {},
//                       builder: (context, state) {
//                         var cubit = PlatformCubit.get(context);
//                         return Container(
//                           decoration: BoxDecoration(
//                             color: Components.setBgColor(cubit.isDarkMode),
//                             borderRadius: BorderRadius.circular(20.0),
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Stack(
//                                 alignment: AlignmentDirectional.topStart,
//                                 children: [
//                                   Container(
//                                     decoration: const BoxDecoration(
//                                       borderRadius: BorderRadius.vertical(
//                                         top: Radius.circular(
//                                           28.0,
//                                         ),
//                                       ),
//                                     ),
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Center(
//                                       child: Text(
//                                         S.of(context).new_req,
//                                         style:
//                                             AppTextStyles.title1Style.copyWith(
//                                           color: Components.setTextColor(
//                                               cubit.isDarkMode),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsetsDirectional.only(
//                                       start: 8.0,
//                                       top: 8.0,
//                                     ),
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         cubit.changing2(context);
//                                       },
//                                       child: CircleAvatar(
//                                         backgroundColor: cubit.isDarkMode
//                                             ? AppColors.darkBorder
//                                             : AppColors.lightBborder,
//                                         radius: 16.0,
//                                         child: Icon(
//                                           Icons.close,
//                                           color: cubit.isDarkMode
//                                               ? Colors.white
//                                               : Colors.black,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: cubit.isDarkMode
//                                       ? AppColors.darkBgColor
//                                       : AppColors.lightBgColor,
//                                   borderRadius: const BorderRadius.only(
//                                     topLeft: Radius.circular(16.0),
//                                     topRight: Radius.circular(16.0),
//                                   ),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(
//                                       height: 300.0,
//                                       child: ListView.builder(
//                                         padding: const EdgeInsets.all(16.0),
//                                         itemCount: cubit.chapters.keys.length,
//                                         itemBuilder: (context, index) =>
//                                             ParentChildCheckbox(
//                                           childrenCheckboxScale: 0.7,
//                                           childrenCheckboxColor:
//                                               Components.setBgColor(
//                                                   cubit.isDarkMode),
//                                           parentCheckboxColor:
//                                               Components.setBgColor(
//                                                   cubit.isDarkMode),
//                                           parent: Text(
//                                             cubit.chapters.keys
//                                                 .elementAt(index),
//                                             style: AppTextStyles.body1Style,
//                                           ),
//                                           children: List.generate(
//                                             cubit
//                                                 .chapters[cubit.chapters.keys
//                                                     .elementAt(index)]!
//                                                 .length,
//                                             (indexx) => Text(
//                                               cubit.chapters[cubit.chapters.keys
//                                                       .elementAt(index)]!
//                                                   .elementAt(indexx),
//                                               style: AppTextStyles.body2Style,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             '${S.of(context).questions_num}:',
//                                             style: AppTextStyles.body2Style,
//                                           ),
//                                           const SizedBox(width: 16.0),
//                                           Column(
//                                             children: [
//                                               InkWell(
//                                                 onTap: () {
//                                                   cubit.incrementQuestionsNum();

//                                                   queNumsController.text =
//                                                       cubit.number.toString();
//                                                 },
//                                                 child: const Icon(
//                                                   Icons.arrow_drop_up,
//                                                   size: 28,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 4.0),
//                                               InkWell(
//                                                 onTap: () {
//                                                   cubit.decrementQuestionsNum();
//                                                   queNumsController.text =
//                                                       cubit.number.toString();
//                                                 },
//                                                 child: const Icon(
//                                                   Icons.arrow_drop_down,
//                                                   size: 28,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(
//                                             width: 50,
//                                             height: 50,
//                                             child: TextFormField(
//                                               controller: queNumsController,
//                                               textAlign: TextAlign.center,
//                                               enabled: false,
//                                               keyboardType:
//                                                   TextInputType.number,
//                                               decoration: const InputDecoration(
//                                                 border: OutlineInputBorder(),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//                 cubit.changing2(context);
//               }
//             },
//             backgroundColor: Components.setBgColor(cubit.isDarkMode),
//             child: cubit.icon2,
//           ),
//         );
//       },
//     );
//   }
// }

// class QuizTile extends StatelessWidget {
//   QuizTile({
//     super.key,
//     required this.isDarkMode,
//     required this.date,
//     required this.grade,
//     required this.questionNums,
//     required this.title,
//     required this.id,
//     // required this.questions,
//   });
//   bool isDarkMode;
//   String title;
//   DateTime date;
//   int questionNums;
//   int grade;
//   String id;
//   // List<StdQuestionModel> questions;
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Components.push(
//           context: context,
//           widget: QuizAnswersScreen(
//             //  questions: questions,
//             title: title,
//             quizCode: id,
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12.0),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12.0),
//           color: isDarkMode ? AppColors.darkBorder : AppColors.lightBborder,
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     maxLines: 3,
//                     style: AppTextStyles.title2Style,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 12.0),
//                   Text(
//                     '${S.of(context).date} ${DateFormat('dd-MM-yyyy').format(date)}',
//                     maxLines: 1,
//                     style:
//                         AppTextStyles.body2Style.copyWith(color: Colors.grey),
//                   ),
//                   Text(
//                     '${S.of(context).questions} $questionNums',
//                     maxLines: 1,
//                     style:
//                         AppTextStyles.body2Style.copyWith(color: Colors.grey),
//                   ),
//                   Text(
//                     '${S.of(context).your_result} $grade',
//                     maxLines: 1,
//                     style:
//                         AppTextStyles.body2Style.copyWith(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//             CircularPercentIndicator(
//               radius: 40.0,
//               lineWidth: 10.0,
//               circularStrokeCap: CircularStrokeCap.round,
//               percent: (grade / questionNums),
//               center: Text(
//                 "${((grade / questionNums) * 100).ceil()}%",
//                 style: AppTextStyles.body2Style,
//               ),
//               progressColor: AppColors.appPrimaryColor,
//               backgroundColor: AppColors.appSecondaryColor,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
