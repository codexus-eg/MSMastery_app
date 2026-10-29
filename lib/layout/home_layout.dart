// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/models/user_model.dart';
import 'package:salah_online_platform/widgets/ai_chat_fab.dart';

class HomeLayout extends StatefulWidget {
  HomeLayout({
    super.key,
    required this.cubit,
    required this.pageController,
    this.isFirstTime,
  });
  PlatformCubit cubit;
  PageController pageController;
  bool? isFirstTime;
  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    // سجّل الـ PageController حتى يمكن التنقّل بين التبويبات برمجيًا (الإشعارات).
    widget.cubit.homePageController = widget.pageController;

    widget.cubit.curIdx = 0;

    UserModel sm = Constants.userBox.get('user');

    if (sm.code == Constants.guest) {
      widget.cubit
        ..getVideos()
        ..getBanners()
        ..getPostsCount()
        ..getSocialMedia();
    } else {
      if (widget.isFirstTime != null) {
        widget.cubit
          ..setLocalData()
          ..getPostsCount()
          ..getVideos()
          ..getBanners()
          // ..getIsShowOnlinePayment()
          //  ..getRequests()
          ..getSocialMedia();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        final bool isQuestionBankTab =
            cubit.curIdx == 2 && cubit.examTypeIndex == 1;
        final bool isBottomSheetOpen = cubit.down2;
        final bool hideAiFab = isBottomSheetOpen;
        final double aiFabBottom = isQuestionBankTab ? 84.0 : 16.0;

        return Scaffold(
          backgroundColor:
              cubit.isDarkMode ? AppColors.darkBgColor : AppColors.lightBgColor,
          body: Stack(
            children: [
              // المحتوى الرئيسي
              // نراقب اتجاه السكرول من الإشعارات بدلاً من ScrollController مشترك،
              // لأن الـ PageView يبني أكثر من صفحة في نفس الوقت أثناء التنقل.
              NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis != Axis.vertical) {
                    return false;
                  }
                  if (notification.direction == ScrollDirection.reverse) {
                    if (!_isCollapsed) setState(() => _isCollapsed = true);
                  } else if (notification.direction ==
                      ScrollDirection.forward) {
                    if (_isCollapsed) setState(() => _isCollapsed = false);
                  }
                  return false;
                },
                child: PageView(
                  physics:
                      cubit.down2 ? const NeverScrollableScrollPhysics() : null,
                  controller: widget.pageController,
                  children: Constants.screensList,
                  onPageChanged: (value) {
                    cubit.changeBottomIndex(value);
                  },
                ),
              ),
              /*
              // الزرار الشمال (Home)
              PositionedDirectional(
                end: 20,
                bottom: 40,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 400),
                  child: _isCollapsed
                      ? FloatingActionButton(
                          heroTag: UniqueKey(),
                          key: ValueKey("homeIcon"),
                          backgroundColor: cubit.isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.lightBborder,
                          onPressed: () => setState(() => _isCollapsed = false),
                          shape: CircleBorder(
                            side: BorderSide(
                              color: Components.setBgColor(cubit.isDarkMode),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.home,
                            color:
                                cubit.isDarkMode ? Colors.white : Colors.black,
                            size: 30,
                          ),
                        )
                      : SizedBox(),
                ),
              ),
          */
              /*
              // الزرار اليمين (WhatsApp)
              PositionedDirectional(
                end: 5,
                bottom: 2,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 400),
                  opacity: _isCollapsed ? 1 : 0,
                  child: _isCollapsed
                      ? Column(
                          children: [
                            Text(
                              S.of(context).support,
                              style: TextStyle(
                                color: Components.setBgColor(cubit.isDarkMode),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            FloatingActionButton(
                              heroTag: UniqueKey(),
                              key: ValueKey("whatsAppIcon"),
                              backgroundColor: Colors.transparent,
                              onPressed: () async {
                                UserModel um = Constants.userBox.get('user');

                                String phoneNumber = '';
                                if (um.groupId!.isEmpty) {
                                  phoneNumber =
                                      await cubit.getPhoneNum('online');
                                } else {
                                  phoneNumber =
                                      await cubit.getPhoneNum(um.grade!);
                                }

                                String whatsappUrl =
                                    "https://wa.me/+2$phoneNumber";

                                if (await canLaunchUrlString(whatsappUrl)) {
                                  await launchUrlString(whatsappUrl);
                                } else {
                                  // إذا لم يتمكن من فتح الرابط
                                  debugPrint("Could not open WhatsApp.");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Could not open WhatsApp."),
                                    ),
                                  );
                                }
                              },
                              child: CircleAvatar(
                                backgroundColor:
                                    Components.setBgColor(cubit.isDarkMode),
                                radius: 27,
                                child: FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                ),
              ),
             */
              // زرار مساعد الرياضيات الذكي
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
                end: 16,
                bottom: aiFabBottom,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  opacity: hideAiFab ? 0.0 : 1.0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutBack,
                    scale: hideAiFab ? 0.0 : 1.0,
                    child: IgnorePointer(
                      ignoring: hideAiFab,
                      child: AiChatFab(
                        isCollapsed: _isCollapsed,
                      ),
                    ),
                  ),
                ),
              ),
              /*
              // البوتوم نافيجيشن
              PositionedDirectional(
                bottom: 0,
                end: 0,
                start: 0,
                child: AnimatedSlide(
                  duration: Duration(milliseconds: 400),
                  offset: _isCollapsed ? Offset(0, 1.5) : Offset.zero,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    height: 70,
                    decoration: BoxDecoration(
                      color: cubit.isDarkMode
                          ? AppColors.darkBorder
                          : AppColors.lightBborder,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavItem(
                          icon: Icons.quiz,
                          label: S.of(context).quizs,
                          value: 0,
                          cubit: cubit,
                        ),
                        _buildNavItem(
                          icon: Icons.play_circle_fill,
                          label: S.of(context).lectures,
                          value: 1,
                          cubit: cubit,
                        ),
          
                        // Home button in center
          
                        Transform.translate(
                          offset: Offset(0, -30),
                          child: FloatingActionButton(
                            heroTag: UniqueKey(),
                            key: ValueKey("homeIcon"),
                            backgroundColor: cubit.isDarkMode
                                ? AppColors.darkBorder
                                : AppColors.lightBborder,
                            onPressed: () {
                              debugPrint('Ahmed');
          
                              if (!cubit.down2) {
                                widget.pageController.animateToPage(
                                  2,
                                  duration: const Duration(microseconds: 1),
                                  curve: Curves.linear,
                                );
                                cubit.changeBottomIndex(2);
                              }
                              setState(() => _isCollapsed = false);
                            },
                            shape: CircleBorder(
                              side: BorderSide(
                                color: Components.setBgColor(cubit.isDarkMode),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.home,
                              color: cubit.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              size: 30,
                            ),
                          ),
                        ),
          
                        _buildNavItem(
                          icon: Icons.campaign,
                          label: S.of(context).posts,
                          value: 3,
                          cubit: cubit,
                        ),
                        _buildNavItem(
                          icon: Icons.settings,
                          label: S.of(context).profile,
                          value: 4,
                          cubit: cubit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // فوق Positioned بتاع البوتوم نافيجيشن
           */
            ],
          ),
          bottomNavigationBar: NavigationBar(
            indicatorColor:
                Components.setBgColor(cubit.isDarkMode).withValues(alpha: 0.2),
            selectedIndex: cubit.curIdx,
            backgroundColor: cubit.isDarkMode
                ? AppColors.darkBgColor
                : AppColors.lightBgColor,
            elevation: 0.0,
            onDestinationSelected: (value) {
              widget.pageController.animateToPage(
                value,
                duration: const Duration(microseconds: 1),
                curve: Curves.linear,
              );
              cubit.changeBottomIndex(value);
            },
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(
                  Icons.home,
                  color: Components.setBgColor(cubit.isDarkMode),
                ),
                label: S.of(context).home,
              ),
              /*
              NavigationDestination(
                icon: Icon(Icons.book_outlined),
                selectedIcon: Icon(Icons.book),
                label: S.of(context).external_books,
              ),
              */
              NavigationDestination(
                icon: Icon(Icons.video_library_outlined),
                selectedIcon: Icon(
                  Icons.video_library_sharp,
                  color: Components.setBgColor(cubit.isDarkMode),
                ),
                label: S.of(context).lectures,
              ),
              NavigationDestination(
                icon: Icon(Icons.quiz_outlined),
                selectedIcon: Icon(
                  Icons.quiz,
                  color: Components.setBgColor(cubit.isDarkMode),
                ),
                label: S.of(context).quiz,
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(
                  Icons.settings,
                  color: Components.setBgColor(cubit.isDarkMode),
                ),
                label: S.of(context).profile,
              ),
            ],
          ),
        );
      },
    );
  }
