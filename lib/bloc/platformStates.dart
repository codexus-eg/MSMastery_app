import 'package:salah_online_platform/models/video_details_model.dart';
import 'package:salah_online_platform/models/watches_video_model.dart';

import '../models/question_model.dart';

abstract class PlatformStates {}

class PaltformAppInitialState extends PlatformStates {}

class PaltformChangeIndexState extends PlatformStates {}

class PaltformChangePasswordSecureState extends PlatformStates {}

class PlatformChangeQuestionBankState extends PlatformStates {}

class PlatformChangeLecturesExamsState extends PlatformStates {}

class PaltformChangeOldPasswordSecureState extends PlatformStates {}

class PlatformChangeQuestionsNumsState extends PlatformStates {}

class PaltformChangeNewPasswordSecureState extends PlatformStates {}

class PlatformChangeSliderState extends PlatformStates {}

class PlatformChangeModeState extends PlatformStates {}

class PlatformChangeAppColorState extends PlatformStates {}

class PlatformChangeLanguageState extends PlatformStates {}

class PlatformCreateUserLoadingState extends PlatformStates {}

class PlatformCreateUserSuccessState extends PlatformStates {
  int balance;
  PlatformCreateUserSuccessState(this.balance);
}

class PlatformCreateUserFailState extends PlatformStates {
  String err;
  PlatformCreateUserFailState(this.err);
}

class PlatformLoginLoadingState extends PlatformStates {}

class PlatformLoginSuccessState extends PlatformStates {
  bool enabled;
  bool active;

  PlatformLoginSuccessState({
    required this.enabled,
    required this.active,
  });
}

enum LoginErrorType {
  userNotFound,
  deviceLimit,
  noInternet,
  invalidCredentials,
  unknown,
}

class PlatformLoginFailState extends PlatformStates {
  String err;
  final LoginErrorType type;
  PlatformLoginFailState(this.err, {this.type = LoginErrorType.unknown});
}

class PlatformGetUserDataLoadingState extends PlatformStates {}

class PlatformGetUserDataSuccessState extends PlatformStates {}

class PlatformGetUserDataFailState extends PlatformStates {
  String err;
  PlatformGetUserDataFailState(this.err);
}

class PlatformLogoutLoadingState extends PlatformStates {}

class PlatformLogoutSuccessState extends PlatformStates {}

class PlatformLogoutFailState extends PlatformStates {
  String err;
  PlatformLogoutFailState(this.err);
}

class PlatfomrRefreshState extends PlatformStates {}

class PlatformDeleteAccountSuccessState extends PlatformStates {}

class PlatformDeleteAccountFailState extends PlatformStates {
  String err;
  PlatformDeleteAccountFailState(this.err);
}

class PlatformCheckCodeSuccessState extends PlatformStates {
  VideoDetailsModel? videoDetailsModel;
  // bool isWallet;

  PlatformCheckCodeSuccessState({
    this.videoDetailsModel,
    //  required this.isWallet,
  });
}

class PlatformAccountNotBlockedAndPendingState extends PlatformStates {}

class PlatformCheckCodeLoadingState extends PlatformStates {}

class PlatformCheckPurchaseQuizCodeLoadingState extends PlatformStates {}

class PlatformCheckPurchaseQuizCodeSuccessState extends PlatformStates {}

class PlatformCheckPurchaseQuizCodeFailState extends PlatformStates {
  String err;
  PlatformCheckPurchaseQuizCodeFailState(this.err);
}

class PlatformGetIsDelAccShowSuccessState extends PlatformStates {}

class PlatformGetPurchasedVideosSuccessState extends PlatformStates {}

class PlatformGetBannersLoadingState extends PlatformStates {}

class PlatformGetBannersSuccessState extends PlatformStates {}

class PlatformGetBannersFailState extends PlatformStates {
  final String error;
  PlatformGetBannersFailState(this.error);
}

class PlatformAccountBlockedState extends PlatformStates {}

class PlatformAccountPendingState extends PlatformStates {}

