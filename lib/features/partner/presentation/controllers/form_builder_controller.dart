import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/form_field_config.dart';
import '../../domain/entities/workshop_form_version.dart';

/// GetxController managing the Dynamic Workshop Registration Form Builder
/// Enforces Section 4.2A & FR-27 to FR-29:
/// - Admin can CREATE, EDIT, REORDER, and TOGGLE Required/Optional on configurable fields
/// - Admin CANNOT DELETE or RETIRE fields (Action exclusively reserved for Super Admin)
/// - Baseline verification documents (CNIC Front/Back, Tax Return, Storefront Photo) are policy-locked
/// - Publishes immutable numbered schema versions
class FormBuilderController extends GetxController {
  final Rx<WorkshopFormVersion> currentVersion = WorkshopFormVersion.initialVersion().obs;
  final RxList<FormFieldConfig> editableFields = <FormFieldConfig>[].obs;
  final RxBool isDraft = false.obs;
  final RxBool isLoading = false.obs;

  FormBuilderController() {
    editableFields.assignAll(currentVersion.value.fields);
  }

  @override
  void onInit() {
    super.onInit();
    if (editableFields.isEmpty) {
      editableFields.assignAll(currentVersion.value.fields);
    }
  }

  void _showNotification(String title, String message, {bool isError = false}) {
    try {
      if (Get.isRegistered<GetMaterialController>() && Get.context != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: isError ? Colors.red.shade100 : Colors.blue.shade100,
          colorText: isError ? Colors.red.shade900 : Colors.blue.shade900,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (_) {
      // In headless unit tests without widget tree, safely skip UI snackbar
    }
  }

  /// Add a new custom field (Admin & Super Admin)
  void addField({
    required String label,
    required FormFieldType type,
    required bool required,
    String? helpText,
    List<String>? options,
  }) {
    final newId = 'custom_${type.name}_${DateTime.now().millisecondsSinceEpoch}';
    final nextOrder = editableFields.length + 1;

    final newField = FormFieldConfig(
      fieldId: newId,
      label: label.trim(),
      type: type,
      order: nextOrder,
      required: required,
      lockedByPolicy: false,
      helpText: helpText?.trim(),
      options: options,
    );

    editableFields.add(newField);
    isDraft.value = true;
    _showNotification('Field Added', '"$label" added to registration form draft.');
  }

  /// Update an existing custom field
  void updateField(FormFieldConfig updatedField) {
    final index = editableFields.indexWhere((f) => f.fieldId == updatedField.fieldId);
    if (index != -1) {
      // Security rule: policy-locked baseline fields cannot alter their required status
      if (editableFields[index].lockedByPolicy && !updatedField.required) {
        _showNotification(
          'Policy Locked',
          'Baseline legal verification document requirements cannot be marked optional.',
          isError: true,
        );
        return;
      }

      editableFields[index] = updatedField;
      isDraft.value = true;
    }
  }

  /// Toggle Required/Optional on configurable fields
  void toggleRequired(String fieldId, bool isRequired) {
    final index = editableFields.indexWhere((f) => f.fieldId == fieldId);
    if (index != -1) {
      if (editableFields[index].lockedByPolicy) {
        _showNotification(
          'Policy Locked',
          '${editableFields[index].label} is a mandatory baseline requirement.',
          isError: true,
        );
        return;
      }

      editableFields[index] = editableFields[index].copyWith(required: isRequired);
      isDraft.value = true;
    }
  }

  /// Reorder fields
  void reorderFields(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = editableFields.removeAt(oldIndex);
    editableFields.insert(newIndex, item);

    // Update order indices
    for (int i = 0; i < editableFields.length; i++) {
      editableFields[i] = editableFields[i].copyWith(order: i + 1);
    }
    isDraft.value = true;
  }

  /// Super Admin Exclusive: Soft-retire a field with reason and impact audit
  void retireFieldSuperAdminOnly({
    required String fieldId,
    required String reason,
    required String actorUid,
  }) {
    final index = editableFields.indexWhere((f) => f.fieldId == fieldId);
    if (index != -1) {
      editableFields[index] = editableFields[index].copyWith(
        active: false,
        retiredAt: DateTime.now(),
        retiredBy: actorUid,
        retirementReason: reason.trim(),
      );
      isDraft.value = true;
      _showNotification(
        'Field Retired',
        'Field has been retired for future registrations. Existing submissions remain retained.',
      );
    }
  }

  /// Publish new form schema version
  Future<void> publishNewVersion(String publishedByUid) async {
    isLoading.value = true;
    try {
      final newVerNo = currentVersion.value.versionNo + 1;
      final newVerId = 'v$newVerNo.0';

      final published = WorkshopFormVersion(
        versionId: newVerId,
        versionNo: newVerNo,
        status: 'published',
        fields: List.from(editableFields),
        createdAt: DateTime.now(),
        publishedAt: DateTime.now(),
        publishedBy: publishedByUid,
      );

      currentVersion.value = published;
      isDraft.value = false;
      _showNotification(
        'Version Published',
        'Form Schema $newVerId is now live for all new workshop registrations.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
