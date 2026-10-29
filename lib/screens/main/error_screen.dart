// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/layout/home_layout.dart';
import 'package:salah_online_platform/screens/auth_screens/login_screens/login_page.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ErrorScreen extends StatefulWidget {
  ErrorScreen({
    super.key,
    required this.cubit,
    required this.status,
  });

  PlatformCubit cubit;
  String status;

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    widget.cubit.setErrScreenData();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await widget.cubit.setErrScreenData();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isBlocked => widget.status == Constants.accountBlocked;

  _StatusTheme _theme() {
    if (_isBlocked) {
      return _StatusTheme(
        color: const Color(0xffef4444),
        icon: Icons.block_rounded,
        badge: 'محظور',
      );
    }
    return _StatusTheme(
      color: const Color(0xfff59e0b),
      icon: Icons.hourglass_top_rounded,
      badge: 'قيد المراجعة',
    );
  }

  Future<void> _openWhatsApp() async {
    final phoneNumber = await widget.cubit.getPhoneNum('mrSupport');
    final whatsappUrl = 'https://wa.me/+2$phoneNumber';
    if (await canLaunchUrlString(whatsappUrl)) {
      await launchUrlString(whatsappUrl);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformDeleteAccountSuccessState) {
          Components.pushReplacement(
            context: context,
            widget: const LoginPage(),
          );
        }
        if (state is PlatformAccountNotBlockedAndPendingState) {
          widget.cubit.isShowDelAccount();
          Components.pushAndRemoveAll(
            context: context,
            name: Components.homeRouteName,
            widget: HomeLayout(
              cubit: widget.cubit,
              pageController: PageController(initialPage: 0),
              isFirstTime: true,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = PlatformCubit.get(context);
        final theme = _theme();
        final fontFamily = cubit.isAr ? 'Cairo' : 'Roboto';
        final isLoading = _isRefreshing;

        return Scaffold(
          backgroundColor: const Color(0xfffafbfd),
          body: SafeArea(
            child: RefreshIndicator(
              color: theme.color,
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  _Header(
                    fontFamily: fontFamily,
                    isAr: cubit.isAr,
                    onLogout: () => _confirmLogout(context, fontFamily),
                  ),
                  const SizedBox(height: 24),
                  _StatusHero(
                    theme: theme,
                    pulse: _pulseController,
                    fontFamily: fontFamily,
                    isAr: cubit.isAr,
                  ),
                  const SizedBox(height: 28),
                  _MessageCard(
                    theme: theme,
                    fontFamily: fontFamily,
                    title: _isBlocked
                        ? S.of(context).account_blocked
                        : (cubit.isAr
                            ? 'حسابك قيد المراجعة'
                            : 'Account under review'),
                    body: _isBlocked
                        ? (cubit.isAr
                            ? 'تم تعطيل حسابك مؤقتًا. للاستفسار أو إعادة التفعيل تواصل مع الدعم.'
                            : 'Your account has been suspended. Contact support for details.')
                        : S.of(context).account_created,
                  ),
                  const SizedBox(height: 22),
                  _PrimaryAction(
                    label: cubit.isAr ? 'تحديث الحالة' : 'Refresh status',
                    icon: Icons.refresh_rounded,
                    color: theme.color,
                    isLoading: isLoading,
                    loadingText:
                        cubit.isAr ? 'جاري التحديث...' : 'Refreshing...',
                    fontFamily: fontFamily,
                    onPressed: _refresh,
                  ),
                  const SizedBox(height: 12),
                  _ContactCard(
                    fontFamily: fontFamily,
                    isAr: cubit.isAr,
                    onTap: _openWhatsApp,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      cubit.isAr
                          ? 'اسحب للأسفل لتحديث الحالة'
                          : 'Pull down to refresh status',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openWhatsApp,
            backgroundColor: const Color(0xff25d366),
            child: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context, String fontFamily) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection:
            widget.cubit.isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            widget.cubit.isAr ? 'تسجيل الخروج' : 'Log out',
            style: TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            widget.cubit.isAr
                ? 'هل تريد تسجيل الخروج والعودة لتسجيل الدخول؟'
                : 'Do you want to log out and return to login?',
            style: TextStyle(fontFamily: fontFamily),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                widget.cubit.isAr ? 'إلغاء' : 'Cancel',
                style: TextStyle(
                  fontFamily: fontFamily,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Components.pushReplacement(
                  context: context,
                  widget: const LoginPage(),
                );
              },
              child: Text(
                widget.cubit.isAr ? 'خروج' : 'Log out',
                style: TextStyle(
                  fontFamily: fontFamily,
                  color: const Color(0xffef4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTheme {
  final Color color;
  final IconData icon;
  final String badge;
  _StatusTheme({
    required this.color,
    required this.icon,
    required this.badge,
  });
}

class _Header extends StatelessWidget {
  final String fontFamily;
  final bool isAr;
  final VoidCallback onLogout;

  const _Header({
    required this.fontFamily,
    required this.isAr,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/white_logo.png'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            isAr ? 'حالة الحساب' : 'Account status',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xff1a1a1a),
            ),
          ),
        ),
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onLogout,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusHero extends StatelessWidget {
  final _StatusTheme theme;
  final AnimationController pulse;
  final String fontFamily;
  final bool isAr;

  const _StatusHero({
    required this.theme,
    required this.pulse,
    required this.fontFamily,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: pulse,
                builder: (_, __) {
                  final t = Curves.easeInOut.transform(pulse.value);
                  return Container(
                    width: 170 + (t * 14),
                    height: 170 + (t * 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.color.withValues(alpha: 0.08 - t * 0.04),
                    ),
                  );
                },
              ),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.color.withValues(alpha: 0.14),
                ),
              ),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.color.withValues(alpha: 0.2),
                ),
                child: Icon(
                  theme.icon,
                  color: theme.color,
                  size: 48,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: theme.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                theme.badge,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  final _StatusTheme theme;
  final String fontFamily;
  final String title;
  final String body;

  const _MessageCard({
    required this.theme,
    required this.fontFamily,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff1a1a1a),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 14,
              height: 1.6,
              color: Colors.black.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final String loadingText;
  final String fontFamily;
  final VoidCallback onPressed;

  const _PrimaryAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.loadingText,
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
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: color,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        loadingText,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Row(
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

class _ContactCard extends StatelessWidget {
  final String fontFamily;
  final bool isAr;
  final VoidCallback onTap;

  const _ContactCard({
    required this.fontFamily,
    required this.isAr,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const wa = Color(0xff25d366);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: wa.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: wa.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: wa,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'تواصل مع الدعم' : 'Contact support',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr
                          ? 'راسل المسؤول على واتساب'
                          : 'Reach out on WhatsApp',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isAr
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