class PlatformUpdateRequestStatueState extends PlatformStates {}

class PlatformGetRequestsSuccessState extends PlatformStates {}

class PlatformGetMyLecturesDataSuccessState extends PlatformStates {}

class PlatformApplyGeneralCodeToBalanceSuccessState extends PlatformStates {}

class PlatformApplyGeneralCodeToBalanceFailState extends PlatformStates {
  String err;
  PlatformApplyGeneralCodeToBalanceFailState(this.err);
}

class PlatformChangeRequestFilterState extends PlatformStates {}

class PlatformGetRequestsFailState extends PlatformStates {
  String err;
  PlatformGetRequestsFailState(this.err);
}

class PlatformCheckCodeFailState extends PlatformStates {
  String err;
  PlatformCheckCodeFailState(this.err);
}

class PlatformCheckCodeAlreadyChargedState extends PlatformStates {
  VideoDetailsModel? videoDetailsModel;

  PlatformCheckCodeAlreadyChargedState(this.videoDetailsModel);
}

class PlatformGetVideosLoadingState extends PlatformStates {}

class PlatformGetVideosSuccessState extends PlatformStates {}

class PlatformGetVideosFailState extends PlatformStates {
  String err;
  PlatformGetVideosFailState(this.err);
}

class PlatformGetRecentVideosLoadingState extends PlatformStates {}

class PlatformGetRecentVideosSuccessState extends PlatformStates {}

class PlatformGetRecentVideosFailState extends PlatformStates {
  String err;
  PlatformGetRecentVideosFailState(this.err);
}

class PlatformGetVideoDetailsLoadingState extends PlatformStates {}

class PlatformGetVideoDetailsSuccessState extends PlatformStates {
  List<VideoDetailsModel> videoDetails;
  PlatformGetVideoDetailsSuccessState(this.videoDetails);
}

class PlatformGetVideoDetailsFailState extends PlatformStates {
  String err;
  PlatformGetVideoDetailsFailState(this.err);
}

class PlatformGetVideosDetailsLoadingState extends PlatformStates {}

class PlatformGetVideosDetailsSuccessState extends PlatformStates {}

class PlatformGetVideosDetailsFailState extends PlatformStates {
  String err;
  PlatformGetVideosDetailsFailState(this.err);
}

class PlatformBuyLecturesLoadingState extends PlatformStates {}

class PlatformBuyLecturesSuccessState extends PlatformStates {
  bool pop;
  PlatformBuyLecturesSuccessState({required this.pop});
}

class PlatformBuyChaptersSuccessState extends PlatformStates {
  bool pop;
  PlatformBuyChaptersSuccessState({required this.pop});
}

class PlatformBuyLecturesFailState extends PlatformStates {
  String err;
  PlatformBuyLecturesFailState(this.err);
}

class PlatformaddPdfLoadingState extends PlatformStates {}

class PlatformaddPdfSuccessState extends PlatformStates {}

class PlatformaddPdfFailState extends PlatformStates {
  String err;
  PlatformaddPdfFailState(this.err);
}

class PlatformRemoveLecturesLoadingState extends PlatformStates {}

class PlatformRemoveLecturesSuccessState extends PlatformStates {}

class PlatformRebuildStateState extends PlatformStates {}

class PlatformRemoveLecturesFailState extends PlatformStates {
  String err;
  PlatformRemoveLecturesFailState(this.err);
}

class PlatformPickImageFromGallerySuccessState extends PlatformStates {}

class PlatformPickImageFromGalleryFailState extends PlatformStates {
  String err;
  PlatformPickImageFromGalleryFailState(this.err);
}

class PlatformUplaodImageLoadingState extends PlatformStates {}

class PlatformUplaodImageFailState extends PlatformStates {}

class PlatformUplaodUpdatedDataLoadingState extends PlatformStates {}

class PlatformUplaodUpdatedDataSuccessState extends PlatformStates {}

class PlatformUplaodUpdatedDataFailState extends PlatformStates {
  String err;
  PlatformUplaodUpdatedDataFailState(this.err);
}

