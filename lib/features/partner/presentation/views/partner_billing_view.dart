import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/status_badge.dart';

/// D22: Partner Billing & Commission Ledger
/// Shows:
/// - Cash collected summary (today / month)
/// - Platform commission liability breakdown (services @ 10%, parts @ 5%)
/// - Settlement history with admin-verified payment dates
class PartnerBillingView extends StatelessWidget {
  const PartnerBillingView({super.key});

  // Pilot seeded financial data
  static const int _todayCashPaisa = 4850000; // Rs 48,500.00
  static const int _monthCashPaisa = 32740000; // Rs 3,27,400.00
  static const int _serviceCommBps = 1000; // 10.00%
  static const int _partsCommBps = 500; // 5.00%

  // Simulated revenue breakdown
  static const int _monthServiceRevenuePaisa = 24200000;
  static const int _monthPartsRevenuePaisa = 8540000;

  @override
  Widget build(BuildContext context) {
    final serviceComm =
        CurrencyUtils.calculateCommission(_monthServiceRevenuePaisa, _serviceCommBps);
    final partsComm =
        CurrencyUtils.calculateCommission(_monthPartsRevenuePaisa, _partsCommBps);
    final totalComm = serviceComm + partsComm;
    final netRetained = _monthCashPaisa - totalComm;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Billing & Commission', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue Overview Hero Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MONTHLY CASH COLLECTED',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const StatusBadge(
                          label: 'NOV 2026',
                          variant: StatusBadgeVariant.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyUtils.formatPaisa(_monthCashPaisa),
                      style: AppTypography.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Today: ${CurrencyUtils.formatPaisa(_todayCashPaisa)}',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white60),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net Retained (after commission):',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                        ),
                        Text(
                          CurrencyUtils.formatPaisa(netRetained),
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Commission Breakdown
              Text(
                'Commission Breakdown',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              _CommissionRow(
                label: 'Service Revenue',
                revenue: _monthServiceRevenuePaisa,
                rateBps: _serviceCommBps,
                commission: serviceComm,
              ),
              const SizedBox(height: 10),
              _CommissionRow(
                label: 'Parts Revenue',
                revenue: _monthPartsRevenuePaisa,
                rateBps: _partsCommBps,
                commission: partsComm,
              ),
              const SizedBox(height: 10),
              CarfixziCard(
                color: AppColors.surfaceContainerHigh,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Commission Payable',
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      CurrencyUtils.formatPaisa(totalComm),
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settlement History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settlement History',
                    style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Last 3 cycles',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _SettlementCard(
                period: 'October 2026',
                totalCommission: 2890000,
                paidDate: '03 Nov 2026',
                status: 'Settled',
                isSettled: true,
              ),
              const SizedBox(height: 10),
              _SettlementCard(
                period: 'September 2026',
                totalCommission: 3125000,
                paidDate: '05 Oct 2026',
                status: 'Settled',
                isSettled: true,
              ),
              const SizedBox(height: 10),
              _SettlementCard(
                period: 'August 2026',
                totalCommission: 2540000,
                paidDate: '04 Sep 2026',
                status: 'Settled',
                isSettled: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommissionRow extends StatelessWidget {
  final String label;
  final int revenue;
  final int rateBps;
  final int commission;

  const _CommissionRow({
    required this.label,
    required this.revenue,
    required this.rateBps,
    required this.commission,
  });

  @override
  Widget build(BuildContext context) {
    final ratePercent = (rateBps / 100).toStringAsFixed(1);
    return CarfixziCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
              StatusBadge(
                label: '$ratePercent% Rate',
                variant: StatusBadgeVariant.info,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue: ${CurrencyUtils.formatPaisa(revenue)}',
                style: AppTypography.bodySmall,
              ),
              Text(
                'Commission: ${CurrencyUtils.formatPaisa(commission)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  final String period;
  final int totalCommission;
  final String paidDate;
  final String status;
  final bool isSettled;

  const _SettlementCard({
    required this.period,
    required this.totalCommission,
    required this.paidDate,
    required this.status,
    required this.isSettled,
  });

  @override
  Widget build(BuildContext context) {
    return CarfixziCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSettled ? AppColors.successContainer : AppColors.warningContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isSettled ? Icons.check_circle_outline : Icons.schedule_rounded,
              color: isSettled ? AppColors.success : AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period,
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Paid: $paidDate',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyUtils.formatPaisa(totalCommission),
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryContainer,
                ),
              ),
              StatusBadge(
                label: status,
                variant: isSettled ? StatusBadgeVariant.success : StatusBadgeVariant.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
