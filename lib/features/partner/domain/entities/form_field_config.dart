/// Supported dynamic field types for the workshop onboarding form builder
enum FormFieldType {
  text,
  multiline,
  phone,
  email,
  number,
  dropdown,
  checkbox,
  businessPhoto,
  cnicFront,
  cnicBack,
  taxReturn,
  addressMap;

  String get label {
    switch (this) {
      case FormFieldType.text:
        return 'Short Text';
      case FormFieldType.multiline:
        return 'Long Description';
      case FormFieldType.phone:
        return 'Contact Phone';
      case FormFieldType.email:
        return 'Business Email';
      case FormFieldType.number:
        return 'Number / Capacity';
      case FormFieldType.dropdown:
        return 'Dropdown Select';
      case FormFieldType.checkbox:
        return 'Checkbox Confirmation';
      case FormFieldType.businessPhoto:
        return 'Business Storefront Photo';
      case FormFieldType.cnicFront:
        return 'Owner CNIC (Front)';
      case FormFieldType.cnicBack:
        return 'Owner CNIC (Back)';
      case FormFieldType.taxReturn:
        return 'Current Tax-Year Return';
      case FormFieldType.addressMap:
        return 'Shop Address & Map Pin';
    }
  }

  bool get isProtectedDocument =>
      this == FormFieldType.cnicFront ||
      this == FormFieldType.cnicBack ||
      this == FormFieldType.taxReturn;
}

/// Dynamic Field Definition configured by Admin / Super Admin
class FormFieldConfig {
  final String fieldId;
  final String label;
  final FormFieldType type;
  final int order;
  final bool required;
  final bool active;
  final bool lockedByPolicy; // Mandatory legal verification uploads cannot be unlocked by Admin
  final String? helpText;
  final List<String>? options;
  final DateTime? retiredAt;
  final String? retiredBy;
  final String? retirementReason;

  const FormFieldConfig({
    required this.fieldId,
    required this.label,
    required this.type,
    required this.order,
    this.required = true,
    this.active = true,
    this.lockedByPolicy = false,
    this.helpText,
    this.options,
    this.retiredAt,
    this.retiredBy,
    this.retirementReason,
  });

  FormFieldConfig copyWith({
    String? fieldId,
    String? label,
    FormFieldType? type,
    int? order,
    bool? required,
    bool? active,
    bool? lockedByPolicy,
    String? helpText,
    List<String>? options,
    DateTime? retiredAt,
    String? retiredBy,
    String? retirementReason,
  }) {
    return FormFieldConfig(
      fieldId: fieldId ?? this.fieldId,
      label: label ?? this.label,
      type: type ?? this.type,
      order: order ?? this.order,
      required: required ?? this.required,
      active: active ?? this.active,
      lockedByPolicy: lockedByPolicy ?? this.lockedByPolicy,
      helpText: helpText ?? this.helpText,
      options: options ?? this.options,
      retiredAt: retiredAt ?? this.retiredAt,
      retiredBy: retiredBy ?? this.retiredBy,
      retirementReason: retirementReason ?? this.retirementReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fieldId': fieldId,
      'label': label,
      'type': type.name,
      'order': order,
      'required': required,
      'active': active,
      'lockedByPolicy': lockedByPolicy,
      'helpText': helpText,
      'options': options,
      'retiredAt': retiredAt?.toIso8601String(),
      'retiredBy': retiredBy,
      'retirementReason': retirementReason,
    };
  }

  static FormFieldConfig fromMap(Map<String, dynamic> map) {
    return FormFieldConfig(
      fieldId: map['fieldId'] ?? '',
      label: map['label'] ?? '',
      type: FormFieldType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => FormFieldType.text,
      ),
      order: map['order'] ?? 0,
      required: map['required'] ?? true,
      active: map['active'] ?? true,
      lockedByPolicy: map['lockedByPolicy'] ?? false,
      helpText: map['helpText'],
      options: (map['options'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      retiredAt: map['retiredAt'] != null ? DateTime.tryParse(map['retiredAt']) : null,
      retiredBy: map['retiredBy'],
      retirementReason: map['retirementReason'],
    );
  }

  /// Default Baseline Legal Verification Fields (Locked by Policy)
  static List<FormFieldConfig> get baselineFields => [
        const FormFieldConfig(
          fieldId: 'business_name',
          label: 'Registered Business Name',
          type: FormFieldType.text,
          order: 1,
          required: true,
          lockedByPolicy: true,
          helpText: 'Official legal trade name of your workshop or detailing service',
        ),
        const FormFieldConfig(
          fieldId: 'business_address',
          label: 'Storefront Address & City Area',
          type: FormFieldType.addressMap,
          order: 2,
          required: true,
          lockedByPolicy: true,
          helpText: 'Complete physical street address in pilot city (Sahiwal)',
        ),
        const FormFieldConfig(
          fieldId: 'contact_phone',
          label: 'Business Contact Mobile',
          type: FormFieldType.phone,
          order: 3,
          required: true,
          lockedByPolicy: true,
          helpText: 'Active Pakistani contact number (Unverified, contact only)',
        ),
        const FormFieldConfig(
          fieldId: 'business_photo',
          label: 'Workshop Storefront Photograph',
          type: FormFieldType.businessPhoto,
          order: 4,
          required: true,
          lockedByPolicy: true,
          helpText: 'Clear exterior image showing workshop signage and entrance',
        ),
        const FormFieldConfig(
          fieldId: 'cnic_front',
          label: 'Owner CNIC (Front Side)',
          type: FormFieldType.cnicFront,
          order: 5,
          required: true,
          lockedByPolicy: true,
          helpText: 'Government CNIC card front (Protected delivery, synthetic for demo)',
        ),
        const FormFieldConfig(
          fieldId: 'cnic_back',
          label: 'Owner CNIC (Back Side)',
          type: FormFieldType.cnicBack,
          order: 6,
          required: true,
          lockedByPolicy: true,
          helpText: 'Government CNIC card back with permanent address',
        ),
        const FormFieldConfig(
          fieldId: 'tax_return',
          label: 'Current Tax-Year Return Document',
          type: FormFieldType.taxReturn,
          order: 7,
          required: true,
          lockedByPolicy: true,
          helpText: 'FBR active taxpayer verification or current tax return acknowledgment',
        ),
      ];
}
