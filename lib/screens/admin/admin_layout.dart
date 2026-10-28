import 'package:flutter/material.dart';
import '../../state/pos_state.dart';
import '../../theme/app_colors.dart';
import 'dashboard_view.dart';
import 'products_view.dart';
import 'inventory_view.dart';
import 'suppliers_view.dart';
import 'transactions_view.dart';
import 'customers_view.dart';
import 'employees_view.dart';
import 'reports_view.dart';
import 'settings_view.dart';
import '../auth/change_password_dialog.dart';

class AdminLayout extends StatefulWidget {
  final VoidCallback onNavigateToPos;
  final VoidCallback onLogout;
  final VoidCallback? onNavigateToMerchant;
  final VoidCallback? onNavigateToCustomer;

  const AdminLayout({
    super.key,
    required this.onNavigateToPos,
    required this.onLogout,
    this.onNavigateToMerchant,
    this.onNavigateToCustomer,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedTabIndex = 0;
  final PosState posState = PosState();
  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    posState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    posState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Widget _buildCurrentView() {
    switch (_selectedTabIndex) {
      case 0:
        return DashboardView(
          onNavigateTab: (index) {
            if (index == -1) {
              widget.onNavigateToPos();
            } else {
              setState(() => _selectedTabIndex = index);
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
        return const CustomersView();
      case 6:
        return const EmployeesView();
      case 7:
        return const ReportsView();
      case 8:
        return const SettingsView();
      default:
        return DashboardView(onNavigateTab: (i) => setState(() => _selectedTabIndex = i));
    }
  }

  void _openNotificationsDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final notifications = posState.notifications;

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('System Notifications (US-054)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepBerry)),
                  TextButton(
                    onPressed: () {
                      posState.markNotificationsRead();
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Mark all as read', style: TextStyle(color: AppColors.richMagenta)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...notifications.map((n) {
                return ListTile(
                  leading: Icon(n.isWarning ? Icons.warning_amber_rounded : Icons.info_outline, color: n.isWarning ? Colors.orange : AppColors.richMagenta),
                  title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(n.message, style: const TextStyle(fontSize: 12)),
                  trailing: Text('${n.timestamp.toLocal()}'.substring(11, 16), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final unreadCount = posState.notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      body: Row(
        children: [
          // Collapsible Left Navigation Sidebar (Desktop)
          if (isDesktop) _buildSidebar(),

          // Main View Section
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                _buildHeaderBar(isDesktop, unreadCount),

                // Active View Body
                Expanded(child: _buildCurrentView()),
              ],
            ),
          ),
        ],
      ),
      // Drawer for mobile / tablet view
      drawer: isDesktop ? null : Drawer(child: _buildSidebarContent(isDrawer: true)),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isSidebarCollapsed ? 76 : 260,
      decoration: const BoxDecoration(
        color: AppColors.deepBerry, // Adobe Palette: 59123E
      ),
      child: _buildSidebarContent(isDrawer: false),
    );
  }

  Widget _buildSidebarContent({required bool isDrawer}) {
    final collapsed = !isDrawer && _isSidebarCollapsed;

    return Column(
      children: [
        // Sidebar Brand Logo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.richMagenta, // Adobe Palette: 8C0057
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.vibrantPink.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 22),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUPER ADMIN',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0),
                    ),
                    Text(
                      'Corporate Master Portal',
                      style: TextStyle(color: AppColors.softPink, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const Divider(color: Colors.white12, height: 1),

        // Navigation Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            children: [
              _buildNavItem(0, Icons.dashboard_outlined, 'Dashboard (US-007)', collapsed),
              _buildNavItem(1, Icons.inventory_2_outlined, 'Products & Menu (US-009)', collapsed),
              _buildNavItem(2, Icons.warehouse_outlined, 'Stock & Inventory (US-014)', collapsed),
              _buildNavItem(3, Icons.local_shipping_outlined, 'Suppliers & PO (US-025)', collapsed),
              _buildNavItem(4, Icons.receipt_long_outlined, 'Sales & Digital Pay (US-041)', collapsed),
              _buildNavItem(5, Icons.people_outline, 'Customers & VIP (US-044)', collapsed),
              _buildNavItem(6, Icons.badge_outlined, 'Staff & Shifts (US-008)', collapsed),
              _buildNavItem(7, Icons.analytics_outlined, 'Reports & Analytics (US-052)', collapsed),
              _buildNavItem(8, Icons.settings_outlined, 'Store Settings (US-059)', collapsed),
            ],
          ),
        ),

        const Divider(color: Colors.white12, height: 1),

        // Bottom Fast Actions: POS, Merchant, Customer
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
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
              if (widget.onNavigateToMerchant != null) ...[
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.softPink,
                      side: const BorderSide(color: AppColors.softPink),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.storefront, size: 15),
                    label: collapsed
                        ? const SizedBox.shrink()
                        : const Text('Merchant Portal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: widget.onNavigateToMerchant,
                  ),
                ),
              ],
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

  Widget _buildHeaderBar(bool isDesktop, int unreadNotifications) {
    final user = posState.currentUser;
    final rate = posState.storeInfo.usdToKhrRate;

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
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
                const SizedBox(width: 8),
                // Store branch title
                Expanded(
                  child: Text(
                    '${posState.storeInfo.storeName} • Corporate Headquarters',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepBerry),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Portal quick switchers for Admin
              if (widget.onNavigateToMerchant != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.richMagenta,
                      side: const BorderSide(color: AppColors.richMagenta),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.storefront, size: 16),
                    label: const Text('Merchant Portal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: widget.onNavigateToMerchant,
                  ),
                ),

              if (widget.onNavigateToCustomer != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.vibrantPink,
                      side: const BorderSide(color: AppColors.vibrantPink),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.phone_android, size: 16),
                    label: const Text('Customer App', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: widget.onNavigateToCustomer,
                  ),
                ),

              if (isDesktop) ...[
                // Exchange Rate Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.blushTint.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.softPink),
                  ),
                  child: Text(
                    'Rate: \$1 = ${rate.toStringAsFixed(0)} ៛',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.deepBerry),
                  ),
                ),
                const SizedBox(width: 10),

                // Active Shift indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: posState.activeShift != null ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: posState.activeShift != null ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        posState.activeShift != null ? 'Shift Open' : 'Shift Closed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: posState.activeShift != null ? Colors.green.shade900 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // Notifications
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.deepBerry),
                    tooltip: 'Notifications',
                    onPressed: _openNotificationsDrawer,
                  ),
                  if (unreadNotifications > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.richMagenta, shape: BoxShape.circle),
                        child: Text(
                          '$unreadNotifications',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),

              // User Profile Dropdown Menu
              PopupMenuButton<String>(
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.deepBerry,
                      child: Text(
                        (user?.name.isNotEmpty ?? false) ? user!.name[0] : 'A',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(user?.name ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textMain)),
                        Text(user?.roleDisplay ?? 'Super Admin', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.textMuted),
                  ],
                ),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'pos',
                    child: Row(
                      children: [
                        Icon(Icons.point_of_sale, size: 18, color: AppColors.richMagenta),
                        SizedBox(width: 10),
                        Text('Launch POS Terminal'),
                      ],
                    ),
                  ),
                  if (widget.onNavigateToMerchant != null)
                    const PopupMenuItem(
                      value: 'merchant',
                      child: Row(
                        children: [
                          Icon(Icons.storefront, size: 18, color: AppColors.richMagenta),
                          SizedBox(width: 10),
                          Text('Switch to Merchant Portal'),
                        ],
                      ),
                    ),
                  if (widget.onNavigateToCustomer != null)
                    const PopupMenuItem(
                      value: 'customer',
                      child: Row(
                        children: [
                          Icon(Icons.phone_android, size: 18, color: AppColors.vibrantPink),
                          SizedBox(width: 10),
                          Text('Customer Mobile App View'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'password',
                    child: Row(
                      children: [
                        Icon(Icons.lock_reset, size: 18),
                        SizedBox(width: 10),
                        Text('Change Password (US-003)'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18, color: AppColors.danger),
                        SizedBox(width: 10),
                        Text('Logout (US-002)', style: TextStyle(color: AppColors.danger)),
                      ],
                    ),
                  ),
                ],
                onSelected: (val) {
                  if (val == 'pos') {
                    widget.onNavigateToPos();
                  } else if (val == 'merchant') {
                    widget.onNavigateToMerchant?.call();
                  } else if (val == 'customer') {
                    widget.onNavigateToCustomer?.call();
                  } else if (val == 'password') {
                    showDialog(context: context, builder: (_) => const ChangePasswordDialog());
                  } else if (val == 'logout') {
                    widget.onLogout();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