class PlatformUpdatePasswordLoadingState extends PlatformStates {}

class PlatformUpdatePasswordSuccessState extends PlatformStates {}

class PlatformUpdatePasswordFailState extends PlatformStates {
  String err;
  PlatformUpdatePasswordFailState(this.err);
}

class PlatformCheckQuizLoadingState extends PlatformStates {}

class PlatformCheckLectureQuizSuccessState extends PlatformStates {
  String? vidId;
  int? minDegree;

  PlatformCheckLectureQuizSuccessState(this.vidId, this.minDegree);
}

class PlatformCheckQuizSuccessState extends PlatformStates {
  String? title;
  PlatformCheckQuizSuccessState({this.title});
}

class PlatformCheckQuizFailState extends PlatformStates {
  String err;
  PlatformCheckQuizFailState(this.err);
}

class PlatformGetAvaExamsLoadingState extends PlatformStates {}

class PlatformGetAvaExamsSuccessState extends PlatformStates {}

class PlatformGetAvaExamsFailState extends PlatformStates {
  String err;
  PlatformGetAvaExamsFailState(this.err);
}

class PlatformQuizInitState extends PlatformStates {}

class PlatformQuizGetQuizesLoadingState extends PlatformStates {}

class PlatformQuizGetQuizesSuccessState extends PlatformStates {
  List<QuestionModel> questions;
  PlatformQuizGetQuizesSuccessState(this.questions);
}

class PlatformQuizGetQuizesFailState extends PlatformStates {
  String err;
  PlatformQuizGetQuizesFailState(this.err);
}

class PlatformQuizGetQuestionBankLoadingState extends PlatformStates {}

class PlatformQuizGetQuestionBankSuccessState extends PlatformStates {
  List<QuestionModel> questions;
  PlatformQuizGetQuestionBankSuccessState(this.questions);
}

class PlatformQuizGetQuestionBankChaptersSuccessState extends PlatformStates {
  Map<String?, List<String?>> chapters;
  PlatformQuizGetQuestionBankChaptersSuccessState(this.chapters);
}

class PlatformQuizGetQuestionBankFailState extends PlatformStates {
  String err;
  PlatformQuizGetQuestionBankFailState(this.err);
}

class PlatformQuizSelectAnswerState extends PlatformStates {}

class PlatformQuestionbankSelectAnswerState extends PlatformStates {}

class PlatformQuizCheckIsLastState extends PlatformStates {}

class PlatformQuizCheckIsStartState extends PlatformStates {}

class PlatformAddStdPointsLoadingState extends PlatformStates {}

class PlatformAddStdPointsSuccessState extends PlatformStates {}

class PlatformAddStdPointsFailState extends PlatformStates {
  String err;
  PlatformAddStdPointsFailState(this.err);
}

class PlatformAddStdQuestionbankPointsLoadingState extends PlatformStates {}

class PlatformAddStdQuestionbankPointsSuccessState extends PlatformStates {}

class PlatformAddStdQuestionbankPointsFailState extends PlatformStates {
  String err;
  PlatformAddStdQuestionbankPointsFailState(this.err);
}

class PlatformQuizGetFreeQuestionBankSuccessState extends PlatformStates {
  Map<String, Map<String, List<QuestionModel>>> questionbankFreeQuestions;
  PlatformQuizGetFreeQuestionBankSuccessState(this.questionbankFreeQuestions);
}

class PlatformQuizGetFreeQuestionBankLoadingState extends PlatformStates {}

class PlatformQuizGetFreeQuestionBankFailState extends PlatformStates {
  String err;
  PlatformQuizGetFreeQuestionBankFailState(this.err);
}

class PlatformLoadMoreFreeQuestionBankLoadingState extends PlatformStates {
  String lectureKey;
  PlatformLoadMoreFreeQuestionBankLoadingState(this.lectureKey);
}

class PlatformLoadMoreFreeQuestionBankSuccessState extends PlatformStates {
  String lectureKey;
  bool hasMore;
  PlatformLoadMoreFreeQuestionBankSuccessState(this.lectureKey, this.hasMore);
}

