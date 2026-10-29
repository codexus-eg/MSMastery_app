// ignore_for_file: must_be_immutable

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/constants/styles.dart';
import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/models/purchases_widget_data.dart';
import 'package:salah_online_platform/models/video_details_model.dart';
import 'package:salah_online_platform/network/local/shared_pref_helper.dart';
import 'package:salah_online_platform/screens/auth_screens/login_screens/login_page.dart';
import 'package:salah_online_platform/screens/main/edit_profile_screen.dart';
import 'package:salah_online_platform/screens/main/error_screen.dart';
import 'package:salah_online_platform/screens/main/lectures_details_details_screen.dart';
import 'package:salah_online_platform/screens/main/attendance_screen.dart';
import 'package:salah_online_platform/screens/main/purchased_lectures_screen.dart';
import 'package:salah_online_platform/screens/main/posts/posts_screen.dart';
import 'package:salah_online_platform/screens/main/requests.dart';
import 'package:salah_online_platform/screens/main/wallet/wallet_screen.dart';

import '../../models/user_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformDeleteAccountSuccessState) {
          Components.pushReplacement(
            context: context,
            widget: LoginPage(),
          );
        }
        if (state is PlatformAccountBlockedState) {
          Components.pushReplacement(
            context: context,
            widget: ErrorScreen(
              cubit: PlatformCubit.get(context),
              status: Constants.accountBlocked,
            ),
          );
        }
        if (state is PlatformAccountPendingState) {
          Components.pushReplacement(
            context: context,
            widget: ErrorScreen(
              cubit: PlatformCubit.get(context),
              status: Constants.accountPending,
            ),
          );
        }
      },
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        UserModel? um = Constants.userBox.get('user');

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await cubit.getVideos();
              await cubit.getBanners();

              cubit.getPostsCount();
              if (!cubit.isGuest()) {
                await cubit.setUserDataLocally();
              }
            },
            color: Components.setBgColor(cubit.isDarkMode),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context, um, cubit.isDarkMode, cubit.postsCount),
                  const SizedBox(height: 12.0),

                  // Promotional banner carousel
                  BannerCarousel(banners: cubit.bannersList),

                  // Recent Lectures Section
                  _buildSectionHeader(
                    context,
                    S.of(context).recent_lectures,
                    cubit.isDarkMode,
                    icon: Icons.video_library_rounded,
                    //   count: cubit.recentVideosList.length,
                  ),

                  const SizedBox(height: 14.0),
                  _buildRecentLectures(context, cubit),

                  const SizedBox(height: 24.0),

                  // Quick Actions Grid
                  _buildSectionHeader(
                    context,
                    S.of(context).quick_actions,
                    cubit.isDarkMode,
                    icon: Icons.flash_on_rounded,
                  ),
                  const SizedBox(height: 14.0),

                  _buildQuickActionsGrid(context, cubit, um),
                  const SizedBox(height: 8.0),

                  // Continue Watching Section
                  ContinueWatchingSection(
                    isDarkMode: cubit.isDarkMode,
                    lectures: cubit.purchasedVideosList,
                  ),

                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(
      BuildContext context, UserModel? um, bool isDarkMode, int postsCount) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
      child: Row(
        children: [
          // std picture
          GestureDetector(
            onTap: () {
              Components.push(context: context, widget: EditProfileScreen());
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    clipBehavior: Clip.antiAlias,
                    child: DefaultImage(
                      imgUrl: um?.img ?? '',
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Components.setBgColor(isDarkMode),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isDarkMode ? AppColors.darkBgColor : Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${S.of(context).hey} 👋',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 2),
                Text(
                  '${um?.ar_fname} ${um?.ar_sname} ${um?.ar_thname}',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo',
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          /*
          // Edit button
          GestureDetector(
            onTap: () {
              Components.push(context: context, widget: EditProfileScreen());
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.edit, size: 22),
            ),
          ),
       */
          // posts button

          Stack(
            alignment: AlignmentDirectional.topEnd,
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  Components.push(context: context, widget: PostsScreen());
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.notifications, size: 22),
                ),
              ),
              if ((SharedPrefHelper.getData('postsCount') ?? 0) != postsCount)
                PositionedDirectional(
                  start: -4,
                  top: -4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool isDarkMode, {
    // int? count,
    IconData? icon,
  }) {
    final primaryColor = Components.setBgColor(isDarkMode);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          if (icon != null) ...[
            Icon(icon, color: primaryColor, size: 20),
            const SizedBox(width: 6),
          ],
          Text(
            title,
            style: AppTextStyles.title2Style.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          /*
          if (count != null && count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        */
        ],
      ),
    );
  }

  Widget _buildRecentLectures(BuildContext context, PlatformCubit cubit) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 3.5,
        child: cubit.recentVideosList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 48,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      S.of(context).no_videos_yet,
                      style: AppTextStyles.body2Style.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemBuilder: (context, index) => LectureCard(
                  cubit: cubit,
                  vdm: cubit.recentVideosList[index],
                ),
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 12.0),
                itemCount: cubit.recentVideosList.length >= 3
                    ? 3
                    : cubit.recentVideosList.length,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
              ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(
      BuildContext context, PlatformCubit cubit, UserModel? um) {
    final actions = <BuildIconCard>[
      if (um != null && um.groupName!.isNotEmpty && um.groupName != 'Online')
        BuildIconCard(
          isDarkMode: cubit.isDarkMode,
          icon: Icons.qr_code_scanner_rounded,
          name: S.of(context).attendance,
          isQr: true,
          color: const Color(0xFF7C5CFF),
          widget: MyCodeScreen(),
        ),
      if (!cubit.showDelAcc) ...[
        BuildIconCard(
          isDarkMode: cubit.isDarkMode,
          icon: Icons.account_balance_wallet_rounded,
          name: S.of(context).wallet_code,
          color: const Color(0xFFFF8A3D),
          widget: WalletScreen(),
        ),
        BuildIconCard(
          isDarkMode: cubit.isDarkMode,
          icon: Icons.video_collection_rounded,
          name: S.of(context).purchased_videos,
          color: const Color(0xFF22C7A0),
          widget: MyLecturesScreen(cubit: cubit),
        ),
      ],
      BuildIconCard(
        isDarkMode: cubit.isDarkMode,
        icon: Icons.question_answer_rounded,
        name: S.of(context).ask_us,
        color: const Color(0xFFFF5C7A),
        widget: RequestsScreen(),
      ),
    ];

    const rowHeight = 110.0;
    const gap = 12.0;
    final rows = <Widget>[];
    for (int i = 0; i < actions.length; i += 2) {
      final isLastSingle = i + 1 >= actions.length;
      rows.add(
        SizedBox(
          height: rowHeight,
          child: isLastSingle
              ? actions[i]
              : Row(
                  children: [
                    Expanded(child: actions[i]),
                    const SizedBox(width: gap),
                    Expanded(child: actions[i + 1]),
                  ],
                ),
        ),
      );
      if (i + 2 < actions.length) rows.add(const SizedBox(height: gap));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}

// ── Promotional Banner Carousel (Firebase: banners -> imgUrl) ──────────────
class BannerCarousel extends StatefulWidget {
  final List<String> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = PlatformCubit.get(context).isDarkMode;
    final accent = Components.setBgColor(isDarkMode);

    // Nothing to show yet (still loading or no banners configured).
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final double height = MediaQuery.of(context).size.width * 0.45;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.banners.length,
          options: CarouselOptions(
            height: height,
            viewportFraction: 0.88,
            enlargeCenterPage: true,
            enlargeFactor: 0.18,
            autoPlay: widget.banners.length > 1,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 700),
            autoPlayCurve: Curves.easeInOutCubic,
            onPageChanged: (index, _) => setState(() => _current = index),
          ),
          itemBuilder: (context, index, realIndex) {
            return _BannerItem(
              imgUrl: widget.banners[index],
              isDarkMode: isDarkMode,
            );
          },
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (i) {
                final isActive = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isActive ? accent : accent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),
        ],
        SizedBox(height: 12.0),
      ],
    );
  }
}

