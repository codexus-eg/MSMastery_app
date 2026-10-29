import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/screens/update/cubit/update_cubit.dart';
import 'package:salah_online_platform/screens/update/cubit/update_states.dart';
import 'package:terminate_restart/terminate_restart.dart';

class UpdateScreen extends StatefulWidget {
  final VoidCallback onSkip;
  const UpdateScreen({super.key, required this.onSkip});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _glowController;

  bool _autoStarted = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platform = PlatformCubit.get(context);
    final primaryColor = Components.setBgColor(platform.isDarkMode);
    final fontFamily = platform.isAr ? 'Cairo' : 'Roboto';
    final isAr = platform.isAr;
    final size = MediaQuery.of(context).size;

    return BlocConsumer<UpdateCubit, UpdateState>(
      listener: (context, state) {
        if (state is UpdateAvailable && !_autoStarted) {
          _autoStarted = true;
          UpdateCubit.get(context).downloadUpdate();
        }
        if (state is UpdateReadyToRestart) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              TerminateRestart.instance
                  .restartApp(options: TerminateRestartOptions());
            }
          });
        }
      },
      builder: (context, state) {
        final progress = state is UpdateDownloading ? state.progress : 0.0;
        final percent = (progress * 100).round();
        final isDone = state is UpdateReadyToRestart;
        final isFailed = state is UpdateFailed;

        return Scaffold(
          backgroundColor: const Color(0xfffafbfd),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -size.width * 0.25,
                  right: -size.width * 0.25,
                  child: _blob(
                    size.width * 0.7,
                    primaryColor.withValues(alpha: 0.08),
                  ),
                ),
                Positioned(
                  bottom: -size.width * 0.3,
                  left: -size.width * 0.2,
                  child: _blob(
                    size.width * 0.65,
                    primaryColor.withValues(alpha: 0.06),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      _DownloadIllustration(
                        primaryColor: primaryColor,
                        floatAnim: _floatController,
                        glowAnim: _glowController,
                        isDone: isDone,
                        isFailed: isFailed,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _titleFor(state, isAr),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff1a1a1a),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _subtitleFor(state, isAr),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _ProgressCard(
                        progress: progress,
                        percent: percent,
                        primaryColor: primaryColor,
                        fontFamily: fontFamily,
                        isAr: isAr,
                        isDone: isDone,
                        isFailed: isFailed,
                      ),
                      const SizedBox(height: 20),
                      _Actions(
                        state: state,
                        primaryColor: primaryColor,
                        fontFamily: fontFamily,
                        isAr: isAr,
                        onRetry: () =>
                            UpdateCubit.get(context).downloadUpdate(),
                        onRestart: () {
                          TerminateRestart.instance
                              .restartApp(options: TerminateRestartOptions());
                        },
                        onSkip: widget.onSkip,
                      ),
                      const Spacer(flex: 3),
                      Text(
                        isAr
                            ? 'لا تغلق التطبيق أثناء التحديث'
                            : 'Please don\'t close the app while updating',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  String _titleFor(UpdateState s, bool isAr) {
    if (s is UpdateReadyToRestart) {
      return isAr ? 'تم التحديث بنجاح' : 'Update complete';
    }
    if (s is UpdateFailed) {
      return isAr ? 'فشل التحديث' : 'Update failed';
    }
    if (s is UpdateDownloading) {
      return isAr ? 'جاري تحميل التحديث' : 'Downloading update';
    }
    return isAr ? 'تحديث جديد متاح' : 'New update available';
  }

  String _subtitleFor(UpdateState s, bool isAr) {
    if (s is UpdateReadyToRestart) {
      return isAr
          ? 'هيتم إعادة تشغيل التطبيق لاستكمال التحديث'
          : 'The app will restart to apply the update';
    }
    if (s is UpdateFailed) {
      return s.error;
    }
    return isAr
        ? 'احنا بنحمل آخر تحسينات وإصلاحات للتطبيق، خليك معانا لحظات.'
        : 'We are downloading the latest improvements. This will take a moment.';
  }
}

class _DownloadIllustration extends StatelessWidget {
  final Color primaryColor;
  final AnimationController floatAnim;
  final AnimationController glowAnim;
  final bool isDone;
  final bool isFailed;

  const _DownloadIllustration({
    required this.primaryColor,
    required this.floatAnim,
    required this.glowAnim,
    required this.isDone,
    required this.isFailed,
  });

  @override
  Widget build(BuildContext context) {
    final color = isFailed
        ? const Color(0xffef4444)
        : isDone
            ? const Color(0xff22c55e)
            : primaryColor;
    final icon = isFailed
        ? Icons.error_outline_rounded
        : isDone
            ? Icons.check_rounded
            : Icons.cloud_download_rounded;

    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: glowAnim,
            builder: (_, __) {
              final t = Curves.easeInOut.transform(glowAnim.value);
              return Container(
                width: 180 + (t * 18),
                height: 180 + (t * 18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.06 + (0.04 * (1 - t))),
                ),
              );
            },
          ),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
            ),
          ),
          AnimatedBuilder(
            animation: floatAnim,
            builder: (_, __) {
              final t = Curves.easeInOut.transform(floatAnim.value);
              final dy = (isDone || isFailed) ? 0.0 : (t - 0.5) * 8;
              return Transform.translate(
                offset: Offset(0, dy),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 44),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final double progress;
  final int percent;
  final Color primaryColor;
  final String fontFamily;
  final bool isAr;
  final bool isDone;
  final bool isFailed;

  const _ProgressCard({
    required this.progress,
    required this.percent,
    required this.primaryColor,
    required this.fontFamily,
    required this.isAr,
    required this.isDone,
    required this.isFailed,
  });

  @override
  Widget build(BuildContext context) {
    final color = isFailed
        ? const Color(0xffef4444)
        : isDone
            ? const Color(0xff22c55e)
            : primaryColor;
    final shownPercent = isDone ? 100 : percent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(
                  isDone
                      ? Icons.check_rounded
                      : isFailed
                          ? Icons.error_outline_rounded
                          : Icons.downloading_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isFailed
                      ? (isAr ? 'حدث خطأ' : 'Error')
                      : isDone
                          ? (isAr ? 'اكتمل التحميل' : 'Download complete')
                          : (isAr ? 'جاري التحميل...' : 'Downloading...'),
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff1a1a1a),
                  ),
                ),
              ),
              Text(
                '$shownPercent%',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  color: color.withValues(alpha: 0.1),
                ),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  widthFactor: isDone ? 1.0 : progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.85),
                          color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final UpdateState state;
  final Color primaryColor;
  final String fontFamily;
  final bool isAr;
  final VoidCallback onRetry;
  final VoidCallback onRestart;
  final VoidCallback onSkip;

  const _Actions({
    required this.state,
    required this.primaryColor,
    required this.fontFamily,
    required this.isAr,
    required this.onRetry,
    required this.onRestart,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    if (state is UpdateReadyToRestart) {
      return _Button(
        label: isAr ? 'إعادة التشغيل الآن' : 'Restart now',
        icon: Icons.restart_alt_rounded,
        color: const Color(0xff22c55e),
        fontFamily: fontFamily,
        onPressed: onRestart,
      );
    }
    if (state is UpdateFailed) {
      return Column(
        children: [
          _Button(
            label: isAr ? 'اعادة المحاولة' : 'Try again',
            icon: Icons.refresh_rounded,
            color: primaryColor,
            fontFamily: fontFamily,
            onPressed: onRetry,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onSkip,
            child: Text(
              isAr ? 'تخطي والاستمرار' : 'Skip and continue',
              style: TextStyle(
                fontFamily: fontFamily,
                color: Colors.black.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

class _Button extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String fontFamily;
  final VoidCallback onPressed;

  const _Button({
    required this.label,
    required this.icon,
    required this.color,
    required this.fontFamily,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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
