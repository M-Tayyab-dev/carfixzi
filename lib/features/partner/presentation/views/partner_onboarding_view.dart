import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carfixzi/theme/app_colors.dart';
import 'package:carfixzi/theme/app_typography.dart';
import 'package:carfixzi/shared/widgets/carfixzi_card.dart';
import 'package:carfixzi/shared/widgets/carfixzi_button.dart';
import 'package:carfixzi/shared/widgets/carfixzi_text_field.dart';
import 'package:carfixzi/shared/widgets/status_badge.dart';
import 'package:carfixzi/app/routes/app_routes.dart';
import 'package:carfixzi/features/partner/presentation/controllers/form_builder_controller.dart';
import 'package:carfixzi/features/partner/domain/entities/form_field_config.dart';

/// D18: Dynamic Workshop Registration & Document Verification Form (Partner Android)
/// Complies with Section 4.2 & 4.2A:
/// - Renders active published schema version
/// - Validates mandatory baseline verification media:
///   1. Storefront Photo
///   2. Owner CNIC Front
///   3. Owner CNIC Back
///   4. Current Tax-Year Return Document
/// - Stores answers keyed by stable fieldId with schema version reference
class PartnerOnboardingView extends StatefulWidget {
  const PartnerOnboardingView({super.key});

  @override
  State<PartnerOnboardingView> createState() => _PartnerOnboardingViewState();
}

class _PartnerOnboardingViewState extends State<PartnerOnboardingView> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _uploadedMedia = {}; // fieldId -> mock/signed upload reference
  late FormBuilderController _formCtrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<FormBuilderController>()) {
      _formCtrl = Get.put(FormBuilderController());
    } else {
      _formCtrl = Get.find<FormBuilderController>();
    }

    // Initialize controllers for active fields
    for (var f in _formCtrl.currentVersion.value.activeFields) {
      _controllers[f.fieldId] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _handleMockMediaUpload(String fieldId, String label) {
    // In demo environment, generates a valid synthetic signed media reference
    final syntheticPublicId = 'carfixzi_demo_${fieldId}_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _uploadedMedia[fieldId] = syntheticPublicId;
    });

    Get.snackbar(
      'Document Attached',
      'Synthetic $label attached for verification preview.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      margin: const EdgeInsets.all(16),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate mandatory verification uploads
      final activeFields = _formCtrl.currentVersion.value.activeFields;
      for (var f in activeFields) {
        if (f.type.isProtectedDocument || f.type == FormFieldType.businessPhoto) {
          if (!_uploadedMedia.containsKey(f.fieldId)) {
            Get.snackbar(
              'Required Document Missing',
              'Please attach your ${f.label} before submitting.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
              margin: const EdgeInsets.all(16),
            );
            return;
          }
        }
      }

      setState(() => _isSubmitting = true);

      // Simulate submission of application with active schema version
      Future.delayed(const Duration(milliseconds: 1200), () {
        setState(() => _isSubmitting = false);
        Get.offNamed(AppRoutes.partnerReviewStatus);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeFields = _formCtrl.currentVersion.value.activeFields;
    final schemaVer = _formCtrl.currentVersion.value.versionId;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Workshop Onboarding', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Banner
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const StatusBadge(
                      label: 'STEP 2 OF 2 · VERIFICATION',
                      variant: StatusBadgeVariant.info,
                    ),
                    Text(
                      'Schema $schemaVer',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.outline),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  'Partner Identity & Storefront Submission',
                  style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Submit your official business credentials. Documents are protected and reviewed solely by authorized platform administrators.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 24),

                // Dynamically Rendered Fields based on Active Schema Version
                ...activeFields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildDynamicField(field),
                  );
                }),

                const SizedBox(height: 16),

                // Submit Button
                CarfixziButton(
                  text: 'Submit Application for Review',
                  icon: Icons.send_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicField(FormFieldConfig field) {
    // Media Upload Fields (Storefront Photo, CNIC Front, CNIC Back, Tax Return)
    if (field.type.isProtectedDocument || field.type == FormFieldType.businessPhoto) {
      final isAttached = _uploadedMedia.containsKey(field.fieldId);

      return CarfixziCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  field.type.isProtectedDocument ? Icons.shield_outlined : Icons.storefront_outlined,
                  size: 20,
                  color: AppColors.primaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    field.label,
                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (field.required)
                  Text(
                    '*Required',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.error),
                  ),
              ],
            ),
            if (field.helpText != null) ...[
              const SizedBox(height: 4),
              Text(field.helpText!, style: AppTypography.bodySmall),
            ],
            const SizedBox(height: 12),
            if (isAttached)
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Attached: ${_uploadedMedia[field.fieldId]}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.success),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _handleMockMediaUpload(field.fieldId, field.label),
                    child: const Text('Replace'),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: AppColors.primaryContainer),
                ),
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: Text('Upload Document / Photo'),
                onPressed: () => _handleMockMediaUpload(field.fieldId, field.label),
              ),
          ],
        ),
      );
    }

    // Standard Text / Phone / Multiline / Map inputs
    final controller = _controllers.putIfAbsent(field.fieldId, () => TextEditingController());

    return CarfixziTextField(
      label: '${field.label}${field.required ? ' *' : ''}',
      hint: field.helpText ?? 'Enter ${field.label.toLowerCase()}',
      controller: controller,
      keyboardType: field.type == FormFieldType.phone
          ? TextInputType.phone
          : (field.type == FormFieldType.number ? TextInputType.number : TextInputType.text),
      maxLines: field.type == FormFieldType.multiline ? 3 : 1,
      validator: field.required ? (v) => v == null || v.trim().isEmpty ? '${field.label} is required' : null : null,
    );
  }
}