class PlatformLoadMoreFreeQuestionBankFailState extends PlatformStates {
  String err;
  PlatformLoadMoreFreeQuestionBankFailState(this.err);
}

class PlatformGetLecturesDataLoadingState extends PlatformStates {}

class PlatformGetLecturesDataSuccessState extends PlatformStates {
  List<Map<String, dynamic>> lectureData;
  List<WatchesVideoModel> vidds;
  PlatformGetLecturesDataSuccessState(this.lectureData, this.vidds);
}

class PlatformGetLecturesDataFailState extends PlatformStates {
  String err;
  PlatformGetLecturesDataFailState(this.err);
}

class PlatformGetAttendenceDataLoadingState extends PlatformStates {}

class PlatformGetAttendanceDataSuccessState extends PlatformStates {}

class PlatformGetAttendanceDataFailState extends PlatformStates {
  String err;
  PlatformGetAttendanceDataFailState(this.err);
}

class States extends PlatformStates {}

class SecgetRequestsLoadingState extends PlatformStates {}

class GetRequests2state extends PlatformStates {}

class AddRequestLoadingState extends PlatformStates {}

class AddRequestSuccessState extends PlatformStates {}

class AddRequestErrorState extends PlatformStates {}

class PickImageState extends PlatformStates {}

class PickImageState2 extends PlatformStates {}

class ImageLoadingState extends PlatformStates {}

class DeleteImage extends PlatformStates {}

class ChangeIcon1State extends PlatformStates {}

class GetALlRequests1 extends PlatformStates {}

class ChangeIcon2State extends PlatformStates {}

class ChangeIcon21State extends PlatformStates {}

class ChangeIcon22State extends PlatformStates {}

class GetALlRequests2 extends PlatformStates {}

class GetALlRequests3 extends PlatformStates {}

class ChangeSendIconstate extends PlatformStates {}

class UploadLoadingState extends PlatformStates {}

class AddMessageLoadingState extends PlatformStates {}

class UploadChatImageState extends PlatformStates {}

class SwapState extends PlatformStates {}

class PlatformgetChaptersFailState extends PlatformStates {}

class PlatformgetChaptersLoadingState extends PlatformStates {}

class PlatformgetChaptersSuccessState extends PlatformStates {}

class LecturesChoicesStates extends PlatformStates {}

class RequestChoicesStates extends PlatformStates {}

class GetAttendanceGroupsState extends PlatformStates {}

class PlatformGetPostsSuccessState extends PlatformStates {}

class PlatformGetPostsFailState extends PlatformStates {
  String err;
  PlatformGetPostsFailState(this.err);
}

class PlatformTogglePostLikeSuccessState extends PlatformStates {}

class PlatformChangeCommentValue extends PlatformStates {}

class WrittenAnswerImageChangedState extends PlatformStates {}

class WrittenAnswerSavedState extends PlatformStates {}

class WrittenAnswerUpdated extends PlatformStates {}

class WrittenAnswerUploading extends PlatformStates {
  final bool isUploading;
  WrittenAnswerUploading(this.isUploading);
}

class PlatformBuyQuizWalletLoadingState extends PlatformStates {}

class PlatformBuyQuizWalletSuccessState extends PlatformStates {}

class PlatformBuyQuizWalletFailState extends PlatformStates {
  String err;
  PlatformBuyQuizWalletFailState(this.err);
}

class PlatfromGetAllInvoicesLoadingState extends PlatformStates {}

class PlatfromGetAllInvoicesSuccessState extends PlatformStates {}

class PlatfromGetAllInvoicesFailState extends PlatformStates {
  String err;
  PlatfromGetAllInvoicesFailState(this.err);
}

class PlatfromGetMoreInvoicesLoadingState extends PlatformStates {}

class PlatfromGetMoreInvoicesSuccessState extends PlatformStates {}

class PlatfromGetMoreInvoicesFailState extends PlatformStates {
  String err;
  PlatfromGetMoreInvoicesFailState(this.err);
}
