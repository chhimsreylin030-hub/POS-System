import 'package:flutter/material.dart';
import '../../models/food_models.dart';
import '../../state/food_delivery_state.dart';
import '../../theme/app_colors.dart';

class AdminWebPortal extends StatefulWidget {
  final VoidCallback onNavigateToMerchant;
  final VoidCallback onNavigateToCustomer;
  final VoidCallback onNavigateToDriver;
  final VoidCallback onLogout;

  const AdminWebPortal({
    super.key,
    required this.onNavigateToMerchant,
    required this.onNavigateToCustomer,
    required this.onNavigateToDriver,
    required this.onLogout,
  });

  @override
  State<AdminWebPortal> createState() => _AdminWebPortalState();
}

class _AdminWebPortalState extends State<AdminWebPortal> {
  final FoodDeliveryState state = FoodDeliveryState();
  int _selectedTabIndex = 0; // 0: Dashboard, 1: Merchants, 2: Drivers (Static), 3: Vouchers

  @override
  void initState() {
    super.initState();
    state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    state.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  // Add Voucher Dialog
  void _openAddVoucherDialog() {
    final codeCtrl = TextEditingController();
    final discountCtrl = TextEditingController(text: '15');
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create Platform Promo Voucher', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepBerry)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Voucher Code (e.g. FOODIE20)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: discountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Discount Percentage (%)', suffixText: '%', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description / Terms', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.richMagenta, foregroundColor: Colors.white),
            onPressed: () {
              if (codeCtrl.text.isNotEmpty) {
                final discount = double.tryParse(discountCtrl.text) ?? 10.0;
                state.addVoucher(PromoVoucher(code: codeCtrl.text.toUpperCase(), discountPercent: discount, description: descCtrl.text));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✓ Voucher created!'), backgroundColor: AppColors.success));
              }
            },
            child: const Text('Create Voucher'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeaderBar(),
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
      color: AppColors.deepBerry, // 59123E
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
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
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SUPER ADMIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0)),
                  Text('Food Platform Controller', style: TextStyle(color: AppColors.softPink, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 1),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            children: [
              _buildNavItem(0, Icons.dashboard_outlined, 'Platform Overview'),
              _buildNavItem(1, Icons.storefront_outlined, 'Merchants & Restaurants'),
              _buildNavItem(2, Icons.two_wheeler_outlined, 'Driver Fleet (Static)'),
              _buildNavItem(3, Icons.local_offer_outlined, 'Vouchers & Promotions'),
            ],
          ),
        ),