class _BannerItem extends StatelessWidget {
  final String imgUrl;
  final bool isDarkMode;

  const _BannerItem({required this.imgUrl, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DefaultImage(
              imgUrl: imgUrl,
              fit: BoxFit.cover,
            ),
            // Subtle bottom gradient for depth / text legibility.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuildIconCard extends StatelessWidget {
  BuildIconCard({
    super.key,
    required this.isDarkMode,
    this.widget,
    required this.icon,
    required this.name,
    this.isQr,
    this.onPressed,
    this.color,
  });
  UserModel? um = Constants.userBox.get('user');

  bool isDarkMode;
  Widget? widget;
  IconData icon;
  String name;
  bool? isQr;
  Color? color;
  void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Components.setBgColor(isDarkMode);
    final cardColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.55);
    final labelColor = isDarkMode ? Colors.white : const Color(0xff1a1a1a);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (um?.code == Constants.guest) {
              Constants.showLoginDialog(
                isDarkMode: isDarkMode,
                context: context,
              );
            } else {
              if (widget != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => widget!,
                  ),
                );
              } else {
                onPressed;
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContinueWatchingSection extends StatelessWidget {
  final bool isDarkMode;
  final List<PurchasesWidgetData> lectures;

  const ContinueWatchingSection({
    super.key,
    required this.isDarkMode,
    required this.lectures,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final primaryColor = Components.setBgColor(isDarkMode);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.play_circle_fill_rounded,
                  color: primaryColor, size: 20),
              const SizedBox(width: 6),
              Text(
                S.of(context).continue_watching,
                style: AppTextStyles.title2Style.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          lectures.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          Icons.play_circle_outline_rounded,
                          size: 32,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        S.of(context).no_videos_yet,
                        style: AppTextStyles.body2Style.copyWith(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.black.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lectures.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => BuildCard(
                    width: screenWidth - 32,
                    lecture: lectures[index],
                    isDarkMode: isDarkMode,
                  ),
                ),
        ],
      ),
    );
  }
}

