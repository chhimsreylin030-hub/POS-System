import 'package:flutter/material.dart';
import '../../models/supplier.dart';
import '../../state/pos_state.dart';

class SuppliersView extends StatefulWidget {
  const SuppliersView({super.key});

  @override
  State<SuppliersView> createState() => _SuppliersViewState();
}

class _SuppliersViewState extends State<SuppliersView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PosState posState = PosState();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCreatePoDialog() {
    if (posState.suppliers.isEmpty) return;
    String supplierName = posState.suppliers.first.name;
    final itemCtrl = TextEditingController(text: posState.products.first.name);
    final qtyCtrl = TextEditingController(text: '50');
    final costCtrl = TextEditingController(text: '1.20');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Purchase Order (US-026)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: supplierName,
              decoration: const InputDecoration(labelText: 'Supplier', border: OutlineInputBorder()),
              items: posState.suppliers.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
              onChanged: (val) => supplierName = val!,
            ),
            const SizedBox(height: 12),
            TextField(controller: itemCtrl, decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity to Order', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: costCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Unit Cost (\$)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            onPressed: () {
              final qty = int.tryParse(qtyCtrl.text) ?? 10;
              final cost = double.tryParse(costCtrl.text) ?? 1.0;
              final po = PurchaseOrder(
                poNumber: 'PO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                supplierName: supplierName,
                orderDate: DateTime.now(),
                expectedDelivery: DateTime.now().add(const Duration(days: 3)),
                items: [POLineItem(productName: itemCtrl.text, quantity: qty, unitCost: cost)],
                totalCost: qty * cost,
              );
              posState.addPurchaseOrder(po);
              Navigator.of(ctx).pop();
              setState(() {});
            },
            child: const Text('Submit PO'),
          ),
        ],
      ),
    );
  }

  void _openCreateReturnDialog() {
    final poCtrl = TextEditingController(text: 'PO-REF-1002');
    final itemCtrl = TextEditingController(text: 'French Butter Croissant');
    final qtyCtrl = TextEditingController(text: '5');
    final reasonCtrl = TextEditingController(text: 'Damaged packaging during transit');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Purchase Return to Supplier (US-027)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: poCtrl, decoration: const InputDecoration(labelText: 'PO Reference', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: itemCtrl, decoration: const InputDecoration(labelText: 'Product Returned', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Return Quantity', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Return Reason', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () {
              final qty = int.tryParse(qtyCtrl.text) ?? 1;
              final pr = PurchaseReturn(
                returnNumber: 'RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                poNumber: poCtrl.text,
                supplierName: posState.suppliers.first.name,
                returnDate: DateTime.now(),
                productName: itemCtrl.text,
                quantity: qty,
                refundAmount: qty * 1.5,
                reason: reasonCtrl.text,
              );
              posState.addPurchaseReturn(pr);
              Navigator.of(ctx).pop();
              setState(() {});
            },
            child: const Text('Submit Return'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Suppliers & Purchasing',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage vendor directory, purchase orders, deliveries, and returns.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.assignment_return_outlined, size: 16),
                    label: const Text('Purchase Return'),
                    onPressed: _openCreateReturnDialog,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create Purchase Order'),
                    onPressed: _openCreatePoDialog,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF0F172A),
            indicatorColor: const Color(0xFF0F172A),
            tabs: const [
              Tab(text: 'Suppliers Directory (US-025)'),
              Tab(text: 'Purchase Orders (US-026)'),
              Tab(text: 'Purchase Returns (US-027)'),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 520,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSuppliersDirectory(),
                _buildPurchaseOrdersList(),
                _buildPurchaseReturnsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliersDirectory() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            columns: const [
              DataColumn(label: Text('SUPPLIER NAME', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('CONTACT PERSON', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('PHONE NUMBER', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('EMAIL', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('SUPPLIED CATEGORY', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('ADDRESS', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: posState.suppliers.map((s) {
              return DataRow(
                cells: [
                  DataCell(Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(s.contactPerson)),
                  DataCell(Text(s.phone)),
                  DataCell(Text(s.email)),
                  DataCell(Text(s.categorySupplied)),
                  DataCell(Text(s.address)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseOrdersList() {
    final pos = posState.purchaseOrders;

    if (pos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text('No purchase orders yet. Click "Create Purchase Order" above.'),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            columns: const [
              DataColumn(label: Text('PO NUMBER', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('SUPPLIER', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('ITEMS ORDERED', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('TOTAL COST', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('EXPECTED DELIVERY', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('ACTION', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: pos.map((po) {
              final isReceived = po.status == PurchaseOrderStatus.received;

              return DataRow(
                cells: [
                  DataCell(Text(po.poNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(po.supplierName)),
                  DataCell(Text(po.items.map((i) => '${i.quantity}x ${i.productName}').join(', '))),
                  DataCell(Text('\$${po.totalCost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('${po.expectedDelivery.toLocal()}'.substring(0, 10))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isReceived ? Colors.green.shade50 : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isReceived ? 'Received & Restocked' : 'Pending Delivery',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isReceived ? Colors.green.shade800 : Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    isReceived
                        ? const Icon(Icons.check, color: Colors.green)
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                            onPressed: () {
                              posState.receivePurchaseOrder(po.poNumber);
                              setState(() {});
                            },
                            child: const Text('Receive Items', style: TextStyle(fontSize: 11)),
                          ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseReturnsList() {
    final prs = posState.purchaseReturns;

    if (prs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_return_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text('No purchase returns recorded.'),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            columns: const [
              DataColumn(label: Text('RETURN #', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('PO REF', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('SUPPLIER', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('PRODUCT & QTY', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('REFUND AMOUNT', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('REASON', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: prs.map((pr) {
              return DataRow(
                cells: [
                  DataCell(Text(pr.returnNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(pr.poNumber)),
                  DataCell(Text(pr.supplierName)),
                  DataCell(Text('${pr.quantity}x ${pr.productName}')),
                  DataCell(Text('\$${pr.refundAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                  DataCell(Text(pr.reason)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
