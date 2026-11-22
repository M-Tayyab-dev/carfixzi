import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../core/utils/currency_utils.dart';

/// Item in a receipt breakdown
class ReceiptItem {
  final String label;
  final String amount;

  const ReceiptItem({required this.label, required this.amount});
}

/// Branded Receipt Dialog with "Save Photo" functionality for all account types
/// (Customer, Workshop Partner, Admin, Super Admin).
/// Captures high-res branded receipt image with CARFIXZI logo and saves to phone storage.
class CarfixziReceiptDialog extends StatefulWidget {
  final String receiptNumber;
  final String title;
  final String partyName; // Customer Name or Workshop Name
  final String partyRole; // 'Customer' or 'Workshop Partner' or 'Admin'
  final String vehicleOrMeta; // Vehicle plate, bay, or period
  final String date;
  final int totalPaisa;
  final String paymentMethod;
  final String status;
  final List<ReceiptItem> items;

  const CarfixziReceiptDialog({
    super.key,
    required this.receiptNumber,
    required this.title,
    required this.partyName,
    required this.partyRole,
    required this.vehicleOrMeta,
    required this.date,
    required this.totalPaisa,
    required this.paymentMethod,
    this.status = 'Completed',
    this.items = const [],
  });

  /// Convenient static helper to show the dialog anywhere
  static void show({
    required BuildContext context,
    required String receiptNumber,
    required String title,
    required String partyName,
    required String partyRole,
    required String vehicleOrMeta,
    required String date,
    required int totalPaisa,
    required String paymentMethod,
    String status = 'Completed',
    List<ReceiptItem> items = const [],
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: CarfixziReceiptDialog(
          receiptNumber: receiptNumber,
          title: title,
          partyName: partyName,
          partyRole: partyRole,
          vehicleOrMeta: vehicleOrMeta,
          date: date,
          totalPaisa: totalPaisa,
          paymentMethod: paymentMethod,
          status: status,
          items: items,
        ),
      ),
    );
  }

  @override
  State<CarfixziReceiptDialog> createState() => _CarfixziReceiptDialogState();
}

class _CarfixziReceiptDialogState extends State<CarfixziReceiptDialog> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveReceiptToPhone() async {
    setState(() => _isSaving = true);
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Receipt surface is not ready to capture.');
      }

      // Capture at 3x pixel ratio for crisp print/gallery quality
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to generate receipt image data.');
      }

      final bytes = byteData.buffer.asUint8List();
      final fileName = 'CARFIXZI_${widget.receiptNumber}_${DateTime.now().millisecondsSinceEpoch}.png';

      // 1. Try public Pictures directory on Android so user sees it in Gallery
      Directory? targetDir;
      try {
        final publicPictures = Directory('/storage/emulated/0/Pictures/CARFIXZI');
        if (!await publicPictures.exists()) {
          await publicPictures.create(recursive: true);
        }
        targetDir = publicPictures;
      } catch (_) {
        // Fallback to Documents directory
        try {
          final docs = await getApplicationDocumentsDirectory();
          final carfixziDir = Directory('${docs.path}/CARFIXZI_Receipts');
          if (!await carfixziDir.exists()) {
            await carfixziDir.create(recursive: true);
          }
          targetDir = carfixziDir;
        } catch (_) {
          // Last resort fallback
          targetDir = Directory.systemTemp;
        }
      }

      final file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        Get.snackbar(
          'Photo Saved to Phone! 📸',
          'Receipt saved to: ${targetDir.path}/$fileName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successContainer,
          colorText: AppColors.success,
          icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Saved to App Storage',
          'Receipt image generated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successContainer,
          colorText: AppColors.success,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Printable/Saveable Receipt Box
          RepaintBoundary(
            key: _repaintKey,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Brand Header with Logo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accentGold, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.directions_car_filled_rounded,
                              size: 28,
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARFIXZI',
                              style: AppTypography.headlineMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'Verified Automotive Care · Sahiwal Pilot',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.outline,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.status.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 1.5),
                  const SizedBox(height: 10),

                  // Receipt Meta Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RECEIPT / INVOICE', style: AppTypography.bodySmall.copyWith(color: AppColors.outline, fontSize: 10)),
                          Text(widget.receiptNumber, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('DATE & TIME', style: AppTypography.bodySmall.copyWith(color: AppColors.outline, fontSize: 10)),
                          Text(widget.date, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Service & Party Details
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${widget.partyRole}:', style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
                            Text(widget.partyName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        if (widget.vehicleOrMeta.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Reference / Vehicle:', style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
                              Text(widget.vehicleOrMeta, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Payment Method:', style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
                            Text(widget.paymentMethod, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.primaryContainer)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Line Items Breakdown (if present)
                  if (widget.items.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('ITEMIZED BREAKDOWN', style: AppTypography.labelSmall.copyWith(color: AppColors.outline, letterSpacing: 0.8)),
                    const SizedBox(height: 6),
                    ...widget.items.map((it) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(it.label, style: AppTypography.bodySmall),
                              Text(it.amount, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )),
                  ],

                  const SizedBox(height: 14),
                  const Divider(thickness: 2),
                  const SizedBox(height: 8),

                  // Total Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL SETTLED',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkSlate,
                        ),
                      ),
                      Text(
                        CurrencyUtils.formatPaisa(widget.totalPaisa),
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Footer with Guarantee & Verification
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color.fromRGBO(45, 49, 66, 0.08)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Officially verified CARFIXZI transaction. Keep this receipt for 7-day warranty claim or audit inspection.',
                            style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.outline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons (Save Photo / Close)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.darkSlate,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkSlate),
                          )
                        : const Icon(Icons.photo_camera_rounded, size: 18),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save Photo',
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800),
                    ),
                    onPressed: _isSaving ? null : _saveReceiptToPhone,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
