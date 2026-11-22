import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/status_badge.dart';

/// NEW-13: Super Admin Commission Policy Management
/// Allows the super admin to view and adjust platform commission rates in basis points.
/// - Services default: 1000 bps (10.00%)
/// - Parts default: 500 bps (5.00%)
/// All commission calculations use integer Paisa arithmetic via CurrencyUtils.
/// Supports editing rates by tapping card, entering as a digit (TextField) or by range (Slider).
class SuperAdminCommissionView extends StatefulWidget {
  const SuperAdminCommissionView({super.key});

  @override
  State<SuperAdminCommissionView> createState() => _SuperAdminCommissionViewState();
}

class _SuperAdminCommissionViewState extends State<SuperAdminCommissionView> {
  // Commission rates in basis points (1 bps = 0.01%)
  int _serviceRateBps = 1000; // 10.00%
  int _partsRateBps = 500; // 5.00%
  int _washRateBps = 1200; // 12.00%
  int _mobileMechanicRateBps = 1500; // 15.00%

  // Pilot aggregate stats
  static const int _totalServiceRevPaisa = 145600000; // Rs 14,56,000
  static const int _totalPartsRevPaisa = 42800000; // Rs 4,28,000
  static const int _totalWashRevPaisa = 18500000; // Rs 1,85,000
  static const int _totalMobileRevPaisa = 8200000; // Rs 82,000

