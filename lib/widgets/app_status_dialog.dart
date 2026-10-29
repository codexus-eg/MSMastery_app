import 'package:flutter/material.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/network/local/shared_pref_helper.dart';

enum AppDialogStatus { loading, success, error, warning, info }

class AppStatusDialog extends StatefulWidget {
  final AppDialogStatus status;
  final String title;
  final String message;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final bool barrierDismissible;
  final bool isAr;

  const AppStatusDialog({
    super.key,
    required this.status,
    required this.title,
    required this.message,
    this.primaryActionText,
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.barrierDismissible = true,
    this.isAr = true,
  });

  static Future<void> show({
    required BuildContext context,
    required AppDialogStatus status,
    required String title,
    required String message,
    String? primaryActionText,
    VoidCallback? onPrimaryAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    bool barrierDismissible = true,
    bool isAr = true,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible:
          barrierDismissible && status != AppDialogStatus.loading,
      barrierLabel: 'dialog',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return Transform.scale(
          scale: 0.9 + (0.1 * curved.value),
          child: Opacity(
            opacity: anim.value.clamp(0.0, 1.0),
            child: AppStatusDialog(
              status: status,
              title: title,
              message: message,
              primaryActionText: primaryActionText,
              onPrimaryAction: onPrimaryAction,
              secondaryActionText: secondaryActionText,
              onSecondaryAction: onSecondaryAction,
              barrierDismissible: barrierDismissible,
              isAr: isAr,
            ),
          ),
        );
      },
    );
  }

  @override
  State<AppStatusDialog> createState() => _AppStatusDialogState();
}

class _AppStatusDialogState extends State<AppStatusDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  _StatusTheme _themeFor(AppDialogStatus s) {
    switch (s) {
      case AppDialogStatus.success:
        return _StatusTheme(
          color: const Color(0xff22c55e),
          icon: Icons.check_rounded,
        );
      case AppDialogStatus.error:
        return _StatusTheme(
          color: const Color(0xffef4444),
          icon: Icons.close_rounded,
        );
      case AppDialogStatus.warning:
        return _StatusTheme(
          color: const Color(0xfff59e0b),
          icon: Icons.priority_high_rounded,
        );
      case AppDialogStatus.info:
        return _StatusTheme(
          color: AppColors.appPrimaryColor,
          icon: Icons.info_outline_rounded,
        );
      case AppDialogStatus.loading:
        return _StatusTheme(
          color: AppColors.appPrimaryColor,
          icon: Icons.hourglass_top_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themeFor(widget.status);
    final fontFamily = widget.isAr ? 'Cairo' : 'Roboto';
    final isLoading = widget.status == AppDialogStatus.loading;

    return PopScope(
      canPop: !isLoading,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: (SharedPrefHelper.getData('isDarkMode') ?? false)
                ? const Color(0xff1a1a1a)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 28),
              _buildIcon(theme, isLoading),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: (SharedPrefHelper.getData('isDarkMode') ?? false)
                        ? Colors.white
                        : Colors.black,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: (SharedPrefHelper.getData('isDarkMode') ?? false)
                        ? Colors.white.withValues(alpha: 0.65)
                        : Colors.black.withValues(alpha: 0.65),
                    fontFamily: fontFamily,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!isLoading) _buildActions(theme, fontFamily),
              if (isLoading) const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(_StatusTheme theme, bool isLoading) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.color.withValues(alpha: 0.12),
      ),
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.color.withValues(alpha: 0.18),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: theme.color,
                      strokeWidth: 3,
                    ),
                  )
                : ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _iconController,
                      curve: Curves.elasticOut,
                    ),
                    child: Icon(
                      theme.icon,
                      color: theme.color,
                      size: 34,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(_StatusTheme theme, String fontFamily) {
    final primaryText = widget.primaryActionText;
    final secondaryText = widget.secondaryActionText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          if (secondaryText != null) ...[
            Expanded(
              child: _DialogButton(
                text: secondaryText,
                onPressed: widget.onSecondaryAction ??
                    () => Navigator.of(context).pop(),
                color: theme.color,
                fontFamily: fontFamily,
                isOutlined: true,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: _DialogButton(
              text: primaryText ?? (widget.isAr ? 'تمام' : 'OK'),
              onPressed:
                  widget.onPrimaryAction ?? () => Navigator.of(context).pop(),
              color: theme.color,
              fontFamily: fontFamily,
              isOutlined: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTheme {
  final Color color;
  final IconData icon;
  _StatusTheme({required this.color, required this.icon});
}

class _DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final String fontFamily;
  final bool isOutlined;

  const _DialogButton({
    required this.text,
    required this.onPressed,
    required this.color,
    required this.fontFamily,
    required this.isOutlined,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: isOutlined ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: isOutlined
                  ? Border.all(color: color.withValues(alpha: 0.45), width: 1.4)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isOutlined ? color : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
