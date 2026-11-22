import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/carfixzi_receipt_dialog.dart';

/// D16: Service History & Receipts (Customer Android)
class ServiceHistoryView extends StatefulWidget {
  const ServiceHistoryView({super.key});

  @override
  State<ServiceHistoryView> createState() => _ServiceHistoryViewState();
}

class _ServiceHistoryViewState extends State<ServiceHistoryView> {
  final List<_HistoryItem> _history = [
    _HistoryItem(
      id: 'bk_2026_99',
      receiptNumber: 'REC-2026-99',
      serviceTitle: 'Brake Pad Replacement & Bleed',
      workshopName: 'Apex GT Motorwerks',
      vehiclePlate: 'LES-18-4921',
      date: '08 Nov 2026',
      totalPaisa: 420000, // Rs 4,200.00
      status: 'Completed',
      paymentMethod: 'Cash on Service',
      hasWarranty: true,
    ),
    _HistoryItem(
      id: 'bk_2026_88',
      receiptNumber: 'REC-2026-88',
      serviceTitle: 'Exterior Express Doorstep Wash',
      workshopName: 'Royal Auto Detailing Hub',
      vehiclePlate: 'LES-20-8812',
      date: '02 Nov 2026',
      totalPaisa: 80000, // Rs 800.00
      status: 'Completed',
      paymentMethod: 'Cash on Service',
      hasWarranty: false,
    ),
    _HistoryItem(
      id: 'bk_2026_74',
      receiptNumber: 'REC-2026-74',
      serviceTitle: 'Roadside Battery Jumpstart & Scan',
      workshopName: 'PakWheels Express Bay',
      vehiclePlate: 'LES-18-4921',
      date: '24 Oct 2026',
      totalPaisa: 120000, // Rs 1,200.00
      status: 'Completed',
      paymentMethod: 'Cash on Service',
      hasWarranty: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Service History & Receipts', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ..._history.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HistoryCard(
                    item: item,
                    onViewReceipt: () => _showReceiptModal(item),
                    onDispute: () => _showDisputeModal(item),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showReceiptModal(_HistoryItem item) {
    CarfixziReceiptDialog.show(
      context: context,
      receiptNumber: item.receiptNumber,
      title: item.serviceTitle,
      partyName: item.workshopName,
      partyRole: 'Workshop',
      vehicleOrMeta: item.vehiclePlate,
      date: item.date,
      totalPaisa: item.totalPaisa,
      paymentMethod: item.paymentMethod,
      status: item.status,
      items: [
        ReceiptItem(label: 'Service & Labor', amount: CurrencyUtils.formatPaisa((item.totalPaisa * 0.6).round())),
        ReceiptItem(label: 'Parts & Consumables', amount: CurrencyUtils.formatPaisa((item.totalPaisa * 0.4).round())),
        ReceiptItem(label: 'Punjab Sales Tax', amount: 'Exempt (Pilot)'),
        ReceiptItem(label: 'Total Paid', amount: CurrencyUtils.formatPaisa(item.totalPaisa)),
      ],
    );
  }

  void _showDisputeModal(_HistoryItem item) {
    final reasonCtrl = TextEditingController();

    Get.defaultDialog(
      title: 'File Warranty Dispute',
      titleStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CARFIXZI 7-Day / 500 km Guarantee',
            style: AppTypography.labelLarge.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'If the mechanical issue recurs after service at ${item.workshopName}, '
            'our regional admin will mediate and arrange re-inspection.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: reasonCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Describe the issue...',
              hintText: 'e.g. Brake noise returned under moderate braking',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          final text = reasonCtrl.text.trim();
          if (text.isEmpty) return;
          Get.back();
          Get.snackbar(
            'Dispute Case Registered',
            'Case #DIS-${item.id.substring(3)} opened. Regional Admin will contact you within 24 hours.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorContainer,
            colorText: AppColors.error,
            duration: const Duration(seconds: 4),
          );
        },
        child: const Text('Submit Dispute'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
}

class _HistoryItem {
  final String id;
  final String receiptNumber;
  final String serviceTitle;
  final String workshopName;
  final String vehiclePlate;
  final String date;
  final int totalPaisa;
  final String status;
  final String paymentMethod;
  final bool hasWarranty;

  _HistoryItem({
    required this.id,
    required this.receiptNumber,
    required this.serviceTitle,
    required this.workshopName,
    required this.vehiclePlate,
    required this.date,
    required this.totalPaisa,
    required this.status,
    required this.paymentMethod,
    required this.hasWarranty,
  });
}

class _HistoryCard extends StatelessWidget {
  final _HistoryItem item;
  final VoidCallback onViewReceipt;
  final VoidCallback onDispute;

  const _HistoryCard({
    required this.item,
    required this.onViewReceipt,
    required this.onDispute,
  });

  @override
  Widget build(BuildContext context) {
    return CarfixziCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.receiptNumber,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const StatusBadge(label: 'COMPLETED', variant: StatusBadgeVariant.success),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.serviceTitle,
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            '${item.workshopName} · ${item.vehiclePlate}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyUtils.formatPaisa(item.totalPaisa),
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryContainer,
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(0, 32),
                    ),
                    icon: const Icon(Icons.receipt_long_rounded, size: 14),
                    label: const Text('Receipt'),
                    onPressed: onViewReceipt,
                  ),
                  if (item.hasWarranty) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        minimumSize: const Size(0, 32),
                        foregroundColor: AppColors.error,
                      ),
                      onPressed: onDispute,
                      child: const Text('Dispute'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
        Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