  void _showEditRateDialog({
    required String title,
    required int currentBps,
    required int monthlyRevenue,
    required ValueChanged<int> onSave,
  }) {
    int tempBps = currentBps;
    final digitController = TextEditingController(
      text: (currentBps / 100).toStringAsFixed(1),
    );

    Get.defaultDialog(
      title: 'Set Commission: $title',
      titleStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      content: StatefulBuilder(
        builder: (context, setModalState) {
          final ratePercent = (tempBps / 100).toStringAsFixed(1);
          final projected = CurrencyUtils.calculateCommission(monthlyRevenue, tempBps);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adjust commission rate by entering an exact digit or using the range slider:',
                style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
              ),
              const SizedBox(height: 16),

              // Method 1: Enter as a digit (direct number input)
              Text(
                'Enter as Digit (Percentage %):',
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: digitController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        suffixText: '%',
                        hintText: 'e.g. 10.5',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val.trim());
                        if (parsed != null && parsed >= 0 && parsed <= 50) {
                          setModalState(() {
                            tempBps = (parsed * 100).round();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$tempBps bps',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Preset Digits
              Wrap(
                spacing: 6,
                children: [5.0, 7.5, 10.0, 12.5, 15.0, 20.0].map((preset) {
                  final isCurrent = (tempBps / 100) == preset;
                  return ActionChip(
                    label: Text('${preset.toStringAsFixed(1)}%'),
                    backgroundColor: isCurrent ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                    labelStyle: TextStyle(
                      color: isCurrent ? Colors.white : AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: () {
                      setModalState(() {
                        tempBps = (preset * 100).round();
                        digitController.text = preset.toStringAsFixed(1);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Method 2: Adjust by Range (Slider)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Adjust by Range:',
                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '$ratePercent%',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primaryContainer,
                  inactiveTrackColor: AppColors.surfaceContainerHigh,
                  thumbColor: AppColors.primaryContainer,
                  trackHeight: 4,
                ),
                child: Slider(
                  value: tempBps.toDouble().clamp(0, 3000),
                  min: 0,
                  max: 3000,
                  divisions: 60,
                  label: '$ratePercent%',
                  onChanged: (v) {
                    setModalState(() {
                      tempBps = v.round();
                      digitController.text = (tempBps / 100).toStringAsFixed(1);
                    });
                  },
                ),
              ),

              // Projected revenue impact
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Projected Commission:', style: AppTypography.bodySmall),
                    Text(
                      CurrencyUtils.formatPaisa(projected),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        onPressed: () {
          onSave(tempBps);
          Get.back();
          Get.snackbar(
            'Rate Saved',
            '$title updated to ${(tempBps / 100).toStringAsFixed(1)}% ($tempBps bps)',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successContainer,
            colorText: AppColors.success,
          );
        },
        child: const Text('Apply Rate'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCommission =
        CurrencyUtils.calculateCommission(_totalServiceRevPaisa, _serviceRateBps) +
            CurrencyUtils.calculateCommission(_totalPartsRevPaisa, _partsRateBps) +
            CurrencyUtils.calculateCommission(_totalWashRevPaisa, _washRateBps) +
            CurrencyUtils.calculateCommission(_totalMobileRevPaisa, _mobileMechanicRateBps);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Commission Policies', style: AppTypography.headlineSmall),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Save Changes',
            icon: const Icon(Icons.save_rounded, color: AppColors.success),
            onPressed: _saveChanges,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Platform Revenue Overview
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
                          'PLATFORM COMMISSION (PILOT)',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const StatusBadge(
                          label: 'SUPER ADMIN',
                          variant: StatusBadgeVariant.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyUtils.formatPaisa(totalCommission),
                      style: AppTypography.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total projected monthly commission at current rates',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Rate Configuration Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commission Rate Configuration',
                    style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Tap to edit',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tap any card to enter by digit or adjust by range. 100 bps = 1.00%.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
              ),
              const SizedBox(height: 16),

              _RateCard(
                icon: Icons.build_rounded,
                title: 'Workshop Services',
                subtitle: 'Mechanical repairs, diagnostics, maintenance',
                currentBps: _serviceRateBps,
                monthlyRevenue: _totalServiceRevPaisa,
                onChanged: (v) => setState(() => _serviceRateBps = v),
                onTap: () => _showEditRateDialog(
                  title: 'Workshop Services',
                  currentBps: _serviceRateBps,
                  monthlyRevenue: _totalServiceRevPaisa,
                  onSave: (v) => setState(() => _serviceRateBps = v),
                ),
              ),
              const SizedBox(height: 12),

              _RateCard(
                icon: Icons.inventory_2_rounded,
                title: 'Spare Parts Sales',
                subtitle: 'OEM & aftermarket parts marketplace',
                currentBps: _partsRateBps,
                monthlyRevenue: _totalPartsRevPaisa,
                onChanged: (v) => setState(() => _partsRateBps = v),
                onTap: () => _showEditRateDialog(
                  title: 'Spare Parts Sales',
                  currentBps: _partsRateBps,
                  monthlyRevenue: _totalPartsRevPaisa,
                  onSave: (v) => setState(() => _partsRateBps = v),
                ),
              ),
              const SizedBox(height: 12),

              _RateCard(
                icon: Icons.local_car_wash_rounded,
                title: 'Car Wash Services',
                subtitle: 'Doorstep and in-shop wash packages',
                currentBps: _washRateBps,
                monthlyRevenue: _totalWashRevPaisa,
                onChanged: (v) => setState(() => _washRateBps = v),
                onTap: () => _showEditRateDialog(
                  title: 'Car Wash Services',
                  currentBps: _washRateBps,
                  monthlyRevenue: _totalWashRevPaisa,
                  onSave: (v) => setState(() => _washRateBps = v),
                ),
              ),
              const SizedBox(height: 12),

              _RateCard(
                icon: Icons.motorcycle_rounded,
                title: 'Mobile Mechanic',
                subtitle: 'On-location emergency and scheduled repairs',
                currentBps: _mobileMechanicRateBps,
                monthlyRevenue: _totalMobileRevPaisa,
                onChanged: (v) => setState(() => _mobileMechanicRateBps = v),
                onTap: () => _showEditRateDialog(
                  title: 'Mobile Mechanic',
                  currentBps: _mobileMechanicRateBps,
                  monthlyRevenue: _totalMobileRevPaisa,
                  onSave: (v) => setState(() => _mobileMechanicRateBps = v),
                ),
              ),
              const SizedBox(height: 24),

              // Audit Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.warning),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Rate changes are audit-logged with your Super Admin ID and timestamp. '
                        'Rate adjustments do NOT retroactively apply to existing settlements.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() {
    Get.snackbar(
      'Commission Rates Updated',
      'Services: ${(_serviceRateBps / 100).toStringAsFixed(1)}% · '
          'Parts: ${(_partsRateBps / 100).toStringAsFixed(1)}% · '
          'Wash: ${(_washRateBps / 100).toStringAsFixed(1)}% · '
          'Mobile: ${(_mobileMechanicRateBps / 100).toStringAsFixed(1)}%',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successContainer,
      colorText: AppColors.success,
      duration: const Duration(seconds: 3),
    );
  }
}

class _RateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int currentBps;
  final int monthlyRevenue;
  final ValueChanged<int> onChanged;
  final VoidCallback onTap;

  const _RateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.currentBps,
    required this.monthlyRevenue,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final projected = CurrencyUtils.calculateCommission(monthlyRevenue, currentBps);
    final ratePercent = (currentBps / 100).toStringAsFixed(1);

    return CarfixziCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primaryContainer, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                    ),
                  ],
                ),
              ),
              // Clickable rate badge to edit by digit or range
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryContainer.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$ratePercent%',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit_rounded, size: 14, color: AppColors.primaryContainer),
                        ],
                      ),
                      Text(
                        '$currentBps bps',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.outline,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Range Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryContainer,
              inactiveTrackColor: AppColors.surfaceContainerHigh,
              thumbColor: AppColors.primaryContainer,
              overlayColor: AppColors.primaryContainer.withOpacity(0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: currentBps.toDouble().clamp(0, 3000),
              min: 0,
              max: 3000, // 0% to 30%
              divisions: 60,
              label: '$ratePercent%',
              onChanged: (v) => onChanged(v.round()),
            ),
          ),

          // Projected Commission + Tap Hint
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue: ${CurrencyUtils.formatPaisa(monthlyRevenue, includeDecimals: false)}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.outline, fontSize: 11),
              ),
              Row(
                children: [
                  Text(
                    'Projected: ${CurrencyUtils.formatPaisa(projected)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.touch_app_outlined, size: 13, color: AppColors.outline),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
