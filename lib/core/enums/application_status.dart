/// Partner Onboarding Application Status
enum ApplicationStatus {
  draft,
  pending_review,
  approved,
  rejected,
  changes_required,
  suspended;

  String get label {
    switch (this) {
      case ApplicationStatus.draft:
        return 'Draft';
      case ApplicationStatus.pending_review:
        return 'Pending Verification';
      case ApplicationStatus.approved:
        return 'Verified & Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.changes_required:
        return 'Changes Required';
      case ApplicationStatus.suspended:
        return 'Suspended';
    }
  }

  static ApplicationStatus fromString(String? val) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val?.toLowerCase(),
      orElse: () => ApplicationStatus.draft,
    );
  }
}

