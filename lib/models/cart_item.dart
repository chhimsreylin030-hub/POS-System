// US-030, US-032, US-033, US-036
import 'product.dart';

class CartItem {
  final ProductItem product;
  int quantity;
  double discountPercent; // e.g. 5% or 10%

  CartItem({
    required this.product,
    this.quantity = 1,
    this.discountPercent = 0.0,
  });

  double get unitPrice => product.sellingPrice;
  double get originalTotal => unitPrice * quantity;
  double get discountAmount => originalTotal * (discountPercent / 100);
  double get finalTotal => originalTotal - discountAmount;

  CartItem copyWith({
    ProductItem? product,
    int? quantity,
    double? discountPercent,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }
}

class HeldSale {
  final String id;
  final String note;
  final DateTime heldAt;
  final List<CartItem> items;
  final String? customerName;
  final double discountPercent;

  HeldSale({
    required this.id,
    required this.note,
    required this.heldAt,
    required this.items,
    this.customerName,
    this.discountPercent = 0.0,
  });

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.finalTotal);
}
