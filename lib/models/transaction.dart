// US-028, US-029, US-034, US-035, US-038, US-039, US-040, US-041, US-042, US-043, US-045
import 'cart_item.dart';

enum PaymentMethod {
  cash,
  bakongKhqr,
  creditCard,
  splitPayment,
}

enum TransactionStatus {
  completed,
  refunded,
  pending,
  failed,
}

class TransactionRecord {
  final String invoiceNumber;
  final DateTime timestamp;
  final List<CartItem> items;
  final double subtotal;
  final double discountAmount;
  final double taxAmount; // VAT 10%
  final double grandTotalUSD;
  final double grandTotalKHR;
  final PaymentMethod paymentMethod;
  final String paymentReference; // e.g., Bakong Tx Hash or Card Auth Code
  final double amountTendered;
  final double changeGiven;
  final String cashierName;
  final String? customerName;
  final String? customerPhone;
  TransactionStatus status;
  String? refundReason;
  DateTime? refundedAt;

  // For Split Payment
  final double? splitCashAmount;
  final double? splitDigitalAmount;

  TransactionRecord({
    required this.invoiceNumber,
    required this.timestamp,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.grandTotalUSD,
    required this.grandTotalKHR,
    required this.paymentMethod,
    required this.paymentReference,
    required this.amountTendered,
    required this.changeGiven,
    required this.cashierName,
    this.customerName,
    this.customerPhone,
    this.status = TransactionStatus.completed,
    this.refundReason,
    this.refundedAt,
    this.splitCashAmount,
    this.splitDigitalAmount,
  });

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Cash (សាច់ប្រាក់)';
      case PaymentMethod.bakongKhqr:
        return 'Bakong KHQR (បាគង)';
      case PaymentMethod.creditCard:
        return 'Card / Visa / MC';
      case PaymentMethod.splitPayment:
        return 'Split (បែងចែកការទូទាត់)';
    }
  }
}
