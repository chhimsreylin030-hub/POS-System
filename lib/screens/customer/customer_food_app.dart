import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/food_models.dart';
import '../../state/food_delivery_state.dart';
import '../../theme/app_colors.dart';

// ----------------------------------------------------------------------------
// Reusable Password Input Field with Instant Hide/Unhide Toggle
// ----------------------------------------------------------------------------
class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final ValueChanged<String>? onChanged;

  const PasswordInputField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.prefixIcon = Icons.lock_outline,
    this.onChanged,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(widget.prefixIcon, color: AppColors.richMagenta, size: 20),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show password' : 'Hide password',
          icon: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: _obscure ? Colors.grey : AppColors.richMagenta,
          ),
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class CustomerFoodApp extends StatefulWidget {
  final VoidCallback? onSwitchPortal;

  const CustomerFoodApp({super.key, this.onSwitchPortal});

  @override
  State<CustomerFoodApp> createState() => _CustomerFoodAppState();
}

class _CustomerFoodAppState extends State<CustomerFoodApp> {
  final FoodDeliveryState state = FoodDeliveryState();
  int _currentNavIndex = 0; // 0: Home, 1: Tracking, 2: Profile & Settings
  String _selectedCategory = 'All';
  String _searchQuery = '';
  RestaurantMerchant? _viewingMerchant;
  final TextEditingController _voucherController = TextEditingController();

  // Sort & Filter state for Restaurants
  String _merchantSortBy = 'Rating: High to Low'; // 'Rating: High to Low', 'Fastest Delivery', 'Delivery Fee: Low to High', 'Name: A to Z'
  bool _filterOpenOnly = false;
  bool _filterTopRatedOnly = false; // rating >= 4.8
  bool _filterFastDeliveryOnly = false; // <= 25 mins
  bool _filterLowFeeOnly = false; // <= $1.50

  // Dish sorting and filtering inside restaurant
  String _dishSortBy = 'Recommended'; // 'Recommended', 'Price: Low to High', 'Price: High to Low', 'Name: A to Z'
  String _dishCategoryFilter = 'All';
  String _dishSearchQuery = '';

  // Profile preferences
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  Timer? _customerPollTimer;

  // Customer Auth Form State
  bool _isRegisterMode = false;
  final TextEditingController _authNameCtrl = TextEditingController();
  final TextEditingController _authPhoneCtrl = TextEditingController(text: '010 334 556');
  final TextEditingController _authEmailCtrl = TextEditingController(text: 'bopha.pich@outlook.com');
  final TextEditingController _authPassCtrl = TextEditingController(text: '123456');
  final TextEditingController _authAddressCtrl = TextEditingController(text: 'House 42, St 271, Boeng Tumpun, Phnom Penh');
  bool _isLoadingAuth = false;

  List<String> get _categories {
    final Set<String> cats = {'All'};
    for (final m in state.merchants) {
      if (m.cuisine.isNotEmpty) {
        final clean = m.cuisine.split('•').first.split('&').first.trim();
        if (clean.isNotEmpty) cats.add(clean);
      }
    }
    return cats.toList();
  }

