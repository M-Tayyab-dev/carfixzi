import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/status_badge.dart';

/// NEW-14: Super Admin Manual Settlement Recording
/// Records audited manual cash settlements against partner commission liabilities.
/// Since CARFIXZI is a cash-on-service model, partners physically collect cash and
/// owe commission to the platform. This screen lets the super admin record when
/// partners submit their commission payments (via bank transfer, cash, cheque, etc.)
class SuperAdminSettlementsView extends StatefulWidget {
  const SuperAdminSettlementsView({super.key});

  @override
  State<SuperAdminSettlementsView> createState() => _SuperAdminSettlementsViewState();
}

class _SuperAdminSettlementsViewState extends State<SuperAdminSettlementsView> {
  final List<_SettlementRecord> _settlements = _SettlementRecord.pilotData;
  String _filterStatus = 'All';

  List<_SettlementRecord> get _filtered {
    if (_filterStatus == 'All') return _settlements;
    return _settlements.where((s) => s.status == _filterStatus).toList();
  }

  int get _totalOutstandingPaisa =>
      _settlements.where((s) => s.status == 'Outstanding').fold(0, (sum, s) => sum + s.amountPaisa);
  int get _totalSettledPaisa =>
      _settlements.where((s) => s.status == 'Settled').fold(0, (sum, s) => sum + s.amountPaisa);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Settlements Ledger', style: AppTypography.headlineSmall),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Record New Settlement',
            icon: const Icon(Icons.add_circle_outline, color: AppColors.success),
            onPressed: _showRecordSettlementDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Summary Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceContainerLowest,
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: 'Outstanding',
                      amount: CurrencyUtils.formatPaisa(_totalOutstandingPaisa),
                      color: AppColors.error,
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryTile(
                      label: 'Settled (All Time)',
                      amount: CurrencyUtils.formatPaisa(_totalSettledPaisa),
                      color: AppColors.success,
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
            ),

