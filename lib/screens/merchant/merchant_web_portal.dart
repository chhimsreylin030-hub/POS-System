import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/food_models.dart';
import '../../state/food_delivery_state.dart';
import '../../theme/app_colors.dart';

class MerchantWebPortal extends StatefulWidget {
  final VoidCallback onNavigateToAdmin;
  final VoidCallback onNavigateToCustomer;
  final VoidCallback onNavigateToDriver;
  final VoidCallback onLogout;

  const MerchantWebPortal({
    super.key,
    required this.onNavigateToAdmin,
    required this.onNavigateToCustomer,
    required this.onNavigateToDriver,
    required this.onLogout,
  });

  @override
  State<MerchantWebPortal> createState() => _MerchantWebPortalState();
}

class _MerchantWebPortalState extends State<MerchantWebPortal> {
  final FoodDeliveryState state = FoodDeliveryState();
  int _selectedTabIndex = 0; // 0: Live Orders, 1: Menu CRUD, 2: Store Profile

  // Order sorting & filtering
  String _orderStatusFilter = 'ALL'; // ALL, pendingAcceptance, delivering, delivered
  String _orderSearchQuery = '';
  String _orderSortBy = 'Newest First'; // 'Newest First', 'Oldest First', 'Highest Total ($)', 'Lowest Total ($)'

  // Menu item sorting & filtering
  String _menuSearchQuery = '';
  String _menuCategoryFilter = 'All';
  String _menuAvailabilityFilter = 'All'; // All, Available, Out of Stock
  String _menuSortBy = 'Name (A - Z)'; // 'Name (A - Z)', 'Price: Low to High', 'Price: High to Low'

  Timer? _ordersPollTimer;

  // Merchant Authentication (Login & Register Form)
  bool _isRegisterMode = false;
  bool _obscureLoginPass = true;
  bool _obscureRegPass = true;
  bool _obscureRegConfirmPass = true;
  bool _isLoadingMerchantAuth = false;

  // Merchant Login Controllers
  final TextEditingController _merchantEmailCtrl = TextEditingController(text: 'angkor.heritage@gmail.com');
  final TextEditingController _merchantPassCtrl = TextEditingController(text: '123456');