class BuildCard extends StatelessWidget {
  const BuildCard({
    super.key,
    required this.width,
    required this.lecture,
    required this.isDarkMode,
  });

  final double width;
  final PurchasesWidgetData lecture;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Components.setBgColor(isDarkMode);
    final cardColor = isDarkMode ? AppColors.darkBorder : Colors.white;
    final titleColor = isDarkMode ? Colors.white : const Color(0xff1a1a1a);
    final progress = lecture.avaWatches == 0
        ? 0.0
        : (lecture.stdWatches / lecture.avaWatches).clamp(0.0, 1.0);

    void openLecture() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LectureDetailsDetailsScreen(
            key: ValueKey(lecture.lectureId),
            price: lecture.price,
            dep: lecture.lectureDep,
            thumbnail: lecture.lectureImg,
            title: lecture.lectureTitle,
            lecId: lecture.lectureId,
            subTitle: lecture.lectureSubTitle,
            chapId: lecture.chapterId,
          ),
          settings: const RouteSettings(name: 'lectureDetails'),
        ),
      );
    }

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: openLecture,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            /*
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          */
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 110,
                    height: 72,
                    child: DefaultImage(
                      imgUrl: lecture.lectureImg,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lecture.lectureTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: primaryColor.withValues(alpha: 0.18),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.65)
                              : Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    /*
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
               */
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LectureCard extends StatelessWidget {
  LectureCard({
    super.key,
    required this.vdm,
    required this.cubit,
  });

  VideoDetailsModel vdm;
  PlatformCubit cubit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LectureDetailsDetailsScreen(
              price: vdm.price,
              dep: vdm.dep,
              thumbnail: vdm.thumbnail,
              subTitle: vdm.subTitle,
              title: vdm.title,
              lecId: vdm.lecId,
              chapId: vdm.chapId,
            ),
            settings: const RouteSettings(name: 'lectureDetails'),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.4,
        decoration: BoxDecoration(
          color: cubit.isDarkMode ? AppColors.darkBorder : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20.0)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: DefaultImage(
                      imgUrl: vdm.thumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Components.setBgColor(cubit.isDarkMode),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                vdm.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body2Style.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
