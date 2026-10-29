// ignore_for_file: must_be_immutable

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:salah_online_platform/models/attende_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:salah_online_platform/constants/colors.dart';
import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/generated/l10n.dart';

import '../../bloc/platformCubit.dart';
import '../../bloc/platformStates.dart';
import '../../constants/components.dart';
import '../../constants/constants.dart';
import '../../constants/styles.dart';
import '../../models/user_model.dart';

class MyCodeScreen extends StatefulWidget {
  const MyCodeScreen({super.key});

  @override
  State<MyCodeScreen> createState() => _MyCodeScreenState();
}

class _MyCodeScreenState extends State<MyCodeScreen> {
  UserModel um = Constants.userBox.get('user');

  @override
  void initState() {
    super.initState();
    PlatformCubit.get(context).getAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformCubit, PlatformStates>(
      builder: (context, state) {
        var cubit = PlatformCubit.get(context);
        final bool isDarkMode = cubit.isDarkMode;

        final int loan = cubit.loan;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultBackBtn(
                    txt: S.of(context).attendance,
                  ),
                  const SizedBox(height: 4.0),

                  // ---------- QR / Code card ----------
                  _QrCard(um: um, isDarkMode: isDarkMode),

                  const SizedBox(height: 14.0),

                  // ---------- Summary chips (loan + total paid) ----------
                  if (loan != 0)
                    _SummaryCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: S.of(context).loan_desc,
                      value: '$loan ${S.of(context).egp}',
                      color: Colors.redAccent,
                      isDarkMode: isDarkMode,
                    ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18.0),
                        Row(
                          children: [
                            Icon(
                              Icons.event_available_outlined,
                              color: Components.setBgColor(isDarkMode),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              S.of(context).attendance,
                              style: AppTextStyles.title1Style,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Expanded(
                          child: RefreshIndicator(
                            color: Components.setBgColor(isDarkMode),
                            onRefresh: () => cubit.getAttendance(),
                            child: ConditionalBuilder(
                                condition: cubit.stdAttendanceList.isEmpty,
                                builder: (context) => ListView(
                                      children: [
                                        const SizedBox(height: 60.0),
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 56,
                                          color: (isDarkMode
                                                  ? Colors.white
                                                  : Colors.black)
                                              .withValues(alpha: 0.2),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Center(
                                          child: Text(
                                            S.of(context).no_attendance_yet,
                                            style: AppTextStyles.title2Style,
                                          ),
                                        ),
                                      ],
                                    ),
                                fallback: (context) {
                                  return ListView.separated(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    itemCount: cubit.stdAttendanceList.length,
                                    itemBuilder: (context, index) {
                                      return AttendanceItem(
                                        lecName: cubit.stdAttendanceList.keys
                                            .elementAt(index),
                                        isDarkMode: isDarkMode,
                                        attendeModel: cubit
                                            .stdAttendanceList.values
                                            .elementAt(index),
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        seperatorWidget(cubit, index),
                                  );
                                }),
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

  Widget seperatorWidget(PlatformCubit cubit, int index) {
    return cubit.stdAttendanceList.values.elementAt(index).amount != null
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Divider(
                  height: 1,
                  color: cubit.isDarkMode ? Colors.white : Colors.black,
                ),
                Text(
                  S.of(context).new_month,
                  style: AppTextStyles.title1Style.copyWith(fontSize: 22.0),
                ),
              ],
            ),
          )
        : const SizedBox(height: 12.0);
  }
}

/// Modern gradient card that shows the student's QR code, code and group.
class _QrCard extends StatelessWidget {
  final UserModel um;
  final bool isDarkMode;

  const _QrCard({required this.um, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final Color baseColor = Components.setBgColor(isDarkMode);
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor,
            Color.lerp(baseColor, Colors.black, 0.25) ?? baseColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: QrImageView(
              data: 'MS${um.code ?? ''}',
              size: 110,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.qr_code_2_rounded,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 6.0),
                    Text(
                      S.of(context).code,
                      style: AppTextStyles.body2Style.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  um.code ?? '',
                  style: AppTextStyles.title1Style.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.groups_2_outlined,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6.0),
                      Flexible(
                        child: Text(
                          um.groupName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body2Style.copyWith(
                            fontFamily: 'Cairo',
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
    );
  }
}

/// Compact card used for the loan / total-paid summary.
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDarkMode;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBorder : AppColors.lightBgColor,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body2Style.copyWith(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            value,
            style: AppTextStyles.title2Style.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class AttendanceItem extends StatelessWidget {
  final AttendeModel attendeModel;
  final bool isDarkMode;
  final String lecName;
  UserModel get um => Constants.userBox.get('user');

  const AttendanceItem({
    super.key,
    required this.lecName,
    required this.attendeModel,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    bool isSub = attendeModel.groupName != null &&
        attendeModel.groupName != um.groupName;
    final Color statusColor = isSub
        ? Colors.orange
        : (attendeModel.isAttend ? Colors.green : Colors.red);

    final IconData statusIcon = isSub
        ? Icons.swap_horiz_rounded
        : (attendeModel.isAttend
            ? Icons.check_circle_outline_outlined
            : Icons.cancel_outlined);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBorder : AppColors.lightBgColor,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: BorderDirectional(
          start: BorderSide(
            color: statusColor,
            width: 4,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lecName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isSub)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    attendeModel.groupName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body2Style.copyWith(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _InfoChip(
                  icon: Icons.calendar_month_outlined,
                  label: S.of(context).lecture_date,
                  value:
                      '${DateFormat('EEEE').format(attendeModel.date)} ${DateFormat('(MM - dd)', 'en').format(attendeModel.date)}',
                  isDarkMode: isDarkMode,
                ),
                if (attendeModel.arrivalTime != null)
                  _InfoChip(
                    icon: Icons.access_time_rounded,
                    label: S.of(context).arrival_time,
                    value:
                        '${DateFormat('hh:mm', 'en').format(attendeModel.arrivalTime!)} ${DateFormat('a').format(attendeModel.arrivalTime!)}',
                    isDarkMode: isDarkMode,
                  ),
                if (attendeModel.examDegree != null &&
                    attendeModel.fullExamDegree != null &&
                    attendeModel.fullExamDegree != '0')
                  _InfoChip(
                    icon: Icons.quiz_outlined,
                    label: S.of(context).quiz_degree,
                    value: attendeModel.fullExamDegree!.isEmpty
                        ? S.of(context).no_exam
                        : '${attendeModel.examDegree!} / ${attendeModel.fullExamDegree!}',
                    isDarkMode: isDarkMode,
                  ),
                if (attendeModel.hwDegree != null &&
                    attendeModel.fullHWDegree != null &&
                    attendeModel.fullHWDegree != '0')
                  _InfoChip(
                    icon: Icons.assignment_outlined,
                    label: S.of(context).homework,
                    value: attendeModel.fullHWDegree!.isEmpty
                        ? S.of(context).no_hw
                        : '${attendeModel.hwDegree!} / ${attendeModel.fullHWDegree!}',
                    isDarkMode: isDarkMode,
                  ),
                if (attendeModel.pay != null && attendeModel.pay != 0)
                  _InfoChip(
                    icon: Icons.payments_outlined,
                    label: S.of(context).paid,
                    value: '${attendeModel.pay} ${S.of(context).egp}',
                    isDarkMode: isDarkMode,
                    highlightColor: Colors.green,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small labelled chip used inside an [AttendanceItem].
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDarkMode;
  final Color? highlightColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDarkMode,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = highlightColor ??
        (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.75);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
      decoration: BoxDecoration(
        color: (highlightColor ?? (isDarkMode ? Colors.white : Colors.black))
            .withValues(alpha: isDarkMode ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6.0),
          Text(
            '$label: ',
            style: AppTextStyles.body2Style.copyWith(
              fontSize: 13,
              color: fg.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body2Style.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