  // Merchant Registration Controllers
  final TextEditingController _regAccountNameCtrl = TextEditingController();
  final TextEditingController _regEmailCtrl = TextEditingController();
  final TextEditingController _regPhoneCtrl = TextEditingController();
  final TextEditingController _regCompanyNoCtrl = TextEditingController();
  final TextEditingController _regRestaurantNameCtrl = TextEditingController();
  final TextEditingController _regKhmerNameCtrl = TextEditingController();
  final TextEditingController _regCuisineCtrl = TextEditingController(text: 'Khmer Gourmet & Asian Cuisine');
  final TextEditingController _regAddressCtrl = TextEditingController(text: 'Phnom Penh, Cambodia');
  final TextEditingController _regPassCtrl = TextEditingController();
  final TextEditingController _regConfirmPassCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    state.addListener(_onStateChange);
    // Real-time Order Polling: Checks MySQL pos_db every 3 seconds for new orders
    _ordersPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      state.syncOrdersOnly();
    });
  }

  @override
  void dispose() {
    _ordersPollTimer?.cancel();
    state.removeListener(_onStateChange);
    _merchantEmailCtrl.dispose();
    _merchantPassCtrl.dispose();
    _regAccountNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regCompanyNoCtrl.dispose();
    _regRestaurantNameCtrl.dispose();
    _regKhmerNameCtrl.dispose();
    _regCuisineCtrl.dispose();
    _regAddressCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmPassCtrl.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  RestaurantMerchant get _currentMerchant {
    final allowed = state.currentMerchantRestaurants;
    if (allowed.isNotEmpty) {
      return allowed.firstWhere(
        (m) => m.id == state.activeMerchantId,
        orElse: () => allowed.first,
      );
    }
    return state.merchants.firstWhere((m) => m.id == state.activeMerchantId, orElse: () => state.merchants.first);
  }

  // --------------------------------------------------------------------------
  // Add / Edit Food Menu Dialog (CRUD)
  // --------------------------------------------------------------------------
  void _openAddEditDishDialog({FoodMenuItem? existingItem}) {
    final nameCtrl = TextEditingController(text: existingItem?.name ?? '');
    final khmerCtrl = TextEditingController(text: existingItem?.khmerName ?? '');
    final descCtrl = TextEditingController(text: existingItem?.description ?? '');
    final priceCtrl = TextEditingController(text: existingItem != null ? existingItem.priceUSD.toStringAsFixed(2) : '');
    final imgCtrl = TextEditingController(text: existingItem?.imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80');
    String selectedCat = existingItem?.category ?? 'Khmer Dishes';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(existingItem == null ? 'Add New Dish to Menu' : 'Edit Menu Item', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBerry)),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Dish Name (English)', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: khmerCtrl, decoration: const InputDecoration(labelText: 'Khmer Name (ឈ្មោះខ្មែរ)', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (\$ USD)', prefixText: '\$ ', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCat,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: ['Khmer Dishes', 'Coffee', 'Bakery', 'Burgers', 'Pizza', 'Appetizers', 'Drinks']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCat = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'Image Web URL', border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Short Description', border: OutlineInputBorder())),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.richMagenta, foregroundColor: Colors.white),
              onPressed: () {
                final price = double.tryParse(priceCtrl.text) ?? 3.50;
                if (existingItem == null) {
                  final newItem = FoodMenuItem(
                    id: 'dish-${DateTime.now().millisecondsSinceEpoch}',
                    merchantId: _currentMerchant.id,
                    name: nameCtrl.text.isEmpty ? 'New Dish' : nameCtrl.text,
                    khmerName: khmerCtrl.text.isEmpty ? 'ម្ហូបថ្មី' : khmerCtrl.text,
                    description: descCtrl.text,
                    priceUSD: price,
                    imageUrl: imgCtrl.text,
                    category: selectedCat,
                    isAvailable: true,
                  );
                  state.addMenuItem(newItem);
                } else {
                  final updated = existingItem.copyWith(
                    name: nameCtrl.text,
                    khmerName: khmerCtrl.text,
                    description: descCtrl.text,
                    priceUSD: price,
                    imageUrl: imgCtrl.text,
                    category: selectedCat,
                  );
                  state.updateMenuItem(updated);
                }
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✓ Menu item saved successfully!'), backgroundColor: AppColors.success),
                );
              },
              child: const Text('Save Dish'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!state.isMerchantLoggedIn) {
      return _buildMerchantLoginScreen();
    }

    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      body: Row(
        children: [
          // Sidebar (Webpage Controller Navigation)
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeaderBar(),
                if (state.lastNewOrderNotification != null) _buildNewOrderNotificationBanner(),
                Expanded(child: _buildCurrentTab()),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: _buildSidebarContent()),
    );
  }

  // --------------------------------------------------------------------------
  // Sidebar
  // --------------------------------------------------------------------------
  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: AppColors.deepBerry, // Palette: 59123E
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        // Brand Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.richMagenta,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppColors.vibrantPink.withValues(alpha: 0.3), blurRadius: 8),
                  ],
                ),
                child: const Icon(Icons.storefront, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.currentMerchantAccount?.accountName ?? 'MERCHANT ACCOUNT', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('🏪 ${_currentMerchant.name} (${state.currentMerchantRestaurants.length} Stores)', style: const TextStyle(color: AppColors.softPink, fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 1),

        // Navigation Links
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            children: [
              _buildNavItem(0, Icons.outdoor_grill_outlined, 'Live Kitchen Orders'),
              _buildNavItem(1, Icons.restaurant_menu, 'Menu & Dishes (CRUD)'),
              _buildNavItem(2, Icons.store_outlined, 'Restaurant Profile & Sales'),
            ],
          ),
        ),

        const Divider(color: Colors.white12, height: 1),

        // Fast Portal Links for easy demonstration
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.softPink,
                    side: const BorderSide(color: AppColors.softPink),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.phone_android, size: 16),
                  label: const Text('Customer App View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: widget.onNavigateToCustomer,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.two_wheeler, size: 16),
                  label: const Text('Driver Console (Static)', style: TextStyle(fontSize: 11)),
                  onPressed: widget.onNavigateToDriver,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedTabIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.richMagenta : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: AppColors.vibrantPink.withValues(alpha: 0.5)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : AppColors.softPink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Real-time Incoming Order Alert Banner
  // --------------------------------------------------------------------------
  Widget _buildNewOrderNotificationBanner() {
    final newOrder = state.lastNewOrderNotification;
    if (newOrder == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepBerry, AppColors.richMagenta],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.vibrantPink.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 750;

          final alertHeader = Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              const Text(
                '🔔 NEW LIVE ORDER RECEIVED!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.vibrantPink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  newOrder.orderNumber,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          );

          final detailsText = Text(
            'Customer: ${newOrder.customerName} (${newOrder.customerPhone}) • ${newOrder.items.length} items • \$${newOrder.totalUSD.toStringAsFixed(2)} • ${newOrder.paymentDisplay}',
            style: const TextStyle(color: AppColors.softPink, fontSize: 11, fontWeight: FontWeight.w500),
          );

          final actionButtons = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.deepBerry,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check_circle, size: 16, color: AppColors.richMagenta),
                label: const Text('Accept & Dispatch Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () {
                  state.merchantAcceptOrder(newOrder.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ Order #${newOrder.orderNumber} accepted! Driver ${newOrder.driverName} dispatched.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                tooltip: 'Dismiss alert',
                onPressed: () => state.dismissNewOrderNotification(),
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.notifications_active, color: AppColors.richMagenta, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          alertHeader,
                          const SizedBox(height: 2),
                          detailsText,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: actionButtons,
                ),
              ],
            );
          }

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_active, color: AppColors.richMagenta, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    alertHeader,
                    const SizedBox(height: 2),
                    detailsText,
                  ],
                ),
              ),
              const SizedBox(width: 12),
              actionButtons,
            ],
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Header Bar
  // --------------------------------------------------------------------------
  Widget _buildHeaderBar() {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth > 32 ? constraints.maxWidth - 32 : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isDesktop) ...[
                  Builder(
                    builder: (btnCtx) => IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.deepBerry),
                      tooltip: 'Toggle Navigation Menu',
                      onPressed: () => Scaffold.of(btnCtx).openDrawer(),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.blushTint.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Merchant Controller', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry)),
                ),
                const SizedBox(width: 10),

                // Store Selector Dropdown (Strictly Isolated to This Merchant Account's Stores)
                Builder(
                  builder: (context) {
                    final allowedStores = state.currentMerchantRestaurants;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: allowedStores.any((m) => m.id == state.activeMerchantId)
                              ? state.activeMerchantId
                              : (allowedStores.isNotEmpty ? allowedStores.first.id : '1'),
                          isDense: true,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry),
                          items: allowedStores.map((m) => DropdownMenuItem(
                            value: m.id,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: Text('🏪 ${m.name}', overflow: TextOverflow.ellipsis),
                            ),
                          )).toList(),
                          onChanged: (newId) {
                            if (newId != null) {
                              setState(() {
                                state.activeMerchantId = newId;
                                _menuCategoryFilter = 'All';
                              });
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),

                // MySQL Live Database Indicator & Sync
                InkWell(
                  onTap: () async {
                    await state.syncWithDatabase();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✓ Refreshed from MySQL (${state.merchants.length} stores, ${state.menuItems.length} dishes, ${state.orders.length} orders)'),
                        backgroundColor: AppColors.richMagenta,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: state.isDbConnected ? Colors.green.shade50 : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: state.isDbConnected ? Colors.green.shade300 : Colors.amber.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: state.isDbConnected ? Colors.green : Colors.amber, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          state.isDbConnected ? 'pos_db (Connected)' : 'Offline',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: state.isDbConnected ? Colors.green.shade800 : Colors.amber.shade900),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.sync, size: 12, color: AppColors.deepBerry),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Open/Closed badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: _currentMerchant.isOpen ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: _currentMerchant.isOpen ? Colors.green : Colors.red, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(
                        _currentMerchant.isOpen ? 'Kitchen Open' : 'Kitchen Closed',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _currentMerchant.isOpen ? Colors.green.shade800 : Colors.red.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(width: 20),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.deepBerry,
                    side: const BorderSide(color: AppColors.deepBerry),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  icon: const Icon(Icons.admin_panel_settings, size: 16),
                  label: const Text('Admin Portal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: widget.onNavigateToAdmin,
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Log Out', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    state.logoutMerchant();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out of merchant corporate account.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
}

  // --------------------------------------------------------------------------
  // Tab Router
  // --------------------------------------------------------------------------
  Widget _buildCurrentTab() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildKitchenOrdersTab();
      case 1:
        return _buildMenuCrudTab();
      case 2:
        return _buildStoreProfileTab();
      default:
        return _buildKitchenOrdersTab();
    }
  }

  // --------------------------------------------------------------------------
  // Tab 1: Kitchen Orders Display with Status Filters & Sorting
  // --------------------------------------------------------------------------
  Widget _buildKitchenOrdersTab() {
    final allMerchantOrders = state.orders.where((o) => o.merchantId == _currentMerchant.id).toList();

    final pendingCount = allMerchantOrders.where((o) => o.status == FoodOrderStatus.pendingAcceptance).length;
    final deliveringCount = allMerchantOrders.where((o) => o.status == FoodOrderStatus.delivering).length;
    final deliveredCount = allMerchantOrders.where((o) => o.status == FoodOrderStatus.delivered).length;

    final filteredOrders = allMerchantOrders.where((o) {
      final matchesStatus = _orderStatusFilter == 'ALL' ||
          (_orderStatusFilter == 'pendingAcceptance' && o.status == FoodOrderStatus.pendingAcceptance) ||
          (_orderStatusFilter == 'delivering' && o.status == FoodOrderStatus.delivering) ||
          (_orderStatusFilter == 'delivered' && o.status == FoodOrderStatus.delivered);
      final q = _orderSearchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          o.orderNumber.toLowerCase().contains(q) ||
          o.customerName.toLowerCase().contains(q) ||
          o.customerPhone.contains(q);
      return matchesStatus && matchesSearch;
    }).toList();

    filteredOrders.sort((a, b) {
      switch (_orderSortBy) {
        case 'Oldest First':
          return a.orderTime.compareTo(b.orderTime);
        case 'Highest Total (\$)':
          return b.totalUSD.compareTo(a.totalUSD);
        case 'Lowest Total (\$)':
          return a.totalUSD.compareTo(b.totalUSD);
        case 'Newest First':
        default:
          return b.orderTime.compareTo(a.orderTime);
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kitchen Order Pipeline • ${_currentMerchant.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
                    const Text('Manage live customer food orders from MySQL database in real-time.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.richMagenta, foregroundColor: Colors.white),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Orders'),
                onPressed: () => state.syncWithDatabase(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search & Filter Toolbar
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final sortDropdownWidget = Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sort, size: 16, color: AppColors.richMagenta),
                            const SizedBox(width: 6),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _orderSortBy,
                                isDense: true,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry),
                                items: const [
                                  DropdownMenuItem(value: 'Newest First', child: Text('Newest')),
                                  DropdownMenuItem(value: 'Oldest First', child: Text('Oldest')),
                                  DropdownMenuItem(value: 'Highest Total (\$)', child: Text('High \$')),
                                  DropdownMenuItem(value: 'Lowest Total (\$)', child: Text('Low \$')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _orderSortBy = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      );

                      if (constraints.maxWidth < 600) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Search by Order #, Customer Name, or Phone...',
                                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.richMagenta),
                                filled: true,
                                fillColor: AppColors.canvasLight,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              onChanged: (val) => setState(() => _orderSearchQuery = val),
                            ),
                            const SizedBox(height: 10),
                            sortDropdownWidget,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search by Order #, Customer Name, or Phone...',
                                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.richMagenta),
                                filled: true,
                                fillColor: AppColors.canvasLight,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              onChanged: (val) => setState(() => _orderSearchQuery = val),
                            ),
                          ),
                          const SizedBox(width: 14),
                          sortDropdownWidget,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Order Status Tabs (Horizontal Scrollable)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusFilterChip('ALL', 'All Orders (${allMerchantOrders.length})', null),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip('pendingAcceptance', 'Pending ($pendingCount)', Colors.orange),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip('delivering', 'Delivering ($deliveringCount)', AppColors.richMagenta),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip('delivered', 'Delivered ($deliveredCount)', AppColors.success),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (filteredOrders.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('No orders match your filter criteria for ${_currentMerchant.name}.', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredOrders.length,
              itemBuilder: (ctx, idx) {
                final order = filteredOrders[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.deepBerry)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _getOrderColor(order.status).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: _getOrderColor(order.status)),
                                  ),
                                  child: Text(
                                    order.statusDisplay,
                                    style: TextStyle(color: _getOrderColor(order.status), fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            Text('\$${order.totalUSD.toStringAsFixed(2)} (${order.totalKHR.toStringAsFixed(0)} ៛)', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.richMagenta)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Customer: ${order.customerName} (${order.customerPhone}) • Address: ${order.deliveryAddress}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const Divider(height: 20),

                        // Order items
                        ...order.items.map((i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              children: [
                                Text('${i.quantity}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.richMagenta)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          i.menuItem.name,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (i.specialNotes.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(6)),
                                            child: Text('Note: ${i.specialNotes}', style: TextStyle(fontSize: 10, color: Colors.amber.shade900, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('\$${i.totalUSD.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 16),

                        // Kitchen Action Buttons
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (order.status == FoodOrderStatus.pendingAcceptance) ...[
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.richMagenta, foregroundColor: Colors.white),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Accept & Assign Driver'),
                                  onPressed: () => state.merchantAcceptOrder(order.id),
                                ),
                              ] else if (order.status == FoodOrderStatus.delivering) ...[
                                Text('🛵 ${order.driverName} • Delivering', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepBerry)),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                                  icon: const Icon(Icons.done_all, size: 16),
                                  label: const Text('Mark Delivered'),
                                  onPressed: () => state.markOrderDelivered(order.id),
                                ),
                              ] else ...[
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                                    SizedBox(width: 6),
                                    Text('Completed & Delivered', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(String key, String label, Color? color) {
    final isSelected = _orderStatusFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color?.withValues(alpha: 0.15) ?? AppColors.blushTint,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? (color ?? AppColors.richMagenta) : AppColors.textMain,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? (color ?? AppColors.richMagenta) : AppColors.borderLight),
      ),
      onSelected: (_) => setState(() => _orderStatusFilter = key),
    );
  }

  Color _getOrderColor(FoodOrderStatus status) {
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
  // Tab 2: Menu CRUD with Search, Filter & Sort
  // --------------------------------------------------------------------------
  Widget _buildMenuCrudTab() {
    final merchantItems = state.menuItems.where((i) => i.merchantId == _currentMerchant.id).toList();

    final Set<String> menuCats = {'All'};
    for (final i in merchantItems) {
      if (i.category.isNotEmpty) menuCats.add(i.category);
    }

    final filteredItems = merchantItems.where((i) {
      final q = _menuSearchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          i.name.toLowerCase().contains(q) ||
          i.khmerName.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q);
      final matchesCategory = _menuCategoryFilter == 'All' || i.category == _menuCategoryFilter;
      final matchesAvailability = _menuAvailabilityFilter == 'All' ||
          (_menuAvailabilityFilter == 'Available' && i.isAvailable) ||
          (_menuAvailabilityFilter == 'Out of Stock' && !i.isAvailable);
      return matchesSearch && matchesCategory && matchesAvailability;
    }).toList();

    filteredItems.sort((a, b) {
      switch (_menuSortBy) {
        case 'Price: Low to High':
          return a.priceUSD.compareTo(b.priceUSD);
        case 'Price: High to Low':
          return b.priceUSD.compareTo(a.priceUSD);
        case 'Name (A - Z)':
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Restaurant Menu Catalog • ${_currentMerchant.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
                    Text('${filteredItems.length} of ${merchantItems.length} products shown (synced with MySQL pos_db).', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.richMagenta, foregroundColor: Colors.white),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New Dish'),
                onPressed: () => _openAddEditDishDialog(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Menu Search & Filter Toolbar
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final availabilityDropdown = Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _menuAvailabilityFilter,
                            isDense: true,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Stock Status')),
                              DropdownMenuItem(value: 'Available', child: Text('Available Only')),
                              DropdownMenuItem(value: 'Out of Stock', child: Text('Sold Out Only')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _menuAvailabilityFilter = val);
                            },
                          ),
                        ),
                      );

                      final sortDropdown = Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sort, size: 16, color: AppColors.richMagenta),
                            const SizedBox(width: 6),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _menuSortBy,
                                isDense: true,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry),
                                items: const [
                                  DropdownMenuItem(value: 'Name (A - Z)', child: Text('Sort: A - Z')),
                                  DropdownMenuItem(value: 'Price: Low to High', child: Text('Sort: \$ Low to High')),
                                  DropdownMenuItem(value: 'Price: High to Low', child: Text('Sort: \$ High to Low')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _menuSortBy = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      );

                      if (constraints.maxWidth < 650) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Search dishes by name or ingredients...',
                                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.richMagenta),
                                filled: true,
                                fillColor: AppColors.canvasLight,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              onChanged: (val) => setState(() => _menuSearchQuery = val),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                availabilityDropdown,
                                sortDropdown,
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search dishes by name or ingredients...',
                                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.richMagenta),
                                filled: true,
                                fillColor: AppColors.canvasLight,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              onChanged: (val) => setState(() => _menuSearchQuery = val),
                            ),
                          ),
                          const SizedBox(width: 14),
                          availabilityDropdown,
                          const SizedBox(width: 10),
                          sortDropdown,
                        ],
                      );
                    },
                  ),

                  // Category Chips (if available)
                  if (menuCats.length > 2) ...[
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: menuCats.map((cat) {
                          final isSel = _menuCategoryFilter == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSel,
                              selectedColor: AppColors.richMagenta,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                fontSize: 11,
                                color: isSel ? Colors.white : AppColors.textMain,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: isSel ? AppColors.richMagenta : AppColors.borderLight),
                              ),
                              onSelected: (_) => setState(() => _menuCategoryFilter = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Dishes Grid
          if (filteredItems.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.restaurant_menu, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('No dishes match your filter criteria for ${_currentMerchant.name}.', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                childAspectRatio: 0.82,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (ctx, idx) {
                final item = filteredItems[idx];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          item.imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(height: 120, color: AppColors.blushTint),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepBerry), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: 6),
                                Text('\$${item.priceUSD.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.richMagenta)),
                              ],
                            ),
                            Text(item.khmerName, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(item.isAvailable ? 'Available' : 'Sold Out', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.isAvailable ? Colors.green : Colors.red), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                                Switch(
                                  value: item.isAvailable,
                                  activeThumbColor: AppColors.richMagenta,
                                  onChanged: (_) => state.toggleItemAvailability(item.id),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.deepBerry),
                                  onPressed: () => _openAddEditDishDialog(existingItem: item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                  onPressed: () => state.deleteMenuItem(item.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Tab 3: Store Profile & Sales
  // --------------------------------------------------------------------------
  Widget _buildStoreProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Restaurant Settings & Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
          const SizedBox(height: 16),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(_currentMerchant.logoUrl),
                          ),
                          const SizedBox(width: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_currentMerchant.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.deepBerry), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(_currentMerchant.khmerName, style: const TextStyle(fontSize: 12, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('${_currentMerchant.cuisine} • Rating: ${_currentMerchant.rating} ★', style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Kitchen Toggle
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentMerchant.isOpen ? AppColors.richMagenta : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(_currentMerchant.isOpen ? Icons.check_circle : Icons.pause_circle),
                        label: Text(_currentMerchant.isOpen ? 'Store is Open' : 'Store is Paused'),
                        onPressed: () => state.toggleMerchantOpen(_currentMerchant.id),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 650) {
                        return Column(
                          children: [
                            _buildStatBox("Today's Gross Sales", '\$${_currentMerchant.totalSalesUSD.toStringAsFixed(2)}', isExpanded: false),
                            const SizedBox(height: 10),
                            _buildStatBox('Local Currency (៛)', '${state.usdToKhr(_currentMerchant.totalSalesUSD).toStringAsFixed(0)} ៛', isExpanded: false),
                            const SizedBox(height: 10),
                            _buildStatBox('Standard Delivery Fee', '\$${_currentMerchant.deliveryFeeUSD.toStringAsFixed(2)}', isExpanded: false),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          _buildStatBox("Today's Gross Sales", '\$${_currentMerchant.totalSalesUSD.toStringAsFixed(2)}', isExpanded: true),
                          const SizedBox(width: 14),
                          _buildStatBox('Local Currency (៛)', '${state.usdToKhr(_currentMerchant.totalSalesUSD).toStringAsFixed(0)} ៛', isExpanded: true),
                          const SizedBox(width: 14),
                          _buildStatBox('Standard Delivery Fee', '\$${_currentMerchant.deliveryFeeUSD.toStringAsFixed(2)}', isExpanded: true),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String val, {bool isExpanded = true}) {
    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blushTint.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.softPink.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
        ],
      ),
    );
    if (isExpanded) {
      return Expanded(child: box);
    }
    return box;
  }

  // --------------------------------------------------------------------------
  // Multi-Tenant Merchant Corporate Partner Authentication Screen (Login / Register)
  // --------------------------------------------------------------------------
  Widget _buildMerchantLoginScreen() {
    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Navigation Shortcut Bar
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.richMagenta,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.storefront, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SmartFood Merchant',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.deepBerry),
                              ),
                              Text(
                                'Partner Portal & Kitchen Terminal',
                                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.deepBerry,
                              side: const BorderSide(color: AppColors.deepBerry),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.phone_android, size: 16),
                            label: const Text('Customer App', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: widget.onNavigateToCustomer,
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.deepBerry,
                              side: const BorderSide(color: AppColors.borderLight),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.admin_panel_settings, size: 16),
                            label: const Text('Admin', style: TextStyle(fontSize: 11)),
                            onPressed: widget.onNavigateToAdmin,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Brand Hero Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
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
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isRegisterMode ? 'Merchant Partner Registration' : 'Merchant Partner Login',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isRegisterMode
                                    ? 'Register your company and launch your restaurant on the SmartFood platform.'
                                    : 'Sign in to access your kitchen terminal, live orders, and menu catalog.',
                                style: const TextStyle(color: AppColors.softPink, fontSize: 11, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Toggle Segment: Sign In vs Register
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => setState(() => _isRegisterMode = false),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !_isRegisterMode ? AppColors.richMagenta : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !_isRegisterMode
                                    ? [BoxShadow(color: AppColors.richMagenta.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login, size: 16, color: !_isRegisterMode ? Colors.white : AppColors.textMuted),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Merchant Sign In',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: !_isRegisterMode ? Colors.white : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => setState(() => _isRegisterMode = true),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _isRegisterMode ? AppColors.richMagenta : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _isRegisterMode
                                    ? [BoxShadow(color: AppColors.richMagenta.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.app_registration, size: 16, color: _isRegisterMode ? Colors.white : AppColors.textMuted),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Register Partner',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: _isRegisterMode ? Colors.white : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Auth Card Container (Login or Register Form)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isRegisterMode ? _buildMerchantRegisterForm() : _buildMerchantLoginForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Merchant Sign In Form
  // --------------------------------------------------------------------------
  Widget _buildMerchantLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.deepBerry),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter your corporate email or account ID to log into your merchant terminal.',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),

        // Corporate Email or Account ID
        TextField(
          controller: _merchantEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Corporate Email or Account ID',
            hintText: 'e.g. angkor.heritage@gmail.com',
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.richMagenta, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        const SizedBox(height: 14),

        // Password
        TextField(
          controller: _merchantPassCtrl,
          obscureText: _obscureLoginPass,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.richMagenta, size: 20),
            suffixIcon: IconButton(
              icon: Icon(_obscureLoginPass ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted, size: 20),
              onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        const SizedBox(height: 14),

        // Quick Demo Fill Chips
        const Text(
          'Quick Demo Accounts (1-Tap Login):',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ActionChip(
              avatar: const Icon(Icons.store, size: 14, color: AppColors.deepBerry),
              label: const Text('Angkor Heritage (ID #1)', style: TextStyle(fontSize: 11)),
              backgroundColor: AppColors.blushTint,
              onPressed: () {
                _merchantEmailCtrl.text = 'angkor.heritage@gmail.com';
                _merchantPassCtrl.text = '123456';
              },
            ),
            ActionChip(
              avatar: const Icon(Icons.coffee, size: 14, color: AppColors.deepBerry),
              label: const Text('Brown Coffee (ID #2)', style: TextStyle(fontSize: 11)),
              backgroundColor: AppColors.blushTint,
              onPressed: () {
                _merchantEmailCtrl.text = 'artisan.coffee@gmail.com';
                _merchantPassCtrl.text = '123456';
              },
            ),
            ActionChip(
              avatar: const Icon(Icons.fastfood, size: 14, color: AppColors.deepBerry),
              label: const Text('Burger Labs (ID #3)', style: TextStyle(fontSize: 11)),
              backgroundColor: AppColors.blushTint,
              onPressed: () {
                _merchantEmailCtrl.text = 'smash.burger@gmail.com';
                _merchantPassCtrl.text = '123456';
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.richMagenta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isLoadingMerchantAuth ? const SizedBox.shrink() : const Icon(Icons.login, size: 18),
            label: _isLoadingMerchantAuth
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Sign In to Merchant Terminal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: _isLoadingMerchantAuth ? null : () => _handleMerchantLogin(),
          ),
        ),
        const SizedBox(height: 14),

        // Switch to Register prompt
        Center(
          child: TextButton(
            onPressed: () => setState(() => _isRegisterMode = true),
            child: const Text(
              "Don't have a merchant account? Register partner here",
              style: TextStyle(color: AppColors.richMagenta, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Merchant Registration Form
  // --------------------------------------------------------------------------
  Widget _buildMerchantRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Register Corporate Merchant',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.deepBerry),
        ),
        const SizedBox(height: 4),
        const Text(
          'Create a corporate merchant account and list your restaurant on SmartFood.',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 18),

        // Company Name
        TextField(
          controller: _regAccountNameCtrl,
          decoration: InputDecoration(
            labelText: 'Company / Corporate Name *',
            hintText: 'e.g. Siem Reap Culinary Ventures',
            prefixIcon: const Icon(Icons.business, color: AppColors.richMagenta, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),

        // Business Email & Phone
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _regEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Corporate Email *',
                  hintText: 'partner@company.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.richMagenta, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _regPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Business Phone *',
                  hintText: '+855 12 888 999',
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.richMagenta, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Company Registration No.
        TextField(
          controller: _regCompanyNoCtrl,
          decoration: InputDecoration(
            labelText: 'Company Registration Number (Optional)',
            hintText: 'e.g. MO-2026-9912',
            prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.richMagenta, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),

        // Divider with label
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Primary Restaurant Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.deepBerry.withValues(alpha: 0.8)),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),

        // Restaurant Name (English & Khmer)
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _regRestaurantNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Restaurant Name (English) *',
                  hintText: 'e.g. Angkor BBQ & Grill',
                  prefixIcon: const Icon(Icons.restaurant, color: AppColors.richMagenta, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _regKhmerNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Khmer Name (Optional)',
                  hintText: 'e.g. អង្គរ អាំង',
                  prefixIcon: const Icon(Icons.translate, color: AppColors.richMagenta, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Cuisine & Address
        TextField(
          controller: _regCuisineCtrl,
          decoration: InputDecoration(
            labelText: 'Cuisine Category',
            hintText: 'e.g. Traditional Khmer Dishes • Seafood',
            prefixIcon: const Icon(Icons.dinner_dining, color: AppColors.richMagenta, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _regAddressCtrl,
          decoration: InputDecoration(
            labelText: 'Restaurant Address *',
            hintText: 'e.g. St 271, Boeng Tumpun, Phnom Penh',
            prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.richMagenta, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),

        // Password & Confirm Password
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _regPassCtrl,
                obscureText: _obscureRegPass,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.richMagenta, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureRegPass ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted, size: 18),
                    onPressed: () => setState(() => _obscureRegPass = !_obscureRegPass),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _regConfirmPassCtrl,
                obscureText: _obscureRegConfirmPass,
                decoration: InputDecoration(
                  labelText: 'Confirm Password *',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.richMagenta, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureRegConfirmPass ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted, size: 18),
                    onPressed: () => setState(() => _obscureRegConfirmPass = !_obscureRegConfirmPass),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Register Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.richMagenta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isLoadingMerchantAuth ? const SizedBox.shrink() : const Icon(Icons.how_to_reg, size: 18),
            label: _isLoadingMerchantAuth
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Register Partner & Open Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: _isLoadingMerchantAuth ? null : () => _handleMerchantRegister(),
          ),
        ),
        const SizedBox(height: 12),

        // Switch back to Login
        Center(
          child: TextButton(
            onPressed: () => setState(() => _isRegisterMode = false),
            child: const Text(
              'Already have a merchant account? Sign In here',
              style: TextStyle(color: AppColors.richMagenta, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // Merchant Corporate Account Login Handler
  // --------------------------------------------------------------------------
  Future<void> _handleMerchantLogin() async {
    final identifier = _merchantEmailCtrl.text.trim();
    final pass = _merchantPassCtrl.text.trim();

    if (identifier.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _isLoadingMerchantAuth = true);
    final res = await state.loginMerchant(identifier, pass);
    if (!mounted) return;
    setState(() => _isLoadingMerchantAuth = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${res['message']} (Access granted to ${state.currentMerchantRestaurants.length} stores)'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Login failed'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  // --------------------------------------------------------------------------
  // Merchant Corporate Account Registration Handler
  // --------------------------------------------------------------------------
  Future<void> _handleMerchantRegister() async {
    final accName = _regAccountNameCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final phone = _regPhoneCtrl.text.trim();
    final restName = _regRestaurantNameCtrl.text.trim();
    final pass = _regPassCtrl.text.trim();
    final confirmPass = _regConfirmPassCtrl.text.trim();

    if (accName.isEmpty || email.isEmpty || phone.isEmpty || restName.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields (*)'), backgroundColor: AppColors.danger),
      );
      return;
    }

    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppColors.danger),
      );
      return;
    }

    setState(() => _isLoadingMerchantAuth = true);
    final res = await state.registerMerchant(
      accountName: accName,
      email: email,
      phone: phone,
      password: pass,
      companyRegNumber: _regCompanyNoCtrl.text.trim().isNotEmpty ? _regCompanyNoCtrl.text.trim() : null,
      restaurantName: restName,
      khmerName: _regKhmerNameCtrl.text.trim().isNotEmpty ? _regKhmerNameCtrl.text.trim() : null,
      cuisine: _regCuisineCtrl.text.trim().isNotEmpty ? _regCuisineCtrl.text.trim() : 'Khmer Cuisine',
      address: _regAddressCtrl.text.trim().isNotEmpty ? _regAddressCtrl.text.trim() : 'Phnom Penh, Cambodia',
    );
    if (!mounted) return;
    setState(() => _isLoadingMerchantAuth = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${res['message']}'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Registration failed'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
