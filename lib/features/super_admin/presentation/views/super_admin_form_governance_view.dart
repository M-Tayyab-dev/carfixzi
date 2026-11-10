import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carfixzi/theme/app_colors.dart';
import 'package:carfixzi/theme/app_typography.dart';
import 'package:carfixzi/shared/widgets/carfixzi_card.dart';
import 'package:carfixzi/shared/widgets/status_badge.dart';
import 'package:carfixzi/shared/widgets/carfixzi_text_field.dart';
import 'package:carfixzi/features/partner/domain/entities/form_field_config.dart';
import 'package:carfixzi/features/partner/presentation/controllers/form_builder_controller.dart';
import 'package:carfixzi/features/auth/presentation/controllers/auth_controller.dart';

/// Super Admin Exclusive: Workshop Form Field Retirement & Governance
/// Complies with Section 4.2A, FR-28 & FR-29:
/// - Exclusive Field Retirement & Restoration capabilities
/// - Mandatory typed confirmation and explicit audit reason
/// - Logical soft-retirement preserves historical submissions and protected media
class SuperAdminFormGovernanceView extends StatefulWidget {
  const SuperAdminFormGovernanceView({super.key});

  @override
  State<SuperAdminFormGovernanceView> createState() => _SuperAdminFormGovernanceViewState();
}

class _SuperAdminFormGovernanceViewState extends State<SuperAdminFormGovernanceView> {
  late FormBuilderController _controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<FormBuilderController>()) {
      _controller = Get.put(FormBuilderController());
    } else {
      _controller = Get.find<FormBuilderController>();
    }
  }

  void _showRetireFieldDialog(FormFieldConfig field) {
    final reasonCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    Get.defaultDialog(
      title: 'Retire Field: ${field.label}',
      titleStyle: AppTypography.headlineSmall.copyWith(
        color: AppColors.error,
        fontWeight: FontWeight.w700,
      ),
      contentPadding: const EdgeInsets.all(20),
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Impact Notice: This field will be removed from all FUTURE workshop onboarding forms. Historical partner submissions and uploaded documents will remain preserved in the audit database.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 16),
                CarfixziTextField(
                  label: 'Retirement Audit Reason',
                  hint: 'e.g. Replaced by commercial tax certificate check',
                  controller: reasonCtrl,
                ),
                const SizedBox(height: 12),
                CarfixziTextField(
                  label: 'Type "RETIRE" to confirm',
                  hint: 'RETIRE',
                  controller: confirmCtrl,
                ),
              ],
            ),
          );
        },
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          if (confirmCtrl.text.trim() == 'RETIRE' && reasonCtrl.text.trim().isNotEmpty) {
            final authCtrl = Get.find<AuthController>();
            _controller.retireFieldSuperAdminOnly(
              fieldId: field.fieldId,
              reason: reasonCtrl.text.trim(),
              actorUid: authCtrl.user?.uid ?? 'super_admin',
            );
            Get.back();
          } else {
            Get.snackbar(
              'Confirmation Failed',
              'You must type "RETIRE" and provide an explicit audit reason.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
              margin: const EdgeInsets.all(16),
            );
          }
        },
        child: const Text('Confirm Soft-Retire'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'SUPER ADMIN ROOT',
                style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Text('Form Schema Governance & Retirement', style: AppTypography.headlineSmall),
          ],
        ),
        actions: [
          Obx(
            () => ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: AppColors.darkSlate,
              ),
              icon: const Icon(Icons.publish_rounded, size: 20),
              label: Text(_controller.isLoading.value ? 'Publishing...' : 'Publish Schema'),
              onPressed: _controller.isLoading.value
                  ? null
                  : () => _controller.publishNewVersion(authCtrl.user?.uid ?? 'super_admin_root'),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active & Configured Registration Fields',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              Obx(() {
                final fields = _controller.editableFields;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: fields.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final field = fields[index];
                    return CarfixziCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: field.active ? AppColors.surfaceContainerHigh : AppColors.errorContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              field.active ? Icons.check_circle_outline_rounded : Icons.block_rounded,
                              size: 20,
                              color: field.active ? AppColors.primaryContainer : AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      field.label,
                                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(width: 8),
                                    if (field.lockedByPolicy)
                                      const StatusBadge(
                                        label: 'BASELINE PROTECTED',
                                        variant: StatusBadgeVariant.neutral,
                                      ),
                                    if (!field.active)
                                      const StatusBadge(
                                        label: 'RETIRED',
                                        variant: StatusBadgeVariant.error,
                                      ),
                                  ],
                                ),
                                Text(
                                  '${field.type.label} · ID: ${field.fieldId}',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                                ),
                                if (field.retirementReason != null)
                                  Text(
                                    'Reason: ${field.retirementReason}',
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                                  ),
                              ],
                            ),
                          ),
                          // Super Admin Exclusive Retire Action
                          if (field.active && !field.lockedByPolicy)
                            TextButton.icon(
                              style: TextButton.styleFrom(foregroundColor: AppColors.error),
                              icon: const Icon(Icons.delete_outline_rounded, size: 18),
                              label: const Text('Retire Field'),
                              onPressed: () => _showRetireFieldDialog(field),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