            // Status filter
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['All', 'Outstanding', 'Settled', 'Disputed'].map((status) {
                  final isSelected = status == _filterStatus;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      labelStyle: AppTypography.labelSmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      selectedColor: AppColors.primaryContainer,
                      backgroundColor: AppColors.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      side: BorderSide(
                        color:
                            isSelected ? Colors.transparent : const Color.fromRGBO(45, 49, 66, 0.1),
                      ),
                      onSelected: (_) => setState(() => _filterStatus = status),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Settlements List
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No settlements match this filter.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final record = _filtered[index];
                        return _SettlementRecordCard(
                          record: record,
                          onMarkSettled: record.status == 'Outstanding'
                              ? () => _markAsSettled(record)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _markAsSettled(_SettlementRecord record) {
    Get.defaultDialog(
      title: 'Confirm Settlement',
      titleStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        children: [
          Text(
            'Mark ${record.partnerName}\'s commission of '
            '${CurrencyUtils.formatPaisa(record.amountPaisa)} as settled?',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warningContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'This action is audit-logged. Ensure physical payment '
              '(bank transfer/cash/cheque) has been received.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warning,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () {
          setState(() {
            record.status = 'Settled';
            record.settledDate = 'Just Now';
          });
          Get.back();
          Get.snackbar(
            'Settlement Recorded',
            '${record.partnerName} — ${CurrencyUtils.formatPaisa(record.amountPaisa)} marked as settled.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successContainer,
            colorText: AppColors.success,
          );
        },
        child: const Text('Confirm Settlement'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }

  void _showRecordSettlementDialog() {
    final amountCtrl = TextEditingController();
    String selectedPartner = 'Apex GT Motorwerks';
    String method = 'Bank Transfer';

    Get.defaultDialog(
      title: 'Record New Settlement',
      titleStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
      contentPadding: const EdgeInsets.all(20),
      content: StatefulBuilder(
        builder: (context, setDialogState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedPartner,
              items: ['Apex GT Motorwerks', 'Royal Auto Detailing Hub', 'PakWheels Express Bay']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setDialogState(() => selectedPartner = v!),
              decoration: InputDecoration(
                labelText: 'Partner',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (Rs)',
                hintText: 'e.g. 25000',
                prefixText: 'Rs ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: method,
              items: ['Bank Transfer', 'Physical Cash', 'Cheque', 'JazzCash', 'EasyPaisa']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setDialogState(() => method = v!),
              decoration: InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.darkSlate,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () {
          final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;
          if (amount <= 0) {
            Get.snackbar(
              'Invalid Amount',
              'Enter a valid settlement amount.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.errorContainer,
              colorText: AppColors.error,
            );
            return;
          }
          setState(() {
            _settlements.insert(
              0,
              _SettlementRecord(
                id: 'stl_${DateTime.now().millisecondsSinceEpoch}',
                partnerName: selectedPartner,
                period: 'November 2026',
                amountPaisa: amount * 100,
                method: method,
                status: 'Settled',
                settledDate: 'Just Now',
              ),
            );
          });
          Get.back();
          Get.snackbar(
            'Settlement Recorded',
            '$selectedPartner — ${CurrencyUtils.formatPaisa(amount * 100)} via $method',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: const Text('Record'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
}

class _SettlementRecord {
  final String id;
  final String partnerName;
  final String period;
  final int amountPaisa;
  final String method;
  String status; // 'Outstanding', 'Settled', 'Disputed'
  String? settledDate;

  _SettlementRecord({
    required this.id,
    required this.partnerName,
    required this.period,
    required this.amountPaisa,
    required this.method,
    required this.status,
    this.settledDate,
  });

  static List<_SettlementRecord> get pilotData => [
        _SettlementRecord(
          id: 'stl_001',
          partnerName: 'Apex GT Motorwerks',
          period: 'October 2026',
          amountPaisa: 2890000,
          method: 'Bank Transfer',
          status: 'Outstanding',
        ),
        _SettlementRecord(
          id: 'stl_002',
          partnerName: 'Royal Auto Detailing Hub',
          period: 'October 2026',
          amountPaisa: 1250000,
          method: 'Physical Cash',
          status: 'Outstanding',
        ),
        _SettlementRecord(
          id: 'stl_003',
          partnerName: 'Apex GT Motorwerks',
          period: 'September 2026',
          amountPaisa: 3125000,
          method: 'Bank Transfer',
          status: 'Settled',
          settledDate: '05 Oct 2026',
        ),
        _SettlementRecord(
          id: 'stl_004',
          partnerName: 'Royal Auto Detailing Hub',
          period: 'September 2026',
          amountPaisa: 980000,
          method: 'JazzCash',
          status: 'Settled',
          settledDate: '04 Oct 2026',
        ),
        _SettlementRecord(
          id: 'stl_005',
          partnerName: 'PakWheels Express Bay',
          period: 'September 2026',
          amountPaisa: 720000,
          method: 'EasyPaisa',
          status: 'Settled',
          settledDate: '06 Oct 2026',
        ),
        _SettlementRecord(
          id: 'stl_006',
          partnerName: 'Apex GT Motorwerks',
          period: 'August 2026',
          amountPaisa: 2540000,
          method: 'Bank Transfer',
          status: 'Settled',
          settledDate: '04 Sep 2026',
        ),
      ];
}

class _SettlementRecordCard extends StatelessWidget {
  final _SettlementRecord record;
  final VoidCallback? onMarkSettled;

  const _SettlementRecordCard({
    required this.record,
    this.onMarkSettled,
  });

  @override
  Widget build(BuildContext context) {
    final isOutstanding = record.status == 'Outstanding';
    final isDisputed = record.status == 'Disputed';

    return CarfixziCard(
      border: isOutstanding
          ? Border.all(color: AppColors.error.withOpacity(0.3), width: 1.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.partnerName,
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${record.period} · ${record.method}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: record.status,
                variant: isOutstanding
                    ? StatusBadgeVariant.error
                    : isDisputed
                        ? StatusBadgeVariant.warning
                        : StatusBadgeVariant.success,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Amount & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyUtils.formatPaisa(record.amountPaisa),
                style: AppTypography.headlineSmall.copyWith(
                  color: isOutstanding ? AppColors.error : AppColors.primaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (record.settledDate != null)
                Text(
                  'Settled: ${record.settledDate}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.success, fontSize: 11),
                ),
              if (onMarkSettled != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(0, 34),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Mark Settled'),
                  onPressed: onMarkSettled,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            amount,
            style: AppTypography.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
