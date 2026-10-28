import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/customer.dart';
import '../../models/transaction.dart';
import '../../state/pos_state.dart';
import '../../theme/app_colors.dart';
import 'barcode_scanner_modal.dart';
import 'payment_modal.dart';
import 'receipt_dialog.dart';
import 'held_sales_modal.dart';

class PosTerminalScreen extends StatefulWidget {
  final VoidCallback onNavigateToAdmin;
  final VoidCallback onLogout;
  final VoidCallback? onNavigateToMerchant;
  final VoidCallback? onNavigateToCustomer;

  const PosTerminalScreen({
    super.key,
    required this.onNavigateToAdmin,
    required this.onLogout,
    this.onNavigateToMerchant,
    this.onNavigateToCustomer,
  });

  @override
  State<PosTerminalScreen> createState() => _PosTerminalScreenState();
}

class _PosTerminalScreenState extends State<PosTerminalScreen> {
  final PosState posState = PosState();
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    posState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    posState.removeListener(_onStateChanged);
    _searchController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  List<ProductItem> get _filteredProducts {
    return posState.products.where((p) {
      final matchesCategory = _selectedCategoryId == 'all' || p.categoryId == _selectedCategoryId;
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.khmerName.contains(q) ||
          p.barcode.contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openBarcodeScanner() {
    showDialog(
      context: context,
      builder: (_) => BarcodeScannerModal(
        onProductScanned: (product) {
          posState.addToCart(product);
        },
      ),
    );
  }

  void _openHoldSaleDialog() {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hold Active Sale'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Customer or Table note (optional)',
            hintText: 'e.g. Table 4 / Waiting for drink',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              posState.holdCurrentSale(noteController.text);
            },
            child: const Text('Hold Sale'),
          ),
        ],
      ),
    );
  }

  void _openHeldSalesList() {
    showDialog(
      context: context,
      builder: (_) => HeldSalesModal(
        onRecallSale: (sale) {
          posState.recallHeldSale(sale);
        },
      ),
    );
  }

  void _openPaymentModal() {
    if (posState.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty. Please select products first.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentModal(
        onPaymentSuccess: () {},
        onShowReceipt: (TransactionRecord record) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => ReceiptDialog(transaction: record),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      appBar: _buildTopBar(),
      body: isDesktop
          ? Row(
              children: [
                // Left 65%: Product Catalog
                Expanded(flex: 65, child: _buildCatalogSection()),
                // Right 35%: Cart & Checkout
                Container(
                  width: 440,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepBerry.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(-2, 0),
                      ),
                    ],
                  ),
                  child: _buildCartSection(),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildCatalogSection()),
                _buildMobileCartSummarySheet(),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildTopBar() {
    final user = posState.currentUser;
    final heldCount = posState.heldSales.length;

    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.deepBerry, // Palette: 59123E
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.richMagenta, // Palette: 8C0057
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.point_of_sale, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                posState.storeInfo.storeName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                'POS Terminal • Cashier: ${user?.name ?? "Cashier"}',
                style: const TextStyle(fontSize: 11, color: AppColors.softPink),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Barcode Scanner Shortcut
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: AppColors.softPink),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          icon: const Icon(Icons.qr_code_scanner, size: 18),
          label: const Text('Scan Barcode'),
          onPressed: _openBarcodeScanner,
        ),
        const SizedBox(width: 8),

        // Held Sales Button
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.pause_circle_outline, color: AppColors.softPink),
              tooltip: 'Held Sales',
              onPressed: _openHeldSalesList,
            ),
            if (heldCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.vibrantPink, shape: BoxShape.circle),
                  child: Text(
                    '$heldCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),

        // Portal Switchers
        if (widget.onNavigateToMerchant != null)
          IconButton(
            icon: const Icon(Icons.storefront, color: Colors.white),
            tooltip: 'Go to Merchant Store Portal',
            onPressed: widget.onNavigateToMerchant,
          ),

        if (posState.isAdmin)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
            tooltip: 'Go to Super Admin Web Dashboard',
            onPressed: widget.onNavigateToAdmin,
          ),

        if (widget.onNavigateToCustomer != null)
          IconButton(
            icon: const Icon(Icons.phone_android, color: AppColors.softPink),
            tooltip: 'View Customer Mobile App',
            onPressed: widget.onNavigateToCustomer,
          ),

        // Logout
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white70),
          tooltip: 'Logout',
          onPressed: widget.onLogout,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCatalogSection() {
    return Column(
      children: [
        // Search & Filter header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: Colors.white,
          child: Column(
            children: [
              // Search input
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search product name, Khmer title, or barcode...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 10),

              // Horizontal Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All Items (ទាំងអស់)'),
                      selected: _selectedCategoryId == 'all',
                      onSelected: (val) => setState(() => _selectedCategoryId = 'all'),
                    ),
                    const SizedBox(width: 8),
                    ...posState.categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('${cat.name} (${cat.khmerName})'),
                          selected: _selectedCategoryId == cat.id,
                          onSelected: (val) => setState(() => _selectedCategoryId = cat.id),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Product Grid
        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text('No products found', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return _buildProductCard(product);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductItem product) {
    final isOut = product.isOutOfStock;
    final isLow = product.isLowStock;
    final khrPrice = posState.usdToKhr(product.sellingPrice);

    return InkWell(
      onTap: isOut ? null : () => posState.addToCart(product),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOut ? Colors.red.shade200 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Stock Badge
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.fastfood, color: Colors.grey, size: 36),
                      ),
                    ),
                  ),
                  if (isOut)
                    Container(
                      color: Colors.black.withValues(alpha: 0.55),
                      child: const Center(
                        child: Text(
                          'OUT OF STOCK',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                      ),
                    )
                  else if (isLow)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Low: ${product.stockQuantity}',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          product.khmerName,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${product.sellingPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              '${khrPrice.toStringAsFixed(0)} ៛',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isOut ? Colors.grey.shade300 : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSection() {
    final cart = posState.cartItems;
    final subtotal = posState.cartSubtotal;
    final discount = posState.cartDiscountAmount;
    final tax = posState.cartTaxAmount;
    final grandTotalUSD = posState.cartGrandTotalUSD;
    final grandTotalKHR = posState.cartGrandTotalKHR;

    return Column(
      children: [
        // Customer Membership selector (US-030)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Customer Membership:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  if (posState.selectedCustomer != null)
                    GestureDetector(
                      onTap: () => posState.setCustomer(null),
                      child: const Text('Clear', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<Customer?>(
                initialValue: posState.selectedCustomer,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                hint: const Text('Walk-in Customer (No Discount)', style: TextStyle(fontSize: 12)),
                items: [
                  const DropdownMenuItem<Customer?>(
                    value: null,
                    child: Text('Walk-in Customer (Standard)', style: TextStyle(fontSize: 12)),
                  ),
                  ...posState.customers.map((c) {
                    return DropdownMenuItem<Customer?>(
                      value: c,
                      child: Text(
                        '${c.name} • ${c.tierName}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (val) => posState.setCustomer(val),
              ),
            ],
          ),
        ),

        // Cart items table
        Expanded(
          child: cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 54, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Cart is empty', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Tap any product to add to order', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.product.imageUrl,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 44,
                                height: 44,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.fastfood, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '\$${item.unitPrice.toStringAsFixed(2)} each',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          // Quantity +/-
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                onPressed: () => posState.updateCartQuantity(item.product.id, item.quantity - 1),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                onPressed: () => posState.updateCartQuantity(item.product.id, item.quantity + 1),
                              ),
                            ],
                          ),
                          // Total
                          SizedBox(
                            width: 60,
                            child: Text(
                              '\$${item.finalTotal.toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Promo code / Discount bar (US-036, US-037)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Promo code (e.g. WELCOME10)',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final success = posState.applyPromoCode(_promoController.text);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✓ Promo code applied: ${posState.appliedPromoCode}')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid promo code. Try WELCOME10 or BAKONG15')),
                    );
                  }
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ),

        // Totals & Checkout Panel
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            children: [
              _buildSummaryLine('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
              if (discount > 0)
                _buildSummaryLine('Discount (${posState.orderDiscountPercent.toStringAsFixed(0)}%)', '-\$${discount.toStringAsFixed(2)}', color: Colors.green),
              _buildSummaryLine('Tax (VAT 10%)', '\$${tax.toStringAsFixed(2)}'),
              const Divider(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${grandTotalUSD.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.richMagenta),
                      ),
                      Text(
                        '${grandTotalKHR.toStringAsFixed(0)} ៛',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Action Buttons: Hold Sale, Clear, Pay Now
              Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: cart.isEmpty ? null : () => posState.clearCart(),
                    child: const Icon(Icons.delete_outline, size: 20),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: BorderSide(color: AppColors.warning.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.pause, size: 18),
                    label: const Text('Hold'),
                    onPressed: cart.isEmpty ? null : _openHoldSaleDialog,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.richMagenta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'Pay / Checkout',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: cart.isEmpty ? null : _openPaymentModal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryLine(String title, String amount, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(amount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color ?? AppColors.textMain)),
        ],
      ),
    );
  }

  Widget _buildMobileCartSummarySheet() {
    final count = posState.cartItems.fold(0, (sum, i) => sum + i.quantity);
    final total = posState.cartGrandTotalUSD;

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$count items in cart', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepBerry),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.richMagenta, foregroundColor: Colors.white),
              onPressed: _openPaymentModal,
              child: const Text('Proceed to Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
