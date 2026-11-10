import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/status_badge.dart';

/// D25: Partner Application Verification Queue (Admin Responsive Web)
/// Regional admin workflow to review baseline legal documents & record physical inspections.
class AdminVerificationsView extends StatefulWidget {
  const AdminVerificationsView({super.key});

  @override
  State<AdminVerificationsView> createState() => _AdminVerificationsViewState();
}

class _AdminVerificationsViewState extends State<AdminVerificationsView> {
  final List<_ApplicationItem> _applications = [
    _ApplicationItem(
      id: 'app_001',
      workshopName: 'Al-Madina Precision Motors',
      ownerName: 'Muhammad Tariq',
      ownerPhone: '+92 300 1234567',
      address: 'Main Multan Road, Sahiwal',
      submittedDate: '09 Nov 2026',
      bayCount: 3,
      hasCnicFront: true,
      hasCnicBack: true,
      hasBusinessPhoto: true,
      hasTaxReturn: true,
      status: 'Pending Inspection',
    ),
    _ApplicationItem(
      id: 'app_002',
      workshopName: 'Speedy Auto Electrics & AC',
      ownerName: 'Imran Ashraf',
      ownerPhone: '+92 333 9876543',
      address: 'Circular Road, Near High School, Sahiwal',
      submittedDate: '08 Nov 2026',
      bayCount: 2,
      hasCnicFront: true,
      hasCnicBack: true,
      hasBusinessPhoto: true,
      hasTaxReturn: false, // Incomplete document
      status: 'Documents Incomplete',
    ),
    _ApplicationItem(
      id: 'app_003',
      workshopName: 'Apex GT Motorwerks',
      ownerName: 'Farhan Zaidi',
      ownerPhone: '+92 321 5551234',
      address: 'High Street, Commercial Zone, Sahiwal',
      submittedDate: '01 Nov 2026',
      bayCount: 4,
      hasCnicFront: true,
      hasCnicBack: true,
      hasBusinessPhoto: true,
      hasTaxReturn: true,
      status: 'Approved',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Partner Verification Queue', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _applications.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final app = _applications[index];
            return _ApplicationCard(
              app: app,
              onReview: () => _showReviewDialog(app),
            );
          },
        ),
      ),
    );
  }

  void _showReviewDialog(_ApplicationItem app) {
    final noteCtrl = TextEditingController();

    Get.defaultDialog(
      title: 'Review: ${app.workshopName}',
      titleStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
      contentPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner: ${app.ownerName} · ${app.ownerPhone}', style: AppTypography.labelLarge),
            Text('Address: ${app.address}', style: AppTypography.bodySmall),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            Text('Mandatory Legal Documents:', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            _DocCheck(label: 'Workshop Front Photo', isVerified: app.hasBusinessPhoto),
            _DocCheck(label: 'Owner CNIC (Front)', isVerified: app.hasCnicFront),
            _DocCheck(label: 'Owner CNIC (Back)', isVerified: app.hasCnicBack),
            _DocCheck(label: 'FBR Tax Return / NTN', isVerified: app.hasTaxReturn),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(
                labelText: 'Inspection Notes / Justification',
                hintText: 'e.g. Physical site inspection completed. 3 active bays verified.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          setState(() => app.status = 'Approved');
          Get.back();
          Get.snackbar(
            'Partner Approved',
            '${app.workshopName} has been approved and activated in Sahiwal directory.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successContainer,
            colorText: AppColors.success,
          );
        },
        child: const Text('Approve & Activate'),
      ),
      cancel: TextButton(
        style: TextButton.styleFrom(foregroundColor: AppColors.error),
        onPressed: () {
          setState(() => app.status = 'Rejected');
          Get.back();
          Get.snackbar(
            'Application Rejected',
            '${app.workshopName} marked as rejected.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: const Text('Reject Application'),
      ),
    );
  }
}

class _ApplicationItem {
  final String id;
  final String workshopName;
  final String ownerName;
  final String ownerPhone;
  final String address;
  final String submittedDate;
  final int bayCount;
  final bool hasCnicFront;
  final bool hasCnicBack;
  final bool hasBusinessPhoto;
  final bool hasTaxReturn;
  String status;

  _ApplicationItem({
    required this.id,
    required this.workshopName,
    required this.ownerName,
    required this.ownerPhone,
    required this.address,
    required this.submittedDate,
    required this.bayCount,
    required this.hasCnicFront,
    required this.hasCnicBack,
    required this.hasBusinessPhoto,
    required this.hasTaxReturn,
    required this.status,
  });
}

class _ApplicationCard extends StatelessWidget {
  final _ApplicationItem app;
  final VoidCallback onReview;

  const _ApplicationCard({required this.app, required this.onReview});

  @override
  Widget build(BuildContext context) {
    final isApproved = app.status == 'Approved';

    return CarfixziCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                app.id.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(color: AppColors.outline),
              ),
              StatusBadge(
                label: app.status,
                variant: isApproved
                    ? StatusBadgeVariant.success
                    : app.status == 'Rejected'
                        ? StatusBadgeVariant.error
                        : StatusBadgeVariant.warning,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(app.workshopName, style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
          Text('${app.ownerName} · ${app.address}', style: AppTypography.bodySmall),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Submitted: ${app.submittedDate}', style: AppTypography.bodySmall.copyWith(color: AppColors.outline, fontSize: 11)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 34),
                ),
                icon: const Icon(Icons.assignment_turned_in_rounded, size: 16),
                label: const Text('Review Application'),
                onPressed: onReview,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocCheck extends StatelessWidget {
  final String label;
  final bool isVerified;

  const _DocCheck({required this.label, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: isVerified ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isVerified ? AppColors.darkSlate : AppColors.error,
              fontWeight: isVerified ? FontWeight.w500 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
