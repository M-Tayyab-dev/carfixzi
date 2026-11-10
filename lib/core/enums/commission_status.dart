/// Platform Commission Ledger Status
enum CommissionStatus {
  pending,
  due,
  partially_settled,
  settled;

  String get label {
    switch (this) {
      case CommissionStatus.pending:
        return 'Pending Verification';
      case CommissionStatus.due:
        return 'Commission Due';
      case CommissionStatus.partially_settled:
        return 'Partially Settled';
      case CommissionStatus.settled:
        return 'Settled';
    }
  }

  static CommissionStatus fromString(String? val) {
    return CommissionStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val?.toLowerCase(),
      orElse: () => CommissionStatus.pending,
    );
  }
}

