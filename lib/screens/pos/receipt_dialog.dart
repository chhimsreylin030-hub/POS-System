import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../state/pos_state.dart';
import '../../widgets/custom_barcode.dart';

class ReceiptDialog extends StatelessWidget {
  final TransactionRecord transaction;

  const ReceiptDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final posState = PosState();
    final store = posState.storeInfo;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380, maxHeight: 720),
        child: Column(
          children: [
            // Top action bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Receipt Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.print, color: Color(0xFF0F172A)),
                        tooltip: 'Print',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Sent to POS Thermal Printer')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Thermal Paper Slip
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Store Title
                    Text(
                      store.storeName,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      store.khmerStoreName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.address,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Tel: ${store.phone}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                    ),
                    Text(
                      'VAT TIN: ${store.vatTin}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                    ),

                    const SizedBox(height: 12),
                    _buildDashedLine(),
                    const SizedBox(height: 8),

                    // Metadata
                    _buildMetadataRow('Invoice #:', transaction.invoiceNumber),
                    _buildMetadataRow('Date/Time:', '${transaction.timestamp.toLocal()}'.substring(0, 19)),
                    _buildMetadataRow('Cashier:', transaction.cashierName),
                    if (transaction.customerName != null)
                      _buildMetadataRow('Customer:', transaction.customerName!),

                    const SizedBox(height: 8),
                    _buildDashedLine(),
                    const SizedBox(height: 8),

                    // Items Table
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(flex: 5, child: Text('ITEM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        Expanded(flex: 3, child: Text('PRICE', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                        Expanded(flex: 3, child: Text('TOTAL', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 6),

                    ...transaction.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                item.product.name,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '\$${item.unitPrice.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '\$${item.finalTotal.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),
                    _buildDashedLine(),
                    const SizedBox(height: 8),

                    // Totals
                    _buildTotalRow('Subtotal:', '\$${transaction.subtotal.toStringAsFixed(2)}'),
                    if (transaction.discountAmount > 0)
                      _buildTotalRow('Discount:', '-\$${transaction.discountAmount.toStringAsFixed(2)}'),
                    _buildTotalRow('VAT (10%):', '\$${transaction.taxAmount.toStringAsFixed(2)}'),

                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'GRAND TOTAL:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '\$${transaction.grandTotalUSD.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total in KHR:',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                        ),
                        Text(
                          '${transaction.grandTotalKHR.toStringAsFixed(0)} ៛',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    _buildDashedLine(),
                    const SizedBox(height: 8),

                    // Payment details
                    _buildMetadataRow('Payment Method:', transaction.paymentMethodLabel),
                    _buildMetadataRow('Ref / Auth:', transaction.paymentReference),
                    _buildMetadataRow('Tendered:', '\$${transaction.amountTendered.toStringAsFixed(2)}'),
                    _buildMetadataRow('Change Given:', '\$${transaction.changeGiven.toStringAsFixed(2)}'),

                    const SizedBox(height: 14),

                    // Barcode
                    BarcodeWidget(
                      code: transaction.invoiceNumber,
                      width: 170,
                      height: 40,
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      'សូមអរគុណ! សូមអញ្ជើញមកពិសារម្តងទៀត',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'Thank you for your purchase!',
                      style: TextStyle(fontSize: 10, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'WiFi: ${store.wifiPassword}',
                      style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Done Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Start New Order', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black87)),
          Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.constrainWidth() / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (_) {
            return const SizedBox(
              width: 4,
              height: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: Colors.black38)),
            );
          }),
        );
      },
    );
  }
}
