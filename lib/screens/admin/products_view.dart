import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../state/pos_state.dart';
import '../../widgets/custom_barcode.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final PosState posState = PosState();
  String _selectedCategory = 'all';
  String _search = '';

  void _openAddEditProductDialog([ProductItem? existingProduct]) {
    final isEditing = existingProduct != null;
    final nameCtrl = TextEditingController(text: existingProduct?.name ?? '');
    final khmerCtrl = TextEditingController(text: existingProduct?.khmerName ?? '');
    final barcodeCtrl = TextEditingController(text: existingProduct?.barcode ?? '88501230${posState.products.length + 1}');
    final costCtrl = TextEditingController(text: existingProduct?.costPrice.toStringAsFixed(2) ?? '1.00');
    final sellCtrl = TextEditingController(text: existingProduct?.sellingPrice.toStringAsFixed(2) ?? '2.50');
    final stockCtrl = TextEditingController(text: existingProduct?.stockQuantity.toString() ?? '20');
    final lowThresholdCtrl = TextEditingController(text: existingProduct?.lowStockThreshold.toString() ?? '10');
    final imageCtrl = TextEditingController(text: existingProduct?.imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300');
    String categoryId = existingProduct?.categoryId ?? posState.categories.first.id;
    ProductStatus status = existingProduct?.status ?? ProductStatus.active;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final cost = double.tryParse(costCtrl.text) ?? 0.0;
          final sell = double.tryParse(sellCtrl.text) ?? 0.0;
          final margin = sell > 0 ? (((sell - cost) / sell) * 100).toStringAsFixed(1) : '0';

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEditing ? 'Edit Product' : 'Add New Product',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Name (EN & KH)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(labelText: 'Product Name (English)', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: khmerCtrl,
                              decoration: const InputDecoration(labelText: 'ឈ្មោះជាភាសាខ្មែរ (Khmer)', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Category & Barcode
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: categoryId,
                              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                              items: posState.categories.map((c) {
                                return DropdownMenuItem(value: c.id, child: Text(c.name));
                              }).toList(),
                              onChanged: (val) => setDialogState(() => categoryId = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: barcodeCtrl,
                              decoration: const InputDecoration(labelText: 'Barcode / SKU', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Cost Price & Selling Price with Margin
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: costCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Cost Price (\$)', border: OutlineInputBorder()),
                              onChanged: (_) => setDialogState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: sellCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Selling Price (\$)', border: OutlineInputBorder()),
                              onChanged: (_) => setDialogState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Text(
                              'Margin: $margin%',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Stock & Low Threshold
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Current Stock Quantity', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: lowThresholdCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Low Stock Threshold Alert', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Image URL
                      TextField(
                        controller: imageCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Product Image URL',
                          border: OutlineInputBorder(),
                          hintText: 'https://images.unsplash.com/...',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            final newProduct = ProductItem(
                              id: isEditing ? existingProduct.id : 'p-${DateTime.now().millisecondsSinceEpoch}',
                              name: nameCtrl.text.isNotEmpty ? nameCtrl.text : 'New Product',
                              khmerName: khmerCtrl.text.isNotEmpty ? khmerCtrl.text : 'ទំនិញថ្មី',
                              categoryId: categoryId,
                              barcode: barcodeCtrl.text.isNotEmpty ? barcodeCtrl.text : '8850000000',
                              costPrice: double.tryParse(costCtrl.text) ?? 1.0,
                              sellingPrice: double.tryParse(sellCtrl.text) ?? 2.5,
                              stockQuantity: int.tryParse(stockCtrl.text) ?? 0,
                              lowStockThreshold: int.tryParse(lowThresholdCtrl.text) ?? 10,
                              imageUrl: imageCtrl.text.isNotEmpty ? imageCtrl.text : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300',
                              status: status,
                            );

                            if (isEditing) {
                              posState.updateProduct(newProduct);
                            } else {
                              posState.addProduct(newProduct);
                            }

                            Navigator.of(ctx).pop();
                            setState(() {});
                          },
                          child: Text(isEditing ? 'Save Changes' : 'Create Product', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = posState.products.where((p) {
      final matchesCategory = _selectedCategory == 'all' || p.categoryId == _selectedCategory;
      final q = _search.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.khmerName.contains(q) ||
          p.barcode.contains(q);
      return matchesCategory && matchesSearch;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Products & Catalog Management',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage items, prices, barcodes, and stock levels across categories.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New Product', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _openAddEditProductDialog(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filters Row
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search products by name, Khmer name, or barcode...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() => _search = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Categories')),
                      ...posState.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Product Table
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                columnSpacing: 18,
                columns: const [
                  DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('CATEGORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('BARCODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('COST / SELL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('STOCK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
                rows: products.map((p) {
                  final cat = posState.categories.firstWhere((c) => c.id == p.categoryId, orElse: () => posState.categories.first);
                  final isOut = p.isOutOfStock;
                  final isLow = p.isLowStock;

                  return DataRow(
                    cells: [
                      // Product Image & Name
                      DataCell(
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                p.imageUrl,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 36, height: 36, color: Colors.grey.shade200),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(p.khmerName, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(cat.name, style: const TextStyle(fontSize: 12))),
                      DataCell(
                        Tooltip(
                          message: p.barcode,
                          child: BarcodeWidget(code: p.barcode, width: 80, height: 25, showText: true),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\$${p.costPrice.toStringAsFixed(2)} / \$${p.sellingPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${p.stockQuantity} units',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOut ? Colors.red : (isLow ? Colors.orange.shade800 : Colors.black87),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isOut
                                ? Colors.red.shade50
                                : (isLow ? Colors.orange.shade50 : Colors.green.shade50),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isOut ? 'Out of Stock' : (isLow ? 'Low Stock' : 'Active'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isOut ? Colors.red : (isLow ? Colors.orange.shade800 : Colors.green.shade800),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Edit',
                              onPressed: () => _openAddEditProductDialog(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () {
                                posState.deleteProduct(p.id);
                                setState(() {});
                              },
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
        ],
      ),
    );
  }
}
