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

/// Admin Web: Workshop Registration Form Builder
/// Complies with Section 4.2A:
/// - Create, edit, reorder onboarding fields
/// - Toggle Required / Optional on configurable fields
/// - Policy-locked baseline documents (CNIC, Tax return) cannot be made optional
/// - Admin CANNOT delete or retire fields (Super Admin exclusive)
class AdminFormBuilderView extends StatefulWidget {
  const AdminFormBuilderView({super.key});

  @override
  State<AdminFormBuilderView> createState() => _AdminFormBuilderViewState();
}

class _AdminFormBuilderViewState extends State<AdminFormBuilderView> {
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

  void _showAddFieldDialog() {
    final labelCtrl = TextEditingController();
    final helpCtrl = TextEditingController();
    FormFieldType selectedType = FormFieldType.text;
    bool isRequired = true;

    Get.defaultDialog(
      title: 'Add Registration Field',
      titleStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
      contentPadding: const EdgeInsets.all(20),
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarfixziTextField(
                  label: 'Field Label / Question',
                  hint: 'e.g. Years of Mechanical Operation',
                  controller: labelCtrl,
                ),
                const SizedBox(height: 12),
                Text(
                  'Input Type',
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<FormFieldType>(
                  value: selectedType,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  items: const [
                    DropdownMenuItem(value: FormFieldType.text, child: Text('Short Text Input')),
                    DropdownMenuItem(value: FormFieldType.multiline, child: Text('Long Description')),
                    DropdownMenuItem(value: FormFieldType.number, child: Text('Numeric Value / Count')),
                    DropdownMenuItem(value: FormFieldType.checkbox, child: Text('Checkbox Consent')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 12),
                CarfixziTextField(
                  label: 'Help / Placeholder Text',
                  hint: 'e.g. Total years serving vehicles in Sahiwal',
                  controller: helpCtrl,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mandatory / Required Field', style: AppTypography.labelMedium),
                    Switch(
                      value: isRequired,
                      activeColor: AppColors.primaryContainer,
                      onChanged: (v) => setDialogState(() => isRequired = v),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold, foregroundColor: AppColors.darkSlate),
        onPressed: () {
          if (labelCtrl.text.trim().isNotEmpty) {
            _controller.addField(
              label: labelCtrl.text.trim(),
              type: selectedType,
              required: isRequired,
              helpText: helpCtrl.text.trim().isNotEmpty ? helpCtrl.text.trim() : null,
            );
            Get.back();
          }
        },
        child: const Text('Add to Schema'),
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
            Text('Workshop Form Builder', style: AppTypography.headlineSmall),
            const SizedBox(width: 12),
            Obx(
              () => StatusBadge(
                label: 'Active: ${_controller.currentVersion.value.versionId}',
                variant: StatusBadgeVariant.accent,
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => _controller.isDraft.value
                  ? const StatusBadge(
                      label: 'Unsaved Draft Changes',
                      variant: StatusBadgeVariant.warning,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add Field'),
            onPressed: _showAddFieldDialog,
          ),
          const SizedBox(width: 12),
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
                  : () => _controller.publishNewVersion(authCtrl.user?.uid ?? 'admin_root'),
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
              // Governance Notice Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color.fromRGBO(45, 49, 66, 0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security_rounded, size: 22, color: AppColors.primaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Governance Rule: Baseline verification fields (Business Photo, CNIC Front/Back, Tax Return) are policy-locked. Only Super Admin can retire fields. Published versions are permanently immutable.',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Reorderable Field List
              Obx(() {
                final fields = _controller.editableFields;
                return ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: fields.length,
                  onReorder: _controller.reorderFields,
                  itemBuilder: (context, index) {
                    final field = fields[index];
                    return _FormFieldTile(
                      key: ValueKey(field.fieldId),
                      field: field,
                      onToggleRequired: (val) => _controller.toggleRequired(field.fieldId, val),
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

class _FormFieldTile extends StatelessWidget {
  final FormFieldConfig field;
  final ValueChanged<bool> onToggleRequired;

  const _FormFieldTile({
    super.key,
    required this.field,
    required this.onToggleRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: CarfixziCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.drag_indicator_rounded, color: AppColors.outline),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                field.type.isProtectedDocument ? Icons.shield_rounded : Icons.text_fields_rounded,
                size: 20,
                color: AppColors.primaryContainer,
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
                          label: 'POLICY LOCKED',
                          variant: StatusBadgeVariant.neutral,
                        ),
                    ],
                  ),
                  Text(
                    '${field.type.label} · ID: ${field.fieldId}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                  ),
                  if (field.helpText != null)
                    Text(
                      field.helpText!,
                      style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
            // Required / Optional Switch
            Row(
              children: [
                Text(
                  field.required ? 'Required' : 'Optional',
                  style: AppTypography.labelSmall.copyWith(
                    color: field.required ? AppColors.primary : AppColors.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Switch(
                  value: field.required,
                  activeColor: AppColors.primaryContainer,
                  onChanged: field.lockedByPolicy ? null : onToggleRequired,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
