/// Payment status - Explicit separation of Cash and Demo transactions
enum PaymentStatus {
  unpaid,
  cash_declared,
  cash_verified,
  demo_simulated,
  disputed;

  String get label {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Unpaid';
      case PaymentStatus.cash_declared:
        return 'Cash Collected (Pending Customer Confirmation)';
      case PaymentStatus.cash_verified:
        return 'Cash Payment Verified';
      case PaymentStatus.demo_simulated:
        return 'Demo Mode (Simulated Payment)';
      case PaymentStatus.disputed:
        return 'Payment Disputed';
    }
  }

  static PaymentStatus fromString(String? val) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val?.toLowerCase(),
      orElse: () => PaymentStatus.unpaid,
    );
  }
}

