// ignore_for_file: deprecated_member_use, must_be_immutable, use_build_context_synchronously

import 'dart:io';
import 'dart:ui';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/constants/payment_options.dart';
import 'package:salah_online_platform/models/watches_video_model.dart';
import 'package:salah_online_platform/screens/quiz/start_quiz_screen.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../bloc/platformCubit.dart';
import '../../bloc/platformStates.dart';
import '../../constants/colors.dart';
import '../../constants/components.dart';
import '../../constants/constants.dart';
import '../../constants/styles.dart';
import '../../constants/widgets.dart';
import '../../generated/l10n.dart';
import '../../models/user_model.dart';

import '../quiz/quiz_answs_screen.dart';
import 'pdf_screen.dart';
import 'youtube_player_screen.dart';

class LectureDetailsDetailsScreen extends StatefulWidget {
  LectureDetailsDetailsScreen({
    super.key,
    required this.price,
    required this.thumbnail,
    required this.title,
    this.chapTitle,
    this.subTitle,
    this.prevPrice,
    required this.chapId,
    required this.lecId,
    required this.dep,
  });

  String thumbnail;
  int price;
  int? prevPrice;
  String title;
  String? chapTitle;
  String? subTitle;

  String chapId;
  String lecId;
  bool dep;

  @override
  State<LectureDetailsDetailsScreen> createState() =>
      _LectureDetailsDetailsScreenState();
}

