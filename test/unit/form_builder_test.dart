import 'package:flutter_test/flutter_test.dart';
import 'package:carfixzi/features/partner/presentation/controllers/form_builder_controller.dart';
import 'package:carfixzi/features/partner/domain/entities/form_field_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Workshop Registration Form Builder Tests (Section 4.2A, FR-27, FR-28)', () {
    late FormBuilderController controller;

    setUp(() {
      controller = FormBuilderController();
    });

    test('Initializes with baseline verification fields', () {
      expect(controller.editableFields.length, FormFieldConfig.baselineFields.length);
      final cnicField = controller.editableFields.firstWhere((f) => f.fieldId == 'cnic_front');
      expect(cnicField.required, true);
      expect(cnicField.lockedByPolicy, true);
    });

    test('Admin can add new custom field to schema draft', () {
      final initialCount = controller.editableFields.length;
      controller.addField(
        label: 'Years in Business',
        type: FormFieldType.number,
        required: false,
        helpText: 'Operational history in Sahiwal',
      );

      expect(controller.editableFields.length, initialCount + 1);
      expect(controller.isDraft.value, true);
      final added = controller.editableFields.last;
      expect(added.label, 'Years in Business');
      expect(added.type, FormFieldType.number);
      expect(added.required, false);
      expect(added.lockedByPolicy, false);
    });

    test('Policy-locked baseline fields cannot be made optional by Admin', () {
      final cnicField = controller.editableFields.firstWhere((f) => f.fieldId == 'cnic_front');
      expect(cnicField.required, true);

      // Attempt to toggle required to false
      controller.toggleRequired('cnic_front', false);

      // Field must remain required!
      final refreshed = controller.editableFields.firstWhere((f) => f.fieldId == 'cnic_front');
      expect(refreshed.required, true);
    });

    test('Configurable custom field can toggle Required / Optional', () {
      controller.addField(
        label: 'Emergency Mobile Service',
        type: FormFieldType.checkbox,
        required: true,
      );
      final customField = controller.editableFields.last;

      controller.toggleRequired(customField.fieldId, false);
      final updated = controller.editableFields.firstWhere((f) => f.fieldId == customField.fieldId);
      expect(updated.required, false);
    });

    test('Super Admin soft-retirement retains field with audit reason', () {
      controller.addField(
        label: 'Legacy Fax Number',
        type: FormFieldType.text,
        required: false,
      );
      final field = controller.editableFields.last;

      controller.retireFieldSuperAdminOnly(
        fieldId: field.fieldId,
        reason: 'Fax is deprecated',
        actorUid: 'super_admin_test_uid',
      );

      final retired = controller.editableFields.firstWhere((f) => f.fieldId == field.fieldId);
      expect(retired.active, false);
      expect(retired.retirementReason, 'Fax is deprecated');
      expect(retired.retiredBy, 'super_admin_test_uid');
      expect(retired.retiredAt, isNotNull);
    });

    test('Publishing creates a new immutable numbered version', () async {
      final currentVerNo = controller.currentVersion.value.versionNo;
      await controller.publishNewVersion('admin_uid_123');

      expect(controller.currentVersion.value.versionNo, currentVerNo + 1);
      expect(controller.currentVersion.value.versionId, 'v${currentVerNo + 1}.0');
      expect(controller.isDraft.value, false);
      expect(controller.currentVersion.value.publishedBy, 'admin_uid_123');
    });
  });
}
