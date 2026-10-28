import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../state/pos_state.dart';
import '../pos/receipt_dialog.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final PosState posState = PosState();
  String _filterMethod = 'all';

  void _openRefundDialog(TransactionRecord transaction) {
    final reasonCtrl = TextEditingController(text: 'Customer requested return (Defective / Changed mind)');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Process Refund: ${transaction.invoiceNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refund Amount: \$${transaction.grandTotalUSD.toStringAsFixed(2)} (${transaction.grandTotalKHR.toStringAsFixed(0)} ៛)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Original Payment: ${transaction.paymentMethodLabel} (${transaction.paymentReference})',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason for Refund',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '✓ Inventory items will be automatically restocked into catalog.',
              style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () {
              posState.processRefund(transaction.invoiceNumber, reasonCtrl.text);
              Navigator.of(ctx).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ Refund processed for ${transaction.invoiceNumber}'),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            },
            child: const Text('Confirm Refund'),
          ),
        ],
      ),
    );
  }

  void _viewReceipt(TransactionRecord t) {
    showDialog(
      context: context,
      builder: (_) => ReceiptDialog(transaction: t),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = posState.transactions.where((t) {
      if (_filterMethod == 'all') return true;
      if (_filterMethod == 'khqr' && t.paymentMethod == PaymentMethod.bakongKhqr) return true;
      if (_filterMethod == 'card' && t.paymentMethod == PaymentMethod.creditCard) return true;
      if (_filterMethod == 'cash' && t.paymentMethod == PaymentMethod.cash) return true;
      if (_filterMethod == 'split' && t.paymentMethod == PaymentMethod.splitPayment) return true;
      return false;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Digital Payments & Transaction Ledger',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monitor customer receipts, Bakong KHQR verifications, and process refunds.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _filterMethod,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Payment Channels')),
                  DropdownMenuItem(value: 'khqr', child: Text('Bakong KHQR Only')),
                  DropdownMenuItem(value: 'card', child: Text('Credit / Debit Card')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash Counter')),
                  DropdownMenuItem(value: 'split', child: Text('Split Payments')),
                ],
                onChanged: (val) => setState(() => _filterMethod = val!),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  columns: const [
                    DataColumn(label: Text('INVOICE #', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('DATE / TIME', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('PAYMENT METHOD', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('REFERENCE / TX', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('TOTAL (USD / KHR)', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('CASHIER', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filtered.map((t) {
                    final isRefunded = t.status == TransactionStatus.refunded;
                    final isKhqr = t.paymentMethod == PaymentMethod.bakongKhqr;

                    return DataRow(
                      cells: [
                        DataCell(Text(t.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('${t.timestamp.toLocal()}'.substring(0, 16))),
                        DataCell(
                          Row(
                            children: [
                              Icon(
                                isKhqr ? Icons.qr_code_2 : Icons.payment,
                                size: 16,
                                color: isKhqr ? const Color(0xFFE2001A) : Colors.blueGrey,
                              ),
                              const SizedBox(width: 6),
                              Text(t.paymentMethodLabel, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        DataCell(Text(t.paymentReference, style: const TextStyle(fontFamily: 'monospace', fontSize: 11))),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '\$${t.grandTotalUSD.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: isRefunded ? TextDecoration.lineThrough : null,
                                  color: isRefunded ? Colors.red : Colors.black87,
                                ),
                              ),
                              Text('${t.grandTotalKHR.toStringAsFixed(0)} ៛', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        DataCell(Text(t.cashierName)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isRefunded ? Colors.red.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isRefunded ? 'Refunded' : 'Completed',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isRefunded ? Colors.red : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.receipt_outlined, size: 18),
                                tooltip: 'Print Receipt',
                                onPressed: () => _viewReceipt(t),
                              ),
                              if (!isRefunded)
                                IconButton(
                                  icon: const Icon(Icons.replay, size: 18, color: Colors.red),
                                  tooltip: 'Refund Order',
                                  onPressed: () => _openRefundDialog(t),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
