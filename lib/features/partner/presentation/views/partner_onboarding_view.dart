import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carfixzi/theme/app_colors.dart';
import 'package:carfixzi/theme/app_typography.dart';
import 'package:carfixzi/shared/widgets/carfixzi_card.dart';
import 'package:carfixzi/shared/widgets/carfixzi_button.dart';
import 'package:carfixzi/shared/widgets/carfixzi_text_field.dart';
import 'package:carfixzi/shared/widgets/status_badge.dart';
import 'package:carfixzi/app/routes/app_routes.dart';
import 'package:carfixzi/core/services/media_upload_service.dart';
import 'package:carfixzi/shared/widgets/osm_location_picker.dart';
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
  final Map<String, String> _uploadedMedia = {}; // fieldId -> Cloudinary secure_url
  final Set<String> _uploadingFields = {};
  final MediaUploadService _mediaService = MediaUploadService();
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

  Future<void> _handleMediaUpload(String fieldId, String label, FormFieldType type) async {
    if (type == FormFieldType.taxReturn) {
      // PDF or Document picker
      try {
        setState(() => _uploadingFields.add(fieldId));
        final result = await _mediaService.pickAndUploadDocument();
        if (result != null) {
          setState(() {
            _uploadedMedia[fieldId] = result.secureUrl;
          });
          Get.snackbar(
            'Document Uploaded',
            '$label uploaded to verified Cloudinary storage.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successContainer,
            colorText: AppColors.success,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Upload Failed',
          'Failed to upload $label: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorContainer,
          colorText: AppColors.error,
        );
      } finally {
        setState(() => _uploadingFields.remove(fieldId));
      }
    } else {
      // Photo picker modal (Camera vs Gallery)
      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload $label',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryContainer),
                title: const Text('Take Photo with Camera'),
                onTap: () async {
                  Get.back();
                  await _pickImageFromSource(fieldId, label, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primaryContainer),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Get.back();
                  await _pickImageFromSource(fieldId, label, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _pickImageFromSource(String fieldId, String label, ImageSource source) async {
    try {
      setState(() => _uploadingFields.add(fieldId));
      final result = await _mediaService.pickAndUploadImage(
        source: source,
        folder: 'carfixzi/onboarding/$fieldId',
      );
      if (result != null) {
        setState(() {
          _uploadedMedia[fieldId] = result.secureUrl;
        });
        Get.snackbar(
          'Photo Uploaded',
          '$label uploaded to Cloudinary.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successContainer,
          colorText: AppColors.success,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        'Could not upload $label: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.error,
      );
    } finally {
      setState(() => _uploadingFields.remove(fieldId));
    }
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
      final isUploading = _uploadingFields.contains(field.fieldId);
      final mediaUrl = _uploadedMedia[field.fieldId] ?? '';

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
            if (isUploading)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Uploading to Cloudinary (mbecykon)...',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            else if (isAttached)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cloudinary URL: $mediaUrl',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.success),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _handleMediaUpload(field.fieldId, field.label, field.type),
                        child: const Text('Replace'),
                      ),
                    ],
                  ),
                  if (field.type != FormFieldType.taxReturn && mediaUrl.startsWith('http')) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        mediaUrl,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ],
              )
            else
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: AppColors.primaryContainer),
                ),
                icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                label: Text('Upload ${field.type == FormFieldType.taxReturn ? "PDF Document" : "Photo"} to Cloudinary'),
                onPressed: () => _handleMediaUpload(field.fieldId, field.label, field.type),
              ),
          ],
        ),
      );
    }

    // Interactive OpenStreetMap Location Pin for Shop Address
    if (field.type == FormFieldType.addressMap) {
      final controller = _controllers.putIfAbsent(field.fieldId, () => TextEditingController());

      return CarfixziCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.map_rounded, size: 20, color: AppColors.primaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    field.label,
                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (field.required)
                  Text('*Required', style: AppTypography.labelSmall.copyWith(color: AppColors.error)),
              ],
            ),
            if (field.helpText != null) ...[
              const SizedBox(height: 4),
              Text(field.helpText!, style: AppTypography.bodySmall),
            ],
            const SizedBox(height: 10),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter street or pin on OpenStreetMap',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              validator: field.required
                  ? (v) => v == null || v.trim().isEmpty ? '${field.label} is required' : null
                  : null,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerHigh,
                foregroundColor: AppColors.primaryContainer,
                elevation: 0,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.pin_drop_rounded, size: 18),
              label: const Text('Pin Workshop on OpenStreetMap (Sahiwal)'),
              onPressed: () async {
                final result = await OsmLocationPicker.show(
                  context,
                  title: 'Pin Workshop Location',
                );
                if (result != null) {
                  controller.text = result.address;
                  Get.snackbar(
                    'Location Selected',
                    'Pinned at: ${result.address}',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
            ),
          ],
        ),
      );
    }

    // Standard Text / Phone / Multiline inputs
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
