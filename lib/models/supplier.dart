// US-021, US-022, US-023, US-024, US-025, US-026, US-027

enum MovementType {
  stockIn,
  stockOut,
  transfer,
  adjustment,
}

enum PurchaseOrderStatus {
  pending,
  received,
  cancelled,
}

class Supplier {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String categorySupplied;

  Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.categorySupplied,
  });
}

class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final MovementType type;
  final int quantity;
  final int remainingStock;
  final String reason;
  final DateTime timestamp;
  final String operator;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.remainingStock,
    required this.reason,
    required this.timestamp,
    required this.operator,
  });

  String get typeLabel {
    switch (type) {
      case MovementType.stockIn:
        return 'Stock In (+)';
      case MovementType.stockOut:
        return 'Stock Out (-)';
      case MovementType.transfer:
        return 'Transfer (⇆)';
      case MovementType.adjustment:
        return 'Adjustment (±)';
    }
  }
}

class PurchaseOrder {
  final String poNumber;
  final String supplierName;
  final DateTime orderDate;
  final DateTime expectedDelivery;
  final List<POLineItem> items;
  final double totalCost;
  PurchaseOrderStatus status;

  PurchaseOrder({
    required this.poNumber,
    required this.supplierName,
    required this.orderDate,
    required this.expectedDelivery,
    required this.items,
    required this.totalCost,
    this.status = PurchaseOrderStatus.pending,
  });
}

class POLineItem {
  final String productName;
  final int quantity;
  final double unitCost;

  POLineItem({
    required this.productName,
    required this.quantity,
    required this.unitCost,
  });

  double get lineTotal => quantity * unitCost;
}

class PurchaseReturn {
  final String returnNumber;
  final String poNumber;
  final String supplierName;
  final DateTime returnDate;
  final String productName;
  final int quantity;
  final double refundAmount;
  final String reason;

  PurchaseReturn({
    required this.returnNumber,
    required this.poNumber,
    required this.supplierName,
    required this.returnDate,
    required this.productName,
    required this.quantity,
    required this.refundAmount,
    required this.reason,
  });
}
