/// Parts Order Fulfilment Status
enum OrderStatus {
  placed,
  confirmed,
  packing,
  out_for_delivery,
  ready_for_pickup,
  fulfilled,
  cancelled,
  returned;

  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.packing:
        return 'Preparing Items';
      case OrderStatus.out_for_delivery:
        return 'Out For Delivery';
      case OrderStatus.ready_for_pickup:
        return 'Ready For Pickup';
      case OrderStatus.fulfilled:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  static OrderStatus fromString(String? val) {
    return OrderStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val?.toLowerCase(),
      orElse: () => OrderStatus.placed,
    );
  }
}

