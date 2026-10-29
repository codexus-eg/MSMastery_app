// ignore_for_file: file_names

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:salah_online_platform/bloc/platformCubit.dart';
import 'package:salah_online_platform/bloc/platformStates.dart';
import 'package:salah_online_platform/constants/components.dart';
import 'package:salah_online_platform/constants/styles.dart';
import 'package:salah_online_platform/constants/widgets.dart';
import 'package:salah_online_platform/generated/l10n.dart';
import 'package:salah_online_platform/models/invoice_model.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    PlatformCubit.get(context).getAllInvoices();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Trigger the next page a bit before reaching the very bottom.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      PlatformCubit.get(context).getMoreInvoices();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatformCubit, PlatformStates>(
      builder: (context, state) {
        final cubit = PlatformCubit.get(context);
        final isDark = cubit.isDarkMode;
        final accent = Components.setBgColor(isDark);

        // Newest invoices first.
        final isLoading = state is PlatfromGetAllInvoicesLoadingState;
        final showFooterLoader = cubit.isLoadingMoreInvoices;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultBackBtn(txt: S.of(context).my_invoices),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: RefreshIndicator(
                      color: accent,
                      onRefresh: () => cubit.getAllInvoices(),
                      child: ConditionalBuilder(
                        condition: isLoading,
                        builder: (context) => Center(
                            child: CircularProgressIndicator(color: accent)),
                        fallback: (context) => ConditionalBuilder(
                          condition: cubit.allInvoices.isEmpty,
                          builder: (context) => _EmptyState(accent: accent),
                          fallback: (context) => ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            // One extra slot for the bottom loader.
                            itemCount: cubit.allInvoices.length + 1,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12.0),
                            itemBuilder: (context, index) {
                              if (index >= cubit.allInvoices.length) {
                                return _FooterLoader(
                                  show: showFooterLoader,
                                  accent: accent,
                                );
                              }
                              return _InvoiceCard(
                                invoice: cubit.allInvoices[index],
                                isDarkMode: isDark,
                                accent: accent,
                              );
                            },
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
      },
    );
  }
}

class _FooterLoader extends StatelessWidget {
  const _FooterLoader({required this.show, required this.accent});
  final bool show;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox(height: 8.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: accent),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(Icons.receipt_long_outlined,
            size: 90, color: accent.withValues(alpha: 0.5)),
        const SizedBox(height: 16.0),
        Text(
          S.of(context).no_invoices_yet,
          textAlign: TextAlign.center,
          style: AppTextStyles.title2Style,
        ),
        const SizedBox(height: 8.0),
        Text(
          S.of(context).invoices_appear_here,
          textAlign: TextAlign.center,
          style: AppTextStyles.body2Style.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.invoice,
    required this.isDarkMode,
    required this.accent,
  });

  final InvoiceModel invoice;
  final bool isDarkMode;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final status = _statusStyle(context, invoice);
    final cardColor = isDarkMode ? const Color(0xff1c1c1e) : Colors.white;
    final mutedColor = isDarkMode ? Colors.white60 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.0),
        border:
            Border.all(color: status.color.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + title + status badge
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(status.icon, color: status.color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.title.isEmpty
                            ? S.of(context).invoice
                            : invoice.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body1Style
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(invoice.createdAt),
                        style: AppTextStyles.body2Style
                            .copyWith(color: mutedColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(label: status.label, color: status.color),
              ],
            ),
          ),

          Divider(height: 1, color: mutedColor.withValues(alpha: 0.15)),

          // Amount row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).amount,
                  style: AppTextStyles.body2Style.copyWith(color: mutedColor),
                ),
                Text(
                  '${_formatAmount(invoice.amount)} ${invoice.currency.isEmpty ? S.of(context).egp : invoice.currency}',
                  style: AppTextStyles.title2Style.copyWith(color: accent),
                ),
              ],
            ),
          ),

          // Detail rows depending on status
          ..._buildDetails(context, mutedColor),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<Widget> _buildDetails(BuildContext context, Color mutedColor) {
    final rows = <Widget>[];

    if (invoice.paymentMethod != null &&
        invoice.paymentMethod!.trim().isNotEmpty) {
      rows.add(_DetailRow(
        icon: Icons.credit_card,
        label: S.of(context).payment_method,
        value: invoice.paymentMethod!,
        mutedColor: mutedColor,
      ));
    }

    if (invoice.isPaid &&
        invoice.referenceNumber != null &&
        invoice.referenceNumber!.trim().isNotEmpty) {
      rows.add(_DetailRow(
        icon: Icons.confirmation_number_outlined,
        label: S.of(context).reference_number,
        value: invoice.referenceNumber!,
        mutedColor: mutedColor,
        copyable: true,
      ));
    }

    if (invoice.isPaid && invoice.paidAt != null) {
      rows.add(_DetailRow(
        icon: Icons.event_available,
        label: S.of(context).payment_date,
        value: _formatDate(invoice.paidAt!),
        mutedColor: mutedColor,
      ));
    }

    if (invoice.isPending) {
      if (invoice.fawryCode != null && invoice.fawryCode!.trim().isNotEmpty) {
        rows.add(_DetailRow(
          icon: Icons.qr_code_2,
          label: S.of(context).fawry_code,
          value: invoice.fawryCode!,
          mutedColor: mutedColor,
          copyable: true,
        ));
      }
      if (invoice.expireDate != null) {
        rows.add(_DetailRow(
          icon: Icons.timer_outlined,
          label: S.of(context).expires_at,
          value: _formatDate(invoice.expireDate!),
          mutedColor: mutedColor,
        ));
      }
    }

    if (invoice.isFailed) {
      if (invoice.failedAt != null) {
        rows.add(_DetailRow(
          icon: Icons.event_busy,
          label: S.of(context).failure_date,
          value: _formatDate(invoice.failedAt!),
          mutedColor: mutedColor,
        ));
      }
      if (invoice.failureReason != null &&
          invoice.failureReason!.trim().isNotEmpty) {
        rows.add(_DetailRow(
          icon: Icons.error_outline,
          label: S.of(context).failure_reason,
          value: invoice.failureReason!,
          mutedColor: mutedColor,
        ));
      }
    }

    return rows;
  }

  _InvoiceStatusStyle _statusStyle(BuildContext context, InvoiceModel invoice) {
    if (invoice.isPaid) {
      return _InvoiceStatusStyle(
        label: S.of(context).status_paid,
        color: const Color(0xff2e9e5b),
        icon: Icons.check_circle,
      );
    } else if (invoice.isPending) {
      return _InvoiceStatusStyle(
        label: S.of(context).status_pending,
        color: const Color(0xffe6a700),
        icon: Icons.hourglass_top,
      );
    } else if (invoice.isFailed) {
      return _InvoiceStatusStyle(
        label: S.of(context).status_failed,
        color: const Color(0xffd64545),
        icon: Icons.cancel,
      );
    }
    return _InvoiceStatusStyle(
      label: S.of(context).status_unknown,
      color: Colors.grey,
      icon: Icons.help_outline,
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }
    return amount.toStringAsFixed(2);
  }

  String _formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy • hh:mm a', 'en').format(date);
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.mutedColor,
    this.copyable = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color mutedColor;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: mutedColor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTextStyles.body2Style
                .copyWith(color: mutedColor, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2Style.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).copied),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(Icons.copy, size: 16, color: mutedColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _InvoiceStatusStyle {
  const _InvoiceStatusStyle({
    required this.label,
    required this.color,
    required this.icon,
  });
  final String label;
  final Color color;
  final IconData icon;
}