  @override
  void initState() {
    super.initState();
    state.addListener(_onStateChange);
    // Real-time Order & Delivery Tracking Polling (every 3 seconds)
    _customerPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      state.syncOrdersOnly();
    });
  }

  @override
  void dispose() {
    _customerPollTimer?.cancel();
    state.removeListener(_onStateChange);
    _voucherController.dispose();
    _authNameCtrl.dispose();
    _authPhoneCtrl.dispose();
    _authEmailCtrl.dispose();
    _authPassCtrl.dispose();
    _authAddressCtrl.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  // --------------------------------------------------------------------------
  // Add Dish Dialog with Special Instructions
  // --------------------------------------------------------------------------
  void _openItemDetailModal(RestaurantMerchant merchant, FoodMenuItem item) {
    int qty = 1;
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 16,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    item.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: AppColors.blushTint,
                      child: const Icon(Icons.fastfood, size: 48, color: AppColors.richMagenta),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.deepBerry),
                          ),
                          Text(
                            item.khmerName,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${item.priceUSD.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.richMagenta),
                        ),
                        Text(
                          '${state.usdToKhr(item.priceUSD).toStringAsFixed(0)} ៛',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    hintText: 'Special instructions (e.g. Less spicy, extra sauce, no ice)',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.note_add_outlined, size: 18, color: AppColors.richMagenta),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Quantity counter
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.blushTint.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.softPink.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18, color: AppColors.deepBerry),
                            onPressed: qty > 1 ? () => setModalState(() => qty--) : null,
                          ),
                          Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18, color: AppColors.deepBerry),
                            onPressed: () => setModalState(() => qty++),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Add button
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.richMagenta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                        label: Text(
                          'Add to Bag • \$${(item.priceUSD * qty).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          for (int i = 0; i < qty; i++) {
                            state.addToCart(merchant, item, notes: notesController.text);
                          }
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added $qty x ${item.name} to food bag'),
                              backgroundColor: AppColors.richMagenta,
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Cart & Simple Payment Modal (Pay on Delivery or Paid)
  // --------------------------------------------------------------------------
  void _openCartModal() {
    if (state.cartItems.isEmpty) return;

    FoodPaymentMethod selectedPayment = FoodPaymentMethod.payOnDelivery;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setCartState) {
          final totalUSD = state.cartTotalUSD;
          final totalKHR = state.cartTotalKHR;

          return Container(
            height: MediaQuery.of(context).size.height * 0.84,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Food Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
                          Text('From ${state.cartMerchant?.name ?? "Restaurant"}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(ctx).pop()),
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
                        // Delivery Address Card (Clickable to Edit / Change Destination)
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            _openAddressManagerSheet();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.blushTint.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.softPink.withValues(alpha: 0.6)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: AppColors.richMagenta, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textMuted)),
                                          SizedBox(width: 4),
                                          Icon(Icons.edit, size: 11, color: AppColors.richMagenta),
                                        ],
                                      ),
                                      Text(state.deliveryAddress, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.richMagenta.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Change', style: TextStyle(color: AppColors.richMagenta, fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Food Items List
                        const Text('Items in Bag', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        ...state.cartItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.menuItem.imageUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(width: 48, height: 48, color: AppColors.blushTint),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.menuItem.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      if (item.specialNotes.isNotEmpty)
                                        Text('Note: ${item.specialNotes}', style: const TextStyle(fontSize: 10, color: AppColors.richMagenta, fontStyle: FontStyle.italic)),
                                      Text('\$${item.menuItem.priceUSD.toStringAsFixed(2)} each', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                                      onPressed: () => setCartState(() => state.updateCartQuantity(item.menuItem.id, item.quantity - 1)),
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 18),
                                      onPressed: () => setCartState(() => state.updateCartQuantity(item.menuItem.id, item.quantity + 1)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 55,
                                  child: Text('\$${item.totalUSD.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 24),

                        // Promo Voucher Input
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _voucherController,
                                textCapitalization: TextCapitalization.characters,
                                decoration: InputDecoration(
                                  hintText: 'Voucher (e.g. WELCOME5, FREESHIP)',
                                  hintStyle: const TextStyle(fontSize: 11),
                                  prefixIcon: const Icon(Icons.local_offer_outlined, size: 18, color: AppColors.richMagenta),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepBerry,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                final applied = state.applyVoucher(_voucherController.text);
                                if (applied) {
                                  setCartState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('✓ Promo ${state.appliedVoucher!.code} applied!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invalid code. Try WELCOME5 or FREESHIP')),
                                  );
                                }
                              },
                              child: const Text('Apply'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Payment Method Selection: Pay by Delivery or Paid (Simplified)
                        const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildPaymentOption(
                              label: 'Pay by Delivery (COD)',
                              icon: Icons.payments_outlined,
                              selected: selectedPayment == FoodPaymentMethod.payOnDelivery,
                              onTap: () => setCartState(() => selectedPayment = FoodPaymentMethod.payOnDelivery),
                            ),
                            const SizedBox(width: 10),
                            _buildPaymentOption(
                              label: 'Paid (Card / Online)',
                              icon: Icons.credit_card,
                              selected: selectedPayment == FoodPaymentMethod.paid,
                              onTap: () => setCartState(() => selectedPayment = FoodPaymentMethod.paid),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Price Breakdown
                        _buildSummaryRow('Food Subtotal', '\$${state.cartSubtotalUSD.toStringAsFixed(2)}'),
                        _buildSummaryRow('Delivery Fee', '\$${state.cartDeliveryFeeUSD.toStringAsFixed(2)}'),
                        if (state.cartDiscountUSD > 0)
                          _buildSummaryRow('Discount Voucher', '-\$${state.cartDiscountUSD.toStringAsFixed(2)}', color: AppColors.success),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total Payable:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('\$${totalUSD.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.richMagenta)),
                                Text('${totalKHR.toStringAsFixed(0)} ៛', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Confirm & Place Order Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.richMagenta,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              selectedPayment == FoodPaymentMethod.paid ? 'Confirm Order • Paid (\$${totalUSD.toStringAsFixed(2)})' : 'Place Order • Pay by Delivery',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              if (!state.isCustomerLoggedIn) {
                                Navigator.of(ctx).pop();
                                _openAuthModal(initialIsRegister: false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please log in or register to place your food order.'),
                                    backgroundColor: AppColors.richMagenta,
                                  ),
                                );
                                return;
                              }
                              final order = state.placeOrder(paymentMethod: selectedPayment);
                              Navigator.of(ctx).pop();
                              setState(() {
                                _currentNavIndex = 1; // Auto-navigate to Tracking tab!
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✓ Order #${order.orderNumber} placed! Track your live delivery below.'),
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

  Widget _buildPaymentOption({required String label, required IconData icon, required bool selected, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.blushTint.withValues(alpha: 0.4) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.richMagenta : AppColors.borderLight, width: selected ? 2 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: selected ? AppColors.richMagenta : AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: selected ? AppColors.richMagenta : AppColors.textMain),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color ?? AppColors.textMain)),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Address & Delivery Location Management Bottom Sheet & Dialog
  // --------------------------------------------------------------------------
  void _openAddressManagerSheet() {
    final quickAddressCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final activeAddress = state.deliveryAddress;
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.blushTint.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.location_on, color: AppColors.richMagenta, size: 22),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery Location',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.deepBerry),
                                ),
                                Text(
                                  'Choose or enter your delivery address',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.deepBerry),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Currently Active Location Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.blushTint.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.richMagenta.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.richMagenta,
                                child: Icon(Icons.check, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CURRENT DESTINATION',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.richMagenta, letterSpacing: 0.5),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      activeAddress,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.deepBerry),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Quick Type / Search Address Input
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppColors.richMagenta, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: quickAddressCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter street, building, or district...',
                                    hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                  onSubmitted: (val) {
                                    if (val.trim().isNotEmpty) {
                                      state.setDeliveryAddress(val.trim());
                                      setSheetState(() {});
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.richMagenta,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  final text = quickAddressCtrl.text.trim();
                                  if (text.isNotEmpty) {
                                    state.setDeliveryAddress(text);
                                    quickAddressCtrl.clear();
                                    setSheetState(() {});
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Delivery address updated: $text'),
                                        backgroundColor: AppColors.richMagenta,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Apply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Quick Phnom Penh Hotspots
                        const Text('Quick Select Districts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepBerry)),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildHotspotChip('📍 BKK1', 'St 57, BKK1, Boeung Keng Kang, Phnom Penh', setSheetState),
                              _buildHotspotChip('📍 Daun Penh', 'Preah Sisowath Quay, Daun Penh, Phnom Penh', setSheetState),
                              _buildHotspotChip('📍 Toul Kork', 'St 315, Toul Kork, Phnom Penh', setSheetState),
                              _buildHotspotChip('📍 Russian Market', 'St 155, Tuol Tompoung, Phnom Penh', setSheetState),
                              _buildHotspotChip('📍 Tonle Bassac', 'Diamond Island (Koh Pich), Tonle Bassac, Phnom Penh', setSheetState),
                              _buildHotspotChip('📍 Sen Sok', 'AEON Mall Sen Sok, Phnom Penh', setSheetState),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Saved Addresses Header & Add Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Saved Addresses', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
                            TextButton.icon(
                              onPressed: () {
                                _openEditAddressDialog().then((_) {
                                  setSheetState(() {});
                                  setState(() {});
                                });
                              },
                              icon: const Icon(Icons.add, size: 16, color: AppColors.richMagenta),
                              label: const Text('Add Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.richMagenta)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Saved Addresses List
                        if (state.savedAddresses.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: const Text('No saved addresses yet. Tap "+ Add Address" above!', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          )
                        else
                          ...state.savedAddresses.map((addr) {
                            final isCurrent = addr.addressLine.trim().toLowerCase() == state.deliveryAddress.trim().toLowerCase();
                            IconData addrIcon = Icons.location_on_outlined;
                            if (addr.label.toLowerCase().contains('home')) {
                              addrIcon = Icons.home;
                            } else if (addr.label.toLowerCase().contains('work') || addr.label.toLowerCase().contains('office')) {
                              addrIcon = Icons.work_outline;
                            } else if (addr.label.toLowerCase().contains('condo') || addr.label.toLowerCase().contains('apt')) {
                              addrIcon = Icons.apartment;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isCurrent ? AppColors.blushTint.withValues(alpha: 0.25) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isCurrent ? AppColors.richMagenta : AppColors.borderLight,
                                  width: isCurrent ? 1.5 : 1.0,
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                leading: CircleAvatar(
                                  radius: 17,
                                  backgroundColor: isCurrent ? AppColors.richMagenta : AppColors.blushTint.withValues(alpha: 0.5),
                                  child: Icon(addrIcon, size: 18, color: isCurrent ? Colors.white : AppColors.richMagenta),
                                ),
                                title: Row(
                                  children: [
                                    Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepBerry)),
                                    if (addr.isDefault) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.richMagenta.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('DEFAULT', style: TextStyle(color: AppColors.richMagenta, fontSize: 9, fontWeight: FontWeight.w800)),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text(
                                  addr.addressLine,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMain),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
                                      tooltip: 'Edit Address',
                                      onPressed: () {
                                        _openEditAddressDialog(existing: addr).then((_) {
                                          setSheetState(() {});
                                          setState(() {});
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                      tooltip: 'Delete Address',
                                      onPressed: () async {
                                        await state.deleteCustomerAddress(addr.id);
                                        setSheetState(() {});
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  state.setDeliveryAddress(addr.addressLine);
                                  setSheetState(() {});
                                  setState(() {});
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Delivery destination: ${addr.addressLine}'),
                                      backgroundColor: AppColors.richMagenta,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                      ],
                    ),
                  ),

                  // Bottom Add Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.richMagenta,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          _openEditAddressDialog().then((_) {
                            setSheetState(() {});
                            setState(() {});
                          });
                        },
                        icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                        label: const Text('Add New Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHotspotChip(String label, String address, StateSetter setSheetState) {
    final isSelected = state.deliveryAddress.trim().toLowerCase() == address.trim().toLowerCase();
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        backgroundColor: isSelected ? AppColors.richMagenta : AppColors.blushTint.withValues(alpha: 0.3),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.deepBerry,
          ),
        ),
        onPressed: () {
          state.setDeliveryAddress(address);
          setSheetState(() {});
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delivery address set to: $address'),
              backgroundColor: AppColors.richMagenta,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openEditAddressDialog({CustomerDeliveryAddress? existing}) async {
    final isEditing = existing != null;
    String selectedLabel = existing?.label ?? 'Home';
    final addressLineCtrl = TextEditingController(text: existing?.addressLine ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? 'Phnom Penh');
    bool isDefault = existing?.isDefault ?? false;

    await showDialog(
      context: context,
      builder: (dlgContext) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.blushTint.withValues(alpha: 0.5),
                    child: Icon(
                      isEditing ? Icons.edit_location_alt : Icons.add_location_alt,
                      color: AppColors.richMagenta,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEditing ? 'Edit Address' : 'Add Address',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.deepBerry),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text('Address Label', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['Home', 'Work', 'Condo', 'Other'].map((lbl) {
                        final isSel = selectedLabel == lbl;
                        return ChoiceChip(
                          label: Text(lbl),
                          selected: isSel,
                          selectedColor: AppColors.richMagenta,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : AppColors.deepBerry,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) setDlgState(() => selectedLabel = lbl);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    const Text('Delivery Address Line', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: addressLineCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g. House 42, St 271, Boeng Tumpun, Phnom Penh',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.pin_drop_outlined, color: AppColors.richMagenta),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),

                    // Quick district chips to insert into address line
                    const Text('Quick Add Area:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        'BKK1',
                        'Daun Penh',
                        'Toul Kork',
                        'Tonle Bassac',
                        'Sen Sok',
                        'Tuol Tompoung',
                      ].map((area) {
                        return ActionChip(
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          label: Text('+ $area', style: const TextStyle(fontSize: 10, color: AppColors.deepBerry)),
                          onPressed: () {
                            setDlgState(() {
                              if (addressLineCtrl.text.isEmpty) {
                                addressLineCtrl.text = '$area, Phnom Penh';
                              } else if (!addressLineCtrl.text.contains(area)) {
                                addressLineCtrl.text = '${addressLineCtrl.text.trim()}, $area';
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    const Text('City / Province', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: cityCtrl,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_city_outlined, color: AppColors.richMagenta),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),

                    SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Set as default delivery address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      activeThumbColor: AppColors.richMagenta,
                      value: isDefault,
                      onChanged: (val) {
                        setDlgState(() => isDefault = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgContext),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.richMagenta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final addrText = addressLineCtrl.text.trim();
                    if (addrText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter an address line.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    if (isEditing) {
                      await state.updateCustomerAddress(
                        id: existing.id,
                        label: selectedLabel,
                        addressLine: addrText,
                        city: cityCtrl.text.trim().isEmpty ? 'Phnom Penh' : cityCtrl.text.trim(),
                        isDefault: isDefault,
                      );
                    } else {
                      await state.addCustomerAddress(
                        label: selectedLabel,
                        addressLine: addrText,
                        city: cityCtrl.text.trim().isEmpty ? 'Phnom Penh' : cityCtrl.text.trim(),
                        isDefault: isDefault,
                      );
                    }

                    if (isDefault) {
                      state.setDeliveryAddress(addrText);
                    }

                    if (!mounted || !dlgContext.mounted) return;
                    Navigator.pop(dlgContext);
                    setState(() {});

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing ? 'Address updated successfully!' : 'Address added successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: Text(isEditing ? 'Update' : 'Save Address', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // Main Build: Responsive Smartphone Frame on Desktop or Native Mobile
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: const Color(0xFF1B0713), // Ultra-dark plum canvas
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Banner
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.deepBerry,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softPink.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.phone_android, color: AppColors.vibrantPink, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Customer Mobile App Experience',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (widget.onSwitchPortal != null) ...[
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.softPink,
                          side: const BorderSide(color: AppColors.softPink),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        icon: const Icon(Icons.swap_horiz, size: 16),
                        label: const Text('Back to Merchant Controller', style: TextStyle(fontSize: 11)),
                        onPressed: widget.onSwitchPortal,
                      ),
                    ],
                  ],
                ),
              ),

              // Phone Frame
              Container(
                width: 395,
                height: 790,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(46),
                  border: Border.all(color: AppColors.vibrantPink.withValues(alpha: 0.35), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.richMagenta.withValues(alpha: 0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(42),
                  child: _buildPhoneContent(),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.canvasLight,
        body: _buildPhoneContent(),
      );
    }
  }

  // --------------------------------------------------------------------------
  // Inside the Phone App
  // --------------------------------------------------------------------------
  Widget _buildPhoneContent() {
    final activeOrdersCount = state.orders.where((o) => o.status != FoodOrderStatus.delivered && o.status != FoodOrderStatus.cancelled).length;

    return Container(
      color: AppColors.canvasLight,
      child: SafeArea(
        child: Column(
          children: [
            // Status bar notch simulation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('9:41', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textMain)),
                  Container(
                    width: 85,
                    height: 18,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
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

            // Top Header: Delivery Location, Live DB Pill & Avatar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _openAddressManagerSheet(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text('DELIVER TO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.richMagenta, letterSpacing: 0.8)),
                                SizedBox(width: 3),
                                Icon(Icons.edit_location_alt, size: 12, color: AppColors.richMagenta),
                                Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.richMagenta),
                              ],
                            ),
                            Text(
                              state.deliveryAddress,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepBerry),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Live MySQL Database Status Pill
                  InkWell(
                    onTap: () {
                      state.syncWithDatabase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.isDbConnected
                              ? '✓ Synced with MySQL pos_db (${state.merchants.length} stores)'
                              : 'Reconnecting to MySQL...'),
                          backgroundColor: AppColors.richMagenta,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: state.isDbConnected ? Colors.green.shade50 : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: state.isDbConnected ? Colors.green.shade300 : Colors.amber.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: state.isDbConnected ? Colors.green : Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            state.isDbConnected ? 'MySQL 8.0' : 'Offline',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: state.isDbConnected ? Colors.green.shade800 : Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.sync, size: 10, color: state.isDbConnected ? Colors.green.shade800 : Colors.amber.shade900),
                        ],
                      ),
                    ),
                  ),
                  if (state.isCustomerLoggedIn)
                    InkWell(
                      onTap: () => setState(() => _currentNavIndex = 2),
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: AppColors.deepBerry,
                        child: Text(
                          state.customerName.isNotEmpty ? state.customerName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    )
                  else
                    InkWell(
                      onTap: () => _openAuthModal(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.richMagenta,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: AppColors.richMagenta.withValues(alpha: 0.3), blurRadius: 4),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.login, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Text('Log In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Active Tab View Body
            Expanded(
              child: _buildCurrentNavTab(),
            ),

            // Floating Cart Bottom Bar (if items in cart)
            if (state.cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(top: BorderSide(color: AppColors.borderLight)),
                  boxShadow: [
                    BoxShadow(color: AppColors.deepBerry.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -3)),
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
                          '${state.cartItems.fold(0, (sum, i) => sum + i.quantity)} items in Bag',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        Text(
                          '\$${state.cartTotalUSD.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.deepBerry),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.richMagenta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.shopping_bag, size: 16),
                      label: const Text('View Bag & Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: _openCartModal,
                    ),
                  ],
                ),
              ),

            // ----------------------------------------------------------------
            // GENERAL APP BOTTOM NAVIGATION BAR: Home • Tracking • Profile
            // ----------------------------------------------------------------
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentNavIndex,
                onTap: (idx) {
                  setState(() {
                    _currentNavIndex = idx;
                    if (idx != 0) {
                      _viewingMerchant = null;
                    }
                  });
                },
                backgroundColor: Colors.white,
                elevation: 0,
                selectedItemColor: AppColors.richMagenta,
                unselectedItemColor: AppColors.textMuted,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                type: BottomNavigationBarType.fixed,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.delivery_dining_outlined),
                        if (activeOrdersCount > 0)
                          Positioned(
                            top: -2,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: AppColors.richMagenta, shape: BoxShape.circle),
                              child: Text(
                                '$activeOrdersCount',
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                    activeIcon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.delivery_dining),
                        if (activeOrdersCount > 0)
                          Positioned(
                            top: -2,
                            right: -6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: AppColors.richMagenta, shape: BoxShape.circle),
                              child: Text(
                                '$activeOrdersCount',
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: 'Tracking',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Router between Home, Tracking, and Profile Tabs
  // --------------------------------------------------------------------------
  Widget _buildCurrentNavTab() {
    switch (_currentNavIndex) {
      case 0:
        if (_viewingMerchant != null) {
          return _buildRestaurantDetailView(_viewingMerchant!);
        } else {
          return _buildHomeTab();
        }

      case 1:
        return _buildTrackingTab();

      case 2:
        return state.isCustomerLoggedIn
            ? _buildProfileSettingsTab()
            : _buildAuthTab();

      default:
        return _buildHomeTab();
    }
  }

  // --------------------------------------------------------------------------
  // TAB 0: HOME VIEW (Discovery, Search, Cuisines, Restaurants)
  // --------------------------------------------------------------------------
  Widget _buildHomeTab() {
    final filteredMerchants = state.merchants.where((m) {
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          m.name.toLowerCase().contains(q) ||
          m.khmerName.toLowerCase().contains(q) ||
          m.cuisine.toLowerCase().contains(q) ||
          m.address.toLowerCase().contains(q);

      final matchesCategory = _selectedCategory == 'All' ||
          m.cuisine.toLowerCase().contains(_selectedCategory.toLowerCase());

      final matchesOpen = !_filterOpenOnly || m.isOpen;
      final matchesRating = !_filterTopRatedOnly || m.rating >= 4.8;
      final matchesSpeed = !_filterFastDeliveryOnly || m.deliveryTimeMin <= 25;
      final matchesFee = !_filterLowFeeOnly || m.deliveryFeeUSD <= 1.50;

      return matchesSearch && matchesCategory && matchesOpen && matchesRating && matchesSpeed && matchesFee;
    }).toList();

    filteredMerchants.sort((a, b) {
      switch (_merchantSortBy) {
        case 'Fastest Delivery':
          return a.deliveryTimeMin.compareTo(b.deliveryTimeMin);
        case 'Delivery Fee: Low to High':
          return a.deliveryFeeUSD.compareTo(b.deliveryFeeUSD);
        case 'Name: A to Z':
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case 'Rating: High to Low':
        default:
          return b.rating.compareTo(a.rating);
      }
    });

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      children: [
        // Live Quick Alert if Order is Active
        if (state.activeTrackingOrder != null && state.activeTrackingOrder!.status != FoodOrderStatus.delivered) ...[
          InkWell(
            onTap: () => setState(() => _currentNavIndex = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.blushTint.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softPink),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delivery_dining, color: AppColors.richMagenta, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live Order #${state.activeTrackingOrder!.orderNumber} • ${state.activeTrackingOrder!.statusDisplay}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.deepBerry),
                    ),
                  ),
                  const Text('Track ➔', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.richMagenta)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Search Bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search food, dishes, or restaurants...',
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.richMagenta),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderLight)),
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: 12),

        // Food Categories Horizontal Scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(cat),
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
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),

        // Sort & Quick Filters Toolbar
        Row(
          children: [
            // Sort Dropdown Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.richMagenta),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _merchantSortBy,
                  isDense: true,
                  icon: const Icon(Icons.swap_vert, color: AppColors.richMagenta, size: 16),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.richMagenta),
                  items: const [
                    DropdownMenuItem(value: 'Rating: High to Low', child: Text('★ Top Rated')),
                    DropdownMenuItem(value: 'Fastest Delivery', child: Text('⚡ Fastest')),
                    DropdownMenuItem(value: 'Delivery Fee: Low to High', child: Text('🛵 Lowest Fee')),
                    DropdownMenuItem(value: 'Name: A to Z', child: Text('A - Z')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _merchantSortBy = val);
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Quick Filter Chips
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Open Now'),
                      selected: _filterOpenOnly,
                      selectedColor: AppColors.blushTint,
                      checkmarkColor: AppColors.richMagenta,
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: _filterOpenOnly ? FontWeight.bold : FontWeight.normal,
                        color: _filterOpenOnly ? AppColors.richMagenta : AppColors.textMain,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onSelected: (val) => setState(() => _filterOpenOnly = val),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: const Text('★ 4.8+'),
                      selected: _filterTopRatedOnly,
                      selectedColor: AppColors.blushTint,
                      checkmarkColor: AppColors.richMagenta,
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: _filterTopRatedOnly ? FontWeight.bold : FontWeight.normal,
                        color: _filterTopRatedOnly ? AppColors.richMagenta : AppColors.textMain,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onSelected: (val) => setState(() => _filterTopRatedOnly = val),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: const Text('≤ 25 min'),
                      selected: _filterFastDeliveryOnly,
                      selectedColor: AppColors.blushTint,
                      checkmarkColor: AppColors.richMagenta,
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: _filterFastDeliveryOnly ? FontWeight.bold : FontWeight.normal,
                        color: _filterFastDeliveryOnly ? AppColors.richMagenta : AppColors.textMain,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onSelected: (val) => setState(() => _filterFastDeliveryOnly = val),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      label: const Text('Fee ≤ \$1.50'),
                      selected: _filterLowFeeOnly,
                      selectedColor: AppColors.blushTint,
                      checkmarkColor: AppColors.richMagenta,
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: _filterLowFeeOnly ? FontWeight.bold : FontWeight.normal,
                        color: _filterLowFeeOnly ? AppColors.richMagenta : AppColors.textMain,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onSelected: (val) => setState(() => _filterLowFeeOnly = val),
                    ),
                    if (_filterOpenOnly || _filterTopRatedOnly || _filterFastDeliveryOnly || _filterLowFeeOnly || _selectedCategory != 'All') ...[
                      const SizedBox(width: 6),
                      ActionChip(
                        label: const Text('Clear', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.red.shade50,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onPressed: () => setState(() {
                          _filterOpenOnly = false;
                          _filterTopRatedOnly = false;
                          _filterFastDeliveryOnly = false;
                          _filterLowFeeOnly = false;
                          _selectedCategory = 'All';
                        }),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Featured Promo Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.richMagenta, AppColors.vibrantPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                      child: const Text('PROMO CODE: WELCOME5', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 6),
                    const Text('20% Off Your First Food Order!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                    const Text('Fast Motor Delivery • Pay by Delivery or Paid', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
              const Icon(Icons.fastfood, color: Colors.white, size: 36),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('Popular Restaurants Near You', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.deepBerry)),
        const SizedBox(height: 10),

        // Restaurant Cards
        ...filteredMerchants.map((merchant) {
          return InkWell(
            onTap: () => setState(() => _viewingMerchant = merchant),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(color: AppColors.richMagenta.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        child: Image.network(
                          merchant.bannerUrl,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(height: 130, color: AppColors.blushTint),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text('${merchant.deliveryTimeMin} min', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                merchant.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.deepBerry),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 12),
                                  const SizedBox(width: 3),
                                  Text('${merchant.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(merchant.khmerName, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(merchant.cuisine, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            const Spacer(),
                            Text('Delivery: \$${merchant.deliveryFeeUSD.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.richMagenta)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // TAB 1: TRACKING VIEW (Streamlined: Placed -> Delivering -> Delivered)
  // --------------------------------------------------------------------------
  Widget _buildTrackingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Food Order Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
        const Text('Live delivery progress automatically assigned to driver upon merchant approval.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 14),

        // Active Order Live Tracker (Only for logged-in user)
        if (state.isCustomerLoggedIn && state.activeTrackingOrder != null) ...[
          _buildDetailedLiveTrackingCard(state.activeTrackingOrder!),
          const SizedBox(height: 20),
        ] else if (state.isCustomerLoggedIn) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.delivery_dining, size: 36, color: AppColors.richMagenta),
                  SizedBox(height: 8),
                  Text('No Active Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.deepBerry)),
                  Text('Place a new order to track your food live.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Past Orders Section (Strictly Isolated to Logged-in Customer)
        const Text('Your Order History', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
        const SizedBox(height: 10),

        if (!state.isCustomerLoggedIn)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.lock_outline, size: 36, color: AppColors.richMagenta),
                  const SizedBox(height: 8),
                  const Text('Log In to View Your Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.deepBerry)),
                  const SizedBox(height: 4),
                  const Text('Your order history is private and individual to your account.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.richMagenta, foregroundColor: Colors.white),
                    onPressed: () => _openAuthModal(),
                    child: const Text('Log In / Register'),
                  ),
                ],
              ),
            ),
          )
        else if (state.customerOrders.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 36, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('No orders yet for ${state.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepBerry)),
                  const Text('Your completed orders will appear here.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          ...state.customerOrders.map((order) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(order.merchantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.deepBerry)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getOrderStatusColor(order.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          order.statusDisplay,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getOrderStatusColor(order.status)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Order #${order.orderNumber} • ${order.paymentDisplay} • ${order.orderTime.toString().substring(11, 16)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const Divider(height: 16),
                  ...order.items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${i.quantity}x ${i.menuItem.name}', style: const TextStyle(fontSize: 12)),
                        Text('\$${i.totalUSD.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  )),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: \$${order.totalUSD.toStringAsFixed(2)} (${order.totalKHR.toStringAsFixed(0)} ៛)', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.richMagenta)),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.richMagenta,
                          side: const BorderSide(color: AppColors.richMagenta),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          for (var item in order.items) {
                            state.addToCart(state.merchants.firstWhere((m) => m.id == order.merchantId), item.menuItem);
                          }
                          _openCartModal();
                        },
                        child: const Text('Reorder', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Streamlined 3-Stage Live Tracking Card (Placed -> Delivering -> Delivered)
  // --------------------------------------------------------------------------
  Widget _buildDetailedLiveTrackingCard(FoodOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: AppColors.richMagenta.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Live Pulse
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: order.status == FoodOrderStatus.delivered ? Colors.green : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('ORDER #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.deepBerry)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getOrderStatusColor(order.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.statusDisplay.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _getOrderStatusColor(order.status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Visual Delivery Progress Steps: Placed -> Delivering -> Delivered
          Row(
            children: [
              _buildProgressIconStep(active: true, icon: Icons.receipt_long, label: '1. Placed'),
              _buildProgressIconStep(active: order.status == FoodOrderStatus.delivering || order.status == FoodOrderStatus.delivered, icon: Icons.two_wheeler, label: '2. Delivering'),
              _buildProgressIconStep(active: order.status == FoodOrderStatus.delivered, icon: Icons.check_circle, label: '3. Delivered', isLast: true),
            ],
          ),
          const SizedBox(height: 16),

          // Assigned Driver Card (Clickable to mark done when delivered)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blushTint.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.softPink.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.deepBerry,
                  child: const Icon(Icons.two_wheeler, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry)),
                      Text(order.driverPlate, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      Text(order.paymentDisplay, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.richMagenta)),
                    ],
                  ),
                ),
                if (order.status == FoodOrderStatus.delivering)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.done_all, size: 14),
                    label: const Text('Mark Delivered', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      state.markOrderDelivered(order.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✓ Order marked as delivered! Enjoy your meal.'), backgroundColor: AppColors.success),
                      );
                    },
                  )
                else if (order.status == FoodOrderStatus.delivered)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text('Done', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIconStep({required bool active, required IconData icon, required String label, bool isLast = false}) {
    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: active ? AppColors.richMagenta : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: active ? Colors.white : Colors.grey),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 3,
                    color: active ? AppColors.richMagenta : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? AppColors.deepBerry : Colors.grey)),
        ],
      ),
    );
  }

  Color _getOrderStatusColor(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.pendingAcceptance:
        return Colors.orange;
      case FoodOrderStatus.delivering:
        return AppColors.richMagenta;
      case FoodOrderStatus.delivered:
        return AppColors.success;
      case FoodOrderStatus.cancelled:
        return AppColors.danger;
    }
  }

  // --------------------------------------------------------------------------
  // TAB 2: PROFILE & SETTINGS VIEW
  // --------------------------------------------------------------------------
  Widget _buildProfileSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User Profile Header Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.deepBerry, AppColors.richMagenta],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: AppColors.richMagenta.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  state.customerName.isNotEmpty ? state.customerName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.richMagenta),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.customerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(state.customerPhone, style: const TextStyle(color: AppColors.softPink, fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars, color: Colors.amberAccent, size: 14),
                          const SizedBox(width: 4),
                          Text('${state.membershipTier} Member • ${state.loyaltyPoints} Points', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Saved Delivery Addresses Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Delivery Addresses', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.deepBerry)),
            TextButton.icon(
              onPressed: () => _openEditAddressDialog(),
              icon: const Icon(Icons.add, size: 16, color: AppColors.richMagenta),
              label: const Text('Add New', style: TextStyle(color: AppColors.richMagenta, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (state.savedAddresses.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppColors.richMagenta, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(state.deliveryAddress, style: const TextStyle(fontSize: 12, color: AppColors.textMain)),
                ),
                TextButton(
                  onPressed: () => _openAddressManagerSheet(),
                  child: const Text('Manage', style: TextStyle(color: AppColors.richMagenta, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        else
          ...state.savedAddresses.map((addr) {
            final isCurrent = addr.addressLine.trim().toLowerCase() == state.deliveryAddress.trim().toLowerCase();
            IconData addrIcon = Icons.location_on_outlined;
            if (addr.label.toLowerCase().contains('home')) {
              addrIcon = Icons.home;
            } else if (addr.label.toLowerCase().contains('work') || addr.label.toLowerCase().contains('office')) {
              addrIcon = Icons.work_outline;
            } else if (addr.label.toLowerCase().contains('condo') || addr.label.toLowerCase().contains('apt')) {
              addrIcon = Icons.apartment;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.blushTint.withValues(alpha: 0.3) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent ? AppColors.richMagenta : AppColors.borderLight,
                  width: isCurrent ? 1.5 : 1.0,
                ),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: CircleAvatar(
                  radius: 17,
                  backgroundColor: isCurrent ? AppColors.richMagenta : AppColors.blushTint.withValues(alpha: 0.5),
                  child: Icon(addrIcon, size: 18, color: isCurrent ? Colors.white : AppColors.richMagenta),
                ),
                title: Row(
                  children: [
                    Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepBerry)),
                    if (addr.isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.richMagenta.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('DEFAULT', style: TextStyle(color: AppColors.richMagenta, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ],
                    if (isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('ACTIVE', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    addr.addressLine,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMain),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onTap: () {
                  state.setDeliveryAddress(addr.addressLine);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Delivery address set to: ${addr.addressLine}'),
                      backgroundColor: AppColors.richMagenta,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
                      tooltip: 'Edit Address',
                      onPressed: () => _openEditAddressDialog(existing: addr),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                      tooltip: 'Delete Address',
                      onPressed: () async {
                        await state.deleteCustomerAddress(addr.id);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Address deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        OutlinedButton.icon(
          onPressed: () => _openAddressManagerSheet(),
          icon: const Icon(Icons.map_outlined, size: 16, color: AppColors.richMagenta),
          label: const Text('Manage & Pick on Map / Presets', style: TextStyle(color: AppColors.richMagenta, fontSize: 12, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.richMagenta),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        const SizedBox(height: 16),

        // Payment Methods Section (Pay by Delivery or Paid)
        const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.deepBerry)),
        const SizedBox(height: 8),
        _buildProfileTile(
          icon: Icons.payments_outlined,
          title: 'Pay by Delivery (COD)',
          subtitle: 'Pay cash to driver upon food arrival',
          trailing: const Icon(Icons.check, color: AppColors.richMagenta, size: 18),
        ),
        _buildProfileTile(
          icon: Icons.credit_card,
          title: 'Paid (Online / Card)',
          subtitle: 'Prepaid digital checkout',
          trailing: const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
        ),
        const SizedBox(height: 16),

        // App Preferences & Settings
        const Text('App Preferences', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.deepBerry)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Push Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('Receive live delivery status alerts', style: TextStyle(fontSize: 11)),
                value: _notificationsEnabled,
                activeThumbColor: AppColors.richMagenta,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Language (ភាសា)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text(_selectedLanguage, style: const TextStyle(fontSize: 11, color: AppColors.richMagenta)),
                trailing: const Icon(Icons.language, size: 20),
                onTap: () {
                  setState(() {
                    _selectedLanguage = _selectedLanguage == 'English' ? 'ភាសាខ្មែរ (Khmer)' : 'English';
                  });
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Customer Support & Hotline', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('Telegram: @fooddelivery_kh • Hotline: 023 999 888', style: TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.headset_mic_outlined, size: 20, color: AppColors.deepBerry),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support Hotline: 023 999 888 (24/7 Service)')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Log Out Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Log Out of Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            onPressed: () {
              state.logoutCustomer();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You have logged out.')),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Quick Portal Switcher
        if (widget.onSwitchPortal != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.deepBerry,
                side: const BorderSide(color: AppColors.deepBerry),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.storefront, size: 18),
              label: const Text('Switch to Merchant Webpage Controller', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: widget.onSwitchPortal,
            ),
          ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildProfileTile({required IconData icon, required String title, required String subtitle, Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.blushTint.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.deepBerry, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepBerry)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        trailing: trailing,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Customer Auth Logic: Login & Register Handlers
  // --------------------------------------------------------------------------
  Future<void> _handleLogin({VoidCallback? onSuccess}) async {
    final identifier = _authPhoneCtrl.text.trim();
    final password = _authPassCtrl.text.trim();
    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number or email.')),
      );
      return;
    }

    setState(() => _isLoadingAuth = true);
    final res = await state.loginCustomer(identifier, password);
    if (!mounted) return;
    setState(() => _isLoadingAuth = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${res['message']}'),
          backgroundColor: AppColors.success,
        ),
      );
      onSuccess?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Login failed'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _handleRegister({VoidCallback? onSuccess}) async {
    final name = _authNameCtrl.text.trim();
    final phone = _authPhoneCtrl.text.trim();
    final email = _authEmailCtrl.text.trim();
    final password = _authPassCtrl.text.trim();
    final address = _authAddressCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name and phone number.')),
      );
      return;
    }

    setState(() => _isLoadingAuth = true);
    final res = await state.registerCustomer(
      name: name,
      phone: phone,
      email: email.isEmpty ? '$phone@smartfood.kh' : email,
      password: password.isEmpty ? '123456' : password,
      address: address.isEmpty ? 'Phnom Penh' : address,
    );
    if (!mounted) return;
    setState(() => _isLoadingAuth = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${res['message']}'),
          backgroundColor: AppColors.success,
        ),
      );
      onSuccess?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Registration failed'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _openAuthModal({bool initialIsRegister = false}) {
    setState(() => _isRegisterMode = initialIsRegister);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 16,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildAuthForm(
                    isModal: true,
                    onSuccess: () => Navigator.of(ctx).pop(),
                    onToggleMode: (isReg) => setModalState(() => _isRegisterMode = isReg),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Tab View for Unauthenticated User (Profile Tab when Logged Out)
  // --------------------------------------------------------------------------
  Widget _buildAuthTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildAuthForm(
          isModal: false,
          onToggleMode: (isReg) => setState(() => _isRegisterMode = isReg),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Modern Adobe Palette Register & Log In Form
  // --------------------------------------------------------------------------
  Widget _buildAuthForm({
    required bool isModal,
    VoidCallback? onSuccess,
    required void Function(bool) onToggleMode,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // App Logo Icon
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.deepBerry, AppColors.richMagenta],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.richMagenta.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          _isRegisterMode ? 'Create Customer Account' : 'Welcome to SmartFood',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.deepBerry),
        ),
        const SizedBox(height: 4),
        Text(
          _isRegisterMode
              ? 'Register now to earn +25 points and save delivery addresses'
              : 'Log in with your phone or email to track live orders',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),

        // Segmented Switcher (Log In vs Register)
        Container(
          decoration: BoxDecoration(
            color: AppColors.blushTint.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.softPink.withValues(alpha: 0.5)),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _isRegisterMode = false);
                    onToggleMode(false);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_isRegisterMode ? AppColors.richMagenta : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: !_isRegisterMode
                          ? [BoxShadow(color: AppColors.richMagenta.withValues(alpha: 0.3), blurRadius: 4)]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        color: !_isRegisterMode ? Colors.white : AppColors.deepBerry,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _isRegisterMode = true);
                    onToggleMode(true);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isRegisterMode ? AppColors.richMagenta : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _isRegisterMode
                          ? [BoxShadow(color: AppColors.richMagenta.withValues(alpha: 0.3), blurRadius: 4)]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: _isRegisterMode ? Colors.white : AppColors.deepBerry,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Form Fields
        if (!_isRegisterMode) ...[
          // Quick Demo Fill Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, size: 14, color: AppColors.richMagenta),
                    SizedBox(width: 4),
                    Text('1-Tap Demo Customer Logins:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.deepBerry)),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ActionChip(
                      avatar: const CircleAvatar(radius: 8, backgroundColor: AppColors.richMagenta, child: Text('B', style: TextStyle(fontSize: 8, color: Colors.white))),
                      label: const Text('Bopha Pich (010 334 556)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: AppColors.blushTint.withValues(alpha: 0.6),
                      onPressed: () {
                        setState(() {
                          _authPhoneCtrl.text = '010 334 556';
                          _authPassCtrl.text = '123456';
                        });
                        _handleLogin(onSuccess: onSuccess);
                      },
                    ),
                    ActionChip(
                      avatar: const CircleAvatar(radius: 8, backgroundColor: AppColors.deepBerry, child: Text('D', style: TextStyle(fontSize: 8, color: Colors.white))),
                      label: const Text('Dara Lim (098 765 432)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: AppColors.blushTint.withValues(alpha: 0.6),
                      onPressed: () {
                        setState(() {
                          _authPhoneCtrl.text = '098 765 432';
                          _authPassCtrl.text = '123456';
                        });
                        _handleLogin(onSuccess: onSuccess);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Log In Phone or Email
          TextField(
            controller: _authPhoneCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Phone Number or Email',
              hintText: 'e.g. 010 334 556',
              prefixIcon: const Icon(Icons.phone_android, color: AppColors.richMagenta, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Log In Password (Self-contained hide/unhide toggle while typing)
          PasswordInputField(
            controller: _authPassCtrl,
            label: 'Password',
            hint: 'Enter your password',
          ),
          const SizedBox(height: 16),

          // Log In Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.richMagenta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              icon: _isLoadingAuth ? const SizedBox.shrink() : const Icon(Icons.login, size: 18),
              label: _isLoadingAuth
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Log In to SmartFood', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              onPressed: _isLoadingAuth ? null : () => _handleLogin(onSuccess: onSuccess),
            ),
          ),
        ] else ...[
          // Register Fields
          TextField(
            controller: _authNameCtrl,
            decoration: InputDecoration(
              labelText: 'Full Name (ឈ្មោះពេញ)',
              hintText: 'e.g. Sreylis Sinoun (ស្រីលីស)',
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.richMagenta, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _authPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number (លេខទូរស័ព្ទ)',
              hintText: 'e.g. 012 999 888',
              prefixIcon: const Icon(Icons.phone, color: AppColors.richMagenta, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _authEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address (អ៊ីមែល - Optional)',
              hintText: 'e.g. user@gmail.com',
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.richMagenta, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),

          // Register Password (Self-contained hide/unhide toggle while typing)
          PasswordInputField(
            controller: _authPassCtrl,
            label: 'Password (ពាក្យសម្ងាត់)',
            hint: 'Create a password',
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _authAddressCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Delivery Address (អាសយដ្ឋានដឹកជញ្ជូន)',
              hintText: 'e.g. House 42, St 271, Boeng Tumpun, Phnom Penh',
              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.richMagenta, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Register Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.richMagenta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              icon: _isLoadingAuth ? const SizedBox.shrink() : const Icon(Icons.person_add_alt_1, size: 18),
              label: _isLoadingAuth
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create Account (+25 Points)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              onPressed: _isLoadingAuth ? null : () => _handleRegister(onSuccess: onSuccess),
            ),
          ),
        ],

        const SizedBox(height: 12),
        // Toggle Switch button
        TextButton(
          onPressed: () {
            setState(() => _isRegisterMode = !_isRegisterMode);
            onToggleMode(_isRegisterMode);
          },
          child: Text(
            _isRegisterMode ? 'Already have an account? Log In' : "Don't have an account? Register now",
            style: const TextStyle(color: AppColors.richMagenta, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Restaurant Detail & Menu View
  // --------------------------------------------------------------------------
  Widget _buildRestaurantDetailView(RestaurantMerchant merchant) {
    final merchantDishes = state.menuItems.where((i) => i.merchantId == merchant.id).toList();
    final Set<String> dishCategories = {'All'};
    for (final d in merchantDishes) {
      if (d.category.isNotEmpty) dishCategories.add(d.category);
    }

    final items = merchantDishes.where((i) {
      final matchesCat = _dishCategoryFilter == 'All' || i.category == _dishCategoryFilter;
      final q = _dishSearchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty || i.name.toLowerCase().contains(q) || i.description.toLowerCase().contains(q);
      return matchesCat && matchesSearch;
    }).toList();

    items.sort((a, b) {
      switch (_dishSortBy) {
        case 'Price: Low to High':
          return a.priceUSD.compareTo(b.priceUSD);
        case 'Price: High to Low':
          return b.priceUSD.compareTo(a.priceUSD);
        case 'Name: A to Z':
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case 'Recommended':
        default:
          return 0;
      }
    });

    return Column(
      children: [
        // Store Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.deepBerry),
                onPressed: () => setState(() {
                  _viewingMerchant = null;
                  _dishCategoryFilter = 'All';
                  _dishSearchQuery = '';
                }),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(merchant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.deepBerry), overflow: TextOverflow.ellipsis),
                    Text('${merchant.deliveryTimeMin} min • \$${merchant.deliveryFeeUSD.toStringAsFixed(2)} delivery • ${merchant.cuisine}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Dish Search & Sort Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search dishes in ${merchant.name}...',
                        hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.richMagenta),
                        filled: true,
                        fillColor: AppColors.canvasLight,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => setState(() => _dishSearchQuery = val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.blushTint.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.softPink),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _dishSortBy,
                        isDense: true,
                        icon: const Icon(Icons.swap_vert, size: 14, color: AppColors.richMagenta),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.richMagenta),
                        items: const [
                          DropdownMenuItem(value: 'Recommended', child: Text('Recommended')),
                          DropdownMenuItem(value: 'Price: Low to High', child: Text('\$ Low to High')),
                          DropdownMenuItem(value: 'Price: High to Low', child: Text('\$ High to Low')),
                          DropdownMenuItem(value: 'Name: A to Z', child: Text('A - Z')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _dishSortBy = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              if (dishCategories.length > 2) ...[
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: dishCategories.map((c) {
                      final isSel = _dishCategoryFilter == c;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(c),
                          selected: isSel,
                          selectedColor: AppColors.richMagenta,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 10,
                            color: isSel ? Colors.white : AppColors.textMain,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: isSel ? AppColors.richMagenta : AppColors.borderLight),
                          ),
                          onSelected: (_) => setState(() => _dishCategoryFilter = c),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No dishes found in this category'))
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: items.length,
                  itemBuilder: (ctx, idx) {
                    final item = items[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.borderLight),
                      ),
                      child: InkWell(
                        onTap: item.isAvailable ? () => _openItemDetailModal(merchant, item) : null,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 76,
                                  height: 76,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 76, height: 76, color: AppColors.blushTint),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepBerry), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(item.khmerName, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    const SizedBox(height: 4),
                                    Text(item.description, style: TextStyle(fontSize: 10, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('\$${item.priceUSD.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.richMagenta)),
                                        if (item.isAvailable)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: AppColors.richMagenta, borderRadius: BorderRadius.circular(8)),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.add, size: 12, color: Colors.white),
                                                SizedBox(width: 2),
                                                Text('Add', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          )
                                        else
                                          const Text('Sold Out', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
