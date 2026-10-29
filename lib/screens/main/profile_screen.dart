// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salah_online_platform/widgets/app_status_dialog.dart';

import 'package:url_launcher/url_launcher_string.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/constants.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/screens/auth_screens/login_screens/login_page.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../constants/styles.dart';
import '../../constants/widgets.dart';
import '../auth_screens/change_pass/change_pass_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlatformCubit, PlatformStates>(
      listener: (context, state) {
        if (state is PlatformLogoutFailState) {
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err
                .substring(state.err.indexOf(']') + 2, state.err.length),
          );
        }
        if (state is PlatformDeleteAccountFailState) {
          AppStatusDialog.show(
            context: context,
            status: AppDialogStatus.error,
            title: 'خلي بالك',
            message: state.err
                .substring(state.err.indexOf(']') + 2, state.err.length),
          );
        }

        if (state is PlatformLogoutSuccessState ||
            state is PlatformDeleteAccountSuccessState) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title with subtle animation
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      S.of(context).profile,
                      style: AppTextStyles.headStyle.copyWith(
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  /*
                  // Profile Header Card (when logged in)
                  if (!cubit.showDelAcc) _buildProfileHeader(context, cubit),
                  const SizedBox(height: 16.0),
        */
                  // Language Toggle (when guest)
                  if (!cubit.showDelAcc) _buildLanguageToggle(cubit),

                  const SizedBox(height: 16.0),

                  // Settings Section
                  _buildSettingsSection(context, cubit),

                  const SizedBox(height: 24.0),

                  // Social Media Section
                  if (!cubit.showDelAcc && cubit.socialMedia.isNotEmpty)
                    _buildSocialMediaSection(context, cubit),

                  const SizedBox(height: 40.0),

                  // Footer Logo
                  _buildFooterLogo(cubit),

                  const SizedBox(height: 30.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageToggle(PlatformCubit cubit) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ToggleSwitch(
            initialLabelIndex: cubit.isAr ? 1 : 0,
            dividerColor: cubit.isDarkMode ? Colors.white24 : Colors.black12,
            minHeight: 48,
            minWidth: double.infinity,
            totalSwitches: 2,
            radiusStyle: true,
            cornerRadius: 20.0,
            customTextStyles: const [
              TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600),
              TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
            ],
            inactiveBgColor: cubit.isDarkMode
                ? AppColors.darkBorder.withValues(alpha: 0.8)
                : AppColors.lightBborder.withValues(alpha: 0.9),
            activeBgColor: [Components.setBgColor(cubit.isDarkMode)],
            activeFgColor: Colors.white,
            inactiveFgColor: cubit.isDarkMode ? Colors.white70 : Colors.black54,
            labels: const [
              'English',
              'عربي',
            ],
            onToggle: (index) {
              cubit.changeLang();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, PlatformCubit cubit) {
    return Container(
      decoration: BoxDecoration(
        color: cubit.isDarkMode
            ? AppColors.darkBorder.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: cubit.isDarkMode ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          /*
          if (!cubit.showDelAcc) ...[
            _buildSettingsTile(
              context: context,
              cubit: cubit,
              icon: Icons.receipt_long_rounded,
              title: S.of(context).purchases_history,
              onTap: () {
                if (!cubit.isGuest()) {
                  Components.push(
                    context: context,
                    widget: PurchasesScreen(),
                  );
                } else {
                  Constants.showLoginDialog(
                    isDarkMode: cubit.isDarkMode,
                    context: context,
                  );
                }
              },
              isFirst: true,
            ),
            _buildDivider(cubit),
          ],
        */
          // Change Password
          _buildSettingsTile(
            context: context,
            cubit: cubit,
            icon: Icons.lock_outline_rounded,
            title: S.of(context).change_pass,
            onTap: () {
              if (!cubit.isGuest()) {
                Components.push(
                  context: context,
                  widget: ChangePasswordScreen(),
                );
              } else {
                Constants.showLoginDialog(
                  isDarkMode: cubit.isDarkMode,
                  context: context,
                );
              }
            },
            isFirst: true,
          ),

          _buildDivider(cubit),

          // Dark Mode
          _buildSettingsTile(
            context: context,
            cubit: cubit,
            icon: cubit.isDarkMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            title: S.of(context).dark_mode,
            trailing: Transform.scale(
              scale: 0.9,
              child: Switch(
                value: cubit.isDarkMode,
                activeThumbColor: AppColors.appPrimaryColor,
                activeTrackColor:
                    AppColors.appPrimaryColor.withValues(alpha: 0.4),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade300,
                thumbIcon: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Icon(Icons.dark_mode,
                        color: Colors.white, size: 16);
                  }
                  return Icon(Icons.light_mode,
                      color: Colors.grey.shade600, size: 16);
                }),
                onChanged: (value) {
                  cubit.changeDarkMode();
                },
              ),
            ),
          ),

          _buildDivider(cubit),

          // App Color
          _buildSettingsTile(
            context: context,
            cubit: cubit,
            icon: Icons.palette_outlined,
            title: S.of(context).color,
            onTap: () => _showColorPickerDialog(context, cubit),
            trailing: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.appPrimaryColor,
                    AppColors.appSecondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: cubit.isDarkMode ? Colors.white24 : Colors.black12,
                  width: 2,
                ),
              ),
            ),
          ),

          // Delete Account (only for logged in users)
          if (cubit.showDelAcc) ...[
            _buildDivider(cubit),
            _buildSettingsTile(
              context: context,
              cubit: cubit,
              icon: Icons.delete_outline_rounded,
              title: S.of(context).del_acc,
              iconColor: Colors.red.shade400,
              titleColor: Colors.red.shade400,
              onTap: () async {
                bool isConnected = await Components.checkConnection();
                if (isConnected) {
                  AppStatusDialog.show(
                    context: context,
                    status: AppDialogStatus.info,
                    title: 'بقولك ايه',
                    message: S.of(context).want_del_acc,
                    primaryActionText: S.of(context).del_acc,
                    onPrimaryAction: () {
                      cubit.deleteAccount();
                    },
                  );
                } else {
                  AppStatusDialog.show(
                    context: context,
                    status: AppDialogStatus.error,
                    title: 'مفيش نت',
                    message: S.of(context).no_internet,
                  );
                }
              },
            ),
          ],

          _buildDivider(cubit),

          // Logout
          _buildSettingsTile(
            context: context,
            cubit: cubit,
            icon: Icons.logout_rounded,
            title: S.of(context).logout,
            iconColor: Colors.red.shade400,
            titleColor: Colors.red.shade400,
            isLast: true,
            onTap: () async {
              bool isConnected = await Components.checkConnection();
              if (isConnected) {
                AppStatusDialog.show(
                  context: context,
                  status: AppDialogStatus.info,
                  title: 'يا بخت من زار وخفف',
                  message: S.of(context).want_logout,
                  primaryActionText: S.of(context).logout,
                  onPrimaryAction: () {
                    Navigator.pop(context);
                    cubit.platformLogout();
                  },
                );
              } else {
                AppStatusDialog.show(
                  context: context,
                  status: AppDialogStatus.error,
                  title: 'مفيش نت',
                  message: S.of(context).no_internet,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required PlatformCubit cubit,
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final defaultIconColor = Components.setBgColor(cubit.isDarkMode);
    final defaultTitleColor = cubit.isDarkMode ? Colors.white : Colors.black87;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(24) : Radius.zero,
          bottom: isLast ? const Radius.circular(24) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      (iconColor ?? defaultIconColor).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? defaultIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body1Style.copyWith(
                    color: titleColor ?? defaultTitleColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Trailing widget
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: cubit.isDarkMode ? Colors.white38 : Colors.black26,
                    size: 24,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(PlatformCubit cubit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: cubit.isDarkMode
            ? Colors.white10
            : Colors.black.withValues(alpha: 0.06),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context, PlatformCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.appPrimaryColor,
                AppColors.appSecondaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.appPrimaryColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: cubit.isDarkMode ? AppColors.darkBgColor : Colors.white,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Components.setBgColor(cubit.isDarkMode)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.palette_outlined,
                        color: Components.setBgColor(cubit.isDarkMode),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      S.of(context).pick_color,
                      style: AppTextStyles.title2Style.copyWith(
                        color: cubit.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Color Options
                _buildColorOption(
                  context: context,
                  cubit: cubit,
                  label: 'Cyan',
                  isSelected: cubit.isPurple,
                  primaryColor: AppColors.appPurblePrimaryColor,
                  secondaryColor: AppColors.appPurbleSecondaryColor,
                  onTap: () {
                    if (!cubit.isPurple) cubit.changeAppColor();
                  },
                ),
                const SizedBox(height: 12),

                _buildColorOption(
                  context: context,
                  cubit: cubit,
                  label: 'Gold',
                  isSelected: !cubit.isPurple,
                  primaryColor: AppColors.appBluePrimaryColor,
                  secondaryColor: AppColors.appBlueSecondaryColor,
                  onTap: () {
                    if (cubit.isPurple) cubit.changeAppColor();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption({
    required BuildContext context,
    required PlatformCubit cubit,
    required String label,
    required bool isSelected,
    required Color primaryColor,
    required Color secondaryColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.15)
                : (cubit.isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Color preview
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Label
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body1Style.copyWith(
                    fontFamily: 'Roboto',
                    color: cubit.isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              // Check icon
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection(BuildContext context, PlatformCubit cubit) {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      cubit.isDarkMode ? Colors.white24 : Colors.black12,
                    ],
                  ),
                ),
              ),
            ),
            Text(
              S.of(context).follow_us_on,
              style: AppTextStyles.body2Style.copyWith(
                color: cubit.isDarkMode ? Colors.white54 : Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cubit.isDarkMode ? Colors.white24 : Colors.black12,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Social Icons
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(
            cubit.socialMedia.length,
            (index) => _buildSocialButton(
              context: context,
              cubit: cubit,
              icon: Constants.icons[cubit.socialMedia[index].type]!,
              onTap: () async {
                bool isConnected = await Components.checkConnection();
                if (isConnected) {
                  launchUrlString(cubit.socialMedia[index].linkUrl);
                } else {
                  AppStatusDialog.show(
                    context: context,
                    status: AppDialogStatus.error,
                    title: 'مفيش نت',
                    message: S.of(context).no_internet,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required PlatformCubit cubit,
    required FaIconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cubit.isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cubit.isDarkMode
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: FaIcon(
            icon,
            size: 28,
            color: cubit.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLogo(PlatformCubit cubit) {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          children: [
            Image(
              width: 70.0,
              height: 70.0,
              fit: BoxFit.contain,
              image: AssetImage(
                cubit.isDarkMode
                    ? 'assets/splash/cod_logo_light.png'
                    : 'assets/splash/cod_logo_black.png',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Codiaeum Tech',
              style: TextStyle(
                fontSize: 12,
                color: cubit.isDarkMode ? Colors.white38 : Colors.black26,
                fontFamily: 'Roboto',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuildProfileWidgets extends StatelessWidget {
  BuildProfileWidgets({
    super.key,
    required this.icon,
    required this.title,
    this.end,
    this.onTap,
    required this.isDarkMode,
    this.padd,
  });
  Icon icon;
  Text title;
  Widget? end;
  void Function()? onTap;
  bool isDarkMode;
  double? padd;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4.0),
        padding: EdgeInsets.all(padd ?? 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBborder,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12.0),
            title,
            const Spacer(),
            end ?? const Icon(Icons.arrow_right_rounded),
          ],
        ),
      ),
    );
  }
}

class BuildSocialIcon extends StatelessWidget {
  BuildSocialIcon({
    super.key,
    required this.icon,
    required this.onTap,
  });
  String icon;
  void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 40.0,
          height: 40.0,
          child: DefaultImage(
            imgUrl: icon,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