class _LectureDetailsDetailsScreenState
    extends State<LectureDetailsDetailsScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();

    PlatformCubit.get(context).getLectureData(
      chapId: widget.chapId,
      lecId: widget.lecId,
    );

    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showTitle) {
        setState(() => _showTitle = true);
      } else if (_scrollController.offset <= 200 && _showTitle) {
        setState(() => _showTitle = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool isLoading = false;

  List<WatchesVideoModel> vidds = [];

  List<Map<String, dynamic>> lectureData = [];
  @override
  Widget build(BuildContext contextm) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformBuyLecturesLoadingState ||
            state is PlatformCheckQuizLoadingState ||
            state is PlatformCheckCodeLoadingState) {
          isLoading = true;
        }
        if (state is PlatformBuyLecturesSuccessState) {
          isLoading = false;
          if (state.pop) {
            Navigator.pop(context);
          }

          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.success,
            title: 'تم بنجاح',
            message: S.of(context).purchased_success,
          );
        }

        if (state is PlatformBuyLecturesFailState) {
          isLoading = false;
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err
                .substring(state.err.indexOf(']') + 2, state.err.length),
          );
        }

        if (state is PlatformGetLecturesDataSuccessState) {
          setState(() {
            lectureData = state.lectureData;
            vidds = state.vidds;
          });
          debugPrint(PlatformCubit.get(context).lectureData.length.toString());
        }
        if (state is PlatformCheckQuizFailState) {
          isLoading = false;
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err
                .substring(state.err.indexOf(']') + 2, state.err.length),
          );
        }

        if (state is PlatformCheckLectureQuizSuccessState) {
          isLoading = false;
          Components.push(
            context: contextm,
            widget: StartQuizScreen(
              chapId: widget.chapId,
              dep: widget.dep,
              price: widget.price,
              thumbnail: widget.thumbnail,
              title: widget.title,
              lecId: state.vidId,
              minDegree: state.minDegree,
            ),
          );
        }

        if (state is PlatformCheckCodeFailState) {
          isLoading = false;
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err
                .substring(state.err.indexOf(']') + 2, state.err.length),
          );
        }
        if (state is PlatformCheckCodeSuccessState) {
          isLoading = false;
          Navigator.pop(context);

          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.success,
            title: 'تم بنجاح',
            message: S.of(context).rech_succ,
          );
        }
      },
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        return Scaffold(
          bottomNavigationBar: _buildPurchaseBar(
            context: context,
            cubit: cubit,
            price: widget.price,
            prevPrice: widget.prevPrice,
            chapId: widget.chapId,
            lecId: widget.lecId,
            vidds: vidds,
            itemName: '${widget.chapTitle ?? ''} - ${widget.title}',
            isLoading: isLoading,
          ),
          body: RefreshIndicator(
            onRefresh: () {
              return cubit.getLectureData(
                chapId: widget.chapId,
                lecId: widget.lecId,
              );
            },
            color: Components.setBgColor(cubit.isDarkMode),
            child: Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // SliverAppBar with background image
                    SliverAppBar(
                      expandedHeight:
                          (widget.subTitle?.isEmpty ?? true) ? 350.0 : 400.0,
                      floating: false,
                      pinned: true,
                      foregroundColor: Colors.white,
                      backgroundColor: cubit.isDarkMode
                          ? Colors.black.withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.95),
                      elevation: 10.0,
                      title: AnimatedOpacity(
                        opacity: _showTitle ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 1000),
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title2Style.copyWith(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background image
                            DefaultImage(
                              imgUrl: widget.thumbnail,
                              fit: BoxFit.cover,
                            ),
                            // Enhanced backdrop filter with multiple layers
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.2),
                                      Colors.black.withValues(alpha: 0.4),
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            // Content overlay
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Enhanced thumbnail with shadow
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.3),
                                          spreadRadius: 2,
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: DefaultImage(
                                          imgUrl: widget.thumbnail,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  // Enhanced title with shadow
                                  Container(
                                    height: (widget.subTitle?.isEmpty ?? true)
                                        ? 70
                                        : 120.0,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.title2Style
                                              .copyWith(
                                            fontSize: 18.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                offset: const Offset(0, 2),
                                                blurRadius: 4,
                                                color: Colors.black
                                                    .withValues(alpha: 0.8),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (widget.subTitle != null &&
                                            widget.subTitle!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Text(
                                              widget.subTitle!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.body2Style,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Awaiting-payment banner (shown after the student starts
                    // an online/Fawry payment but hasn't completed it yet).
                    if (!cubit.showDelAcc &&
                        cubit.isLecturePending(
                          chapId: widget.chapId,
                          lecId: widget.lecId,
                        ))
                      SliverToBoxAdapter(
                        child: Widgets.buildPendingBanner(cubit.isDarkMode),
                      ),

                    // Enhanced lectures list section

                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8.0),
                            Text(
                              S.of(context).content,
                              style: AppTextStyles.title2Style.copyWith(
                                fontSize: 18.0,
                                color: Components.setBgColor(cubit.isDarkMode),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    ),

                    // Enhanced lectures list with staggered animation
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      sliver: cubit.lectureData.isEmpty
                          ? SliverToBoxAdapter(
                              child: Container(
                                margin: const EdgeInsets.all(32.0),
                                padding: const EdgeInsets.all(24.0),
                                decoration: BoxDecoration(
                                  color: cubit.isDarkMode
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: cubit.isDarkMode
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black.withValues(alpha: 0.05),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.video_library_outlined,
                                      size: 48.0,
                                      color: cubit.isDarkMode
                                          ? Colors.white38
                                          : Colors.black38,
                                    ),
                                    const SizedBox(height: 16.0),
                                    Text(
                                      S.of(context).no_content_yet,
                                      style: AppTextStyles.body1Style.copyWith(
                                        color: cubit.isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return TweenAnimationBuilder<double>(
                                    duration: Duration(
                                        milliseconds: 800 + (index * 150)),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    curve: Curves.easeInOut,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 30 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 0), // مفيش مسافات كبيرة
                                            child: _buildLectureContent(
                                                cubit, index),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                childCount: lectureData.length,
                              ),
                            ),

                      /*
                           SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return TweenAnimationBuilder<double>(
                                    duration: Duration(
                                        milliseconds: 800 + (index * 150)),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    curve: Curves.easeInOut,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 30 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 12.0,
                                            ),
                                            child:
                                                _buildLectureContent(cubit),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                childCount: cubit.lectureData.length,
                              ),
                            ),
                  */
                    ),

                    // Bottom padding for better scrolling experience
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100.0),
                    ),
                  ],
                ),
                /*
                if (!(cubit.isGuest() && widget.price != 1111) &&
                    !cubit.showDelAcc &&
                    !cubit.checkPackagePurchased(
                      vidds: vidds,
                      chapId: widget.chapId,
                      lecId: widget.lecId,
                    ))
                  Positioned(
                    bottom: 32,
                    left: MediaQuery.of(context).size.width / 5,
                    right: MediaQuery.of(context).size.width / 5,
                    child: DefaultWaitedButton(
                      isDarkMode: cubit.isDarkMode,
                      isLoading: isLoading,
                      width: double.infinity,
                      onPressed: () async {
                        bool isConnected = await Components.checkConnection();
                        if (isConnected) {
                          if (widget.price == 0 || widget.price == 1111) {
                            if (!isLoading) {
                              cubit.buyLectures(
                                chapId: widget.chapId,
                                lecId: widget.lecId,
                                newVids: vidds,
                                price: 0,
                              );
                            }
                          } else {
                            // show bottom sheet
                            cubit.getIsShowOnlinePayment();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context)
                                      .viewInsets
                                      .bottom,
                                ),
                                child: AnimatedPaymentBottomSheetContent(
                                  isLoading: isLoading,
                                  isDarkMode: cubit.isDarkMode,
                                  isAr: cubit.isAr,
                                  price: widget.price,
                                  itemName:
                                      '${widget.chapTitle ?? ''} - ${widget.title}',
                                  codeClicked: ({required code}) {
                                    cubit.checkCode(
                                      chapId: widget.chapId,
                                      lecId: widget.lecId,
                                      code: code,
                                      context: context,
                                    );
                                  },
                                  walletClicked: () {
                                    cubit.buyLectures(
                                      chapId: widget.chapId,
                                      lecId: widget.lecId,
                                      newVids: vidds,
                                      price: widget.price == 1111
                                          ? 0
                                          : widget.price,
                                    );
                                  },
                                  onlineClicked: () {
                                    cubit.buyLectures(
                                      chapId: widget.chapId,
                                      lecId: widget.lecId,
                                      newVids: vidds,
                                      price: 0,
                                    );
                                  },
                                ),
                              ),
                              backgroundColor: Colors.transparent,
                              enableDrag: true,
                              showDragHandle: false,
                            );
                          }
                        } else {
                          AppStatusDialog.show(
                            context: context,
                            status: AppDialogStatus.error,
                            title: 'مفيش نت',
                            message: S.of(context).no_internet,
                          );
                        }
                      },
                      txt: widget.price == 0 || widget.price == 1111
                          ? '${S.of(context).buy_now} -- ${S.of(context).free}'
                          : '${S.of(context).buy_now} ${S.of(context).withh} - ${widget.price} ${S.of(context).egp}',
                    ),
                  ),
             */
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLectureContent(PlatformCubit cubit, int index) {
    UserModel um = Constants.userBox.get('user');

    int value = 0;
    for (int i = 0; i < lectureData.length; i++) {
      final item = lectureData[i];

      if (item['type'] == 'pdf') {
        final pdfIndex =
            um.purchasedPdfs?[widget.chapId]?[widget.lecId]?.indexWhere(
                  (element) => element == item['id'],
                ) ??
                -1;
        if (pdfIndex != -1) value++;
      } else if (item['type'] == 'video') {
        final vids =
            um.purchasedVideos?[widget.chapId]?.lectures?[widget.lecId]?.videos;
        final vid = vids?[item['id']];
        if (vid != null) {
          if ((vid.avaWatches ?? 4) - (vid.stdWatches ?? 0) <
              (vid.avaWatches ?? 4)) {
            value++;
          }
        }
      } else if (item['type'] == 'quiz') {
        String quizId = '${item['id']},${item['code']}';

        if (um.stdQuizes?[quizId] != null &&
            (um.stdQuizes![quizId]!.degree >= (item['minDegree'] ?? 0))) {
          value++;
        }
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!cubit.showDelAcc &&
              widget.dep &&
              cubit.checkPackagePurchased(
                vidds: vidds,
                chapId: widget.chapId,
                lecId: widget.lecId,
              ))
            Column(
              children: [
                Expanded(
                  child: Container(
                    width: 3,
                    color: index == 0
                        ? Colors.transparent
                        : (index < value
                            ? Components.setBgColor(cubit.isDarkMode)
                            : (cubit.isDarkMode
                                ? AppColors.darkBorder
                                : AppColors.lightBborder)),
                  ),
                ),
                _buildProgressMarker(index, value, cubit.isDarkMode),
                Expanded(
                  child: Container(
                    width: 3,
                    color: index == lectureData.length - 1
                        ? Colors.transparent
                        : (index < value
                            ? Components.setBgColor(cubit.isDarkMode)
                            : (cubit.isDarkMode
                                ? AppColors.darkBorder
                                : AppColors.lightBborder)),
                  ),
                ),
              ],
            ),
          if (widget.dep) const SizedBox(width: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: BuildLecturesItem(
                price: widget.price,
                isLoading: isLoading,
                packagePurchased: cubit.checkPackagePurchased(
                  vidds: vidds,
                  chapId: widget.chapId,
                  lecId: widget.lecId,
                ),
                lecId: widget.lecId,
                cubit: cubit,
                dep: widget.dep,
                chapId: widget.chapId,
                lectureData: lectureData[index],
                previousLectureData: index == 0 ? null : lectureData[index - 1],
                isDarkMode: cubit.isDarkMode,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Modern "awaiting payment" card shown while a lecture is flagged `pending`.
  /// Its button re-opens the payment sheet so the student can resume the same
  /// flow or start a brand-new invoice (e.g. if they lost their Fawry code).

  Widget _buildProgressMarker(int index, int value, bool isDarkMode) {
    final color = Components.setBgColor(isDarkMode);
    final borderColor =
        isDarkMode ? AppColors.darkBorder : AppColors.lightBborder;

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index < value ? color : borderColor,
        border: index == value ? Border.all(width: 2.2, color: color) : null,
      ),
      child: index < value
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}

// Bottom purchase bar.
Widget? _buildPurchaseBar({
  required BuildContext context,
  required PlatformCubit cubit,
  required price,
  required chapId,
  required lecId,
  required vidds,
  prevPrice,
  required itemName,
  required isLoading,
}) {
  if (!(!(cubit.isGuest() && price != 1111) &&
      !cubit.showDelAcc &&
      !cubit.checkPackagePurchased(
        vidds: vidds,
        chapId: chapId,
        lecId: lecId,
      ))) {
    return null;
  }

  final primaryColor = Components.setBgColor(cubit.isDarkMode);
  final hasDiscount = prevPrice != null && prevPrice! > price!;
  UserModel um = Constants.userBox.get('user');
  bool isChapPaid = um.purchasedVideos?[chapId]?.status == 'paid' &&
      um.purchasedVideos?[chapId]?.lectures?[lecId] == null;
  bool isLecPending = cubit.isLecturePending(
    chapId: chapId,
    lecId: lecId,
  );
  return Container(
    decoration: BoxDecoration(
      color: cubit.isDarkMode ? const Color(0xFF161616) : Colors.white,
      border: Border(
        top: BorderSide(
          color: cubit.isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            // Price block
            if (isChapPaid)
              Text(
                S.of(context).paid,
                style: AppTextStyles.title1Style.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
            if (!isChapPaid)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasDiscount)
                    Text(
                      '$prevPrice ${S.of(context).egp}',
                      style: AppTextStyles.body2Style.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.lineThrough,
                        color:
                            cubit.isDarkMode ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price == 0 || price == 1111
                            ? S.of(context).free
                            : '$price',
                        style: AppTextStyles.title1Style.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                      if (price != 0 && price != 1111) ...[
                        const SizedBox(width: 4),
                        Text(
                          S.of(context).egp,
                          style: AppTextStyles.body2Style.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            const SizedBox(width: 16),

            Expanded(
              child: SizedBox(
                height: 52,
                child: Material(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      bool isConnected = await Components.checkConnection();
                      if (isConnected) {
                        if (price == 0 || price == 1111 || isChapPaid) {
                          if (!isLoading) {
                            cubit.buyLectures(
                              chapId: chapId,
                              lecId: lecId,
                              newVids: vidds,
                              price: 0,
                              isChapPaid: isChapPaid,
                              pop: false,
                            );
                          }
                        } else {
                          // show bottom sheet
                          //  cubit.getIsShowOnlinePayment();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: AnimatedPaymentBottomSheetContent(
                                isDarkMode: cubit.isDarkMode,
                                isAr: cubit.isAr,
                                price: price,
                                itemName: itemName,
                                isShowOnlinePayment:
                                    cubit.isLectureShowOnlinePayment,
                                lecId: lecId,
                                chapId: chapId,
                                codeClicked: ({required code}) {
                                  cubit.checkCode(
                                    chapId: chapId,
                                    lecId: lecId,
                                    code: code,
                                    context: context,
                                  );
                                },
                                walletClicked: () {
                                  debugPrint('pressed hereeeeeee');
                                  cubit.buyLectures(
                                    chapId: chapId,
                                    lecId: lecId,
                                    newVids: vidds,
                                    price: price,
                                    pop: true,
                                  );
                                },
                                onlineClicked: ({int? amount}) {
                                  cubit.buyLectures(
                                    chapId: chapId,
                                    lecId: lecId,
                                    newVids: vidds,
                                    price: 0,
                                    pop: true,
                                  );
                                },
                              ),
                            ),
                            backgroundColor: Colors.transparent,
                            enableDrag: true,
                            showDragHandle: false,
                          );
                        }
                      } else {
                        AppStatusDialog.show(
                          context: context,
                          status: AppDialogStatus.error,
                          title: 'مفيش نت',
                          message: S.of(context).no_internet,
                        );
                      }
                    },
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLecPending
                                ? Icons.refresh_rounded
                                : Icons.shopping_cart_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isLecPending
                                ? S.of(context).complete_payment
                                : S.of(context).buy_now,
                            style: AppTextStyles.body1Style.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
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
}

class BuildLecturesItem extends StatelessWidget {
  BuildLecturesItem({
    super.key,
    required this.isDarkMode,
    required this.cubit,
    required this.lectureData,
    this.previousLectureData,
    required this.lecId,
    //  required this.price,
    required this.chapId,
    required this.packagePurchased,
    required this.dep,
    required this.price,
    required this.isLoading,
  });
  bool isDarkMode;
  Map<String, dynamic>? previousLectureData;
  Map<String, dynamic> lectureData;
  bool packagePurchased;
  bool isLoading = false;
  String lecId;
  String chapId;
  bool dep;
  int price;
  // int price;
  PlatformCubit cubit;

  bool isVideoPurchased() => cubit.checkVideoPurchased(
        vidId: lectureData['id'],
        chapId: chapId,
        lecId: lecId,
        // avaWatch: um.pur['avaWatches'] ?? 4,
      );
  bool isPurchased() => cubit.checkPurchased(
        lecId: lecId,
        chapId: chapId,
      );
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (lectureData['type'] == 'pdf') {
          if (isPurchased() || cubit.showDelAcc) {
            if (cubit.showDelAcc) {
              Components.push(
                context: context,
                widget: PdfScreen(
                  pdfUrl: lectureData['url'],
                  chapId: chapId,
                  lecId: lecId,
                  pdfId: lectureData['id'],
                ),
              );
            } else {
              UserModel um = Constants.userBox.get('user');
              if (dep) {
                if (previousLectureData != null) {
                  // previous is video
                  // check at least 1 watch
                  if (previousLectureData!['type'] == 'video') {
                    final vids =
                        um.purchasedVideos?[chapId]?.lectures?[lecId]?.videos;
                    final vid = vids?[previousLectureData!['id']];
                    if (vid != null) {
                      if ((vid.avaWatches ?? 4) - (vid.stdWatches ?? 0) <
                          (vid.avaWatches ?? 4)) {
                        Components.push(
                          context: context,
                          widget: PdfScreen(
                            pdfUrl: lectureData['url'],
                            chapId: chapId,
                            lecId: lecId,
                            pdfId: lectureData['id'],
                          ),
                        );
                      } else {
                        AppStatusDialog.show(
                          context: context,
                          status: AppDialogStatus.warning,
                          title: 'خلي بالك',
                          message: S.of(context).watch_vid_pdf,
                          //     'should watch at least one Time of Previous Video to open this video.',
                          primaryActionText: S.of(context).okay,
                          onPrimaryAction: () {
                            Navigator.pop(context);
                          },
                        );
                      }
                    } else {
                      AppStatusDialog.show(
                        context: context,
                        status: AppDialogStatus.warning,
                        title: 'خلي بالك',
                        message: S.of(context).buy_watch_vid_pdf,
                        //  'should buy and watch at least one Time of Previous Video to open this video.',
                        primaryActionText: S.of(context).okay,
                        onPrimaryAction: () {
                          Navigator.pop(context);
                        },
                      );
                    }

                    // previous is quiz
                    // check getminDegree
                  } else if (previousLectureData!['type'] == 'quiz') {
                    //
                    String quizId =
                        '${previousLectureData!['id']},${previousLectureData!['code']}';

                    if (um.stdQuizes?[quizId] != null) {
                      if (um.stdQuizes![quizId]!.degree >=
                          (previousLectureData!['minDegree'] ?? 0)) {
                        Components.push(
                          context: context,
                          widget: PdfScreen(
                            pdfUrl: lectureData['url'],
                            chapId: chapId,
                            lecId: lecId,
                            pdfId: lectureData['id'],
                          ),
                        );
                      } else {
                        AppStatusDialog.show(
                          context: context,
                          status: AppDialogStatus.warning,
                          title: 'خلي بالك',
                          message:
                              '${S.of(context).get_least} ${previousLectureData!['minDegree']}/${previousLectureData!['fullMark']} ${S.of(context).quiz_pdf}',

                          //   'should get at least ${previousLectureData!['minDegree']}/${previousLectureData!['fullMark']} of Previous quiz to open this video.',
                          primaryActionText: S.of(context).okay,
                          onPrimaryAction: () {
                            Navigator.pop(context);
                          },
                        );
                      }
                    } else {
                      AppStatusDialog.show(
                        context: context,
                        status: AppDialogStatus.warning,
                        title: 'خلي بالك',
                        message:
                            '${S.of(context).ans_get_least} ${previousLectureData!['minDegree']}/${previousLectureData!['fullMark']} ${S.of(context).quiz_pdf}',
                        //  'should answer and get at least ${previousLectureData!['minDegree']}/${previousLectureData!['fullMark']} of Previous quiz to open this video.',
                        primaryActionText: S.of(context).okay,
                        onPrimaryAction: () {
                          Navigator.pop(context);
                        },
                      );
                    }
                  } else {
                    int pdfIndex =
                        um.purchasedPdfs?[chapId]?[lecId]?.indexWhere(
                              (element) =>
                                  element == previousLectureData!['id'],
                            ) ??
                            -1;

                    if (pdfIndex != -1) {
                      Components.push(
                        context: context,
                        widget: PdfScreen(
                          pdfUrl: lectureData['url'],
                          chapId: chapId,
                          lecId: lecId,
                          pdfId: lectureData['id'],
                        ),
                      );
                    } else {
                      AppStatusDialog.show(
                        context: context,
                        status: AppDialogStatus.warning,
                        title: 'خلي بالك',
                        message: S.of(context).open_pdf_pdf,
                        // 'should Open Previous PDF to open this video.',
                        primaryActionText: S.of(context).okay,
                        onPrimaryAction: () {
                          Navigator.pop(context);
                        },
                      );
                    }
                  }
                } else {
                  // first element on list
                  Components.push(
                    context: context,
                    widget: PdfScreen(
                      pdfUrl: lectureData['url'],
                      chapId: chapId,
                      lecId: lecId,
                      pdfId: lectureData['id'],
                    ),
                  );
                }
              } else {
                Components.push(
                  context: context,
                  widget: PdfScreen(
                    pdfUrl: lectureData['url'],
                    chapId: chapId,
                    lecId: lecId,
                    pdfId: lectureData['id'],
                  ),
                );
              }
            }
          } else {
            if (cubit.isGuest() && price != 1111) {
              Constants.showLoginDialog(
                isDarkMode: cubit.isDarkMode,
                context: context,
              );
            }
          }
        } else if (lectureData['type'] == 'video') {
          if (isVideoPurchased() || cubit.showDelAcc) {
            bool isConnected = await Components.checkConnection();
            debugPrint(isConnected.toString());
            if (isConnected) {
              if (cubit.showDelAcc) {
                if (Platform.isWindows &&
                    !lectureData['url'].contains('vimeo')) {
                  // show error message
                  AppStatusDialog.show(
                    context: context,
                    status: AppDialogStatus.error,
                    title: S.of(context).err_open_vid,
                    message: S.of(context).try_mobile_to_open,
                    primaryActionText: S.of(context).okay,
                    onPrimaryAction: () {
                      Navigator.pop(context);
                    },
                  );
                } else {
                  Components.push(
                    context: context,
                    widget: YoutubePlayerScreen(
                      videoUrl: lectureData['url'],
                      cubit: cubit,
                    ),
                  );
                }
              } else {
                UserModel um = Constants.userBox.get('user');
                final purchases =
                    um.purchasedVideos?[chapId]?.lectures?[lecId]?.videos;

                if (dep) {
                  if (previousLectureData != null) {
                    // previous is video
                    // check at least 1 watch
                    if (previousLectureData!['type'] == 'video') {
                      final prevVideo = purchases?[previousLectureData!['id']];

                      if (prevVideo != null) {
                        if ((prevVideo.stdWatches ?? 0) >= 1) {
                          if (Platform.isWindows &&
                              !lectureData['url'].contains('vimeo')) {
                            // show error message
                            AppStatusDialog.show(
                              context: context,
                              status: AppDialogStatus.error,
                              title: S.of(context).err_open_vid,
                              message: S.of(context).try_mobile_to_open,
                              primaryActionText: S.of(context).okay,
                              onPrimaryAction: () {
                                Navigator.pop(context);
                              },
                            );
                            cubit.watchVideo(
                              lecId: lecId,
                              valid: false,
                              vidId: lectureData['id'],
                              chapId: chapId,
                              avaWatches: lectureData['avaWatches'] ?? 4,
                            );
                          } else {
                            AppStatusDialog.show(
                              context: context,
                              status: AppDialogStatus.info,
                              title: 'بقولك ايه',
                              message:
                                  '${S.of(context).sure_enter_video}\n${S.of(context).you_will_have} ${((prevVideo.avaWatches ?? 4) - 1) - (prevVideo.stdWatches ?? 0)} ${S.of(context).watches_left}',
                              primaryActionText: S.of(context).confirm,
                              onPrimaryAction: () {
                                Navigator.pop(context);
                                Components.push(
                                  context: context,
                                  widget: YoutubePlayerScreen(
                                    videoUrl: lectureData['url'],
                                    cubit: cubit,
                                  ),
                                );

                                cubit.watchVideo(
                                  lecId: lecId,
                                  valid: true,
                                  vidId: lectureData['id'],
                                  chapId: chapId,
                                  avaWatches: lectureData['avaWatches'] ?? 4,
                                );
                              },
                            );
                          }
                        } else {
                          AppStatusDialog.show(
                            context: context,
                            status: AppDialogStatus.warning,
                            title: 'خلي بالك',
                            message: S.of(context).watch_vid_vid,
                            //    'should watch at least one Time of Previous Video to open this video.',
                            primaryActionText: S.of(context).okay,
                            onPrimaryAction: () {
                              Navigator.pop(context);
                            },
                          );
                        }
                      } else {
                        AppStatusDialog.show(
                          context: context,
                          status: AppDialogStatus.warning,
                          title: 'خلي بالك',
                          message: S.of(context).buy_watch_vid_vid,

                          //   'should buy and watch at least one Time of Previous Video to open this video.',
                          primaryActionText: S.of(context).okay,
                          onPrimaryAction: () {
                            Navigator.pop(context);
                          },
                        );
                      }

                      // previous is quiz
                      // check getminDegree
                    } else if (previousLectureData!['type'] == 'quiz') {
                      //

                      String quizId =
                          '${previousLectureData!['id']},${previousLectureData!['code']}';

                      if (um.stdQuizes?[quizId] != null) {
                        if (um.stdQuizes![quizId]!.degree >=
                            (previousLectureData!['minDegree'] ?? 0)) {
                          if (Platform.isWindows &&
                              !lectureData['url'].contains('vimeo')) {
                            // show error message
                            AppStatusDialog.show(
                              context: context,
                              status: AppDialogStatus.error,
                              title: S.of(context).err_open_vid,
                              message: S.of(context).try_mobile_to_open,
                              primaryActionText: S.of(context).okay,
                              onPrimaryAction: () {
                                Navigator.pop(context);
                              },
                            );
                            cubit.watchVideo(
                              lecId: lecId,
                              valid: false,
                              vidId: lectureData['id'],
                              chapId: chapId,
                              avaWatches: lectureData['avaWatches'] ?? 4,
                            );
                          } else {
                            AppStatusDialog.show(
                              context: context,
                              status: AppDialogStatus.info,
                              title: 'بقولك ايه',
                              primaryActionText: S.of(context).confirm,
                              // % (lectureData['avaWatches'] ?? 4)
                              message:
                                  '${S.of(context).sure_enter_video}\n${S.of(context).you_will_have} ${((purchases?[lectureData['id']] == null ? 4 : purchases?[lectureData['id']]?.avaWatches ?? 4) - 1) - (purchases?[lectureData['id']] == null ? 0 : (purchases?[lectureData['id']]?.stdWatches ?? 0))} ${S.of(context).watches_left}',
                              onPrimaryAction: () {
                                Navigator.pop(context);
                                Components.push(
                                  context: context,
                                  widget: YoutubePlayerScreen(
                                    videoUrl: lectureData['url'],
                                    cubit: cubit,
                                  ),
                                );

                                cubit.watchVideo(
                                  lecId: lecId,
                                  valid: true,
                                  vidId: lectureData['id'],
                                  avaWatches: lectureData['avaWatches'] ?? 4,
                                  chapId: chapId,
                                );
                              },
                            );
                          }
                        } else {
                          AppStatusDialog.show(
                            context: context,
                            status: AppDialogStatus.warning,
                            title: 'خلي بالك',
                            message:
                                '${S.of(context).get_least} ${previousLectureData!['minDegree']}/${previousLectureData!['fullMark']} ${S.of(context).quiz_vid}',
                            //    'should get at least ${previousLectureData!['minDegree']}/${previousLectureData!['fullMark']} of Previous quiz to open this video.',
                            primaryActionText: S.of(context).okay,
                            onPrimaryAction: () {
                              Navigator.pop(context);
                            },
                          );
                        }
                      } else {
                        AppStatusDialog.show(
                          context: context,
                          status: AppDialogStatus.warning,
                          title: 'خلي بالك',
                          message:
                              '${S.of(context).ans_get_least} ${previousLectureData!['minDegree']}/${previousLectureData!['fullMark']} ${S.of(context).quiz_vid}',
                          //    'should answer and get at least ${previousLectureData!['minDegree']}/${previousLectureData!['fullMark']} of Previous quiz to open this video.',
                          primaryActionText: S.of(context).okay,
                          onPrimaryAction: () {
                            Navigator.pop(context);
                          },
                        );
                      }
                    } else {
                      int pdfIndex =
                          um.purchasedPdfs?[chapId]?[lecId]?.indexWhere(
                                (element) =>
                                    element == previousLectureData!['id'],
                              ) ??
                              -1;

                      if (pdfIndex != -1) {
                        if (Platform.isWindows &&
                            !lectureData['url'].contains('vimeo')) {
                          // show error message
                          AppStatusDialog.show(
                            context: context,
                            status: AppDialogStatus.error,
                            title: S.of(context).err_open_vid,
                            message: S.of(context).try_mobile_to_open,
                            primaryActionText: S.of(context).okay,
                            onPrimaryAction: () {
                              Navigator.pop(context);
                            },
                          );
                          cubit.watchVideo(
                            lecId: lecId,
                            valid: false,
                            vidId: lectureData['id'],
                            chapId: chapId,
                            avaWatches: lectureData['avaWatches'] ?? 4,
                          );
                        } else {
                          AppStatusDialog.show(
                            context: context,
                            status: AppDialogStatus.info,
                            title: 'بقولك ايه',
                            // % (lectureData['avaWatches'] ?? 4)
                            message:
                                '${S.of(context).sure_enter_video}\n${S.of(context).you_will_have} ${((purchases?[lectureData['id']] == null ? 4 : purchases?[lectureData['id']]?.avaWatches ?? 4) - 1) - (purchases?[lectureData['id']] == null ? 0 : (purchases?[lectureData['id']]?.stdWatches ?? 0))} ${S.of(context).watches_left}',
                            primaryActionText: S.of(context).confirm,
                            onPrimaryAction: () {
                              Navigator.pop(context);
                              Components.push(
                                context: context,
                                widget: YoutubePlayerScreen(
                                  videoUrl: lectureData['url'],
                                  cubit: cubit,
                                ),
                              );

                              cubit.watchVideo(
                                lecId: lecId,
                                valid: true,
                                vidId: lectureData['id'],
                                avaWatches: lectureData['avaWatches'] ?? 4,
                                chapId: chapId,
                              );
                            },
                          );
                        }
                      } else {
                        AppStatusDialog.show(
                          context: context,
                          status: AppDialogStatus.warning,
                          title: 'خلي بالك',
                          message: S.of(context).open_pdf_vid,

                          //'should Open Previous PDF to open this video.',
                          primaryActionText: S.of(context).okay,
                          onPrimaryAction: () {
                            Navigator.pop(context);
                          },
                        );
                      }
                    }
                  } else {
                    if (Platform.isWindows &&
                        !lectureData['url'].contains('vimeo')) {
                      // show error message
                      AppStatusDialog.show(
                        context: context,
                        status: AppDialogStatus.error,
                        title: S.of(context).err_open_vid,
                        message: S.of(context).try_mobile_to_open,
                        primaryActionText: S.of(context).okay,
                        onPrimaryAction: () {
                          Navigator.pop(context);
                        },
                      );
                      cubit.watchVideo(
                        lecId: lecId,
                        valid: false,
                        vidId: lectureData['id'],
                        chapId: chapId,
                        avaWatches: lectureData['avaWatches'] ?? 4,
                      );
                    } else {
                      // first element on list
                      AppStatusDialog.show(
                        context: context,
                        status: AppDialogStatus.info,
                        title: 'بقولك ايه',
                        // % (lectureData['avaWatches'] ?? 4)
                        message:
                            '${S.of(context).sure_enter_video}\n${S.of(context).you_will_have} ${((purchases?[lectureData['id']] == null ? 4 : purchases?[lectureData['id']]?.avaWatches ?? 4) - 1) - (purchases?[lectureData['id']] == null ? 0 : (purchases?[lectureData['id']]?.stdWatches ?? 0))} ${S.of(context).watches_left}',
                        primaryActionText: S.of(context).confirm,
                        onPrimaryAction: () {
                          Navigator.pop(context);
                          Components.push(
                            context: context,
                            widget: YoutubePlayerScreen(
                              videoUrl: lectureData['url'],
                              cubit: cubit,
                            ),
                          );

                          cubit.watchVideo(
                            lecId: lecId,
                            valid: true,
                            vidId: lectureData['id'],
                            avaWatches: lectureData['avaWatches'] ?? 4,
                            chapId: chapId,
                          );
                        },
                      );
                    }
                  }
                } else {
                  if (Platform.isWindows &&
                      !lectureData['url'].contains('vimeo')) {
                    // show error message
                    AppStatusDialog.show(
                      context: context,
                      status: AppDialogStatus.error,
                      title: S.of(context).err_open_vid,
                      message: S.of(context).try_mobile_to_open,
                      primaryActionText: S.of(context).okay,
                      onPrimaryAction: () {
                        Navigator.pop(context);
                      },
                    );
                    cubit.watchVideo(
                      lecId: lecId,
                      valid: false,
                      vidId: lectureData['id'],
                      chapId: chapId,
                      avaWatches: lectureData['avaWatches'] ?? 4,
                    );
                  } else {
                    AppStatusDialog.show(
                      context: context,
                      status: AppDialogStatus.info,
                      title: 'بقولك ايه',
                      message:
                          '${S.of(context).sure_enter_video}\n${S.of(context).you_will_have} ${((purchases?[lectureData['id']] == null ? 4 : purchases?[lectureData['id']]?.avaWatches ?? 4) - 1) - (purchases?[lectureData['id']] == null ? 0 : (purchases?[lectureData['id']]?.stdWatches ?? 0))} ${S.of(context).watches_left}',
                      primaryActionText: S.of(context).confirm,
                      onPrimaryAction: () {
                        Navigator.pop(context);
                        Components.push(
                          context: context,
                          widget: YoutubePlayerScreen(
                            videoUrl: lectureData['url'],
                            cubit: cubit,
                          ),
                        );

                        cubit.watchVideo(
                          lecId: lecId,
                          valid: true,
                          vidId: lectureData['id'],
                          avaWatches: lectureData['avaWatches'] ?? 4,
                          chapId: chapId,
                        );
                      },
                    );
                  }
                }
              }
            } else {
              AppStatusDialog.show(
                context: context,
                status: AppDialogStatus.error,
                title: S.of(context).no_internet,
                message: 'مفيش نت',
                primaryActionText: S.of(context).okay,
                onPrimaryAction: () {
                  Navigator.pop(context);
                },
              );
            }
          } else {
            if (cubit.isGuest() && price != 1111) {
              Constants.showLoginDialog(
                isDarkMode: cubit.isDarkMode,
                context: context,
              );
            }
          }
// price for locked video
          /*
           else {
            bool isConnected = await Components.checkConnection();
            if (isConnected) {
              Widgets.defaultAlertDialog(
                context: context,
                type: QuickAlertType.confirm,
                isDarkMode: cubit.isDarkMode,
                body:
                    '${S.of(context).sure_buy} $price ${S.of(context).egp}${S.of(context).question_mark}',
                txt: S.of(context).buy_lec,
                confirmBtnText: S.of(context).buy,
                onConfirmBtnTap: () {
                  Navigator.pop(context);
                  cubit.buyLectures(
                    chapId: chapId,
                    lecId: lecId,
                    vidsIds: [lectureData['id']],
                    price: price,
                    context: context,
                  );
                },
              );
            } else {
              Widgets.defaultAlertDialog(
                context: context,
                type: QuickAlertType.error,
                isDarkMode: PlatformCubit.get(context).isDarkMode,
                body: S.of(context).no_internet,
                txt: 'مفيش نت',
              );
            }
          }
          */
        } else {
          if (isPurchased() || cubit.showDelAcc) {
            UserModel um = Constants.userBox.get('user');
            String quizId = '${lectureData['id']},${lectureData['code']}';
            if (cubit.showDelAcc) {
              if (um.stdQuizes?[quizId] != null) {
                if (um.stdQuizes![quizId]!.degree >=
                    (lectureData['minDegree'] ?? 0)) {
                  bool showDegree =
                      await cubit.getShowDegree(quizId: lectureData['code']);
                  if (showDegree) {
                    Components.push(
                      context: context,
                      widget: QuizAnswersScreen(
                        title: lectureData['title']!,
                        quizCode: lectureData['code'],
                        lecId: lectureData['id'],
                      ),
                    );
                  } else {
                    // show dialog wait to get degree
                    AppStatusDialog.show(
                      context: context,
                      status: AppDialogStatus.info,
                      title: 'خلي بالك',
                      message: S.of(context).wait_to_get_degree,
                      primaryActionText: S.of(context).okay,
                      onPrimaryAction: () {
                        Navigator.pop(context);
                      },
                    );
                  }
                } else {
                  if (!isLoading) {
                    cubit.checkQuiz(
                      quizCode: lectureData['code'],
                      context: context,
                      minDegree: lectureData['minDegree'],
                      vidId: lectureData['id'],
                      title: lectureData['title'],
                    );
                  }
                }
              } else {
                if (!isLoading) {
                  cubit.checkQuiz(
                    quizCode: lectureData['code'],
                    context: context,
                    minDegree: lectureData['minDegree'],
                    vidId: lectureData['id'],
                    title: lectureData['title'],
                  );
                }
              }
            } else {
              if (dep) {
                if (previousLectureData != null) {
                  // previous is video
                  // check at least 1 watch
                  if (previousLectureData!['type'] == 'video') {
                    final vid =
                        um.purchasedVideos?[chapId]?.lectures?[lecId]?.videos;
                    if (vid?[previousLectureData?['id']] != null) {
                      if ((vid![previousLectureData?['id']]!.stdWatches ?? 0) >=
                          1) {
                        if (um.stdQuizes?[quizId] != null) {
                          if (um.stdQuizes![quizId]!.degree >=
                              (lectureData['minDegree'] ?? 0)) {
                            bool showDegree = await cubit.getShowDegree(
                                quizId: lectureData['code']);
                            if (showDegree) {
                              Components.push(
                                context: context,
                                widget: QuizAnswersScreen(
                                  title: lectureData['title']!,
                                  quizCode: lectureData['code'],
                                  lecId: lectureData['id'],
                                ),
                              );
                            } else {
                              // show dialog wait to get degree
                              AppStatusDialog.show(
                                context: context,
                                status: AppDialogStatus.info,
                                title: 'خلي بالك',
                                message: S.of(context).wait_to_get_degree,
                                primaryActionText: S.of(context).okay,
                                onPrimaryAction: () {
                                  Navigator.pop(context);
                                },
                              );
                            }
                          } else {
                            if (!isLoading) {
                              cubit.checkQuiz(
                                quizCode: lectureData['code'],
                                context: context,
                                minDegree: lectureData['minDegree'],
                                vidId: lectureData['id'],
                                title: lectureData['title'],
                              );
                            }
                          }
                        } else {
                          if (!isLoading) {
                            cubit.checkQuiz(
                              quizCode: lectureData['code'],
                              context: context,
                              minDegree: lectureData['minDegree'],
                              vidId: lectureData['id'],
                              title: lectureData['title'],
                            );
                          }
                        }
                      } else {
                        AppStatusDialog.show(
                          context: context,
                          status: AppDialogStatus.warning,
                          title: 'خلي بالك',
                          message: S.of(context).watch_vid_quiz,

                          //    'should watch at least one Time of Previous Video to open this Quiz.',
                          primaryActionText: S.of(context).okay,
                          onPrimaryAction: () {
                            Navigator.pop(context);
                          },
                        );
                      }
                    } else {
                      AppStatusDialog.show(
                        context: context,
                        status: AppDialogStatus.warning,
                        title: 'خلي بالك',
                        message: S.of(context).buy_watch_vid_quiz,
                        primaryActionText: S.of(context).okay,
                        onPrimaryAction: () {
                          Navigator.pop(context);
                        },
                      );
                    }

                    // previous is quiz
                    // check getminDegree
                  } else if (previousLectureData!['type'] == 'quiz') {
                    //
                    String preQuizId =
                        '${previousLectureData!['id']},${previousLectureData!['code']}';

                    if (um.stdQuizes?[preQuizId] != null) {
                      if (um.stdQuizes![preQuizId]!.degree >=
                          (previousLectureData!['minDegree'] ?? 0)) {
                        if (um.stdQuizes?[quizId] != null) {
                          if (um.stdQuizes![quizId]!.degree >=
                              (lectureData['minDegree'] ?? 0)) {
                            bool showDegree = await cubit.getShowDegree(
                                quizId: lectureData['code']);
                            if (showDegree) {
                              Components.push(
                                context: context,
                                widget: QuizAnswersScreen(
                                  title: lectureData['title']!,
                                  quizCode: lectureData['code'],
                                  lecId: lectureData['id'],
                                ),
                              );
                            } else {
                              // show dialog wait to get degree
                              AppStatusDialog.show(
                                context: context,
                                status: AppDialogStatus.info,
                                title: 'خلي بالك',
                                message: S.of(context).wait_to_get_degree,
                                primaryActionText: S.of(context).okay,
                                onPrimaryAction: () {
                                  Navigator.pop(context);
                                },
                              );
                            }
                          } else {
                            if (!isLoading) {
                              cubit.checkQuiz(
                                quizCode: lectureData['code'],
                                context: context,
                                minDegree: lectureData['minDegree'],
                                vidId: lectureData['id'],
                                title: lectureData['title'],
                              );
                            }
                          }
                        } else {
                          if (!isLoading) {
                            cubit.checkQuiz(
                              quizCode: lectureData['code'],
                              context: context,
                              minDegree: lectureData['minDegree'],
                              vidId: lectureData['id'],
                              title: lectureData['title'],
                            );
                          }
                        }
                      } else {
                        AppStatusDialog.show(
                          context: context,
                          status: AppDialogStatus.warning,
                          title: 'خلي بالك',
                          message:
                              '${S.of(context).get_least} ${previousLectureData!['minDegree']}/${previousLectureData!['fullMark']} ${S.of(context).quiz_quiz}',
                          //  'should get at least ${previousLectureData!['minDegree']}/${previousLectureData!['fullMark']} of Previous quiz to open this Quiz.',
                          primaryActionText: S.of(context).okay,
                          onPrimaryAction: () {
                            Navigator.pop(context);
                          },
                        );
                      }
                    } else {
                      AppStatusDialog.show(
                        context: context,
                        status: AppDialogStatus.warning,
                        title: 'خلي بالك',
                        message:
                            '${S.of(context).ans_get_least} ${previousLectureData!['minDegree']}/${previousLectureData!['fullMark']} ${S.of(context).quiz_quiz}',

                        //    'should answer and get at least ${previousLectureData!['minDegree']}/${previousLectureData!['fullMark']} of Previous quiz to open this video.',
                        primaryActionText: S.of(context).okay,
                        onPrimaryAction: () {
                          Navigator.pop(context);
                        },
                      );
                    }
                  } else {
                    int pdfIndex =
                        um.purchasedPdfs?[chapId]?[lecId]?.indexWhere(
                              (element) =>
                                  element == previousLectureData!['id'],
                            ) ??
                            -1;

                    if (pdfIndex != -1) {
                      if (um.stdQuizes?[quizId] != null) {
                        if (um.stdQuizes![quizId]!.degree >=
                            (lectureData['minDegree'] ?? 0)) {
                          bool showDegree = await cubit.getShowDegree(
                              quizId: lectureData['code']);
                          if (showDegree) {
                            Components.push(
                              context: context,
                              widget: QuizAnswersScreen(
                                title: lectureData['title']!,
                                quizCode: lectureData['code'],
                                lecId: lectureData['id'],
                              ),
                            );
                          } else {
                            // show dialog wait to get degree
                            AppStatusDialog.show(
                              context: context,
                              status: AppDialogStatus.info,
                              title: 'خلي بالك',
                              message: S.of(context).wait_to_get_degree,
                              primaryActionText: S.of(context).okay,
                              onPrimaryAction: () {
                                Navigator.pop(context);
                              },
                            );
                          }
                        } else {
                          if (!isLoading) {
                            cubit.checkQuiz(
                              quizCode: lectureData['code'],
                              context: context,
                              minDegree: lectureData['minDegree'],
                              vidId: lectureData['id'],
                              title: lectureData['title'],
                            );
                          }
                        }
                      } else {
                        if (!isLoading) {
                          cubit.checkQuiz(
                            quizCode: lectureData['code'],
                            context: context,
                            minDegree: lectureData['minDegree'],
                            vidId: lectureData['id'],
                            title: lectureData['title'],
                          );
                        }
                      }
                    } else {
                      AppStatusDialog.show(
                        context: context,
                        status: AppDialogStatus.warning,
                        title: 'خلي بالك',
                        message: S.of(context).open_pdf_quiz,
                        //'should Open Previous PDF to open this quiz.',
                        primaryActionText: S.of(context).okay,
                        onPrimaryAction: () {
                          Navigator.pop(context);
                        },
                      );
                    }
                  }
                } else {
                  // first element on list
                  if (um.stdQuizes?[quizId] != null) {
                    if (um.stdQuizes![quizId]!.degree >=
                        (lectureData['minDegree'] ?? 0)) {
                      bool showDegree = await cubit.getShowDegree(
                          quizId: lectureData['code']);
                      if (showDegree) {
                        Components.push(
                          context: context,
                          widget: QuizAnswersScreen(
                            title: lectureData['title']!,
                            quizCode: lectureData['code'],
                            lecId: lectureData['id'],
                          ),
                        );
                      } else {
                        // show dialog wait to get degree
                        AppStatusDialog.show(
                          context: context,
                          status: AppDialogStatus.info,
                          title: 'خلي بالك',
                          message: S.of(context).wait_to_get_degree,
                          primaryActionText: S.of(context).okay,
                          onPrimaryAction: () {
                            Navigator.pop(context);
                          },
                        );
                      }
                    } else {
                      if (!isLoading) {
                        cubit.checkQuiz(
                          quizCode: lectureData['code'],
                          context: context,
                          minDegree: lectureData['minDegree'],
                          vidId: lectureData['id'],
                          title: lectureData['title'],
                        );
                      }
                    }
                  } else {
                    if (!isLoading) {
                      cubit.checkQuiz(
                        quizCode: lectureData['code'],
                        context: context,
                        minDegree: lectureData['minDegree'],
                        vidId: lectureData['id'],
                        title: lectureData['title'],
                      );
                    }
                  }
                }
              } else {
                if (um.stdQuizes?[quizId] != null) {
                  if (um.stdQuizes![quizId]!.degree >=
                      (lectureData['minDegree'] ?? 0)) {
                    bool showDegree =
                        await cubit.getShowDegree(quizId: lectureData['code']);
                    if (showDegree) {
                      Components.push(
                        context: context,
                        widget: QuizAnswersScreen(
                          title: lectureData['title']!,
                          quizCode: lectureData['code'],
                          lecId: lectureData['id'],
                        ),
                      );
                    } else {
                      // show dialog wait to get degree
                      AppStatusDialog.show(
                        context: context,
                        status: AppDialogStatus.info,
                        title: 'خلي بالك',
                        message: S.of(context).wait_to_get_degree,
                        primaryActionText: S.of(context).okay,
                        onPrimaryAction: () {
                          Navigator.pop(context);
                        },
                      );
                    }
                  } else {
                    if (!isLoading) {
                      cubit.checkQuiz(
                        quizCode: lectureData['code'],
                        context: context,
                        minDegree: lectureData['minDegree'],
                        vidId: lectureData['id'],
                        title: lectureData['title'],
                      );
                    }
                  }
                } else {
                  if (!isLoading) {
                    cubit.checkQuiz(
                      quizCode: lectureData['code'],
                      context: context,
                      minDegree: lectureData['minDegree'],
                      vidId: lectureData['id'],
                      title: lectureData['title'],
                    );
                  }
                }
              }
            }
          } else {
            if (cubit.isGuest() && price != 1111) {
              Constants.showLoginDialog(
                isDarkMode: cubit.isDarkMode,
                context: context,
              );
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: isDarkMode ? AppColors.darkBgColor : AppColors.lightBgColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Components.lectureDataIcon(lectureData['type']),
              color: Components.setBgColor(isDarkMode),
              size: 30.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lectureData['title'],
                    maxLines: 2,
                    style: AppTextStyles.body2Style.copyWith(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 17.5,
                    ),
                  ),
                  if (lectureData['type'] == 'video')
                    Row(
                      children: [
                        Text(
                          '${S.of(context).duration}:',
                          style: AppTextStyles.body2Style.copyWith(
                            color: isDarkMode ? Colors.grey : Colors.black54,
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(width: 2.0),
                        Text(
                          '${lectureData['duration']}',
                          style: AppTextStyles.body2Style.copyWith(
                            color: isDarkMode ? Colors.grey : Colors.black54,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2.0),
                        Text(
                          S.of(context).mins,
                          style: AppTextStyles.body2Style.copyWith(
                            color: isDarkMode ? Colors.grey : Colors.black54,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  if (lectureData['type'] == 'quiz' &&
                      (Constants.userBox
                              .get('user')
                              .stdQuizes?[
                                  '${lectureData['id']},${lectureData['code']}']
                              ?.degree !=
                          null))
                    Row(
                      children: [
                        Text(
                          '${S.of(context).your_result} ',
                          style: AppTextStyles.body2Style.copyWith(
                            color: isDarkMode ? Colors.grey : Colors.black54,
                            fontSize: 14.0,
                          ),
                        ),
                        Text(
                          '${Constants.userBox.get('user').stdQuizes?['${lectureData['id']},${lectureData['code']}'].degree.round()} / ${Constants.userBox.get('user').stdQuizes?['${lectureData['id']},${lectureData['code']}'].fullMark.round()}',
                          style: AppTextStyles.body2Style.copyWith(
                            color: isDarkMode ? Colors.grey : Colors.black54,
                            /*
                            (Constants.userBox
                                        .get('user')
                                        .stdQuizes?[
                                            '${lectureData['id']},${lectureData['code']}']
                                        .degree >=
                                    lectureData['minDegree'])
                                ? Colors.green
                                : Colors.red,
                                */
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            (lectureData['type'] == 'pdf' || lectureData['type'] == 'quiz')
                ? (isPurchased() || cubit.showDelAcc
                    ? const SizedBox()
                    : const Center(child: Icon(Icons.lock_outline_rounded)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isVideoPurchased() || cubit.showDelAcc
                            ? Icons.play_arrow_rounded
                            : Icons.lock_outline_rounded,
                      ),
                      const SizedBox(height: 2.0),
                      ConditionalBuilder(
                        condition: isVideoPurchased() && !cubit.showDelAcc,
                        builder: (context) {
                          UserModel um = Constants.userBox.get('user');
                          // Assuming `chapId` and `lecId` are available in the context
                          final vid = um.purchasedVideos?[chapId]
                              ?.lectures?[lecId]?.videos?[lectureData['id']];

                          return Text(
                            '${vid == null ? 0 : vid.stdWatches! % (lectureData['avaWatches'] ?? 4)}/${(lectureData['avaWatches'] ?? 4)}',
                          );
                        },
                        fallback: (context) => const SizedBox(),
                      ),
                    ],
                  ),
            lectureData['type'] == 'quiz'
                ? (cubit.showDelAcc
                    ? ConditionalBuilder(
                        condition: cubit.isExamTaken(
                            lectureId: lectureData['id'],
                            quizCode: lectureData['code']),
                        builder: (context) {
                          UserModel um = Constants.userBox.get('user');

                          String examIdx =
                              '${lectureData['id']},${lectureData['code']}';

                          return CircularPercentIndicator(
                            radius: 23.0,
                            lineWidth: 5.0,
                            animation: true,
                            animationDuration: 800,
                            circularStrokeCap: CircularStrokeCap.round,
                            percent: (um.stdQuizes![examIdx]!.degree /
                                um.stdQuizes![examIdx]!.fullMark),
                            center: Text(
                              "${((um.stdQuizes![examIdx]!.degree / um.stdQuizes![examIdx]!.fullMark) * 100).round()}%",
                              style: AppTextStyles.body2Style.copyWith(
                                color: (um.stdQuizes![examIdx]!.degree >=
                                        lectureData['minDegree'])
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            progressColor: (um.stdQuizes![examIdx]!.degree >=
                                    lectureData['minDegree'])
                                ? Colors.green
                                : Colors.red,
                            backgroundColor: ((um.stdQuizes![examIdx]!.degree >=
                                        lectureData['minDegree'])
                                    ? Colors.green
                                    : Colors.red)
                                .withValues(alpha: 0.15),
                          );
                        },
                        fallback: (context) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Aligns the items in the center
                            children: [
                              // First Column (Questions)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    size: 22.0,
                                    Icons.help_outline,
                                  ), // Question icon
                                  const SizedBox(
                                      height: 4), // Space between icon and text
                                  Text(
                                    '${lectureData['questionsNum'] ?? lectureData['fullMark']} ${S.of(context).questionss}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              // Divider line
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  width: 1, // Width of the divider
                                  height: 40, // Height of the divider
                                  color: cubit.isDarkMode
                                      ? Colors.white
                                      : Colors.black, // Color of the divider
                                ),
                              ),
                              // Second Column (Time)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    size: 22.0,
                                    Icons.access_time,
                                  ), // Clock icon
                                  const SizedBox(
                                      height: 4), // Space between icon and text
                                  Text(
                                    '${lectureData['duration']} ${S.of(context).mins}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      )
                    : (isPurchased()
                        ? ConditionalBuilder(
                            condition: cubit.isExamTaken(
                                lectureId: lectureData['id'],
                                quizCode: lectureData['code']),
                            builder: (context) {
                              UserModel um = Constants.userBox.get('user');

                              String examIdx =
                                  '${lectureData['id']},${lectureData['code']}';

                              return CircularPercentIndicator(
                                radius: 23.0,
                                lineWidth: 5.0,
                                animation: true,
                                animationDuration: 800,
                                circularStrokeCap: CircularStrokeCap.round,
                                percent: (um.stdQuizes![examIdx]!.degree /
                                    um.stdQuizes![examIdx]!.fullMark),
                                center: Text(
                                  "${((um.stdQuizes![examIdx]!.degree / um.stdQuizes![examIdx]!.fullMark) * 100).round()}%",
                                  style: AppTextStyles.body2Style.copyWith(
                                    color: (um.stdQuizes![examIdx]!.degree >=
                                            lectureData['minDegree'])
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                progressColor:
                                    (um.stdQuizes![examIdx]!.degree >=
                                            lectureData['minDegree'])
                                        ? Colors.green
                                        : Colors.red,
                                backgroundColor:
                                    ((um.stdQuizes![examIdx]!.degree >=
                                                lectureData['minDegree'])
                                            ? Colors.green
                                            : Colors.red)
                                        .withValues(alpha: 0.15),
                              );
                            },
                            fallback: (context) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Aligns the items in the center
                                children: [
                                  // First Column (Questions)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        size: 22.0,
                                        Icons.help_outline,
                                      ), // Question icon
                                      const SizedBox(
                                          height:
                                              4), // Space between icon and text
                                      Text(
                                        '${lectureData['questionsNum'] ?? lectureData['fullMark']} ${S.of(context).questionss}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Divider line
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Container(
                                      width: 1, // Width of the divider
                                      height: 40, // Height of the divider
                                      color: cubit.isDarkMode
                                          ? Colors.white
                                          : Colors
                                              .black, // Color of the divider
                                    ),
                                  ),
                                  // Second Column (Time)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        size: 22.0,
                                        Icons.access_time,
                                      ), // Clock icon
                                      const SizedBox(
                                          height:
                                              4), // Space between icon and text
                                      Text(
                                        '${lectureData['duration']} ${S.of(context).mins}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          )
                        : const SizedBox()))
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
