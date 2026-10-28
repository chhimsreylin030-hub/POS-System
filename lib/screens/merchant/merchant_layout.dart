import 'package:flutter/material.dart';
import '../../state/pos_state.dart';
import '../../theme/app_colors.dart';
import '../admin/dashboard_view.dart';
import '../admin/products_view.dart';
import '../admin/inventory_view.dart';
import '../admin/suppliers_view.dart';
import '../admin/transactions_view.dart';
import '../admin/employees_view.dart';

class MerchantLayout extends StatefulWidget {
  final VoidCallback onNavigateToPos;
  final VoidCallback onNavigateToAdmin;
  final VoidCallback onNavigateToCustomer;
  final VoidCallback onLogout;

  const MerchantLayout({
    super.key,
    required this.onNavigateToPos,
    required this.onNavigateToAdmin,
    required this.onNavigateToCustomer,
    required this.onLogout,
  });

  @override
  State<MerchantLayout> createState() => _MerchantLayoutState();
}

class _MerchantLayoutState extends State<MerchantLayout> {
  int _selectedTabIndex = 0;
  final PosState posState = PosState();
  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    posState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    posState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Widget _buildCurrentView() {
    switch (_selectedTabIndex) {
      case 0:
        return DashboardView(
          onNavigateTab: (idx) {
            if (idx == -1) {
              widget.onNavigateToPos();
            } else {
              setState(() => _selectedTabIndex = idx);
            }
          },
        );
      case 1:
        return const ProductsView();
      case 2:
        return const InventoryView();
      case 3:
        return const SuppliersView();
      case 4:
        return const TransactionsView();
      case 5:
        return const EmployeesView();
      default:
        return DashboardView(onNavigateTab: (i) => setState(() => _selectedTabIndex = i));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isDesktop),
                Expanded(child: _buildCurrentView()),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: _buildSidebarContent(isDrawer: true)),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isSidebarCollapsed ? 76 : 260,
      decoration: const BoxDecoration(
        color: AppColors.deepBerry, // Palette: 59123E
      ),
      child: _buildSidebarContent(isDrawer: false),
    );
  }

  Widget _buildSidebarContent({required bool isDrawer}) {
    final collapsed = !isDrawer && _isSidebarCollapsed;

    return Column(
      children: [
        // Brand Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.richMagenta, // Palette: 8C0057
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.vibrantPink.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.storefront, color: Colors.white, size: 22),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MERCHANT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Store Management Portal',
                      style: TextStyle(color: AppColors.softPink, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const Divider(color: Colors.white12, height: 1),

        // Navigation Menu
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            children: [
              _buildNavItem(0, Icons.dashboard_outlined, 'Store Overview', collapsed),
              _buildNavItem(1, Icons.inventory_2_outlined, 'Products & Menu CRUD', collapsed),
              _buildNavItem(2, Icons.warehouse_outlined, 'Stock & Movements', collapsed),
              _buildNavItem(3, Icons.local_shipping_outlined, 'Suppliers & Orders', collapsed),
              _buildNavItem(4, Icons.receipt_long_outlined, 'Sales & Refunds', collapsed),
              _buildNavItem(5, Icons.badge_outlined, 'Cashier Shifts', collapsed),
            ],
          ),
        ),

        const Divider(color: Colors.white12, height: 1),

        // Action Buttons at Bottom
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Launch POS
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.richMagenta,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.point_of_sale, size: 16),
                  label: collapsed
                      ? const SizedBox.shrink()
                      : const Text('Open POS Terminal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: widget.onNavigateToPos,
                ),
              ),
              const SizedBox(height: 8),
              // Open Customer View
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.softPink,
                    side: const BorderSide(color: AppColors.softPink),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.phone_android, size: 16),
                  label: collapsed
                      ? const SizedBox.shrink()
                      : const Text('Customer Mobile App', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: widget.onNavigateToCustomer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title, bool collapsed) {
    final isSelected = _selectedTabIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: collapsed ? title : '',
        child: InkWell(
          onTap: () {
            setState(() => _selectedTabIndex = index);
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.richMagenta.withValues(alpha: 0.6) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: AppColors.vibrantPink.withValues(alpha: 0.5)) : null,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: isSelected ? Colors.white : AppColors.softPink),
                if (!collapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final rate = posState.storeInfo.usdToKhrRate;

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isDesktop)
                IconButton(
                  icon: Icon(_isSidebarCollapsed ? Icons.menu_open : Icons.menu, color: AppColors.deepBerry),
                  onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                )
              else
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.deepBerry),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blushTint.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Merchant Branch View',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.deepBerry),
                ),
              ),
            ],
          ),

          Row(
            children: [
              // Portal Switcher to Admin
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.richMagenta,
                  side: const BorderSide(color: AppColors.richMagenta),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                label: const Text('Switch to Corporate Admin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: widget.onNavigateToAdmin,
              ),
              const SizedBox(width: 12),

              // Exchange Rate Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.blushTint.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.softPink),
                ),
                child: Text(
                  '\$1 = ${rate.toStringAsFixed(0)} ៛',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.deepBerry),
                ),
              ),
              const SizedBox(width: 12),

              // Logout
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.richMagenta),
                tooltip: 'Logout',
                onPressed: widget.onLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
