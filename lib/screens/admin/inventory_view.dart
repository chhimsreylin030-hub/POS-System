import 'package:flutter/material.dart';
import '../../models/supplier.dart';
import '../../state/pos_state.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PosState posState = PosState();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openStockOperationDialog(MovementType type) {
    if (posState.products.isEmpty) return;
    String selectedProductId = posState.products.first.id;
    final qtyCtrl = TextEditingController(text: '10');
    final reasonCtrl = TextEditingController(
      text: type == MovementType.stockIn
          ? 'Supplier Delivery'
          : (type == MovementType.stockOut ? 'Expired / Damaged' : 'Store Shelf Replenishment'),
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          final p = posState.products.firstWhere((item) => item.id == selectedProductId);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(_getMovementTitle(type)),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedProductId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Select Product', border: OutlineInputBorder()),
                    items: posState.products.map((prod) {
                      return DropdownMenuItem(
                        value: prod.id,
                        child: Text('${prod.name} (Cur: ${prod.stockQuantity})', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setDlgState(() => selectedProductId = val!),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Current Stock: ${p.stockQuantity} units',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: type == MovementType.adjustment ? 'New Exact Stock Count' : 'Quantity Units',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(labelText: 'Reason / Note / Batch #', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                onPressed: () {
                  final qty = int.tryParse(qtyCtrl.text) ?? 0;
                  if (qty > 0 || type == MovementType.adjustment) {
                    posState.adjustStock(
                      productId: selectedProductId,
                      type: type,
                      quantityDelta: qty,
                      reason: reasonCtrl.text,
                    );
                    Navigator.of(ctx).pop();
                    setState(() {});
                  }
                },
                child: const Text('Confirm Operation'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getMovementTitle(MovementType type) {
    switch (type) {
      case MovementType.stockIn:
        return 'Stock In (Receive Goods)';
      case MovementType.stockOut:
        return 'Stock Out (Waste / Internal)';
      case MovementType.transfer:
        return 'Stock Transfer (Warehouse to Floor)';
      case MovementType.adjustment:
        return 'Physical Inventory Adjustment';
    }
  }

  void _simulateCsvImport() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Inventory CSV (US-018)'),
        content: const Text(
          'Simulated importing products_inventory.csv (42 records parsed and stock synchronized).',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Successfully imported 42 products from CSV')),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _simulateCsvExport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ Inventory exported: pos_stock_report_2026.csv downloaded.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Quick Operations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inventory & Stock Management',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Audit stocks, stock in/out movements, transfers, and reconcile discrepancy.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.file_upload_outlined, size: 16),
                    label: const Text('Import CSV'),
                    onPressed: _simulateCsvImport,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Export CSV'),
                    onPressed: _simulateCsvExport,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Stock In (+)'),
                    onPressed: () => _openStockOperationDialog(MovementType.stockIn),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
                    icon: const Icon(Icons.remove, size: 16),
                    label: const Text('Stock Out (-)'),
                    onPressed: () => _openStockOperationDialog(MovementType.stockOut),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Adjustment'),
                    onPressed: () => _openStockOperationDialog(MovementType.adjustment),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tabs: Current Stock Levels vs Movement History
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF0F172A),
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: const Color(0xFF0F172A),
            tabs: const [
              Tab(text: 'Current Stock Audit'),
              Tab(text: 'Stock Movement Ledger (Audit Trail)'),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 600,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentStockAuditTable(),
                _buildMovementLedgerTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStockAuditTable() {
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
              DataColumn(label: Text('PRODUCT NAME', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('BARCODE', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('CURRENT STOCK', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('ALERT LEVEL', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('HEALTH STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('QUICK RESTOCK', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: posState.products.map((p) {
              final isLow = p.isLowStock;
              final isOut = p.isOutOfStock;

              return DataRow(
                cells: [
                  DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(p.barcode)),
                  DataCell(
                    Text(
                      '${p.stockQuantity} units',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOut ? Colors.red : (isLow ? Colors.orange.shade800 : Colors.green.shade800),
                      ),
                    ),
                  ),
                  DataCell(Text('<= ${p.lowStockThreshold} units')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOut ? Colors.red.shade50 : (isLow ? Colors.orange.shade50 : Colors.green.shade50),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isOut ? 'Depleted (0)' : (isLow ? 'Low Stock Warning' : 'Optimal'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOut ? Colors.red : (isLow ? Colors.orange.shade800 : Colors.green.shade800),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: () {
                        posState.adjustStock(
                          productId: p.id,
                          type: MovementType.stockIn,
                          quantityDelta: 20,
                          reason: 'Quick Restock (+20)',
                        );
                        setState(() {});
                      },
                      child: const Text('+20 Restock', style: TextStyle(fontSize: 11)),
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

  Widget _buildMovementLedgerTable() {
    final movements = posState.stockMovements;

    if (movements.isEmpty) {
      return const Center(child: Text('No stock movements recorded in this session.'));
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
              DataColumn(label: Text('DATE / TIME', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('OPERATION TYPE', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('QTY DELTA', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('REMAINING', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('REASON / NOTE', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('OPERATOR', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: movements.map((m) {
              return DataRow(
                cells: [
                  DataCell(Text('${m.timestamp.toLocal()}'.substring(0, 19))),
                  DataCell(Text(m.productName, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(m.typeLabel)),
                  DataCell(Text('${m.quantity}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('${m.remainingStock} units')),
                  DataCell(Text(m.reason)),
                  DataCell(Text(m.operator)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
