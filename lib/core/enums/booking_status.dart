/// Full lifecycle status for workshop visits, mobile mechanics, and wash bookings.
enum BookingStatus {
  requested,
  pending_partner_approval,
  confirmed,
  checked_in,
  assigned,
  on_the_way,
  arrived,
  inspection,
  quote_pending,
  in_progress,
  awaiting_confirmation,
  completed,
  cancelled,
  rejected,
  disputed;

  String get label {
    switch (this) {
      case BookingStatus.requested:
        return 'Requested';
      case BookingStatus.pending_partner_approval:
        return 'Pending Approval';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.checked_in:
        return 'Checked In';
      case BookingStatus.assigned:
        return 'Staff Assigned';
      case BookingStatus.on_the_way:
        return 'On The Way';
      case BookingStatus.arrived:
        return 'Arrived';
      case BookingStatus.inspection:
        return 'Inspection';
      case BookingStatus.quote_pending:
        return 'Quote Pending';
      case BookingStatus.in_progress:
        return 'In Progress';
      case BookingStatus.awaiting_confirmation:
        return 'Awaiting Confirmation';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.rejected:
        return 'Declined';
      case BookingStatus.disputed:
        return 'Disputed';
    }
  }

  static BookingStatus fromString(String? status) {
    return BookingStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status?.toLowerCase(),
      orElse: () => BookingStatus.requested,
    );
  }
}