        const Divider(color: Colors.white12, height: 1),

        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.richMagenta,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.storefront, size: 16),
                  label: const Text('Merchant Portal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: widget.onNavigateToMerchant,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.softPink,
                    side: const BorderSide(color: AppColors.softPink),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.phone_android, size: 16),
                  label: const Text('Customer Mobile App', style: TextStyle(fontSize: 11)),
                  onPressed: widget.onNavigateToCustomer,
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.blushTint.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Corporate Super Admin Controller', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry)),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.richMagenta,
                    side: const BorderSide(color: AppColors.richMagenta),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  icon: const Icon(Icons.two_wheeler, size: 16),
                  label: const Text('Driver Console (Static)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: widget.onNavigateToDriver,
                ),
                const SizedBox(width: 10),
                IconButton(icon: const Icon(Icons.logout, color: AppColors.richMagenta), tooltip: 'Logout', onPressed: widget.onLogout),
              ],
            ),
          ],
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
        return _buildPlatformOverviewTab();
      case 1:
        return _buildMerchantsTab();
      case 2:
        return _buildDriversTab();
      case 3:
        return _buildVouchersTab();
      default:
        return _buildPlatformOverviewTab();
    }
  }

  // --------------------------------------------------------------------------
  // Tab 0: Platform Overview
  // --------------------------------------------------------------------------
  Widget _buildPlatformOverviewTab() {
    final gmv = state.totalPlatformGMV;
    final commission = state.platformCommissionEarnings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Executive Food Delivery Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
          const Text('Real-time gross merchandise volume, platform commission, and merchant growth.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 20),

          // 4 Metric KPI Cards (Responsive Grid/Wrap)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 750) {
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildKpiCard('Gross Platform GMV', '\$${gmv.toStringAsFixed(2)}', '+22.4%', Icons.account_balance_wallet, isExpanded: true),
                        const SizedBox(width: 12),
                        _buildKpiCard('Platform Revenue', '\$${commission.toStringAsFixed(2)}', '+18.0%', Icons.monetization_on, isExpanded: true),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildKpiCard('Active Restaurants', '${state.merchants.length}', '4 Open', Icons.storefront, isExpanded: true),
                        const SizedBox(width: 12),
                        _buildKpiCard('Delivery Drivers', '${state.drivers.length}', '2 Online', Icons.two_wheeler, isExpanded: true),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  _buildKpiCard('Gross Platform GMV', '\$${gmv.toStringAsFixed(2)}', '+22.4%', Icons.account_balance_wallet, isExpanded: true),
                  const SizedBox(width: 14),
                  _buildKpiCard('Platform Revenue (15% Cut)', '\$${commission.toStringAsFixed(2)}', '+18.0%', Icons.monetization_on, isExpanded: true),
                  const SizedBox(width: 14),
                  _buildKpiCard('Active Restaurants', '${state.merchants.length}', '4 Open', Icons.storefront, isExpanded: true),
                  const SizedBox(width: 14),
                  _buildKpiCard('Delivery Drivers', '${state.drivers.length}', '2 Online', Icons.two_wheeler, isExpanded: true),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Platform All Orders Stream
          const Text('Live Platform Food Orders Feed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
          const SizedBox(height: 12),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.orders.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final order = state.orders[idx];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.blushTint,
                    child: const Icon(Icons.fastfood, color: AppColors.richMagenta, size: 20),
                  ),
                  title: Text('${order.orderNumber} • ${order.merchantName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepBerry)),
                  subtitle: Text('${order.customerName} • ${order.items.length} items • ${order.paymentDisplay}', style: const TextStyle(fontSize: 11)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${order.totalUSD.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.richMagenta)),
                      Text(order.statusDisplay, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String val, String subtitle, IconData icon, {bool isExpanded = true}) {
    final card = Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, color: AppColors.richMagenta, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
    if (isExpanded) {
      return Expanded(child: card);
    }
    return card;
  }

  // --------------------------------------------------------------------------
  // Tab 1: Merchants Management
  // --------------------------------------------------------------------------
  Widget _buildMerchantsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Registered Merchants & Restaurants', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
          const Text('Approve, view sales metrics, and toggle restaurant store availability.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.merchants.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final m = state.merchants[idx];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(m.logoUrl)),
                  title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepBerry)),
                  subtitle: Text('${m.cuisine} • Phone: ${m.phone} • Rating: ${m.rating} ★', style: const TextStyle(fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Sales: \$${m.totalSalesUSD.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.richMagenta)),
                      const SizedBox(width: 14),
                      Switch(
                        value: m.isOpen,
                        activeThumbColor: AppColors.richMagenta,
                        onChanged: (_) => state.toggleMerchantOpen(m.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Tab 2: Drivers (Static Delivery Part)
  // --------------------------------------------------------------------------
  Widget _buildDriversTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Driver Fleet (Static Delivery Part)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
          const Text('Fleet overview for on-demand motorcycle delivery in Phnom Penh.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),

          ...state.drivers.map((d) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(d.photoUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.deepBerry)),
                              const SizedBox(width: 8),
                              Text('(${d.khmerName})', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                child: const Text('Online • Active', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Vehicle: ${d.vehiclePlate} • Phone: ${d.phone} • Rating: ${d.rating} ★', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${d.totalDeliveriesToday} Trips Today', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry)),
                        Text('Earned: \$${d.earningsUSD.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.richMagenta)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Tab 3: Vouchers
  // --------------------------------------------------------------------------
  Widget _buildVouchersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Platform Promo Vouchers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.deepBerry)),
                  Text('Discounts applied during customer food checkout.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.richMagenta, foregroundColor: Colors.white),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Voucher'),
                onPressed: _openAddVoucherDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...state.vouchers.map((v) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.blushTint, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.local_offer, color: AppColors.richMagenta),
                ),
                title: Text(v.code, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.2, color: AppColors.deepBerry)),
                subtitle: Text(v.description, style: const TextStyle(fontSize: 11)),
                trailing: Text('${v.discountPercent.toStringAsFixed(0)}% OFF', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.richMagenta)),
              ),
            );
          }),
        ],
      ),
    );
  }
}
