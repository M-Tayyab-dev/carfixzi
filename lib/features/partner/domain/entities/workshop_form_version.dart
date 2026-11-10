import 'form_field_config.dart';

/// Form Version Snapshot model ensuring immutable schema versions
class WorkshopFormVersion {
  final String versionId;
  final int versionNo;
  final String status; // 'draft', 'published', 'superseded'
  final List<FormFieldConfig> fields;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String? publishedBy;
  final String? schemaHash;

  const WorkshopFormVersion({
    required this.versionId,
    required this.versionNo,
    required this.status,
    required this.fields,
    required this.createdAt,
    this.publishedAt,
    this.publishedBy,
    this.schemaHash,
  });

  /// Get only active (non-retired) fields for partner onboarding
  List<FormFieldConfig> get activeFields =>
      fields.where((f) => f.active).toList()..sort((a, b) => a.order.compareTo(b.order));

  Map<String, dynamic> toMap() {
    return {
      'versionId': versionId,
      'versionNo': versionNo,
      'status': status,
      'fields': fields.map((f) => f.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'publishedBy': publishedBy,
      'schemaHash': schemaHash,
    };
  }

  static WorkshopFormVersion fromMap(Map<String, dynamic> map) {
    return WorkshopFormVersion(
      versionId: map['versionId'] ?? '',
      versionNo: map['versionNo'] ?? 1,
      status: map['status'] ?? 'draft',
      fields: (map['fields'] as List<dynamic>?)
              ?.map((f) => FormFieldConfig.fromMap(f as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      publishedAt: map['publishedAt'] != null ? DateTime.tryParse(map['publishedAt']) : null,
      publishedBy: map['publishedBy'],
      schemaHash: map['schemaHash'],
    );
  }

  /// Initial Baseline Form Version 1.0
  static WorkshopFormVersion initialVersion() {
    return WorkshopFormVersion(
      versionId: 'v1.0',
      versionNo: 1,
      status: 'published',
      fields: FormFieldConfig.baselineFields,
      createdAt: DateTime.now(),
      publishedAt: DateTime.now(),
      publishedBy: 'system_bootstrap',
    );
  }
}

