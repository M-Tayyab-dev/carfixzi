import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/enums/payment_status.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../app/routes/app_routes.dart';

/// D15: Payment Checkout & Receipt Screen
/// Explicitly separates physical Cash-on-Service from clearly labeled Demo Simulated Payment.
/// Complies with Section 4.8 & FR-13:
/// - No fake credit card or banking callbacks
/// - PKR Paisa itemized line items
/// - Customer confirmation triggers commission liability event
class PaymentCheckoutView extends StatefulWidget {
  const PaymentCheckoutView({super.key});

  @override
  State<PaymentCheckoutView> createState() => _PaymentCheckoutViewState();
}

class _PaymentCheckoutViewState extends State<PaymentCheckoutView> {
  PaymentStatus _selectedMethod = PaymentStatus.cash_declared;
  bool _isProcessing = false;

  final int _laborPaisa = 180000; // Rs 1,800
  final int _partsPaisa = 240000; // Rs 2,400
  int get _totalPaisa => _laborPaisa + _partsPaisa; // Rs 4,200

  void _handleCompletePayment() {
    setState(() => _isProcessing = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() => _isProcessing = false);

      Get.defaultDialog(
        title: 'Payment Receipt Issued',
        titleStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.w700,
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          children: [
            const Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success),
            const SizedBox(height: 12),
            Text(
              'Receipt #REC-2026-99',
              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Total Settled: ${CurrencyUtils.formatPaisa(_totalPaisa)}',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedMethod == PaymentStatus.cash_declared
                  ? 'Payment recorded as CASH ON SERVICE physically received by partner.'
                  : 'DEMO MODE: Simulated transaction recorded for evaluation purposes only.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        confirm: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGold,
            foregroundColor: AppColors.darkSlate,
          ),
          onPressed: () {
            Get.back();
            Get.offAllNamed(AppRoutes.customerHome);
          },
          child: const Text('Back to Home'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Payment Checkout', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              CarfixziCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'JOB SUMMARY',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.outline,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const StatusBadge(
                          label: 'VERIFIED QUOTE',
                          variant: StatusBadgeVariant.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Brake Pad Replacement & Bleed',
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Apex GT Motorwerks · Sahiwal Bay 01',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 8),
                    _LineItem(label: 'Mechanical Labor', amount: CurrencyUtils.formatPaisa(_laborPaisa)),
                    const SizedBox(height: 6),
                    _LineItem(label: 'Ceramic Brake Pad Set', amount: CurrencyUtils.formatPaisa(_partsPaisa)),
                    const SizedBox(height: 6),
                    _LineItem(label: 'Provincial Sales Tax (Exempt Pilot)', amount: 'Rs 0.00'),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount:', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          CurrencyUtils.formatPaisa(_totalPaisa),
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method Selection
              Text(
                'Select Payment Option',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              // Option 1: Cash on Service
              CarfixziCard(
                color: _selectedMethod == PaymentStatus.cash_declared
                    ? AppColors.surfaceContainerLowest
                    : AppColors.surfaceContainerLow,
                border: Border.all(
                  color: _selectedMethod == PaymentStatus.cash_declared
                      ? AppColors.primaryContainer
                      : const Color.fromRGBO(45, 49, 66, 0.1),
                  width: _selectedMethod == PaymentStatus.cash_declared ? 2.0 : 1.0,
                ),
                onTap: () => setState(() => _selectedMethod = PaymentStatus.cash_declared),
                child: Row(
                  children: [
                    Radio<PaymentStatus>(
                      value: PaymentStatus.cash_declared,
                      groupValue: _selectedMethod,
                      activeColor: AppColors.primaryContainer,
                      onChanged: (val) => setState(() => _selectedMethod = val!),
                    ),
                    const Icon(Icons.payments_rounded, color: AppColors.success, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash on Service (Recommended)',
                            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Pay Pakistani Rupees in physical cash directly to the technician upon job handover.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Option 2: Demo Simulated Payment
              CarfixziCard(
                color: _selectedMethod == PaymentStatus.demo_simulated
                    ? AppColors.surfaceContainerLowest
                    : AppColors.surfaceContainerLow,
                border: Border.all(
                  color: _selectedMethod == PaymentStatus.demo_simulated
                      ? AppColors.primaryContainer
                      : const Color.fromRGBO(45, 49, 66, 0.1),
                  width: _selectedMethod == PaymentStatus.demo_simulated ? 2.0 : 1.0,
                ),
                onTap: () => setState(() => _selectedMethod = PaymentStatus.demo_simulated),
                child: Row(
                  children: [
                    Radio<PaymentStatus>(
                      value: PaymentStatus.demo_simulated,
                      groupValue: _selectedMethod,
                      activeColor: AppColors.primaryContainer,
                      onChanged: (val) => setState(() => _selectedMethod = val!),
                    ),
                    const Icon(Icons.science_rounded, color: AppColors.warning, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Demo Mode Payment',
                                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 8),
                              const StatusBadge(label: 'SIMULATED', variant: StatusBadgeVariant.warning),
                            ],
                          ),
                          Text(
                            'Simulate digital payment completion for FYP evaluation without actual financial transactions.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Complete Button
              CarfixziButton(
                text: _selectedMethod == PaymentStatus.cash_declared
                    ? 'Confirm Cash Payment (${CurrencyUtils.formatPaisa(_totalPaisa)})'
                    : 'Authorize Demo Transaction (${CurrencyUtils.formatPaisa(_totalPaisa)})',
                icon: Icons.check_circle_rounded,
                isLoading: _isProcessing,
                onPressed: _handleCompletePayment,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  final String label;
  final String amount;

  const _LineItem({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(amount, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
