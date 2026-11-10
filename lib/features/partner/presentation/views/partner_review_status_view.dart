import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/enums/application_status.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Partner Onboarding Review Status Screen (Android Mobile)
/// Displays the verification state machine:
/// - draft -> pending_review -> approved | rejected | changes_required
class PartnerReviewStatusView extends StatefulWidget {
  const PartnerReviewStatusView({super.key});

  @override
  State<PartnerReviewStatusView> createState() => _PartnerReviewStatusViewState();
}

class _PartnerReviewStatusViewState extends State<PartnerReviewStatusView> {
  // Demo interactive state toggle to simulate Admin review decision
  ApplicationStatus _status = ApplicationStatus.pending_review;

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Application Status', style: AppTypography.headlineSmall),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => authCtrl.signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Icon Badge
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _getStatusBgColor(),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(_getStatusIcon(), size: 50, color: _getStatusColor()),
                ),
              ),
              const SizedBox(height: 24),

              StatusBadge(
                label: _status.label,
                variant: _getBadgeVariant(),
              ),
              const SizedBox(height: 16),

              Text(
                _getStatusTitle(),
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              Text(
                _getStatusDescription(),
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 36),

              // Action Buttons based on Status
              if (_status == ApplicationStatus.approved)
                CarfixziButton(
                  text: 'Enter Partner Dashboard',
                  icon: Icons.dashboard_rounded,
                  onPressed: () => Get.offAllNamed(AppRoutes.partnerDashboard),
                )
              else if (_status == ApplicationStatus.changes_required)
                CarfixziButton(
                  text: 'Edit & Resubmit Documents',
                  icon: Icons.edit_note_rounded,
                  onPressed: () => Get.toNamed(AppRoutes.partnerOnboarding),
                )
              else
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppColors.primaryContainer),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Refresh Status'),
                  onPressed: () {
                    Get.snackbar(
                      'Status Checked',
                      'Application remains under review by platform admin.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              const SizedBox(height: 40),

              // Demonstration State Switcher (for FYP demo evaluation)
              CarfixziCard(
                child: Column(
                  children: [
                    Text(
                      'FYP DEMO EVALUATION SWITCHER',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.outline,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Pending'),
                          selected: _status == ApplicationStatus.pending_review,
                          onSelected: (_) => setState(() => _status = ApplicationStatus.pending_review),
                        ),
                        ChoiceChip(
                          label: const Text('Approved'),
                          selected: _status == ApplicationStatus.approved,
                          onSelected: (_) => setState(() => _status = ApplicationStatus.approved),
                        ),
                        ChoiceChip(
                          label: const Text('Changes Req.'),
                          selected: _status == ApplicationStatus.changes_required,
                          onSelected: (_) => setState(() => _status = ApplicationStatus.changes_required),
                        ),
                        ChoiceChip(
                          label: const Text('Rejected'),
                          selected: _status == ApplicationStatus.rejected,
                          onSelected: (_) => setState(() => _status = ApplicationStatus.rejected),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusBgColor() {
    switch (_status) {
      case ApplicationStatus.approved:
        return AppColors.successContainer;
      case ApplicationStatus.changes_required:
      case ApplicationStatus.pending_review:
        return AppColors.warningContainer;
      case ApplicationStatus.rejected:
      case ApplicationStatus.suspended:
        return AppColors.errorContainer;
      default:
        return AppColors.surfaceContainerHigh;
    }
  }

  Color _getStatusColor() {
    switch (_status) {
      case ApplicationStatus.approved:
        return AppColors.success;
      case ApplicationStatus.changes_required:
      case ApplicationStatus.pending_review:
        return AppColors.warning;
      case ApplicationStatus.rejected:
      case ApplicationStatus.suspended:
        return AppColors.error;
      default:
        return AppColors.primaryContainer;
    }
  }

  IconData _getStatusIcon() {
    switch (_status) {
      case ApplicationStatus.approved:
        return Icons.verified_user_rounded;
      case ApplicationStatus.changes_required:
        return Icons.assignment_late_rounded;
      case ApplicationStatus.rejected:
      case ApplicationStatus.suspended:
        return Icons.cancel_rounded;
      case ApplicationStatus.pending_review:
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  StatusBadgeVariant _getBadgeVariant() {
    switch (_status) {
      case ApplicationStatus.approved:
        return StatusBadgeVariant.success;
      case ApplicationStatus.changes_required:
      case ApplicationStatus.pending_review:
        return StatusBadgeVariant.warning;
      case ApplicationStatus.rejected:
      case ApplicationStatus.suspended:
        return StatusBadgeVariant.error;
      default:
        return StatusBadgeVariant.info;
    }
  }

  String _getStatusTitle() {
    switch (_status) {
      case ApplicationStatus.approved:
        return 'Workshop Approved & Published';
      case ApplicationStatus.changes_required:
        return 'Corrections Requested';
      case ApplicationStatus.rejected:
        return 'Application Declined';
      case ApplicationStatus.pending_review:
      default:
        return 'Verification Under Review';
    }
  }

  String _getStatusDescription() {
    switch (_status) {
      case ApplicationStatus.approved:
        return 'Congratulations! Your workshop profile is now discoverable on the Sahiwal map and ready to accept bookings.';
      case ApplicationStatus.changes_required:
        return 'Admin Review Note: "Please re-upload a clearer image of your storefront signage and recent tax acknowledgement."';
      case ApplicationStatus.rejected:
        return 'Your application could not be verified under the pilot program criteria.';
      case ApplicationStatus.pending_review:
      default:
        return 'Our regional administrators in Sahiwal are reviewing your legal credentials and storefront images. You will receive an in-app notice once approved.';
    }
  }
}
