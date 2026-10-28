import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../models/transaction.dart';
import '../../state/pos_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_qr.dart';

class CustomerMobileScreen extends StatefulWidget {
  final VoidCallback? onSwitchPortal;

  const CustomerMobileScreen({super.key, this.onSwitchPortal});

  @override
  State<CustomerMobileScreen> createState() => _CustomerMobileScreenState();
}

class _CustomerMobileScreenState extends State<CustomerMobileScreen> {
  final PosState posState = PosState();
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final List<CartItem> _customerCart = [];
  TransactionRecord? _lastOrder;

  @override
  void initState() {
    super.initState();
    posState.addListener(_onStateChange);
    // Auto-select first customer as sample mobile user if none selected
    if (posState.selectedCustomer == null && posState.customers.isNotEmpty) {
      posState.setCustomer(posState.customers.first);
    }
  }

  @override
  void dispose() {
    posState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  double get _cartTotal {
    final subtotal = _customerCart.fold(0.0, (sum, i) => sum + i.finalTotal);
    final discountPercent = posState.selectedCustomer?.discountPercent ?? 0.0;
    final discount = subtotal * (discountPercent / 100);
    final tax = (subtotal - discount) * (posState.storeInfo.taxRatePercent / 100);
    return (subtotal - discount) + tax;
  }

  void _addToCart(ProductItem product) {
    setState(() {
      final idx = _customerCart.indexWhere((i) => i.product.id == product.id);
      if (idx != -1) {
        _customerCart[idx].quantity += 1;
      } else {
        _customerCart.add(CartItem(product: product, quantity: 1));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to mobile bag'),
        backgroundColor: AppColors.richMagenta,
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  void _openMobileCheckout() {
    if (_customerCart.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final totalUsd = _cartTotal;
          final totalKhr = posState.usdToKhr(totalUsd);

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Top handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mobile Order Checkout',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.deepBerry),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Items in cart summary
                        Text(
                          'Your Order (${_customerCart.length} items)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        ..._customerCart.map((i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${i.quantity}x ${i.product.name}', style: const TextStyle(fontSize: 13)),
                                Text('\$${i.finalTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 24),

                        // VIP Member Discount applied
                        if (posState.selectedCustomer != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.blushTint.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.softPink),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars, color: AppColors.richMagenta, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${posState.selectedCustomer!.tierName} applied automatically!',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepBerry),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // KHQR Card Preview
                        Center(
                          child: BakongKhqrCard(
                            amountUsd: totalUsd,
                            amountKhr: totalKhr,
                            billNumber: 'MOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                            size: 190,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Pay Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.richMagenta,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.touch_app),
                            label: Text(
                              'Pay Now with Bakong App (\$${totalUsd.toStringAsFixed(2)})',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              final invoice = 'INV-MOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
                              final tx = TransactionRecord(
                                invoiceNumber: invoice,
                                timestamp: DateTime.now(),
                                items: List.from(_customerCart),
                                subtotal: totalUsd * 0.9,
                                discountAmount: totalUsd * 0.1,
                                taxAmount: totalUsd * 0.1,
                                grandTotalUSD: totalUsd,
                                grandTotalKHR: totalKhr,
                                paymentMethod: PaymentMethod.bakongKhqr,
                                paymentReference: 'BK-APP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                amountTendered: totalUsd,
                                changeGiven: 0.0,
                                cashierName: 'Self Mobile Checkout',
                                customerName: posState.selectedCustomer?.name,
                                customerPhone: posState.selectedCustomer?.phone,
                              );

                              posState.transactions.insert(0, tx);
                              posState.logActivity('Mobile App Sale', '$invoice completed via Bakong KHQR mobile pay');

                              Navigator.of(ctx).pop();
                              setState(() {
                                _lastOrder = tx;
                                _customerCart.clear();
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✓ Payment Confirmed! Preparing your order.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    if (isDesktop) {
      // Wrap in a smartphone mockup frame on desktop/laptop
      return Scaffold(
        backgroundColor: const Color(0xFF1B0714), // Dark plum backdrop
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar with Switcher
              Container(
                width: 440,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.phone_android, color: AppColors.vibrantPink, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Customer Mobile App View',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    if (widget.onSwitchPortal != null)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.softPink,
                          backgroundColor: AppColors.deepBerry,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: const Text('Back to Web Portals', style: TextStyle(fontSize: 11)),
                        onPressed: widget.onSwitchPortal,
                      ),
                  ],
                ),
              ),

              // Phone Outer Frame
              Container(
                width: 390,
                height: 780,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(color: AppColors.vibrantPink.withValues(alpha: 0.3), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.richMagenta.withValues(alpha: 0.35),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(44),
                  child: _buildPhoneAppBody(),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Direct mobile full screen
      return Scaffold(
        backgroundColor: AppColors.canvasLight,
        body: _buildPhoneAppBody(),
      );
    }
  }

  Widget _buildPhoneAppBody() {
    final customer = posState.selectedCustomer ?? posState.customers.first;
    final filtered = posState.products.where((p) {
      final matchesCat = _selectedCategory == 'all' || p.categoryId == _selectedCategory;
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty || p.name.toLowerCase().contains(q) || p.khmerName.contains(q);
      return matchesCat && matchesSearch;
    }).toList();

    return Container(
      color: AppColors.canvasLight,
      child: SafeArea(
        child: Column(
          children: [
            // Status Notch simulation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('9:41', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textMain)),
                  Container(
                    width: 90,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.wifi, size: 14, color: AppColors.textMain),
                      SizedBox(width: 4),
                      Icon(Icons.battery_full, size: 14, color: AppColors.textMain),
                    ],
                  ),
                ],
              ),
            ),

            // Customer Greeting & VIP Card Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.deepBerry, AppColors.richMagenta],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.richMagenta.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: Text(
                                customer.name[0],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.richMagenta),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  customer.tierName,
                                  style: const TextStyle(color: AppColors.softPink, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.loyalty, size: 14, color: AppColors.softPink),
                              const SizedBox(width: 4),
                              Text(
                                '${customer.loyaltyPoints} Pts',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Welcome to Smart POS Rewards',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    Text(
                      'Enjoy ${customer.discountPercent.toStringAsFixed(0)}% Member Discount on all orders!',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            // Live Order Tracking Banner (if recently ordered)
            if (_lastOrder != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.blushTint.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.vibrantPink),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.delivery_dining, color: AppColors.richMagenta, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Order #${_lastOrder!.invoiceNumber}: Preparing in Kitchen',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.deepBerry),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.richMagenta),
                    ),
                  ],
                ),
              ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search food, coffee, or snacks...',
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.richMagenta),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // Categories horizontal bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildCategoryChip('all', 'All Menu'),
                  ...posState.categories.map((c) => _buildCategoryChip(c.id, c.name)),
                ],
              ),
            ),

            // Products Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.74,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  final khr = posState.usdToKhr(p.sellingPrice);

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.richMagenta.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              p.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: AppColors.blushTint),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textMain),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      p.khmerName,
                                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '\$${p.sellingPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.deepBerry),
                                        ),
                                        Text(
                                          '${khr.toStringAsFixed(0)} ៛',
                                          style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: p.isOutOfStock ? null : () => _addToCart(p),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: p.isOutOfStock ? Colors.grey : AppColors.richMagenta,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.add_shopping_cart, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Sticky Floating Cart & KHQR Checkout Bar
            if (_customerCart.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepBerry.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_customerCart.fold(0, (sum, i) => sum + i.quantity)} items in Bag',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        Text(
                          '\$${_cartTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.deepBerry),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.richMagenta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.qr_code_2, size: 20),
                      label: const Text('KHQR Pay', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _openMobileCheckout,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String id, String label) {
    final isSelected = _selectedCategory == id;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.richMagenta,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textMain,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? AppColors.richMagenta : AppColors.borderLight),
        ),
        onSelected: (_) => setState(() => _selectedCategory = id),
      ),
    );
  }
}
