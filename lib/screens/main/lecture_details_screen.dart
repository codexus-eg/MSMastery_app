// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/payment_options.dart';
import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/screens/main/lectures_details_details_screen.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

import '../../constants/styles.dart';

class VideoDetails extends StatefulWidget {
  VideoDetails({
    super.key,
    required this.chapId,
    required this.thumbnail,
    required this.title,
    required this.subTitle,
    required this.cubit,
    this.price,
    this.prevPrice,
  });
  String chapId;
  String thumbnail;
  String title;
  String? subTitle;
  int? price;
  int? prevPrice;

  PlatformCubit cubit;

  @override
  State<VideoDetails> createState() => _VideoDetailsState();
}

class _VideoDetailsState extends State<VideoDetails>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  bool _showTitle = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    widget.cubit.getVideoDetails(chapId: widget.chapId);
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformBuyLecturesLoadingState ||
            state is PlatformCheckCodeLoadingState) {
          isLoading = true;

          debugPrint(isLoading.toString());
        }

        if (state is PlatformBuyChaptersSuccessState) {
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
      },
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);

        return Scaffold(
          bottomNavigationBar: _buildPurchaseBar(
            context: context,
            cubit: cubit,
            price: widget.price,
            chapId: widget.chapId,
            prevPrice: widget.prevPrice,
            itemName: widget.title,
            isLoading: isLoading,
          ),
          body: RefreshIndicator(
            onRefresh: () {
              debugPrint(widget.prevPrice.toString());

              return cubit.getVideoDetails(chapId: widget.chapId);
            },
            color: Components.setBgColor(cubit.isDarkMode),
            child: CustomScrollView(
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
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
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
                                  color: Colors.black.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.title2Style.copyWith(
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
                                          style:
                                              AppTextStyles.body2Style.copyWith(
                                            color: Colors.white,
                                          ),
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
                if (!cubit.showDelAcc &&
                    cubit.isChapPending(chapId: widget.chapId))
                  SliverToBoxAdapter(
                    child: Widgets.buildPendingBanner(cubit.isDarkMode),
                  ),
                // Enhanced lectures list section
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header with enhanced styling
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: cubit.isDarkMode
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: cubit.isDarkMode
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                color: Components.setBgColor(cubit.isDarkMode),
                                size: 24.0,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                S.of(context).content,
                                style: AppTextStyles.title2Style.copyWith(
                                  color: cubit.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${cubit.videoDetailsList.length} ${S.of(context).lecturess}',
                                style: AppTextStyles.body2Style.copyWith(
                                  color: cubit.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),

                // Enhanced lectures list with staggered animation
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  sliver: cubit.videoDetailsList.isEmpty
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
                                  S.of(context).no_lectures_yet,
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
                                duration:
                                    Duration(milliseconds: 800 + (index * 150)),
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
                                        child: BuildLecturesWidget(
                                          prevPrice: cubit
                                              .videoDetailsList[index]
                                              .prevPrice,
                                          imgUrl: cubit.videoDetailsList[index]
                                              .thumbnail,
                                          subTitle: cubit
                                              .videoDetailsList[index].subTitle,
                                          cubit: cubit,
                                          chapTitle: widget.title,
                                          isDarkMode: cubit.isDarkMode,
                                          title: cubit
                                              .videoDetailsList[index].title,
                                          dep:
                                              cubit.videoDetailsList[index].dep,
                                          lecId: cubit
                                              .videoDetailsList[index].lecId,
                                          chapId: widget.chapId,
                                          price: cubit
                                              .videoDetailsList[index].price,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: cubit.videoDetailsList.length,
                          ),
                        ),
                ),

                // Bottom padding for better scrolling experience
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32.0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Bottom purchase bar.
  Widget? _buildPurchaseBar({
    required BuildContext context,
    required PlatformCubit cubit,
    required price,
    required chapId,
    // required lecId,
//  required vidds,
    prevPrice,
    required itemName,
    required isLoading,
  }) {
    if (price == null) return null;
    if (!(!(cubit.isGuest() && price != 1111) &&
        !cubit.showDelAcc &&
        !cubit.checkChapterPurchased(
          chapId: chapId,
        ))) {
      return null;
    }

    final primaryColor = Components.setBgColor(cubit.isDarkMode);
    final hasDiscount = prevPrice != null && prevPrice! > price!;
    bool isChapPending = cubit.isChapPending(
      chapId: chapId,
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
                      const SizedBox(width: 4),
                      Text(
                        S.of(context).egp,
                        style: AppTextStyles.body2Style.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
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
                          if (price == 0 || price == 1111) {
                            if (!isLoading) {
                              cubit.buyChapter(
                                chapId: chapId,
                                price: 0,
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
                                  chapId: chapId,
                                  codeClicked: ({required code}) {
                                    cubit.checkChapterCode(
                                      chapId: chapId,
                                      code: code,
                                      context: context,
                                    );
                                  },
                                  walletClicked: () {
                                    cubit.buyChapter(
                                      chapId: chapId,
                                      price: price,
                                      pop: true,
                                    );
                                  },
                                  onlineClicked: ({int? amount}) {
                                    cubit.buyChapter(
                                      chapId: chapId,
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
                              isChapPending
                                  ? Icons.refresh_rounded
                                  : Icons.shopping_cart_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isChapPending
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
}

class BuildLecturesWidget extends StatelessWidget {
  BuildLecturesWidget({
    super.key,
    required this.imgUrl,
    required this.isDarkMode,
    required this.title,
    required this.chapId,
    required this.lecId,
    required this.price,
    this.prevPrice,
    required this.dep,
    required this.cubit,
    this.subTitle,
    required this.chapTitle,
  });
  String imgUrl;
  String title;
  String? subTitle;
  String chapTitle;
  bool isDarkMode;
  String chapId;
  int price;
  int? prevPrice;
  bool dep;
  String lecId;
  PlatformCubit cubit;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LectureDetailsDetailsScreen(
              price: price,
              prevPrice: prevPrice,
              thumbnail: imgUrl,
              title: title,
              chapTitle: chapTitle,
              dep: dep,
              subTitle: subTitle,
              chapId: chapId,
              lecId: lecId,
            ),
            settings: const RouteSettings(name: 'lectureDetails'),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22.0),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: DefaultImage(
                imgUrl: imgUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body1Style.copyWith(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subTitle != null && subTitle!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                subTitle!,
                textAlign: TextAlign.start,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body2Style,
              ),
            ),
        ],
      ),
    );
  }
}