/*
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int value,
    required PlatformCubit cubit,
  }) {
    return InkWell(
      onTap: () {
        if (!cubit.down2) {
          widget.pageController.animateToPage(
            value,
            duration: const Duration(microseconds: 1),
            curve: Curves.linear,
          );
          cubit.changeBottomIndex(value);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: cubit.curIdx == value
                ? Components.setBgColor(cubit.isDarkMode)
                : cubit.isDarkMode
                    ? Colors.white
                    : Colors.black,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: cubit.curIdx == value
                  ? Components.setBgColor(cubit.isDarkMode)
                  : cubit.isDarkMode
                      ? Colors.white
                      : Colors.black,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
*/
}
/*
  @override
  void initState() {
    super.initState();
    if (widget.isQuiz) {
      widget.cubit.curIdx = 2;
    } else {
      widget.cubit.curIdx = 0;
      UserModel sm = Constants.userBox.get('user');

      if (sm.code == Constants.guest) {
        widget.cubit
          ..getVideos()
          ..getBanners()
          ..getPosts()
          ..getSocialMedia();
      } else {
        if (widget.isFirstTime != null) {
          widget.cubit
            ..setLocalData()
            ..getPosts()
            ..getVideos()
            ..getBanners()
            ..getRequests()
            ..getSocialMedia();
        }
      }
    }
  }

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
      },
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        return Scaffold(
          key: cubit.scaffoldKey,
          backgroundColor:
              cubit.isDarkMode ? AppColors.darkBgColor : AppColors.lightBgColor,
          body: PersistentTabView(
            tabs: _tabs(),
            navBarBuilder: (navBarConfig) => Style13BottomNavBar(
              navBarConfig: navBarConfig,
            ),
          ),
          /*
          PageView(
            physics: cubit.down2 ? const NeverScrollableScrollPhysics() : null,
            controller: widget.pageController,
            children: Constants.screensList,
            onPageChanged: (value) {
              cubit.changeBottomIndex(value);
            },
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border(
                top: BorderSide(
                  color:
                      Components.setBgColor(cubit.isDarkMode).withValues(alpha:0.5),
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(12.0),
                topEnd: Radius.circular(12.0),
              ),
              child: GNav(
                backgroundColor: cubit.isDarkMode
                    ? AppColors.darkBorder.withValues(alpha:0.5)
                    : AppColors.lightBborder.withValues(alpha:0.5),
                color: cubit.isDarkMode ? Colors.white : Colors.black,
                haptic: false,
                tabs: [
                  GButton(
                    icon:
                        cubit.curIdx == 0 ? IconlyBold.home : IconlyLight.home,
                    text: S.of(context).home,
                    iconSize: 28.0,
                  ),
                  GButton(
                    icon: cubit.curIdx == 1
                        ? Icons.video_collection_rounded
                        : Icons.video_collection_outlined,
                    text: S.of(context).lectures,
                    iconSize: 28.0,
                  ),
                  GButton(
                    icon: cubit.curIdx == 2
                        ? Icons.article_rounded
                        : Icons.article_outlined,
                    text: S.of(context).posts,
                    iconSize: 28.0,
                  ),
                  GButton(
                    icon: cubit.curIdx == 3
                        ? Icons.quiz_rounded
                        : Icons.quiz_outlined,
                    text: S.of(context).quizs,
                    iconSize: 28.0,
                  ),
                  GButton(
                    icon: cubit.curIdx == 4
                        ? IconlyBold.setting
                        : IconlyLight.setting,
                    text: S.of(context).profile,
                    iconSize: 28.0,
                  ),
                ],
                onTabChange: (value) {
                  if (!cubit.down2) {
                    widget.pageController.animateToPage(
                      value,
                      duration: const Duration(microseconds: 1),
                      curve: Curves.linear,
                    );
                    cubit.changeBottomIndex(value);
                  }
                },
                selectedIndex: cubit.curIdx,
                gap: 0,
                activeColor: Components.setBgColor(cubit.isDarkMode),
                tabBackgroundColor:
                    Components.setBgColor(cubit.isDarkMode).withValues(alpha:0.2),
                padding: const EdgeInsets.all(8.0),
                tabMargin: const EdgeInsetsDirectional.only(
                  top: 12.0,
                  start: 8.0,
                  end: 8.0,
                  bottom: 22.0,
                ),
              ),
            ),
          ),
       */
        );
      },
    );
  }

  List<PersistentTabConfig> _tabs() => [
        PersistentTabConfig(
          screen: const HomeScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.home),
            title: "Home",
          ),
        ),
        PersistentTabConfig(
          screen: const PostsScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.message),
            title: "Messages",
          ),
        ),
        PersistentTabConfig(
          screen: ProfileScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.settings),
            title: "Settings",
          ),
        ),
      ];
}
*/
