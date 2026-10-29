// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/models/user_model.dart';
import 'package:salah_online_platform/network/local/shared_pref_helper.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerScreen extends StatefulWidget {
  YoutubePlayerScreen({
    super.key,
    required this.videoUrl,
    required this.cubit,
  });
  String videoUrl;
  PlatformCubit cubit;

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  String? videoUrl;

  YoutubePlayerController? _ytController;

  final webViewKey = GlobalKey();

  String? extractVimeoId(String url) {
    final regex = RegExp(r'vimeo\.com/(?:video/)?(\d+)');
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl.contains('vimeo') &&
        !widget.videoUrl.contains('player.vimeo')) {
      String? videoId = extractVimeoId(widget.videoUrl);
      if (videoId != null) {
        videoUrl = 'https://player.vimeo.com/video/$videoId';
      }

      // بدء التشغيل في وضع ملء الشاشة
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      });
    } else if (widget.videoUrl.contains('youtu')) {
      String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId != null) {
        _ytController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            hideThumbnail: true,
            forceHD: true,
            loop: false,
            hideControls: false,
            disableDragSeek: true,
            enableCaption: false,
          ),
        );
        _ytController!.addListener(() {
          if (_ytController!.value.isFullScreen) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: []);
          } else {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: SystemUiOverlay.values);
          }
        });
      }
    } else {
      videoUrl = widget.videoUrl;

      // بدء التشغيل في وضع ملء الشاشة

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _startMoving();
      if (!Platform.isWindows) {
        await Constants.noScreenshot.screenshotOff();
      }
    });
  }

  void _startMoving() {
    _moveTimer?.cancel();
// Cancel any existing timer
    _moveTimer = Timer.periodic(Duration(seconds: 7), (timer) {
      if (!mounted) return;
      // Check if widget is still mounted
      final screenSize = MediaQuery.of(context).size;
      final maxLeft = screenSize.width - widgetWidth;
      final maxTop = screenSize.height - widgetHeight;
      setState(() {
        _left = _random.nextDouble() * maxLeft;
        _top = _random.nextDouble() * maxTop;
      });
    });
  }

  double _left = 50;
  double _top = 100;
  final Random _random = Random();
  final double widgetWidth = 100;
  final double widgetHeight = 100;
  Timer? _moveTimer;
  // Declare timer as class variable
  @override
  void dispose() async {
    _moveTimer?.cancel();
    _ytController?.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!Platform.isWindows) {
      await Constants.noScreenshot.screenshotOn();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformCubit, PlatformStates>(
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        UserModel sm = Constants.userBox.get('user');

        return Scaffold(
          extendBodyBehindAppBar: true, // يخلي الـ Stack يملأ الشاشة
          backgroundColor: Colors.black, // مهم عشان مفيش وميض أبيض

          body: PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop) {
                return;
              }
              if (!widget.videoUrl.contains('youtu')) {
                if (MediaQuery.of(context).orientation ==
                    Orientation.landscape) {
                  // تأكد إن الاتجاه بيرجع طبيعي لما نخرج
                  SystemChrome.setPreferredOrientations(
                      [DeviceOrientation.portraitUp]);
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                } else {
                  AppStatusDialog.show(
                    context: context,
                    status: AppDialogStatus.warning,
                    title: SharedPrefHelper.getData('isAr') ?? true
                        ? 'هل أنت متأكد من الخروج؟'
                        : 'Are You Sure to Exit?',
                    primaryActionText: SharedPrefHelper.getData('isAr') ?? true
                        ? 'خروج'
                        : 'Exit',
                    onPrimaryAction: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    message: '',
                  );
                }
              } else {
                if (_ytController!.value.isFullScreen) {
                  _ytController!.toggleFullScreenMode();
                } else {
                  AppStatusDialog.show(
                    context: context,
                    status: AppDialogStatus.warning,
                    title: 'خلي بالك',
                    message: SharedPrefHelper.getData('isAr') ?? true
                        ? 'هل أنت متأكد من الخروج؟'
                        : 'Are You Sure to Exit?',
                    primaryActionText: SharedPrefHelper.getData('isAr') ?? true
                        ? 'خروج'
                        : 'Exit',
                    onPrimaryAction: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  );
                }
              }
            },
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (MediaQuery.of(context).orientation ==
                          Orientation.portrait ||
                      !(_ytController?.value.isFullScreen ?? false))
                    DefaultBackBtn(
                      color: Colors.white,
                      onTap: () {
                        if (widget.videoUrl.contains('vimeo')) {
                          if (Platform.isWindows ||
                              MediaQuery.of(context).orientation ==
                                  Orientation.portrait) {
                            AppStatusDialog.show(
                              context: context,
                              status: AppDialogStatus.warning,
                              title: 'خلي بالك',
                              message: SharedPrefHelper.getData('isAr') ?? true
                                  ? 'هل أنت متأكد من الخروج؟'
                                  : 'Are You Sure to Exit?',
                              primaryActionText:
                                  SharedPrefHelper.getData('isAr') ?? true
                                      ? 'خروج'
                                      : 'Exit',
                              onPrimaryAction: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            );
                          } else {
                            // تأكد إن الاتجاه بيرجع طبيعي لما نخرج
                            SystemChrome.setPreferredOrientations(
                                [DeviceOrientation.portraitUp]);
                            SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.edgeToEdge);
                          }
                        } else {
                          AppStatusDialog.show(
                            context: context,
                            status: AppDialogStatus.warning,
                            title: 'خلي بالك',
                            message: SharedPrefHelper.getData('isAr') ?? true
                                ? 'هل أنت متأكد من الخروج؟'
                                : 'Are You Sure to Exit?',
                            primaryActionText:
                                SharedPrefHelper.getData('isAr') ?? true
                                    ? 'خروج'
                                    : 'Exit',
                            onPrimaryAction: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          );
                        }
                      },
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        if (!widget.videoUrl.contains('youtu'))
                          InAppWebView(
                            key: webViewKey,
                            initialSettings: InAppWebViewSettings(
                              iframeAllowFullscreen: true,
                              allowsInlineMediaPlayback: true,
                              mediaPlaybackRequiresUserGesture: false,
                              disableDefaultErrorPage: true,
                              disableLongPressContextMenuOnLinks: true,
                            ),
                            initialUrlRequest: URLRequest(
                              url: WebUri(
                                videoUrl ?? widget.videoUrl,
                              ),
                            ),
                            onEnterFullscreen: (controller) {
                              SystemChrome.setPreferredOrientations([
                                DeviceOrientation.landscapeRight,
                                DeviceOrientation.landscapeLeft,
                              ]);
                              SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.immersiveSticky,
                              );
                            },
                            onExitFullscreen: (controller) {
                              SystemChrome.setPreferredOrientations([
                                DeviceOrientation.portraitUp,
                              ]);
                              SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.edgeToEdge,
                              );
                            },
                          ),
                        if (widget.videoUrl.contains('youtu'))
                          Center(
                            child: YoutubePlayer(
                              controller: _ytController!,
                              showVideoProgressIndicator: true,
                              progressIndicatorColor:
                                  Components.setBgColor(cubit.isDarkMode),
                              progressColors: ProgressBarColors(
                                backgroundColor: Colors.grey,
                                playedColor:
                                    Components.setBgColor(cubit.isDarkMode),
                                handleColor:
                                    Components.setBgColor(cubit.isDarkMode),
                              ),

                              // Add custom buttons to the bottom control bar
                              bottomActions: [
                                const FullScreenButton(), // Recommended if you are modifying bottomActions

                                const PlaybackSpeedButton(),

                                ProgressBar(
                                  isExpanded: true,
                                  colors: ProgressBarColors(
                                    backgroundColor: Colors.grey,
                                    playedColor:
                                        Components.setBgColor(cubit.isDarkMode),
                                    handleColor:
                                        Components.setBgColor(cubit.isDarkMode),
                                  ),
                                ),

                                // Backward 10 Seconds Button
                                IconButton(
                                  icon: const Icon(Icons.replay_10,
                                      color: Colors.white),
                                  onPressed: () {
                                    final currentPosition =
                                        _ytController!.value.position;
                                    final targetPosition = currentPosition -
                                        const Duration(seconds: 10);
                                    _ytController!.seekTo(targetPosition);
                                  },
                                ),

                                // Forward 10 Seconds Button
                                IconButton(
                                  icon: const Icon(Icons.forward_10,
                                      color: Colors.white),
                                  onPressed: () {
                                    final currentPosition =
                                        _ytController!.value.position;
                                    final targetPosition = currentPosition +
                                        const Duration(seconds: 10);
                                    _ytController!.seekTo(targetPosition);
                                  },
                                ),

                                const RemainingDuration(),
                              ],

                              onEnded: (metaData) {
                                _ytController!.pause();
                                if (_ytController!.value.isFullScreen) {
                                  _ytController!.toggleFullScreenMode();
                                }
                                SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.manual,
                                    overlays: SystemUiOverlay.values);

                                Navigator.pop(context);
                              },
                            ),
                          ),
                        Positioned(
                          left: _left,
                          top: _top,
                          child: Opacity(
                            opacity: 0.7,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sm.code!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
